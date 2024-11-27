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
 *       * Data factory used for test clases
 * 
************************************/

@isTest
public class DataFactoryForTests {

    //Create test User
    public static User createTestUser(string name){
        User testUser = new User(
            LastName = name,
            Alias = 'test',
            Username = 'test_' + DateTime.now().getTime() + '@test.com',
            FirstName = 'Test',
            Email = 'test@rimowa.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CS - Advisor' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Hub__c = 'EU'
        );
        insert testUser;
        return testUser;
    }
    
    //Create Case
    public static Case createCase(){
        Case testCase = new Case(
        	Status = 'New',
            Subject = 'Subject test',
            Description = 'Description Test',
            Origin = 'Email',
            Type = 'To Qualify',
            Activity__c = 'CS',
            Hub_Origin__c = 'AUS',
            HUB_Handle__c = '00',
            SuppliedEmail = 'Test@test.com',
            SuppliedName = 'Test Test'
        );
        insert testCase;
        return testCase;
    }
    
}