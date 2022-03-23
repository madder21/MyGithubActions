global with sharing class BL_WECHAT_Bind extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST,BL_WS_Interfaces.DispatchableDELETE{ 

    /*
        Merge according the union id
        If no client => Create Basic Wechat Account (SA + external user Id )
        If client => merge + new relationship WeChat_SA_Client__c
    */
    global Object executePOST() {
        system.debug('enter in bind');
        String unionid = (String) requestBody.get('union_id');
        String memberid = (String) requestBody.get('memberid');
        String externalid = (String) requestBody.get('externalid');
        String phone = (String) requestBody.get('phone');
        System.debug('params post');
        System.debug('unionid post -->>'+unionid);
        System.debug('memberid post-->>'+memberid);
        System.debug('externalid post-->>'+externalid);
        System.debug('phone -->>'+phone);
        List<Account> clients ;
        
        // GET sa
        List<User> users = (List<User>) new BL_EasyQuery()
        .useCase('Me')
        .condition('WeChat_Work_User_Id__c = \'' + memberid + '\'')
        .executeQuery()
        .getSObjects();
        
        if(users.isEmpty()) {
            throw new BL_Exceptions.CLTException('unknown sa id','The sa id doesn\'t exist in Salesforce');
        }
        
        User sa = users[0];
        
        if(String.isNotEmpty(unionid)){
            // GET account
            clients = (List<Account>) new BL_EasyQuery()
            .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT)
            .condition('wechat_union_id__c = \'' + unionid + '\'')
            .executeQuery()
            .getSObjects();
        }
        else if(String.isNotEmpty(externalid)){
            System.debug('externalid post if-->>'+externalid);
            // GET account
            clients = (List<Account>) new BL_EasyQuery()
            .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT)
            .condition('wechat_external_id__c = \'' + externalid + '\'')
            .executeQuery()
            .getSObjects();
        }
        System.debug('clientsss-->>'+clients);

        Account client;
        if(clients.isEmpty()) {
            client = BL_WECHAT_Utils.createWeChatAccount(requestBody);
            client.NewWeChatClient__c = true;
        }
        else {
            //attribute to account the store of his sa
            client = (Account)BL_WECHAT_Utils.mergeWeChatAccountAndData(clients[0], requestBody);
        }
        
        client.OwnerId = sa.Id;
        
        BL_WECHAT_Utils.upsertClient(client);
        System.debug('client id after upsert'+client.Id);
        
        // Bind
        WeChat_SA_Client__c bind = (WeChat_SA_Client__c)BL_WECHAT_Utils.convertToBind(requestBody);
        System.debug('bind -->> '+bind);
        
        WeChat_SA_Client__c[] binds = [
            SELECT Id
            FROM WeChat_SA_Client__c
            WHERE Client__c = :client.Id AND SA__c = :sa.Id
            ];
            
            if(binds.isEmpty()){
            bind.Client__c = client.Id;
            bind.SA__c = sa.Id;
            Database.insert(bind, true);
        }
        else {
            bind.Id = binds[0].Id;
            Database.update(bind, true);
        }
        
        System.debug('client id before get client'+client.id);
        BL_WECHAT_Utils.createWeChatClientAddress(requestBody, client.id);
        return BL_WECHAT_Utils.getClient(client.Id);
    }


    global Object executeDELETE() {

        String unionid = (String) queryParams.get('union_id');
        String memberid = (String) queryParams.get('memberid');
        String externalid = (String) queryParams.get('externalid');
        String phone = (String) queryParams.get('phone');
        System.debug('params');
        System.debug('unionid -->>'+unionid);
        System.debug('memberid -->>'+memberid);
        System.debug('externalid -->>'+externalid);
        System.debug('phone -->>'+phone);
        
        List<Account> clients ;

        if((unionid == null || externalid ==null) && memberid == null) {
            throw new BL_Exceptions.QueryException('204', 'Body is not correct','Body is not correct');
        }
        // GET sa
        User[] users = [
            SELECT Id
            FROM User
            WHERE WeChat_Work_User_Id__c = :memberid
        ];
        if(users.isEmpty()) {
            throw new BL_Exceptions.QueryException('400', 'unknown sa id','The sa id doesn\'t exist in Salesforce');
        }
        User sa = users[0];

        // GET account
        if(String.isNotEmpty(unionid)){
            // GET account
             clients = (List<Account>) new BL_EasyQuery()
                .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT)
                .condition('wechat_union_id__c = \'' + unionid + '\'')
                .executeQuery()
                .getSObjects();
        }
        else if(String.isNotEmpty(externalid)){
            // GET account
             clients = (List<Account>) new BL_EasyQuery()
                .useCase(BL_WECHAT_Constants.USE_CASE_WECHAT_CLIENT)
                .condition('wechat_external_id__c = \'' + externalid + '\'')
                .executeQuery()
                .getSObjects();
        }

        if(clients.isEmpty()) {
            throw new BL_Exceptions.QueryException('400', 'unknown client id','The client id doesn\'t exist in Salesforce');
        }


        // Bind
        WeChat_SA_Client__c[] binds = [
            SELECT Id
            FROM WeChat_SA_Client__c
            WHERE Client__c = :clients[0].Id AND SA__c = :sa.Id
        ];

        if(binds.isEmpty()){
            throw new BL_Exceptions.QueryException('400', 'The bind id doesn\'t exist in Salesforce ','The bind id doesn\'t exist in Salesforce');
        }

        delete binds;

        return  new Map<String,String> {'message' => 'the bind is deleted' , 'statusCode'=> '200'};
    }
}