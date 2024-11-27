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
public with sharing class TNP_002_ServiceClass {
    
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
        String METHOD_NAME ='buildObjectMap';
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Start');
        
        //retrieve all TNP_ClientMap__c fields using schema
        Map<String, Object> settingObjectMap = new Map<String, Object>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(settingName).getDescribe().fields.getMap();
        Map<String, string> fieldNameLabelMap = TNP_002_ServiceClass.resolveFieldsAPINames(fieldMap);
        
        /* for(String field : fieldNameLabelMap.keySet()) {
        	settingObjectMap.put(fieldNameLabelMap.get(field), accountInput.get(field));// sur Account récupère la valeur du champ B2C_Customer_ID__pc
        }*/
        for(String field : fieldNameLabelMap.keySet()) {
            if(field.toLowercase().contains('optin') && !field.toLowercase().contains('lastupdate')){
                
                String lastUpdateName = 'LastUpdate'+field; //ex: field = OptinCalling_pc__c, LastUpdateOptinCalling_pc__c
                //si OptinCalling_pc__c = false et LastUpdateOptinCalling_pc__c = null
                if(accountInput.get(field) == false && accountInput.get(lastUpdateName) == null){                   
                    settingObjectMap.put(fieldNameLabelMap.get(field), null);
                }else {
                    settingObjectMap.put(fieldNameLabelMap.get(field), accountInput.get(field));
                }   
            }else {
                settingObjectMap.put(fieldNameLabelMap.get(field), accountInput.get(field));
            }
        }
         System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END');
        return settingObjectMap;
    }    
    
    public static String GenerateJSON (account accountInput,string Source, list <CountryCode__c> listCountryCode){
        String METHOD_NAME = 'GenerateJSON';
        String jsonstring = '';
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput'+accountInput);
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Source'+Source);
        map<string,map<string,object>> JsonMap = new map<string,map<string,object>>();
        if (accountInput != null ){
            Integer maxNameLength = CountryCode__c.SObjectType.getDescribe().fields.getMap().get('Name').getDescribe().getLength();
            String CountryIso3Code ;
            String personMaillingCountryIso3Code ;
            String personOtherCountryIso3Code ;
            
            
            //Country Code mapping
            if ( !String.isEmpty(accountInput.Country__pc)){
                for (CountryCode__c nameCustoLabel : listCountryCode ){
                    if (nameCustoLabel.Alpha_2_code__c == accountInput.Country__pc){
                        CountryIso3Code = nameCustoLabel.Alpha_3_code__c;
                        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ ' IN IF ==> accountInput.Country__pc'+CountryIso3Code);
                    }
                }
            }
            
            //Mailling Country Code Mapping
            if (!String.isEmpty(accountInput.PersonMailingCountry) && accountInput.PersonMailingCountry.length() <= maxNameLength  ){
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput.PersonMailingCountry.length()'+ accountInput.PersonMailingCountry.length() );
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'INF  maxNameLength PersonMailingCountry');
                for (CountryCode__c nameCustoLabel : listCountryCode){
                    if (nameCustoLabel.Name == accountInput.PersonMailingCountry ){ 
                        
                        personMaillingCountryIso3Code = nameCustoLabel.Alpha_3_code__c; 
                        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ ' IN IF ==> accountInput.PersonMailingCountry'+personMaillingCountryIso3Code);
                    }
                }
            }
            
            //Other Mailling Country 
            if (!String.isEmpty(accountInput.PersonOtherCountry) && accountInput.PersonOtherCountry.length() <= maxNameLength  ){
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'INF  maxNameLength PersonOtherCountry');
                for (CountryCode__c nameCustoLabel : listCountryCode){
                    if (nameCustoLabel.Name == accountInput.PersonOtherCountry ){                           
                        personOtherCountryIso3Code = nameCustoLabel.Alpha_3_code__c;
                        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ ' IN IF ==> accountInput.PersonOtherCountry'+personOtherCountryIso3Code);
                        
                    }
                }
            } 
            
            //Mailling Country Code Mapping
            if (!String.isEmpty(accountInput.PersonMailingCountry) && accountInput.PersonMailingCountry.length() > maxNameLength  ){
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'SUP  maxNameLength PersonMailingCountry');
                for (CountryCode__c nameCustoLabel : listCountryCode){
                    if (accountInput.PersonMailingCountry.CONTAINS(nameCustoLabel.Name))
                    {                       
                        personMaillingCountryIso3Code = nameCustoLabel.Alpha_3_code__c; 
                        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ ' IN IF ==> accountInput.PersonMailingCountry'+personMaillingCountryIso3Code);
                    }
                }
            }
            
            //Other Mailling Country
            if ( !String.isEmpty(accountInput.PersonOtherCountry)  && accountInput.PersonOtherCountry.length() > maxNameLength ){
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'SUP  maxNameLength PersonOtherCountry');
                for (CountryCode__c nameCustoLabel : listCountryCode){      
                    if (accountInput.PersonOtherCountry.CONTAINS(nameCustoLabel.Name) && !String.isEmpty(accountInput.PersonOtherCountry)){                   
                        personOtherCountryIso3Code = nameCustoLabel.Alpha_3_code__c;
                        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ ' IN IF ==> accountInput.PersonOtherCountry'+personOtherCountryIso3Code);
                    }
                }
            } 
            
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput.Country__pc'+accountInput.Country__pc);            
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput.SFSC_Contact_Key__pc'+accountInput.SFSC_Contact_Key__pc);
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'accountInput.Id'+accountInput.Id);      
            
            //Client Data
            Map<string,object> clientMap = buildObjectMap(accountInput, 'TNP_ClientMap__c');
            clientMap.put ('Source',source);
            clientMap.put ('Country',CountryIso3Code);
            String currentUserName = UserInfo.getName();
            if (currentUserName.contains('ECO') && accountInput.B2C_Date_Created__pc == null){
                clientMap.put('B2CDateCreated',DateTime.now());
            }
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
            
        }
        if (JsonMap != null && JsonMap.size()>0 )
        {
            jsonstring = JSON.serialize(JsonMap); 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'jsonstring'+jsonstring);  
        }   
        
        return jsonstring;
    }
    
    public static void sendRequest  (String jsonGenerated){ 
        String METHOD_NAME = 'sendRequest' ;
        try { 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'jsonGenerated'+jsonGenerated);         
            Http http=new http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            AccountAPI__c apiAccount = AccountAPI__c.getInstance(Label.TNP_APINameAccount);//'Account Api'
            
            if(apiAccount!=null) {
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'apiAccount'+apiAccount); 
                String  endPoint = apiAccount.EndPoint__c;
                String method = apiAccount.Method__c;
                req.setEndpoint(endPoint);
                req.setMethod(method);
                req.setHeader('Content-Type',apiAccount.Content_Type__c);
                req.setHeader('client_id', apiAccount.Client_Id__c);
                req.setHeader('client_secret', apiAccount.Client_secret__c);
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'jsonGenerated : '+jsonGenerated); 
                req.setBody(jsonGenerated);
                req.setTimeout(2000);
                res = http.send(req);  
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'result : '+res.toString());  
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'result Status Code : '+res.getStatusCode());
            }
            
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
        } catch(Exception e) {
			System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'exception : '+e.getMessage());  
        }
    }
    
    public static Map<Id,User> returnMapUserIntegration(){ 
        String METHOD_NAME = 'returnIdUser' ;
        System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'Call single line method');
        return new Map<Id,User>([SELECT Id, Name FROM User WHERE isIntegrationUser__c = TRUE and isActive = TRUE]);
    }
}