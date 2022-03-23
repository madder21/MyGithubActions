public with sharing class BL_WECHAT_Utils {
    
    public static String BASIC_NAME                      = 'NEW WECHAT CLIENT';
    
    public static SObject convertToAccount(Map<String,Object> data){
        System.debug('data convert--> '+data);
        List<SObject> sobjs = new BL_EasyQuery()
        .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT)
        .convertWrapperToSObject(new List<Object>{data});
        
        if(!sobjs.isEmpty()){
            System.debug('data convert--> '+sobjs);
            System.debug('data convert--> '+sobjs[0]);
            return sobjs[0];
        }
        return null;
    }
    
    public static SObject convertToClientAddress(Map<String,Object> data){
        List<SObject> sobjs = new BL_EasyQuery()
            .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT_ADDRESS)
            .convertWrapperToSObject(new List<Object>{data});

        if(!sobjs.isEmpty()){
            return sobjs[0];
        }
        return null;
    }
    public static SObject mergeTwoAccounts(SObject master, SObject slave){
        for(String field : Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet()){
            if (slave.get(field) != null){
                master.put(field, slave.get(field));    
            }
        }
        return master;
    }

    public static Account createWeChatAccount(Map<String,Object> data) {
        System.debug('data -- >> '+data);
        Account client = (Account)convertToAccount(data);
        System.debug('client after convert -- >> '+client);
        
        // Default lastname
        if(String.isEmpty(client.Lastname)){
            client.LastName = BL_WECHAT_Constants.defaultLastname;
        }
        //Set the store according to store code
        List<Store__c> stores = new List<Store__c>();
        if(data.get('storeCode') != null) {
            String storeCode = (String) data.get('storeCode');
            System.debug('--->>>+++'+storeCode);
            stores = [SELECT Id FROM Store__c WHERE SourceStoreId__c = :storeCode];
        }
        if(!stores.isEmpty()) {
            client.OriginStore__pc = stores[0].Id;
        }
        
        //Set the phone number according to mobile and countryCode
        String clientPhone = '';
        if(data.get('country_code') != null) {
            clientPhone += data.get('country_code');
        }
        if(data.get('mobile') != null) {
            clientPhone += (String)data.get('mobile');
        }
        client.Phone = clientPhone;

        String unionId = '';
        if(data.get('union_id') != null){
            unionId +=data.get('union_id');
        }
        client.wechat_union_id__c = unionId;
        
        // if(client.ACC_DateCreation__c == null){
            //     client.ACC_DateCreation__c = System.today();
            // }
            // if(client.ACC_DateOfUpdate__c == null){
                //     client.ACC_DateOfUpdate__c = System.today();
                // }
                // if(client.ACC_CustomerID__c == null){
                    //     client.ACC_CustomerID__c = getCustomerId();
                    // }
                    
        System.debug('client craeted -- >> '+client);
        return client;
    }

    public static void createWeChatClientAddress(Map<String,Object> data, String clientId) {
        ClientAddress__c clientAddress = (ClientAddress__c)convertToClientAddress(data);
        clientAddress.Client__c = clientId;
        upsert clientAddress;
    }

    // private static Long getCustomerId() {
    //     String randSixDigits = String.valueOf(Datetime.now().getTime()).right(6);
    //     return Long.valueOf('9999' + randSixDigits);
    // }

    
        //eli amzllag 
        //I commented out this func becouse it is not use in the app so we don't need to test it
    // public static SObject mergeWeChatAccountAndClient(Account masterClient, Account slaveClient){

    //     Database.merge(new Account(Id = masterClient.Id), slaveClient.Id);
    //     masterClient = (Account) new BL_EasyQuery()
    //         .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT)
    //         .condition('Id = \'' + masterClient.Id + '\'')
    //         .executeQuery()
    //         .getSObject();

    //     // Remove duplicate bind
    //     WeChat_SA_Client__c[] binds = [
    //         SELECT Id, sa__c
    //         FROM WeChat_SA_Client__c
    //         WHERE Client__c = :masterClient.Id
    //         ORDER BY CreatedDate ASC
    //     ];
    //     Map<String,WeChat_SA_Client__c> bindMap = new Map<String,WeChat_SA_Client__c>();
    //     List<WeChat_SA_Client__c> toDelete = new List<WeChat_SA_Client__c>();
    //     for(WeChat_SA_Client__c bind : binds){
    //         if(bindMap.get(bind.SA__c) == null){
    //             bindMap.put(bind.SA__c, bind);
    //         }
    //         else {
    //             toDelete.add(bind);
    //         }
    //     }

    //     delete toDelete;

    //     return masterClient;
    // }

    public static SObject mergeWeChatAccountAndData(SObject masterClient, Map<String,Object> data){
        Account client = (Account)BL_WECHAT_Utils.convertToAccount(data);
        client = (Account)BL_WECHAT_Utils.mergeTwoAccounts(masterClient, client);
        return client;
    }

    public static void upsertClient(Account client){
        System.debug('client to upsert -->> '+client);
        if(String.isNotEmpty(client.id)){
            Database.upsert(client);
            System.debug('client id to upsert -->> '+client);
        }
        else if(String.isNotEmpty(client.wechat_union_id__c)){
            Database.upsert(client, Account.Fields.wechat_union_id__c, true);
        }
        else if(String.isNotEmpty(client.wechat_open_id__c)){
            Database.upsert(client, Account.Fields.wechat_open_id__c, true);
        }
        else if(String.isNotEmpty(client.wechat_oa_open_id__c)){
            Database.upsert(client, Account.Fields.wechat_oa_open_id__c, true);
        }
        else if(String.isNotEmpty(client.wechat_external_id__c)){
            Database.upsert(client, Account.Fields.wechat_external_id__c, true);
        }
        else {
             System.debug('client to upsert else-->> '+client);
            Database.upsert(client);
        }
    }
    public static Object getClient(string id){
        Map<String,Object> response = new Map<String,Object>(getClientInfo(id));
        //response.put(JSONRoot_sales_associates, getClientSalesAssociates(id));
        return response;
    }
    public static Map<String,Object> getClientInfo(string id){
        Map<String,Object> clientInfo = new BL_EasyQuery()
                                    .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT)
                                    .condition('id = \'' + id + '\'')
                                    .executeQuery()
                                    .getMappedObject();
        
        Map<String,Object> clientAddressInfo = getClientAddressInfo(id);
        System.debug('adress info2 --> '+clientAddressInfo);
        
        for(String adressKey : clientAddressInfo.keySet()) {
            clientInfo.put(adressKey, clientAddressInfo.get(adressKey));
        }
        
        System.debug('client info2 --> '+clientInfo);
        return clientInfo;
    }

    public static Map<String,Object> getClientAddressInfo(string id){
        System.debug('adress info --> '+id);
        
        return new BL_EasyQuery()
            .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT_ADDRESS)
            .condition('Client__c = \'' + id + '\' LIMIT 1')
            .executeQuery()
            .getMappedObject();
    }

    // public static Object getClientSalesAssociates(string id){
    //     return new BL_EasyQuery()
    //         .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_SA_CLIENT)
    //         .condition('Client__c = \'' + id + '\'')
    //         .executeQuery()
    //         .getMappedObjects();
    // }

    public static SObject convertToBind(Map<String,Object> data){
        System.debug('data to bind -->>'+data);
        List<SObject> sobjs = new BL_EasyQuery()
        .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_SA_CLIENT)
        .convertWrapperToSObject(new List<Object>{data});
        
        if(!sobjs.isEmpty()){
            System.debug('sobj bind -->>'+sobjs[0]);
            return sobjs[0];
        }

        return null;
    }
}