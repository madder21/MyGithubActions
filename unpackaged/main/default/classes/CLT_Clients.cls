public with sharing class CLT_Clients implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
    
    //We will be using the POST method for the search so we don't have to send sensitive data in params	
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){	
        return new Map<String, Object> { 	
            'clients' => getClients(body)	
        };	
    }

    public Object retrieveGet(Map<String, String> params){   
        return new Map<String, Object> { 
            'clients' => getClients(params)
        };

    }

     List<Map<String, Object>> getClients(Map<String, String> params){
         List<Sobject> clients = searchClient(params);
		 System.debug(clients);
         if(!clients.isEmpty()){
             return CLT_Utils_Mapping.getStandardWrapperListFromObjectList('Account', 'Client', clients);
         }
         return null;
    }

    //getClients method using body instead of params
    List<Map<String, Object>> getClients(Map<String, Object> body){	
        List<Sobject> clients = searchClient(body);	
        System.debug(clients);	
        if(!clients.isEmpty()){	
            return CLT_Utils_Mapping.getStandardWrapperListFromObjectList('Account', 'Client', clients);	
        }	
        return null;	
   }

    private String getSearchTerm(Map<String, String> params){

        Set<String> values = new Set<String>{'nationality__pc', 'billingcountry' };
        List<String> ret = new List<String>();

        for (String key : params.keySet()){
            if (!values.contains(key.toLowerCase())){
                ret.add(params.get(key) + '*');
            }
        }
        return String.join(ret, ' AND ');
    }

    //getSearchTerm method using body instead of params
    private String getSearchTerm(Map<String, Object> body){

        Set<String> values = new Set<String>{'nationality__pc', 'billingcountry' };
        List<String> ret = new List<String>();

        for (String key : body.keySet()){
            if (!values.contains(key.toLowerCase())){
                ret.add(String.valueOf(body.get(key)) + '*');
            }
        }
        return String.join(ret, ' AND ');
    }

    private String getConditions(Map<String, String> params){

        Map<String, List<String>> fieldsNamesMap = getFieldNamesMap();
        List<String> conditionList = new List<String>();

        for (String paramKey : params.keySet()){
            String condition;
            List<String> subCondition = new List<String>();
            String paramValue = params.get(paramKey).trim();

            if(String.isEmpty(paramValue))	continue;

            if(fieldsNamesMap.get(paramKey.trim()) != null){
                for (String fieldName : fieldsNamesMap.get(paramKey.trim())){
                	condition = getCondition(fieldName, paramKey, paramValue);
                	subCondition.add(condition);
            	}
            }
            
            if(!subCondition.isEmpty()){
                conditionList.add( '( ' + String.join(subCondition, ' OR ') +' ) ');
            }
            
        }
        if (!conditionList.isEmpty()){
            return ' WHERE ' + String.join(conditionList, ' AND ');
        }
        return '';
    }

    //getConditions method using body instead of params
    private String getConditions(Map<String, Object> body){	
        Map<String, List<String>> fieldsNamesMap = getFieldNamesMap();	
        List<String> conditionList = new List<String>();	
        for (String paramKey : body.keySet()){	
            String condition;	
            List<String> subCondition = new List<String>();	
            String paramValue = String.valueOf(body.get(paramKey)).trim();	
            if(String.isEmpty(paramValue))	continue;	
            if(fieldsNamesMap.get(paramKey.trim()) != null){	
                for (String fieldName : fieldsNamesMap.get(paramKey.trim())){	
                	condition = getCondition(fieldName, paramKey, paramValue);	
                	subCondition.add(condition);	
            	}	
            }	
            	
            if(!subCondition.isEmpty()){	
                conditionList.add( '( ' + String.join(subCondition, ' OR ') +' ) ');	
            }	
            	
        }	
        if (!conditionList.isEmpty()){	
            return ' WHERE ' + String.join(conditionList, ' AND ');	
        }	
        return '';	
    }

    private String getCondition(String fieldName, String paramKey, String paramValue) {
        switch on paramKey.toLowerCase() {
            when 'firstname', 'lastname', 'passportnumber', 'phone', 'personemail' {
                
                return fieldName + ' LIKE \'%' + paramValue + '%\'';
            }
            
            when 'id' {
                return  'Id IN (SELECT Client__c FROM ClientSource__c WHERE SourceCode__c  = \'' + paramValue + '\')';
            }
			
            when else {
                return fieldName + ' = \'' + paramValue + '\'';
            }
        }
    }


    public static Map<String, List<String>> getFieldNamesMap() {
        Map<String, List<String>> fieldsNamesMap = new Map<String, List<String>>();
        fieldsNamesMap.put('FirstName', new List<String>{'FirstName'});
        fieldsNamesMap.put('LastName', new List<String>{'LastName'});
        fieldsNamesMap.put('Phone', new List<String>{'Phone', 'Phone2__pc', 'Phone3__pc'});
        fieldsNamesMap.put('PersonEmail', new List<String>{'PersonEmail'});
//        fieldsNamesMap.put('Id', new List<String>{'UCRInternalId__c', 'ClientAdvisorId__pc'});
        fieldsNamesMap.put('Id', new List<String>{'Id'});
        fieldsNamesMap.put('Nationality__pc', new List<String>{'Nationality__pc'});
        fieldsNamesMap.put('PassportNumber', new List<String>{'PassportNumber__pc'});
        fieldsNamesMap.put('BillingCountry', new List<String>{'PersonMailingCountry'});
        return fieldsNamesMap;
    }


    public List<Sobject> searchClient(Map<String, String> params) {
        String clientFields = CLT_Utils_Mapping.getFieldsListString('Account', 'Client');

        String query = 'FIND \'' + getSearchTerm(params) + '\' IN ALL FIELDS ' +
                            'RETURNING Account (' + clientFields + getConditions(params) + ' ) LIMIT 100';
        
        
        if(params.get('Id') != null && params.get('Id').length() > 0){
            
            List<ClientSource__c> src = [SELECT Client__c FROM ClientSource__c WHERE SourceCode__c = :params.get('Id')];
            
            if(src.size()> 0){
                Id clientId = src[0].Client__c;

                String accQuery = 'SELECT ' + clientFields +' FROM Account WHERE Id =\'' + clientId + '\'';
                return Database.query(accQuery);
            }
        }
        
        System.debug(query);
        List<List<Sobject>> result = search.query(query);
        return result.get(0);
    }

    //searchClient method using body instead of params
    public List<Sobject> searchClient(Map<String, Object> body) {
        String clientFields = CLT_Utils_Mapping.getFieldsListString('Account', 'Client');

        String query = 'FIND \'' + getSearchTerm(body) + '\' IN ALL FIELDS ' +
                            'RETURNING Account (' + clientFields + getConditions(body) + ' ) LIMIT 100';
        
        
        if(body.get('Id') != null && String.valueOf(body.get('Id')).length() > 0){
            
            List<ClientSource__c> src = [SELECT Client__c FROM ClientSource__c WHERE SourceCode__c = :String.valueOf(body.get('Id'))];
            
            if(src.size()> 0){
                Id clientId = src[0].Client__c;

                String accQuery = 'SELECT ' + clientFields +' FROM Account WHERE Id =\'' + clientId + '\'';
                return Database.query(accQuery);
            }
        }
        
        System.debug(query);
        List<List<Sobject>> result = search.query(query);
        return result.get(0);
    }
}