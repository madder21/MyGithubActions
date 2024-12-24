/***********************************
 * 
 * Creation date : 05/01/2024
 * Created By : JBR
 * Company : Vo2-Group
 * 
 * Date        | By                   | Company        | Modifications description
 * ------------|----------------------|----------------|-------------------------
 * 05/01/2024  | Julien Breuleux      | Vo2-Group      | Initial Creation
 * 
 * Description : 
 *       * Called in changeCaseOwner LWC to update the case Owner / Status / Hub Handle.
 *		 * Allow SFSC user to by pass Sharing settings and Roles, in order to update and take ownership of cases.
 * 
************************************/


public without sharing class CaseOwnerChanger {

    @AuraEnabled
    public static void changeCaseOwner(Id caseId) {
        // Check if the record Id is a Case Id
        if (String.valueOf(caseId).startsWith('500')) {
            try {
                // Get the current Case
                Case caseToUpdate = [SELECT Id, OwnerId, Status FROM Case WHERE Id = :caseId LIMIT 1];

                // Retrieve the Hub handle of the current user
                String userHubHandle = getUserHubHandle();

                // Logic to use the Hub handle, e.g., update a custom field on the Case
                caseToUpdate.HUB_Handle__c = userHubHandle;

                // Update case owner
                caseToUpdate.OwnerId = UserInfo.getUserId();

                // Update the case status only if it's new
                if (caseToUpdate.Status == 'New') {
                    caseToUpdate.Status = 'Working';
                }
                
                update caseToUpdate;
            } catch (Exception e) {
                throw new AuraHandledException('An error occurred when trying to change the case owner: ' + e.getMessage());
            }
        } else {
            throw new AuraHandledException('The recordId is not a Case Id');
        }
    }

    private static String getUserHubHandle() {
        Id userId = UserInfo.getUserId();
        User currentUser = [SELECT Hub__c FROM User WHERE Id = :userId LIMIT 1];
        return currentUser.Hub__c;
    }
}