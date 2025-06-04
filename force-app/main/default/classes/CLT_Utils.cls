public with sharing class CLT_Utils {
    static public User getMyUser() {   
        return [SELECT Id, StoreCode__c,LanguageLocaleKey, EmailLanguages__c,Email_templates__c FROM User WHERE Id = :UserInfo.getUserId()];
    }
      public static sObject getAppSettings(){
        string strQuery = 'select immediate_log__C,Is_LogActive__c,LogHistoryDays__c from Clienteling_App_Setting__mdt limit 1';
        list<sObject> sObjects = database.query(strQuery);
        return sObjects.size() > 0 ? sObjects[0] : null;
         
    }
     public static void createLog(string serviceName, RestRequest request , RestResponse response){
        try {

            sObject settings = getAppSettings();
            boolean isLogActive = (settings == null) ? false : boolean.valueOf(settings.get('Is_LogActive__c'));
            boolean isImmediate = (settings == null) ? false : boolean.valueOf(settings.get('immediate_log__C'));

            if (isLogActive == false) {
                return;
            }

            String stackTrace = '';
            String error = '';
            boolean hasError = response.statusCode == 400 ? true : false;
            string requestBody = request.requestBody.toString();
            string responseBody = response.responseBody == null ? 'null' : response.responseBody.toString();
            if (hasError) {
                Map<String, Object> responseObject = responseBody != 'null' ?
                                                     (Map<String, Object>)JSON.deserializeUntyped(responseBody)
                                                     : new Map<String, Object>() ;
                stackTrace = String.valueOf(responseObject.get('Stack Trace'));
                error = String.valueOf(responseObject.get('Error Message'));
            }


            //string errorMessage = hasError ? (String)JSON.deserialize(responseBody,String.class) : '';
            string errorMessage = error;
            string params = request.params.size() > 0 ? String.valueOf(request.params) : '';
            system.debug(params);
            string userAgent = request.headers.get('User-Agent');
            string mobileLanguage = request.headers.get('Accept-Language');
            string method = string.valueOf(request.httpMethod);
            string mobileTimeZone = request.headers.get('TimeZone') != null ? request.headers.get('TimeZone') : '';
            responseBody = (responseBody.length() > 131000) ? responseBody.abbreviate(131000) : responseBody;
            long reqTime = Long.valueOf(request.headers.get('Time'));
            long resTime = Long.valueOf(response.headers.get('Time'));
            Decimal duration = Decimal.valueOf(resTime - reqTime) / 1000;
            Decimal responseSize = response.responseBody == null ? 0 : response.responseBody.size() / 1000.0;
            Decimal requestSize = request.requestBody.size() / 1000.0;
            string limits = Utils.getCurrentOrgLimits();
            string headers = Utils.getHttpHeaderRequestString(request);
            string Query = request.headers.get('QUERY');
            if (isImmediate) {
                Log__c log = new Log__c(Mobile_Time_Zone__c = mobileTimeZone,
                        mobile_Language__c = mobileLanguage,
                        Duration__c = Duration,
                        Request_Size__c = requestSize,
                        Response_Size__c = responseSize,
                        Service_Name__c = serviceName,
                        method__c = method,
                        user_Agent__c = userAgent,
                        Query_Parameters__c = params,
                        request__c = requestBody.Length() <= 131072  ? requestBody : requestBody.substring(0, 131071), 
                        Stack_Trace__c = stackTrace,
                        response__c = responseBody.Length() <= 131072 ? responseBody : responseBody.substring(0, 131071), 
                        Has_Error__c = hasError,
                        Error_Message__c = errorMessage,
                        SFDC_Limits__c = limits,
                        Request_Headers__c = headers,
                        Query__C = Query);
                insert log;
            } else createLogFuture(mobileTimeZone, mobileLanguage, duration, requestSize, responseSize, serviceName,
                    method, userAgent, params, requestBody, responseBody, hasError, errorMessage, query, stackTrace,
                    limits, headers);
        } catch (Exception ex) {
            string errorStr =
                    ex.getStackTraceString() + '\n\n' + ex.getMessage() + '\n\nlineNumber:' + ex.getLineNumber();
            Log__c log = new Log__c(Service_Name__c = serviceName,
                    Has_Error__C = true,
                    Error_Message__c = errorStr, SFDC_Limits__c = Utils.getCurrentOrgLimits());
            database.insert(log);
        }
    }
     public static void createLogFuture(string mobileTimeZone, string mobileLanguage, Decimal Duration, Decimal requestSize, Decimal responseSize, string serviceName, string method,
                                       string userAgent, string params, string requestBody, string responseBody, boolean hasError, string errorMsg, String stackTrace, string limits,
                                       string headers, string query) {
        Log__c log = new Log__c(Mobile_Time_Zone__c  = mobileTimeZone,
                                Mobile_Language__c = mobileLanguage,
                                Duration__c = Duration,
                                Request_Size__c = requestSize,
                                Response_Size__c = responseSize ,
                                Service_Name__c  = serviceName,
                                method__c = method,
                                user_Agent__c = userAgent,
                                Query_Parameters__c = params,
                                request__c = requestBody,
                                response__c = responseBody,
                                has_Error__c = hasError,
                                Stack_Trace__c = stackTrace,
                                Error_Message__c = errorMsg,
                                SFDC_Limits__c = limits,
                                Request_Headers__c = headers,
                                query__c = query);
        insert log;
    }
    

    static public Store__c getMyStore() {
        String storeCode = getMyUser().StoreCode__c;
        List<Store__c> stores = new List<Store__c>();
        if(!String.isEmpty(storeCode)){
        	stores = [SELECT Id FROM Store__c WHERE SourceStoreId__c = :storeCode];
       	}
        return stores.size() > 0 ? stores[0] : null;
    }
//
//    static public String getUserStoreCode() {
//        return getMyUser().BaseStoreCode__c;
//    }

//    static public Object getObjectList(String objectName, String fields, String whereString){
//        String query = 'SELECT ' + fields + ' From '+ objectName + whereString;
//        Object objectList = Database.query(query);
//        return objectList;
//    }
//
//    public static set<String> getIdList(List<Sobject> items, String fieldName){
//       Set<String> s = new Set<String>();
//
//       for(Sobject ob : items){
//            s.add((string)ob.get(fieldName));
//       }
//       return s;
//    }

   public static String getContactId(string accId){
       String accountId = '';
       List<Account> acc =  [SELECT Id/*, PersonContactId*/ from Account Where Id =: accId limit 1];
        if(acc.size() > 0 ){
            accountId = acc.get(0).Id;
        }
       // return null;// acc.PersonContactId;
        return accountId;
    }



//    public static String convertToString(List<String> stringList){
//        if(stringList.size() > 0){
//            return '(\''+ String.join(stringList, '\',\'') + '\')';
//        } else {
//            return '()';
//        }
//
//    }

    public static String convertToString(Set<String> stringSet){
        if(stringSet.size() > 0){
            List<String> stringList = new List<String>();
            stringList.addAll(stringSet);
            return '(\''+ String.join(stringList, '\',\'') + '\')';
        } else {
            return '()';
        }
          
    }  

//    static public Map<String, map<string, object>> getDocuments(list<map<string, object>> items){
//
//        set<String> parentIds = new set<String>();
//        for(map<string, object> item : items){
//            String itemId = String.valueOf(item.get('id'));
//            parentIds.add(itemId);
//        }
//
//        return getDocuments(parentIds);
//    }

    static public Map<String, map<string, object>> getDocuments(set<String> parentIds){
        Map<String, map<string, object>> documents = new Map<String, map<string, object>>();

        if (parentIds.size() == 0){
            return null;
        }
        
        string soqlCondition = convertToString(parentIds);
        
        list<map<string, object>> docs =  CLT_Utils_Mapping.getStandardWrapperList('ContentDocumentLink', 'Document', 'FROM ContentDocumentLink WHERE LinkedEntityId IN ' + soqlCondition); 
        
        for(map<string, object> doc : docs){
            string parentId = String.valueOf(doc.get('parentId'));
            documents.put(parentId, doc);  
        }
        return documents;        
    } 
     public class Custom_Exception extends Exception { }
    class EmptyStoreCodesException extends Exception{}
}