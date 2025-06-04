public with sharing class CLT_Users  implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return null;
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return updateUser(body);
    }

    public Object retrieveGet(Map<String, String> params){
        return null;
    }

    public User updateUser(Map<String,Object> body) {
        String mutedNotifications = JSON.serialize(body.get('mutedNotifications'));
        
        User u = [SELECT Id,MutedNotifications__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        u.MutedNotifications__c = mutedNotifications;
       
        Database.upsert(u, true);
        return u;
    }
}