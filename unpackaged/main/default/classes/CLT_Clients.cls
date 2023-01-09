public with sharing class CLT_Clients implements CLT_RetailInterface {
    static Map<String, List<String>> compareTypeFieldsMap = new Map<String, List<String>> {
        'contains' => new List<String>{'Phone'},
        'startWith' => new List<String>{'FirstName','LastName','PersonEmail','BillingCity'},
        'id' => new List<String>{'Id'},
        'equal' => new List<String>{'Country__pc','Nationality__pc'}
    };

    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
    
    //We will be using the POST method for the search so we don't have to send sensitive data in params	
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){	
        return new Map<String, Object> { 	
            'clients' => getClients(body)	
        };	
    }

    //getClients method using body instead of params
    List<Map<String, Object>> getClients(Map<String, Object> body){
        String query = getSearchClientQuery(body);
        Utils.addCustomHeader('QUERY', query, RestContext.request);
        return CLT_Utils_Mapping.getStandardWrapperList('Account', 'Client', query);
    }
    
    public String getSearchClientQuery(Map<String, Object> body) {
        return 'FROM Account ' + getConditions(body) + ' LIMIT 100';
    }

    //getConditions method using body instead of params
    private String getConditions(Map<String, Object> body){	
        Boolean hasIdFilter = false;
        Map<String, List<String>> fieldsNamesMap = getFieldNamesMap();	
        List<String> conditionList = new List<String>();	
        for (String paramKey : body.keySet()){
            if(paramKey != 'Id') {
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
            else if(paramKey == 'Id' && fieldsNamesMap.get(paramKey.trim()) != null) {
                hasIdFilter = true;
            }	
        }	

        if (!conditionList.isEmpty() || hasIdFilter){	
            if(hasIdFilter) {
                conditionList.add(getIdCondition(String.valueOf(body.get('Id')).trim(), conditionList));
            }
            return ' WHERE ' + String.join(conditionList, ' AND ');	
        }	
        return '';	
    }

    private String getCondition(String fieldName, String paramKey, String paramValue) {
        String comapreType = compareTypeFieldsMap.get('contains').contains(paramKey) ? 'contains' :
            compareTypeFieldsMap.get('startWith').contains(paramKey) ? 'startWith' :
            compareTypeFieldsMap.get('id').contains(paramKey) ? 'id' :
            compareTypeFieldsMap.get('equal').contains(paramKey) ? 'equal' : 'equal';

        switch on comapreType {
            when 'contains' {                
                return fieldName + ' LIKE \'%' + paramValue + '%\'';
            }
            when 'startWith' {                
                return fieldName + ' LIKE \'' + paramValue + '%\'';
            }			
            when else {
                return fieldName + ' = \'' + paramValue + '\'';
            }
        }
    }

    private String getIdCondition(String paramValue, List<String> conditionList) {
        List<String> clientIds = new List<string>();
        String otherConditions = conditionList.size() > 0 ? 
            (' AND Client__c IN (SELECT Id FROM Account WHERE ' + String.join(conditionList, ' AND ') + ')')
            : '';
            
        String clientSourceQuery = 'SELECT Client__c FROM ClientSource__c WHERE ' +
                        'Source__c = \'001\' AND SourceCode__c LIKE \'' + paramValue + '%\'' + otherConditions + ' LIMIT 100';
        Utils.addCustomHeader('QUERY', 'clientSourceQuery-->' + clientSourceQuery, RestContext.request);

        for(ClientSource__c cs : Database.query(clientSourceQuery)){
            clientIds.add(cs.Client__c);
        }

        String cegidIdClauseStringFormat = clientIds.size() > 0 ? 
                'Id IN (\'' + String.join(clientIds, '\',\'') + '\') OR ' :
                '';
    
        return  '(' + cegidIdClauseStringFormat + 'UCRInternalId__c LIKE \'' + paramValue + '%\')';
    }

    public static Map<String, List<String>> getFieldNamesMap() {
        Map<String, List<String>> fieldsNamesMap = new Map<String, List<String>>();
        fieldsNamesMap.put('FirstName', new List<String>{'FirstName'});
        fieldsNamesMap.put('LastName', new List<String>{'LastName'});
        fieldsNamesMap.put('BillingCity', new List<String>{'PersonMailingCity'});
        fieldsNamesMap.put('Phone', new List<String>{'Phone', 'Phone2__pc', 'Phone3__pc'});
        fieldsNamesMap.put('BillingCountry', new List<String>{'PersonMailingCountry'});
        fieldsNamesMap.put('PersonEmail', new List<String>{'PersonEmail'});
        fieldsNamesMap.put('Id', new List<String>{'UCRInternalId__c'});
        fieldsNamesMap.put('Nationality__pc', new List<String>{'Nationality__pc'});
        fieldsNamesMap.put('Country__pc', new List<String>{'Country__pc'});
        return fieldsNamesMap;
    }

    //*****OLD VERSION USING GET HTTP CALL*****
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
    //*****OLD VERSION USING GET HTTP CALL*****

}