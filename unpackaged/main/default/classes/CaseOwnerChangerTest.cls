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
 *       * Test classe to test the CaseOwnerChanger apex method.
 * 
************************************/

@isTest
public class CaseOwnerChangerTest {

    @isTest
    static void testChangeCaseOwner(){
    User testUser = DataFactoryForTests.createTestUser('test');
    Case testCase = DataFactoryForTests.createCase();
    
        // Run as a specific user
        System.runAs(testUser) {
            // Call the method to test
            Test.startTest();
            CaseOwnerChanger.changeCaseOwner(testCase.Id);
            Test.stopTest();
            
            // Retrieve the updated case
            Case updatedCase = [SELECT OwnerId, Status, HUB_Handle__c FROM Case WHERE Id = :testCase.Id];
            
            // Assert the case owner is changed to the test user
            System.assertEquals(testUser.Id, updatedCase.OwnerId, 'The case owner should be updated to the test user.');
            
            // Assert the case status is updated to 'Working'
            System.assertEquals('Working', updatedCase.Status, 'The case status should be updated to Working.');
            
            // Assert the HUB_Handle__c field is updated
            System.assertEquals(testUser.Hub__c, updatedCase.HUB_Handle__c, 'The HUB_Handle__c field should be updated.');
        }
    }
    
}