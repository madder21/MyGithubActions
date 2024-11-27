/***********************************
 * 
 * Creation date : 12/10/2023
 * Created By : JBR
 * Company : Vo2-Group
 * 
 * Date        | By                   | Company        | Modifications description
 * ------------|----------------------|----------------|-------------------------
 * 12/10/2023  | Julien Breuleux      | Vo2-Group      | Initial Creation
 * 
 * 
 * Description : 
 * 		 * Test class for SFSC_AccountMatchingQueryInvocable_SVE.
 * 		 * Ensures the functionality for querying Account records based on dynamic criteria works as expected.
 * 
************************************/


@isTest
public class Test_SFSC_AccountMatchingQueryInvocable {

    /**
     * Test method to validate the dynamic query construction and Account record retrieval.
     */
    @isTest 
    static void testAccountMatchingQuery() {
        // Create a test Account record
        Account testAcc = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '1234567890',
            Phone2__pc = '0987654321',
            Phone3__pc = '1112233445',
            OtherEmail__pc = 'john.other@example.com',
            PersonEmail = 'john.doe@example.com'
        );
        insert testAcc;
        
        // Prepare the input for the Invocable method
        SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput input = new SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput();
        input.customerFirstName = 'John';
        input.customerLastName = 'Doe';
        input.customerPhone = '1234567890';
        input.customerEmail = 'john.doe@example.com';
        
        // Invoke the method
        List<List<Account>> matchedAccounts = SFSC_AccountMatchingQueryInvocable_SVE.runProcess(new List<SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput>{ input });
        
        // Assert that the matched Account is the one we created
        System.assertEquals(1, matchedAccounts.size());
        System.assertEquals(1, matchedAccounts[0].size());
        System.assertEquals(testAcc.Id, matchedAccounts[0][0].Id);
    }
    
    /**
     * Test method to validate the scenario where no criteria is matched.
     */
    @isTest static void testAccountMatchingNoMatch() {
        // Prepare the input for the Invocable method with non-matching criteria
        SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput input = new SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput();
        input.customerFirstName = 'NonExistent';
        input.customerLastName = 'User';
        input.customerPhone = '9999999999';
        input.customerEmail = 'non.existent@example.com';
        
        // Invoke the method
        List<List<Account>> matchedAccounts = SFSC_AccountMatchingQueryInvocable_SVE.runProcess(new List<SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput>{ input });
        
        // Assert that no Account is returned
        System.assertEquals(1, matchedAccounts.size());
        System.assertEquals(0, matchedAccounts[0].size());
    }
}