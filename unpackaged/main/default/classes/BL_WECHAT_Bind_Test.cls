@isTest
public class BL_WECHAT_Bind_Test {

    @isTest
    static void test_bindExecutePost() {

        try{
            Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            User u = new User();
            u.UserName = '' + UserInfo.getOrganizationId() + System.now().millisecond() + 'test@rimowa.com';
            u.Email ='test@rimowa.com';
            u.LastName = 'test';
            u.ProfileId = sysAdmin.Id;
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.EmailEncodingKey = 'UTF-8';
            u.Alias = 'user4t_';
            u.StoreCode__c = 'FR01';
            u.StaffCode__c = '';
            u.WeChat_Work_User_Id__c = 'memberId1234';
            insert u;
    
            System.runAs(u){
                BL_WECHAT_Bind blRequest = new BL_WECHAT_Bind();
                RestRequest req = new RestRequest();
                req.requestURI = 'wechat/v0/externalcontact/bind';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf('{ "last_name":"test","memberid": "USER1234","union_id": "testSarahUnionid3","externalid": "accExternalId123","phone":"0123456789"}');
                RestContext.request = req;
                blRequest.init('wechat/v0/externalcontact/bind',  '/externalcontact/bind', null);
                Map<String,Object> data = new Map<String,Object>{
                    'last_name'=>'test',
                    'union_id'=>'testSarahUnionid3',
                    'externalid'=>'accExternalId123',
                    'storeCode'=>'FR01',
                    'country_code'=>'0033',
                    'mobile'=>'741791080'
                };
                System.debug('my data ->>'+data);
                Account myClient;
                myClient = BL_WECHAT_Utils.createWeChatAccount(data);
                myClient.wechat_external_id__c = 'accExternalId123';
                System.debug('my client ->>'+myClient);
                BL_WECHAT_Utils.upsertClient(myClient);
        
                Object o = blRequest.executePOST();
            }
        }catch(Exception ex){
            System.debug('ex -->>'+ex);
        }
        
    }

    // @isTest
    // static void test_bind2() {

    //     BL_WECHAT_Bind blRequest = new BL_WECHAT_Bind();
    //     RestRequest req = new RestRequest();
    //     req.requestURI = 'wechat/v0/externalcontact/bind';
    //     req.httpMethod = 'POST';
    //     req.requestBody = Blob.valueOf('{ "last_name":"test","memberid": "USER1234","union_id": "testSarahUnionid3","externalid": "aerytreointreghjgffmhgf","phone":"0123456789"}');
    //     RestContext.request = req;
    //     blRequest.init('wechat/v0/externalcontact/bind',  '/externalcontact/bind', null);
    //     Map<String,Object> data = new Map<String,Object>{
    //         'last_name'=>'',
    //         'union_id'=>'testSarahUnionid3',
    //         'externalid'=>'aerytreointreghjgffmhgf',
    //         'storeCode'=>'FR01',
    //         'country_code'=>'0033',
    //         'mobile'=>'741791080'
    //     };
    //     System.debug('my data ->>'+data);
    //     Account myClient;
    //     myClient = BL_WECHAT_Utils.createWeChatAccount(data);
    //     System.debug('my client ->>'+myClient);
    //     BL_WECHAT_Utils.upsertClient(myClient);


    //     Object o = blRequest.executePOST();

    // }

    @isTest
    static void test_bindExecuteDelete() {
        
		Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
		User u = new User();
		u.UserName = '' + UserInfo.getOrganizationId() + System.now().millisecond() + 'test@rimowa.com';
		u.Email ='test@rimowa.com';
		u.LastName = 'test';
		u.ProfileId = sysAdmin.Id;
		u.LocaleSidKey = 'en_US';
		u.LanguageLocaleKey = 'en_US';
		u.TimeZoneSidKey = 'GMT';
		u.EmailEncodingKey = 'UTF-8';
		u.Alias = 'user4t_';
		u.StoreCode__c = 'FR01';
        u.StaffCode__c = '';
        u.WeChat_Work_User_Id__c = 'memberId1234';
		insert u;

        System.runAs(u){
            // Account acc = new Account();
            // acc.Salutation = '02';    
            // acc.FirstName = 'firstName';
            // acc.LastName = 'lastName';
            // acc.wechat_union_id__c='testEliUnionid123';
            // acc.wechat_external_id__c='testblabla';
            // insert acc;

            Map<String,Object> data = new Map<String,Object>{
                'last_name'=>'test',
                'union_id'=>'testSarahUnionid3',
                // 'externalid'=>'aerytreointreghjgffmhgf',
                'storeCode'=>'FR01',
                'country_code'=>'0033',
                'mobile'=>'741791080'
            };
            System.debug('my data ->>'+data);
            Account acc;
            acc = BL_WECHAT_Utils.createWeChatAccount(data);
            acc.wechat_external_id__c = 'accExternalId123';
            System.debug('my client ->>'+acc);
            BL_WECHAT_Utils.upsertClient(acc);
            System.debug('my client after upsert in delete -->> '+acc);
            Account acc2 = [select id, LastName from Account where wechat_union_id__c = 'testSarahUnionid3'];
            System.debug('my client acc2-->> '+acc2);

            Map<String,Object> dataToBind = new Map<String,Object>{
                'clientid' => acc.Id,
                'memberid'=> u.WeChat_Work_User_Id__c,
                'id'=> u.Id
            };
            WeChat_SA_Client__c bind = new WeChat_SA_Client__c();
            bind.SA__c = u.Id;
            bind.Client__c =acc.Id;
            insert bind;
            
            BL_WECHAT_Bind blRequest = new BL_WECHAT_Bind();
            RestRequest req = new RestRequest();
            req.requestURI = 'wechat/v0/externalcontact/bind';
            req.httpMethod = 'DELETE';
            Map<String, String> parameters =  new  Map<String, String>();
            parameters.put('union_id', acc.wechat_union_id__c);
            parameters.put('externalid', acc.wechat_external_id__c);
            parameters.put('memberid', u.WeChat_Work_User_Id__c);
            req.params.putAll(parameters);
            System.debug('req params -->> '+req.params);
            RestContext.request = req;
            blRequest.init('wechat/v0/externalcontact/bind',  '/externalcontact/bind', null);
     
            Object o = blRequest.executeDELETE();
       }
    }

    @isTest
    static void test_bindExecuteDelete2() {
        try{
            Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            
            User u = new User();
            u.UserName = '' + UserInfo.getOrganizationId() + System.now().millisecond() + 'test@rimowa.com';
            u.Email ='test@rimowa.com';
            u.LastName = 'test';
            u.ProfileId = sysAdmin.Id;
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.EmailEncodingKey = 'UTF-8';
            u.Alias = 'user4t_';
            u.StoreCode__c = 'FR01';
            u.StaffCode__c = '';
            u.WeChat_Work_User_Id__c = 'memberId1234';
            insert u;
    
            System.runAs(u){
                // Account acc = new Account();
                // acc.Salutation = '02';    
                // acc.FirstName = 'firstName';
                // acc.LastName = 'lastName';
                // acc.wechat_union_id__c='testEliUnionid123';
                // acc.wechat_external_id__c='testblabla';
                // insert acc;
    
                Map<String,Object> data = new Map<String,Object>{
                    'last_name'=>'test',
                    'union_id'=>'testSarahUnionid3',
                    // 'externalid'=>'aerytreointreghjgffmhgf',
                    'storeCode'=>'FR01',
                    'country_code'=>'0033',
                    'mobile'=>'741791080'
                };
                System.debug('my data ->>'+data);
                Account acc;
                acc = BL_WECHAT_Utils.createWeChatAccount(data);
                acc.wechat_external_id__c = 'accExternalId123';
                System.debug('my client ->>'+acc);
                BL_WECHAT_Utils.upsertClient(acc);
                System.debug('my client after upsert in delete -->> '+acc);
                Account acc2 = [select id, LastName from Account where wechat_union_id__c = 'testSarahUnionid3'];
                System.debug('my client acc2-->> '+acc2);
    
                Map<String,Object> dataToBind = new Map<String,Object>{
                    'clientid' => acc.Id,
                    'memberid'=> u.WeChat_Work_User_Id__c,
                    'id'=> u.Id
                };
                WeChat_SA_Client__c bind = new WeChat_SA_Client__c();
                bind.SA__c = u.Id;
                bind.Client__c =acc.Id;
                insert bind;
                
                BL_WECHAT_Bind blRequest = new BL_WECHAT_Bind();
                RestRequest req = new RestRequest();
                req.requestURI = 'wechat/v0/externalcontact/bind';
                req.httpMethod = 'DELETE';
                Map<String, String> parameters =  new  Map<String, String>();
                parameters.put('union_id', acc.wechat_union_id__c);
                parameters.put('externalid', acc.wechat_external_id__c);
                // parameters.put('memberid', u.WeChat_Work_User_Id__c);
                req.params.putAll(parameters);
                RestContext.request = req;
                blRequest.init('wechat/v0/externalcontact/bind',  '/externalcontact/bind', null);
         
                Object o = blRequest.executeDELETE();
           }
        } catch(Exception ex){
            System.debug('ex -->>'+ex);
        }
    }
    @isTest
    static void test_bindExecuteDelete3() {
        try{
            Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            
            User u = new User();
            u.UserName = '' + UserInfo.getOrganizationId() + System.now().millisecond() + 'test@rimowa.com';
            u.Email ='test@rimowa.com';
            u.LastName = 'test';
            u.ProfileId = sysAdmin.Id;
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.EmailEncodingKey = 'UTF-8';
            u.Alias = 'user4t_';
            u.StoreCode__c = 'FR01';
            u.StaffCode__c = '';
            u.WeChat_Work_User_Id__c = 'memberId1234';
            insert u;
    
            System.runAs(u){
                // Account acc = new Account();
                // acc.Salutation = '02';    
                // acc.FirstName = 'firstName';
                // acc.LastName = 'lastName';
                // acc.wechat_union_id__c='testEliUnionid123';
                // acc.wechat_external_id__c='testblabla';
                // insert acc;
    
                Map<String,Object> data = new Map<String,Object>{
                    'last_name'=>'test',
                    'union_id'=>'testSarahUnionid3',
                    // 'externalid'=>'aerytreointreghjgffmhgf',
                    'storeCode'=>'FR01',
                    'country_code'=>'0033',
                    'mobile'=>'741791080'
                };
                System.debug('my data ->>'+data);
                Account acc;
                acc = BL_WECHAT_Utils.createWeChatAccount(data);
                acc.wechat_external_id__c = 'accExternalId123';
                System.debug('my client ->>'+acc);
                BL_WECHAT_Utils.upsertClient(acc);
                System.debug('my client after upsert in delete -->> '+acc);
                Account acc2 = [select id, LastName from Account where wechat_union_id__c = 'testSarahUnionid3'];
                System.debug('my client acc2-->> '+acc2);
    
                Map<String,Object> dataToBind = new Map<String,Object>{
                    'clientid' => acc.Id,
                    'memberid'=> u.WeChat_Work_User_Id__c,
                    'id'=> u.Id
                };
                WeChat_SA_Client__c bind = new WeChat_SA_Client__c();
                bind.SA__c = u.Id;
                bind.Client__c =acc.Id;
                insert bind;
                
                BL_WECHAT_Bind blRequest = new BL_WECHAT_Bind();
                RestRequest req = new RestRequest();
                req.requestURI = 'wechat/v0/externalcontact/bind';
                req.httpMethod = 'DELETE';
                Map<String, String> parameters =  new  Map<String, String>();
                parameters.put('union_id', acc.wechat_union_id__c);
                parameters.put('externalid', acc.wechat_external_id__c);
                parameters.put('memberid', 'falseMemberId');
                req.params.putAll(parameters);
                RestContext.request = req;
                blRequest.init('wechat/v0/externalcontact/bind',  '/externalcontact/bind', null);
         
                Object o = blRequest.executeDELETE();
           }
        } catch(Exception ex){
            System.debug('ex -->>'+ex);
        }
    }
}