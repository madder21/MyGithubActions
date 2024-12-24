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
 *       * Test class for SFSC_AccountMatchingQueryInvocable_SVE.
 *       * Ensures the functionality for querying Account records based on dynamic criteria works as expected.
 * 
************************************/
@isTest
public class SFSC_AccountMatchingQueryInvocable_Test {
    @isTest
    static void testRunProcess() {
        // Create test data
        Account testAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '1234567890',
            Phone2__pc = '0987654321',
            Phone3__pc = '1112233445',
            OtherEmail__pc = 'john.other@example.com',
            PersonEmail = 'john.doe@example.com'
        );
        insert testAccount;

        SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput input = new SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput();
        input.customerFirstName = 'John';
        input.customerLastName = 'Doe';
        input.customerPhone = '1234567890';
        input.customerEmail = 'john.doe@example.com';

        List<SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput> inputList = new List<SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput>();
        inputList.add(input);

        Test.startTest();
        List<List<Account>> result = SFSC_AccountMatchingQueryInvocable_SVE.runProcess(inputList);
        Test.stopTest();

        // Perform assertions to validate the results
        System.assert(!result.isEmpty(), 'Result should not be empty.');
        List<Account> accounts = result[0];
        System.assert(!accounts.isEmpty(), 'Account list should not be empty.');

        // Add more assertions to validate the data as needed
        for (Account acc : accounts) {
            System.assertEquals('John', acc.FirstName);
            System.assertEquals('Doe', acc.LastName);
            System.assertEquals('1234567890', acc.Phone);
            System.assertEquals('john.doe@example.com', acc.PersonEmail);
        }
    }

    @isTest
    static void testRunProcessWithNoConditions() {
        SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput input = new SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput();

        List<SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput> inputList = new List<SFSC_AccountMatchingQueryInvocable_SVE.CaseProcessInput>();
        inputList.add(input);

        Test.startTest();
        List<List<Account>> result = SFSC_AccountMatchingQueryInvocable_SVE.runProcess(inputList);
        Test.stopTest();

        // Perform assertions to validate the results
        System.assert(!result.isEmpty(), 'Result should not be empty.');
        List<Account> accounts = result[0];
        System.assert(accounts.isEmpty(), 'Account list should be empty when no conditions are provided.');
    }

    // Add more test methods to cover additional scenarios and edge cases

}