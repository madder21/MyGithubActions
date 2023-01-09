global with sharing class CLT_ClientList implements CLT_RetailInterface{
    public Object retrieveDelete(Map<String, String> params){
        return null;
    }

    global Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    global Object retrieveGet(Map<String, String> params){
        return getClientLists((String)params.get('Type'));
    }

//------------------------------------START GET Client List------------------------------------------------------------------------

    Map<String, Object> getClientLists(String clientListId){
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
    
            if(!String.isEmpty(clientList.clientListQuery__c) || clientList.Type__c == 'Membered'){
                String clientsQuery = CLT_Utils_Query.getClientsQuery(false, false) + CLT_Utils_ClientLists.buildDynamicQuery(clientList, userId, storeCode, isSpecificClientList);
//                String clientsQuery = 'SELECT Id From Account WHERE ID != \'\' ' + CLT_Utils_ClientLists.buildDynamicQuery(clientList, userId, storeCode);
                system.debug(clientsQuery);
                Map<Id, Account> dynamicClients = new Map<Id, Account>((List<Account>)Database.query(clientsQuery));
                clientIds.addAll(dynamicClients.keySet());
                List<Account> clientsToAdd = getClientToAdd(dynamicClients.values(), allClientIds);
                allClientIds.addAll(clientIds);
                clients.addAll((List<Object>)CLT_Utils_Mapping.getStandardWrapperListFromObjectList('Account', 'Client', clientsToAdd));
                
                clientsListWrapper.add(new ClientListWrapper(clientList, clientIds));
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
        string query = 'SELECT Id,OwnerId,Owner.FirstName,CreatedDate,Type__c,Owner.LastName,Description__c,Position__c,Name,ClientListQuery__c,InMyStore__c,StaticList__c,' +
                                'IsDarkText__c,OrderBy__c,Ascendant__c,DisplayType__c,VisibilityBasedOnField__c,SpecificFieldDisplay__c,SpecificFieldDisplayLabel__c, ' + 
                                '(SELECT Description__c,Title__c,Name FROM Client_List_Translations__r' +
                                ' WHERE Language__c = \'' + UserInfo.getLanguage() +'\' LIMIT 1)' +
                        ' FROM ClientList__c ' +
            			' WHERE Id != \'\' AND (Stores__c includes (\'' + storeCode + '\') OR Stores__c = \'\')';
        
        if(clientListId != null){
            query += ' AND Id = \'' + clientListId + '\'';
        }
        if(!isManager){
            query += 'AND IsManagerList__c = false';
        }

        System.debug('queryyyy '+ query);
        return Database.query(query);
    }
//------------------------------------END   GET Client List------------------------------------------------------------------------

    class ClientListWrapper{
        public String id {get;set;}
        public String name {get;set;}
        public String createdDate {get;set;}
        public String listDescription {get;set;}
        public Decimal position {get;set;}
        public String ownerId {get;set;}
        public String type {get;set;}
        public Boolean isStaticList {get; set;}
        public Boolean isDarkText {get;set;}
        public Boolean ascendant {get;set;}
        public String orderBy {get;set;}
        public string displayType {get;set;}
        public string specificFieldDisplay {get; set;}
        public string specificFieldDisplayLabel {get; set;}
        public Set<Id> clientIds {get;set;}
  

        ClientListWrapper(ClientList__c clientList, Set<Id> clientIds){
            this(clientList);
            this.clientIds = clientIds;
        }

        ClientListWrapper(ClientList__c clientList){
            this.id = clientList.Id;
            this.isStaticList = clientList.StaticList__c;
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
            this.createdDate = clientList.CreatedDate.format('yyyy-MM-dd');


            if (!clientList.Client_List_Translations__r.isEmpty()){
                this.listDescription = clientList.Client_List_Translations__r.get(0).Description__c;
                this.name = clientList.Client_List_Translations__r.get(0).Title__c;
            }
        }
    }
}