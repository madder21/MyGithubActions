public with sharing class UpdateHubHandleController {
    @AuraEnabled(cacheable=true)
    public static String getUserHubHandle() {
        Id userId = UserInfo.getUserId();
        User currentUser = [SELECT Hub__c FROM User WHERE Id = :userId LIMIT 1];
        return currentUser.Hub__c;
    }
}