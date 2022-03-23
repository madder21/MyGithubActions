global with sharing class BL_WECHAT_Follow extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST{ 

    /*
       Merge according the Union Id
       or Create basic data: Lastname => 'NEW WECHAT'
   */
    global Object executePOST() { 
        try{

            String unionid = (String) requestBody.get('unionid');
    
            Account client;
            client = BL_WECHAT_Utils.createWeChatAccount(requestBody);
            client.NewWeChatClient__c = true;
    
            BL_WECHAT_Utils.upsertClient(client);
            BL_WECHAT_Utils.createWeChatClientAddress(requestBody, client.id);
            return BL_WECHAT_Utils.getClient(client.Id);
        }
        catch(Exception ex){
            return ex;
        }
    }
}