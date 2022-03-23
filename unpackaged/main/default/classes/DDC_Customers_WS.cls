// /services/apexrest/ddc/v0/customer
public with sharing class DDC_Customers_WS implements BL_Rest_Router_Factory.DispatchablePOST {
    
    private class DDCException extends Exception {}
    private static final String PERSON_ACCOUNT_RT_DEV_NAME = 'PersonAccount';

    public Object executePOST(Map<String, String> pathParameters, Map<String, String> queryParams, Map<String, Object> bodyMap) {
        System.debug('bodyMap: ' + bodyMap);

        // check permissions
        if (!Schema.sObjectType.Account.isCreateable()) {
            throw new DDCException('User does not have permission to create Account');
        }

        List<Object> items = new List<Object> { bodyMap };
        List<Account> accounts = upsertCustomers(items);

        Map<String, String> ret = new Map<String,String> {
            'id' => accounts[0].Id
        };
        return ret;
    }


    @testVisible
    private List<Account> upsertCustomers(List<Object> items) {

        BL_EasyQuery query = new BL_EasyQuery().useCase('DDC Client');

        // convert wrapper items to accounts sobjects
        List<Account> accounts = (List<Account>) query.convertWrapperToSObject(items);

        // replace user and store codes with SF ids
        replaceIds(accounts);

        // set record type for person account
        Id personAccountRtId = getPersonAccountRecordTypeId();
        for (Account acc : accounts) {
            acc.RecordTypeId = personAccountRtId;
        }
        
        insert accounts;

        // create address records
        createAddressRecords(items, accounts);

        // create signature
        createSignatures(items, accounts);

        return accounts;
    }
    

    private void replaceIds(List<SObject> accs) {
        // collect codes for stores and sales men
        Set<String> storeCodes = new Set<String>();
        Set<String> userCodes = new Set<String>();
        for (SObject accountObj : accs) {
            String storeCode = (String) accountObj.get('OriginStore__pc');
            if (String.isNotEmpty(storeCode) && !isValidId(storeCode)) {
                storeCodes.add(storeCode);
            }
            String userCode = (String) accountObj.get('ClientAdvisor__pc');
            if (String.isNotEmpty(userCode) && !isValidId(userCode)) {
                userCodes.add(userCode);
            }
        }

        // load stores and users
        List<Store__c> stores = [SELECT Id, SourceStoreId__c FROM Store__c
                WHERE SourceStoreId__c in :storeCodes];
        Map<String,Object> storesIdsMap = createMap(stores, 'SourceStoreId__c', 'Id');

        List<User> users = [SELECT Id, StaffCode__c FROM User
                WHERE StaffCode__c in :userCodes];
        Map<String,Object> usersIdsMap = createMap(users, 'StaffCode__c', 'Id');

        // replace ids
        for (SObject accountObj : accs) {
            String storeCode = (String) accountObj.get('OriginStore__pc');
            if (!isValidId(storeCode)) {
                accountObj.put('OriginStore__pc', storesIdsMap.get(storeCode));
                System.debug('replacing store Id: ' + storeCode + ' => ' + storesIdsMap.get(storeCode));
            }

            String userCode = (String) accountObj.get('ClientAdvisor__pc');
            if (!isValidId(userCode)) {
                accountObj.put('ClientAdvisor__pc', usersIdsMap.get(userCode));
            }
        }

    }

    /*
     * Creates ClientAddress records for items
     * Using field mapping of separate use case (DDC ClientAddress)
     * ClientAddress has lookup to Account
     * items and accounts contains wrapper objects and Sobjects respectively.
     * accounts should already have SF Id.
     */
    private void createAddressRecords(List<Object> items, List<Account> accounts) {
        BL_EasyQuery addressQuery = new BL_EasyQuery().useCase('DDC ClientAddress');

        List<ClientAddress__c> addresses = new List<ClientAddress__c>();
        for (Integer i=0; i<items.size(); i++) {
            Map<String,Object> itemMap = (Map<String,Object>) items[i];
            Object addressObj = itemMap.get('address');
            if (addressObj != null) {
                ClientAddress__c address = (ClientAddress__c) convertWrapperToSObject(addressQuery, addressObj);
                address.Client__c = accounts[i].Id;
                addresses.add(address);
            }
        }
        insert addresses;
    }

    private static SObject convertWrapperToSObject(BL_EasyQuery easyQuery, Object wrapperObj) {
        List<Object> objList = new List<Object> { wrapperObj };
        List<SObject> sobjList = easyQuery.convertWrapperToSObject(objList);
        return sobjList[0];
    }

    private void createSignatures(List<Object> items, List<Account> accounts) {
        List<Attachment> attachments = new List<Attachment>();
        Map<Id,String> signaturesMap = new Map<Id,String>();
        for (Integer i=0; i<items.size(); i++) {
            Map<String,Object> itemMap = (Map<String,Object>) items[i];
            String signatureSvgStr = (String) itemMap.get('signatureData');
            if (signatureSvgStr != null) {
                signaturesMap.put(accounts[i].Id, signatureSvgStr);
            }
        }

        list<ContentVersion> contentVersions = new list<ContentVersion>();
        
        for (Id parentId : signaturesMap.keySet()) {
            String signatureSvgStr = signaturesMap.get(parentId); 
            
            if (String.isNotEmpty(signatureSvgStr)) {
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                conVer.PathOnClient = 'signature.svg'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = 'Signature '; // Display name of the files
                conVer.VersionData = Blob.valueOf(signatureSvgStr); // converting your binary string to Blob

                contentVersions.add(conVer);
            }
        }

        insert contentVersions;

        contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersions];
        list<ContentDocumentLink> contentDocumentLinks = new list<ContentDocumentLink>();
        for(Integer index = 0; index < contentVersions.size(); index++){
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = contentVersions[index].ContentDocumentId;
            cDe.LinkedEntityId = accounts[0].Id;
            cDe.ShareType = 'I'; 

            contentDocumentLinks.add(cDe);
        }

        insert contentDocumentLinks;
    }

    private static Id getPersonAccountRecordTypeId() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = :PERSON_ACCOUNT_RT_DEV_NAME];
        if (recordTypes.isEmpty()) {
            return null;
        }
        return recordTypes[0].Id;
    }

    private static Boolean isValidId(String id) {
        try {
            Id testId = id;
            return true;
        } catch(Exception ex) {
            return false;
        }
    }

    public static Map<String,Object> createMap(List<SObject> sobjs, String keyField, String valueField) {
        Map<String,Object> valuesMap = new Map<String,Object>();
        for (SObject sobj : sobjs) {
            String key = (String) sobj.get(keyField);
            valuesMap.put(key, sobj.get(valueField));
        }
        return valuesMap;
    }

}