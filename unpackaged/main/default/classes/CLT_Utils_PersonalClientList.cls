public with sharing class CLT_Utils_PersonalClientList {
    public static String CLIENT_LIST_PREFIX = 'a08';
    public static String CLIENT_PREFIX = '001';

    public static Object upsertPersonalClientList(Map<String, String> params, Map<String,Object> body) {
        ClientList__c clientList = new ClientList__c();
        if(params.containsKey('id') && String.isNotEmpty(params.get('id'))){
            checkIdValidity(params.get('id'), CLIENT_LIST_PREFIX, 'not a valid clientlist Id');
            clientList.Id = params.get('id');
            List<ClientList__c> currentCL = [SELECT Name FROM ClientList__c WHERE Id=:clientList.Id];
            
            if(currentCL.size() == 0){
                throw new BL_Exceptions.CLTException('404', 'no clientlist with corresponding Id', 'no clientlist with corresponding Id');
            }
        }
        if(body.containsKey('name')){
            clientList.Name = (String)body.get('name');
            clientList.OwnerId = UserInfo.getUserId();
            clientList.Type__c = 'Personal';
        }

        try {
            upsert clientList;
        } catch (Exception ex) {
            throw new BL_Exceptions.CLTException('400', ex.getMessage(), ex.getMessage());
        }

        if(body.containsKey('memberIds') && body.get('memberIds') != null){
            List<String> membersId = (List<String>)JSON.deserialize(JSON.serialize(body.get('memberIds')), List<String>.class);              
            List<ClientListMember__c> members = new List<ClientListMember__c>();

            Map<String, ClientListMember__c> existingMembers = new Map<String, ClientListMember__c>();

            if(params.containsKey('id') && String.isNotEmpty(params.get('id'))){
                for(ClientListMember__c clm : [SELECT Id,Client__c FROM ClientListMember__c WHERE ClientList__c = :params.get('id')]) {
                    existingMembers.put(clm.Client__c, clm);
                }
            }
            
            for(String mId: membersId){
                checkIdValidity(mId, CLIENT_PREFIX, 'not a valid client list member id');
                if((!params.containsKey('id') || (params.containsKey('id') && String.isEmpty(params.get('id')))) || //is a new list
                    (params.containsKey('id') && String.isNotEmpty(params.get('id')) && !existingMembers.keySet().contains(mId))) {//is an update and the client doesn't exist already
                    members.add(new ClientListMember__c(ClientList__c = clientList.Id, Client__c = mId));
                }
            }
            if(params.containsKey('id') && String.isNotEmpty(params.get('id'))){
                List<ClientListMember__c> membersToDelete = new List<ClientListMember__c>();
                for(String existingClientId : existingMembers.keySet()) {
                    if(!membersId.contains(existingClientId)) {
                        membersToDelete.add(existingMembers.get(existingClientId));
                    }
                }

                if(membersToDelete.size() > 0) {
                    delete membersToDelete;
                }
            }
            if(members.size() > 0) {
                try {
                    upsert members;
                }
                catch(Exception ex) {
                    throw new BL_Exceptions.CLTException('400', ex.getMessage(), ex.getMessage());
                }
            }
        }
        return new Map<String, String>{'id' => clientList.Id};
    }

    public static Boolean checkIdValidity(String recordId, String objPrefix, String message){
        if (Pattern.compile(objPrefix + '[a-zA-Z0-9]{12}|' + objPrefix + '[a-zA-Z0-9]{15}').matcher(recordId).matches()){
            return true;
        }else {                        
            throw new BL_Exceptions.CLTException('404', message, message);            
        }
    }

    public static Object getPersonalClientList() {
        List<CLT_ClientList.ClientListWrapper> clientLists = new List<CLT_ClientList.ClientListWrapper>();

        for (ClientList__c clientList : [SELECT Id,Name,StaticList__c,IsDarkText__c,OrderBy__c,Ascendant__c,DisplayType__c,Type__c,
                                            SpecificFieldDisplay__c,SpecificFieldDisplayLabel__c,position__c,Description__c,OwnerId,CreatedDate,LastModifiedDate,
                                            DisplayToReachOutContactedSection__c,ContactedSectionDisplayPeriod__c,
                                            (SELECT Client__c FROM ClientListMembers__r)
                                        FROM ClientList__c 
                                        WHERE Type__c = 'Personal' AND OwnerId = :UserInfo.getUserId()]) {
            Set<Id> clientIds = new Set<Id>();
            for(ClientListMember__c member : clientList.ClientListMembers__r) {
                clientIds.add(member.Client__c);
            }
            clientLists.add(new CLT_ClientList.ClientListWrapper(clientList,clientIds));
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('clientLists', clientLists);
        result.put('clients', CLT_Utils_Mapping.getStandardWrapperList('Account', 'Client',
            'FROM Account WHERE Id IN (SELECT Client__c FROM ClientListMember__c WHERE ClientList__r.Type__c = \'Personal\' AND ClientList__r.OwnerId = \'' + UserInfo.getUserId() + '\')'));

        return result;
    }

    public static Object deletePersonalClientList(Map<String, String> params) {
        if(params.containsKey('id') && String.isNotEmpty(params.get('id'))){
            String clId = params.get('id');
            checkIdValidity(clId, CLIENT_LIST_PREFIX, 'not a valid clientlist Id');
            List<ClientList__c> clToDelete = [SELECT Id FROM ClientList__c WHERE Id = :clId];
            if(clToDelete.size() > 0) {
                delete clToDelete;
                return true;
            }
            else {
                throw new BL_Exceptions.CLTException('401', 'No client List with this id were found', 'No client List with this id were found');
            }
            
        }
        else {
            throw new BL_Exceptions.CLTException('401', 'No client List id received', 'No client List id received');
        }
    }

    public static Object getClientsByFilters(Map<String,Object> body) {
        Map<String, FilterInformation> filtersInformationMap = getFiltersInformationMap();
        List<String> clientConditions = new List<String>();
        List<String> clientTransactionItemConditions = new List<String>();
        List<String> clientGiftConditions = new List<String>();
        List<String> clientEventConditions = new List<String>();

        if(body.containsKey('contactable')) {
            List<String> outreachChannelList = new List<String>();
            if(body.containsKey('outreachChannel')) {
                for(Object objectOChannel : (List<Object>)JSON.deserializeUntyped(JSON.serialize(body.get('outreachChannel')))) {
                    outreachChannelList.add((String)objectOChannel);
                }
                body.remove('outreachChannel');
            }
            clientConditions.add(getContactableCondition((Boolean)body.get('contactable'), outreachChannelList));
            body.remove('contactable');
        }

        for(String filterName : body.keySet()) {
            if(filtersInformationMap.containsKey(filterName)) {
                FilterInformation filterInfo = filtersInformationMap.get(filterName);
                String condition = '';

                if(filterInfo.isRangeValue) {
                    Map<String, Object> rangeValueMap = ((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(body.get(filterName))));
                    String fromValue = filterInfo.valueType != 'text' ? ((String)rangeValueMap.get('fromValue')) : ('\'' + (String)rangeValueMap.get('fromValue') + '\'');
                    String toValue = filterInfo.valueType != 'text' ? ((String)rangeValueMap.get('toValue')) : ('\'' + (String)rangeValueMap.get('toValue') + '\'');

                    condition = filterInfo.condition.replace('{fromValue}', fromValue).replace('{toValue}', toValue);
                }
                else {
                    if(filterInfo.valueType == 'textList') {
                        List<String> valuesList = (List<String>)JSON.deserialize(JSON.serialize(body.get(filterName)), List<String>.class); 
                        if(valuesList.size() > 0) {
                            condition = filterInfo.condition.replace('{value}', ('\'' + String.join(valuesList, '\',\'') + '\''));
                        }
                    }
                    else {
                        String value = filterInfo.valueType == 'boolean' ? String.valueOf((Boolean)body.get(filterName)) : (String)body.get(filterName);
                        if(!String.isEmpty(value)) {
                            condition = filterInfo.condition.replace('{value}', (filterInfo.valueType == 'text' ? ('\'' + value + '\'') : value));
                        }

                    }
                }

                if(!String.isEmpty(condition)) {
                    if(!filterInfo.isJunctionFilter) {
                        clientConditions.add(condition);
                    }
                    else if(filterInfo.isJunctionFilter && filterInfo.junctionObject == 'TransactionItem__c') {
                        clientTransactionItemConditions.add(condition);
                    }
                    else if(filterInfo.isJunctionFilter && filterInfo.junctionObject == 'Task' && filterInfo.name.startsWith('gift')) {
                        clientGiftConditions.add(condition);
                    }
                    else if(filterInfo.isJunctionFilter && filterInfo.junctionObject == 'Task' && filterInfo.name.startsWith('event')) {
                        clientEventConditions.add(condition);
                    }
                }
            }
        }
        
        String query = ' FROM Account WHERE IsPersonAccount = true ';

        List<String> visibilityConditions = new List<String>();
        for( Schema.PicklistEntry visibilityFieldPicklistVal : ClientList__c.VisibilityBasedOnField__c.getDescribe().getPicklistValues()){
            visibilityConditions.add(visibilityFieldPicklistVal.getValue() + ' = \'' + UserInfo.getUserId() + '\'');
        }

        query += visibilityConditions.size() > 0 ? ' AND (' + String.join(visibilityConditions , ' OR ') + ') ' : ' AND ClientAdvisor__pc = \'' + UserInfo.getUserId() + '\'';
        
        if(clientConditions.size() > 0) {
            query += ' AND ' + String.join(clientConditions, ' AND ');
        }

        if(clientGiftConditions.size() > 0 || clientEventConditions.size() > 0) {
            String taskQuery = 'SELECT AccountId accId FROM Task WHERE AccountId IN (SELECT Id ' + query + ' ) AND ';
            if(clientGiftConditions.size() > 0) {
                taskQuery += String.join(clientGiftConditions, ' AND ') + ' GROUP BY AccountId';
                if(clientEventConditions.size() > 0) {
                    List<String> clientsFromGiftQuery = new List<String>();

                    for(AggregateResult t : Database.query(taskQuery)) {
                        clientsFromGiftQuery.add((String)t.get('accId'));
                    }
                    if(clientsFromGiftQuery.size() > 0) {
                        taskQuery = 'SELECT AccountId accId FROM Task WHERE AccountId IN (\'' + String.join(clientsFromGiftQuery, '\',\'') + '\')  AND ';
                    }
                    else {
                        return new List<Object>();
                    }
                }
            }
            if(clientEventConditions.size() > 0) {
                taskQuery += String.join(clientEventConditions, ' AND ') + ' GROUP BY AccountId';
            }

            List<String> clientsFromTaskQuery = new List<String>();

            for(AggregateResult t : Database.query(taskQuery)) {
                clientsFromTaskQuery.add((String)t.get('accId'));
            }
            
            if(clientsFromTaskQuery.size() > 0) {
                query = ' FROM Account WHERE Id IN (\'' + String.join(clientsFromTaskQuery, '\',\'') + '\') ';
            }
            else {
                return new List<Object>();
            }
        }

        if(clientTransactionItemConditions.size() > 0) {
            query += ' AND Id IN (SELECT Client__c FROM TransactionItem__c WHERE ' + String.join(clientTransactionItemConditions, ' AND ') + ')';
        }
        
        System.debug('client filters query---> ' + query);
        return CLT_Utils_Mapping.getStandardWrapperList('Account', 'Client', query);
    }

    public static Map<String, FilterInformation> getFiltersInformationMap() {
        return new Map<String, FilterInformation> {
            'segment' => new FilterInformation('segment', 'LightCurrentCluster__pc IN ({value})', 'textList'),
            'type' => new FilterInformation('type', 'LocalOrTourist__pc IN ({value})','textList'),
            'lifetimeTurnover' => new FilterInformation('lifetimeTurnover', '(LifeTimePurchaseAmount__pc >= {fromValue} AND LifeTimePurchaseAmount__pc <= {toValue})', 'number', true),
            'lastPurchaseDate' => new FilterInformation('lastPurchaseDate', '(LastPurchaseDate__pc >= {fromValue} AND LastPurchaseDate__pc <= {toValue})', 'date', true),
            'product' => new FilterInformation('product', 'Product__r.StockKeepingUnit IN ({value})', 'textList', true, 'TransactionItem__c'),
            'collection' => new FilterInformation('collection', 'Product__r.model__c IN ({value})','textList', true, 'TransactionItem__c'),
            'size' => new FilterInformation('size', 'Product__r.size__c IN ({value})', 'textList', true, 'TransactionItem__c'),
            'material' => new FilterInformation('material', 'Product__r.material_v3__c IN ({value})', 'textList', true, 'TransactionItem__c'),
            'color' => new FilterInformation('color', 'Product__r.color_v3__c IN ({value})', 'textList', true, 'TransactionItem__c'),
            'giftGifted' => new FilterInformation('giftGifted', 'Gifted__c = {value}', 'boolean', true, 'Task'),
            'giftGiftedDate' => new FilterInformation('giftGiftedDate', 'GiftedDate__c >= {value}', 'date', true, 'Task'),
            'eventAttended' => new FilterInformation('eventAttended', 'EventClientAttended__c = {value}', 'boolean', true, 'Task'),
            'eventAttendedDate' => new FilterInformation('eventAttendedDate', 'EventAttendedDate__c >= {value}', 'date', true, 'Task')
        };
    }

    class FilterInformation {
        String name {get; set;}
        String condition {get; set;}
        String valueType {get; set;}
        Boolean isRangeValue{get;set;}
        Boolean isJunctionFilter {get; set;}
        String junctionObject {get;set;}

        public FilterInformation(String name, String condition, String valueType) {
            this.name = name;
            this.condition = condition;
            this.valueType = valueType;
            this.isRangeValue = false;
            this.isJunctionFilter = false;
        }

        public FilterInformation(String name, String condition, String valueType, Boolean isRangeValue) {
            this.name = name;
            this.condition = condition;
            this.valueType = valueType;
            this.isRangeValue = isRangeValue;
            this.isJunctionFilter = false;
        }

        public FilterInformation(String name, String condition, String valueType, Boolean isJunctionFilter, String junctionObject) {
            this.name = name;
            this.condition = condition;
            this.valueType = valueType;
            this.isRangeValue = false;
            this.isJunctionFilter = isJunctionFilter;
            this.junctionObject = junctionObject;
        }

        public FilterInformation(String name, String condition, String valueType, Boolean isRangeValue, Boolean isJunctionFilter, String junctionObject) {
            this.name = name;
            this.condition = condition;
            this.valueType = valueType;
            this.isRangeValue = isRangeValue;
            this.isJunctionFilter = isJunctionFilter;
            this.junctionObject = junctionObject;
        }
    }
    
    public static String getContactableCondition(Boolean contactable, List<String> outreachChannels) {
        List<String> contactableConditions = new List<String>();
        if(contactable) {
            Map<String, String> contactableConditionMap = getContactableConditionMap();
            if(outreachChannels.size() == 0) {
                for(String oChannel : contactableConditionMap.keySet()) {
                    contactableConditions.add(contactableConditionMap.get(oChannel));
                }
            }
            else {
                for(String oChannel : outreachChannels) {
                    if(contactableConditionMap.containsKey(oChannel)) {
                        contactableConditions.add(contactableConditionMap.get(oChannel));
                    }
                }  
            }
            return '(' + String.join(contactableConditions, ' OR ') + ')';
        }
        else {
            Map<String, String> nonContactableConditionMap = getNonContactableConditionMap();
            if(outreachChannels.size() == 0) {
                for(String oChannel : nonContactableConditionMap.keySet()) {
                    contactableConditions.add(nonContactableConditionMap.get(oChannel));
                }
            }
            else {
                for(String oChannel : outreachChannels) {
                    if(nonContactableConditionMap.containsKey(oChannel)) {
                        contactableConditions.add(nonContactableConditionMap.get(oChannel));
                    }
                }
            }
            return '(' + String.join(contactableConditions, ' AND ') + ')';
        }
    }

    public static Map<String, String> getContactableConditionMap() {
        return new Map<String, String> {
            'Phone' => '(OptinCalling__pc = TRUE AND (Phone != NULL OR Phone2__pc != NULL OR Phone3__pc != NULL))',
            'Email' => '(OptinEmailing__pc = TRUE AND (PersonEmail != NULL OR OtherEmail__pc != NULL))',
            'SMS' => '(OptinInstantMessaging__pc = TRUE AND (Phone != NULL OR Phone2__pc != NULL OR Phone3__pc != NULL))',
            'Whatsapp' => '(OptinInstantMessaging__pc = TRUE AND (Phone != NULL OR Phone2__pc != NULL OR Phone3__pc != NULL))',
            'Wechat' => '(OptinInstantMessaging__pc = TRUE AND WeChat__pc != NULL AND (Phone != NULL OR Phone2__pc != NULL OR Phone3__pc != NULL))',
            'Postal' => '(OptinMailing__pc = TRUE AND NbOfClientAddresses__c >= 1)'
        };
    }

    public static Map<String, String> getNonContactableConditionMap() {
        return new Map<String, String> {
            'Phone' => '(OptinCalling__pc = FALSE)',
            'Email' => '(OptinEmailing__pc = FALSE)',
            'SMS' => '(OptinInstantMessaging__pc = FALSE)',
            'Whatsapp' => '(OptinInstantMessaging__pc = FALSE)',
            'Wechat' => '(OptinInstantMessaging__pc = FALSE)',
            'Postal' => '(OptinMailing__pc = FALSE)'
        };
    }
}