global with sharing class CLT_ClientList implements CLT_RetailInterface{
    public Object retrieveDelete(Map<String, String> params){
        return null;
    }

    global Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    global Object retrieveGet(Map<String, String> params){
        Boolean noLimit = params.containsKey('noLimit') ? Boolean.valueOf(params.get('noLimit')) : false;

        return getClientLists((String)params.get('Type'), noLimit);
    }

//------------------------------------START GET Client List------------------------------------------------------------------------

    Map<String, Object> getClientLists(String clientListId, Boolean noLimit){
        list<ClientListWrapper> clientsListWrapper = new list<ClientListWrapper>();
        User currentUser = [SELECT IsManager__c, StoreCode__c FROM User WHERE Id =: UserInfo.getUserId()];
        Boolean isManager = currentUser.IsManager__c == null ? false : currentUser.IsManager__c;
        Boolean isSpecificClientList = String.isEmpty(clientListId) ? false : true;

        Set<String> clientListIds = new Set<String>();
        String userId = UserInfo.getUserId();
        Set<Object> clients = new Set<Object>();
        User userInfo = CLT_Utils_Query.getUserInfos();
        string storeCode = userInfo.StoreCode__c;
        Set<Id> allClientIds = new Set<Id>();
//        Boolean isManager = userInfo.Is_Manager__c;

        List<ClientList__c > clientLists = getClientLists(clientListId, isManager, storeCode);

        for (ClientList__c clientList: clientLists){
            Set<Id> clientIds = new Set<Id>();
            clientListIds.add(clientList.Id);
    
            if(!String.isEmpty(clientList.clientListQuery__c)){
                String clientsQuery = CLT_Utils_Query.getClientsQuery(false, false) + CLT_Utils_ClientLists.buildDynamicQuery(clientList, userId, storeCode, isSpecificClientList, noLimit);
//                String clientsQuery = 'SELECT Id From Account WHERE ID != \'\' ' + CLT_Utils_ClientLists.buildDynamicQuery(clientList, userId, storeCode);
                system.debug(clientsQuery);
                Map<Id, Account> dynamicClients = new Map<Id, Account>((List<Account>)Database.query(clientsQuery));
                clientIds.addAll(dynamicClients.keySet());
                List<Account> clientsToAdd = getClientToAdd(dynamicClients.values(), allClientIds);
                allClientIds.addAll(clientIds);
                clients.addAll((List<Object>)CLT_Utils_Mapping.getStandardWrapperListFromObjectList('Account', 'Client', clientsToAdd));
                
                clientsListWrapper.add(new ClientListWrapper(clientList, clientIds));
            }
            else if(clientList.Type__c == 'Membered'){
                List<Map<String,Object>> membersWithStatusMap = new List<Map<String,Object>>();
                for(ClientListMember__c clm : [SELECT Client__c, Status__c
                                            FROM ClientListMember__c
                                            WHERE ClientList__c = :clientList.Id AND Client__r.ClientAdvisor__pc = :System.UserInfo.getUserId()]) {
                    membersWithStatusMap.add(new Map<String,Object>{
                        'id' => clm.Client__c,
                        'status' => clm.Status__c
                    });
                    clientIds.add(clm.Client__c);
                }
                String clientsToAddQuery = CLT_Utils_Query.getClientsQuery(false, false) + ' AND Id IN :clientIds AND Id NOT IN :allClientIds';
                List<Account> clientsToAdd = (List<Account>)Database.query(clientsToAddQuery);
                allClientIds.addAll(clientIds);
                clients.addAll((List<Object>)CLT_Utils_Mapping.getStandardWrapperListFromObjectList('Account', 'Client', clientsToAdd));
                
                clientsListWrapper.add(new ClientListWrapper(clientList, clientIds, membersWithStatusMap));
                
            }
        }  

        Map<String, Object> result = new Map<String, Object>();
        result.put('clientLists', clientsListWrapper);
        result.put('clients', clients);
        result.put('documents', CLT_Utils.getDocuments(clientListIds));

        return result;
    }

    private List<Account> getClientToAdd(List<Account> clients, Set<Id> clientIds) {
        List<Account> ret = new List<Account>();

        for (Account client : clients){
            if (!clientIds.contains(client.Id)){
                ret.add(client);
            }
        }
        return ret;
    }

    List<ClientList__c> getClientLists(String clientListId, Boolean isManager, String storeCode){
        string query = 'SELECT Id,OwnerId,Owner.FirstName,CreatedDate,LastModifiedDate,Type__c,Owner.LastName,Description__c,Position__c,Name,ClientListQuery__c,InMyStore__c,StaticList__c,' +
                                'IsDarkText__c,OrderBy__c,Ascendant__c,DisplayType__c,VisibilityBasedOnField__c,SpecificFieldDisplay__c,SpecificFieldDisplayLabel__c,' +
                                'DisplayToReachOutContactedSection__c,ContactedSectionDisplayPeriod__c,AlwaysLimitedList__c, ' + 
                                '(SELECT Description__c,Title__c,Name FROM Client_List_Translations__r' +
                                ' WHERE Language__c = \'' + UserInfo.getLanguage() +'\' LIMIT 1)' +
                        ' FROM ClientList__c ' +
            			' WHERE Id != \'\' AND Type__c != \'Personal\' ';
        List<Store__c> storesList = [SELECT Region__c,Country__c,SourceStoreId__c FROM Store__c WHERE SourceStoreId__c = :storeCode LIMIT 1];
        String perimeterCond = '';
        if(storesList.size() > 0) {
            Store__c store = storesList[0];
            perimeterCond += !String.isEmpty(store.Region__c) ? ' AND (Region__c = \'\' OR Region__c INCLUDES (\'' + store.Region__c + '\'))' : ' AND (Region__c = \'\')';
            perimeterCond += !String.isEmpty(store.Country__c) ? ' AND (Country__c = \'\' OR Country__c INCLUDES (\'' + store.Country__c + '\'))' : ' AND (Country__c = \'\')';
            perimeterCond += !String.isEmpty(store.SourceStoreId__c) ? ' AND (Stores__c = \'\' OR Stores__c INCLUDES (\'' + store.SourceStoreId__c + '\'))' : ' AND (Stores__c = \'\')';
        }
        else {
            perimeterCond += ' AND (Region__c = \'\')';
            perimeterCond += ' AND (Country__c = \'\')';
            perimeterCond += ' AND (Stores__c = \'\')';
        }

        query += perimeterCond;
        
        if(clientListId != null){
            query += ' AND Id = \'' + clientListId + '\' ';
        }
        else if (String.isEmpty(clientListId)) {
            List<String> memberdListIds = new List<String>();
            for(AggregateResult ar : [SELECT ClientList__c clientListId 
                                    FROM ClientListMember__c 
                                    WHERE ClientList__r.Type__c = 'Membered' AND ClientList__r.IsActive__c = TRUE AND 
                                        (ClientList__r.StartDate__c <= TODAY OR ClientList__r.StartDate__c = NULL) AND 
                                        (ClientList__r.EndDate__c >= TODAY OR ClientList__r.EndDate__c = NULL) AND 
                                        Client__r.ClientAdvisor__pc = :UserInfo.getUserId() 
                                    GROUP BY ClientList__c ]) {
                memberdListIds.add((String)ar.get('clientListId'));
            }
            query += ' AND (Type__c != \'Membered\' OR (Type__c = \'Membered\' AND Id IN (\'' + String.join(memberdListIds, '\',\'') +'\'))) ';
        }
        if(!isManager){
            query += ' AND IsManagerList__c = false ';
        }

        System.debug('queryyyy '+ query);
        return Database.query(query);
    }
//------------------------------------END   GET Client List------------------------------------------------------------------------

    public class ClientListWrapper{
        public String id {get;set;}
        public String name {get;set;}
        public String createdDate {get;set;}
        public DateTime modifiedDate {get;set;}
        public String listDescription {get;set;}
        public Decimal position {get;set;}
        public String ownerId {get;set;}
        public String type {get;set;}
        public Boolean isStaticList {get; set;}
        public Boolean displayToReachOutContactedSection {get; set;}
        public Integer contactedSectionDisplayPeriod {get; set;}
        public Boolean isDarkText {get;set;}
        public Boolean ascendant {get;set;}
        public String orderBy {get;set;}
        public string displayType {get;set;}
        public string specificFieldDisplay {get; set;}
        public string specificFieldDisplayLabel {get; set;}
        public Set<Id> clientIds {get;set;}
        public List<Map<String,Object>> membersWithStatus {get;set;}

        public ClientListWrapper(ClientList__c clientList, Set<Id> clientIds, List<Map<String,Object>> membersWithStatus){
            this(clientList, clientIds);
            this.membersWithStatus = membersWithStatus;
        }

        public ClientListWrapper(ClientList__c clientList, Set<Id> clientIds){
            this(clientList);
            this.clientIds = clientIds;
        }

        public ClientListWrapper(ClientList__c clientList){
            this.id = clientList.Id;
            this.isStaticList = clientList.StaticList__c;
            this.displayToReachOutContactedSection = clientList.DisplayToReachOutContactedSection__c;
            this.contactedSectionDisplayPeriod = (Integer)clientList.ContactedSectionDisplayPeriod__c;
            this.isDarkText = clientList.IsDarkText__c;
            this.orderBy = clientList.OrderBy__c;
            this.ascendant = clientList.Ascendant__c;
            this.displayType = clientList.DisplayType__c;
            this.specificFieldDisplay = clientList.SpecificFieldDisplay__c;
            this.specificFieldDisplayLabel = clientList.SpecificFieldDisplayLabel__c;
            this.position = clientList.position__c;
            this.name = clientList.Name;
            this.listDescription = clientList.Description__c;
            this.ownerId = clientList.OwnerId;
            this.type = clientList.Type__c;
            this.createdDate = clientList.CreatedDate.format('yyyy-MM-dd');
            this.modifiedDate = clientList.LastModifiedDate;


            if (!clientList.Client_List_Translations__r.isEmpty()){
                this.listDescription = clientList.Client_List_Translations__r.get(0).Description__c;
                this.name = clientList.Client_List_Translations__r.get(0).Title__c;
            }
        }
    }
}