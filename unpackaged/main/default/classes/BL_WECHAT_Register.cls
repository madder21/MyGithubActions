global class BL_WECHAT_Register extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST {
    /*
        Merge according the CellPhone: phone + indicator
        Search the Basic WeChat Account according the union id and merge / delete it
    */
    global Object executePOST() {       
        Savepoint sp = Database.setSavepoint();
        Id rtId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        try 
        {
            Account client;
            client = BL_WECHAT_Utils.createWeChatAccount(requestBody);
            
            // Fields
            client.wechat_digitalcard__c = true;
            client.NewWeChatClient__c = false;
            
            // Upsert
            BL_WECHAT_Utils.upsertClient(client);
            //Create and upsert the address
            BL_WECHAT_Utils.createWeChatClientAddress(requestBody, client.Id);

            return BL_WECHAT_Utils.getClient(client.Id);
        }
        catch(Exception ex){
            Database.rollback(sp);
            throw new BL_Exceptions.CLTException(ex.getMessage(), ex.getMessage());
        }
    }  
}