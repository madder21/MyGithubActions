/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP_002_ServiceClass  
-- - Author             : Ilhem Zraiga
-- - Description        : This Class contain the service Method 
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 23/03/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
public class TNP_002_ServiceClass {
    
    Public Static String CLASS_NAME = 'TNP_002_ServiceClass';
    
    public static Map<String, string> resolveFieldsAPINames(Map<String, Schema.SObjectField> fieldMap) {
        Map<String, string> resolveAPINameLabelMap = new Map<String, String>();
        Map<String, String> fieldMapTemp = new Map<String, String>();
        for(String fieldName : fieldMap.keyset()) {
            if(fieldName.contains('__c') ) {
                //fieldName.replace('_pc', '__pc');
                if(fieldName.contains('_pc')) {
                	resolveAPINameLabelMap.put(fieldName.replace('_pc', '__pc').split('__c')[0], fieldMap.get(fieldName).getDescribe().getLabel());
                }
                if(fieldName.contains('_c') && !fieldName.contains('_pc')) {
                    resolveAPINameLabelMap.put(fieldName.split('__c')[0].replace('_c', '__c'), fieldMap.get(fieldName).getDescribe().getLabel());
                }
            	
            }
        }
        return resolveAPINameLabelMap;
    }
    
    public static Map<String, Object> buildObjectMap(Account accountInput, String settingName) {
        //retrieve all TNP_ClientMap__c fields using schema
        Map<String, Object> settingObjectMap = new Map<String, Object>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(settingName).getDescribe().fields.getMap();
        Map<String, string> fieldNameLabelMap = TNP_002_ServiceClass.resolveFieldsAPINames(fieldMap);
        for(String field : fieldNameLabelMap.keySet()) {
            settingObjectMap.put(fieldNameLabelMap.get(field), accountInput.get(field));// sur Account récupère la valeur du champ B2C_Customer_ID__pc
        }
        return settingObjectMap;
    }    

    public static String GenerateJSON (account accountInput,string Source){
        String METHOD_NAME = 'GenerateJSON';
        String jsonstring = '';
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput'+accountInput);
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Source'+Source);
        map<string,map<string,object>> JsonMap = new map<string,map<string,object>>();
        if (accountInput != null ){
            
            String CountryIso3Code ;
            String personMaillingCountryIso3Code ;
            String personOtherCountryIso3Code ;
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput.Country__pc'+accountInput.Country__pc);
            //Country Code maping
            if ( accountInput.Country__pc != null && accountInput.Country__pc != ''  ){
                CountryIso3Code = [Select Alpha_3_code__c,Alpha_2_code__c from  CountryCode__c where Alpha_2_code__c =: accountInput.Country__pc].Alpha_3_code__c;
              System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput.Country__pc'+accountInput.Country__pc);
                
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput.SFSC id'+accountInput.SFSC_Contact_Key__pc);
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput.SFSC id'+accountInput.Id);
            }
            //Mailling Country Code Mapping
            if (accountInput.PersonMailingCountry != null && accountInput.PersonMailingCountry != ''  ){
                personMaillingCountryIso3Code = CountryCode__c.getInstance(accountInput.PersonMailingCountry)!=null?CountryCode__c.getInstance(accountInput.PersonMailingCountry).Alpha_3_code__c:null; 
            }
            //Other Mailling Country 
            if (accountInput.PersonOtherCountry != null && accountInput.PersonOtherCountry != ''  ){ 
                personOtherCountryIso3Code = CountryCode__c.getInstance(accountInput.PersonOtherCountry)!=null?CountryCode__c.getInstance(accountInput.PersonOtherCountry).Alpha_3_code__c:null;
            }
    
            //Client Data
            Map<string,object> clientMap = buildObjectMap(accountInput, 'TNP_ClientMap__c');
            clientMap.put ('Source',source);
            clientMap.put ('Country',CountryIso3Code);
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'clientMap'+clientMap);
            JsonMap.put('Client',clientMap);         
            //Adresses Data 
            Map<string,object> addressMap = buildObjectMap(accountInput, 'TNP_AddressMap__c');
            addressMap.put ('Address1_Country',personMaillingCountryIso3Code);   
            addressMap.put ('Address1_DQCheck',false);
            addressMap.put ('Address1_DQValidity',false);     
            addressMap.put ('Address2_Country',personOtherCountryIso3Code);
            addressMap.put ('Address2_DQCheck',false);
            addressMap.put ('Address2_DQValidity',false);
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'addressMap'+addressMap);
            JsonMap.put('Addresses',addressMap);
            //Email Data
            Map<string,object> emailMap = buildObjectMap(accountInput, 'TNP_EmailMap__c');
            emailMap.put ('personEmail_DQCheck',false);
            emailMap.put ('personEmail_DQValidity',false);         
            emailMap.put ('otherEmail_DQCheck',false);
            emailMap.put ('otherEmail_DQValidity',false);
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'emailMap'+emailMap);
            JsonMap.put('Email',emailMap);
            //Phone Data
            
            
            Map<string,object> phoneMap = buildObjectMap(accountInput, 'TNP_PhoneMap__c');
            phoneMap.put ('Phone1_DQCheck',false);
            phoneMap.put ('Phone1_DQValidity',false);          
            phoneMap.put ('Phone2_DQCheck',false);
            phoneMap.put ('Phone2_DQValidity',false);         
            phoneMap.put ('Phone3_DQCheck',false);
            phoneMap.put ('Phone3_DQValidity',false);
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'phoneMap'+phoneMap);
            JsonMap.put('Phone',phoneMap);
            Map<string,object> consentMap = buildObjectMap(accountInput, 'TNP_ConsentMap__c');
            
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Consent'+consentMap);
            JsonMap.put('Consent',consentMap);
            
            //To Check With MAlek 
            // Consent.put ('LastUpdateOptinMailing',accountInput.OptinMailing__pc);
            
                 
        }
        if (JsonMap != null && JsonMap.size()>0 )
        {
            jsonstring = JSON.serialize(JsonMap); 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'jsonstring'+jsonstring);  
        }   
        
        return jsonstring;
    }

}