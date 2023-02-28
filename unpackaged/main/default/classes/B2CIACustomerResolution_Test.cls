/**
 * @author Eric Schultz
 * @date Feb 27, 2020
 *
 * @see B2CIACustomerResolution.resolve
 * @description This testClass is used to exercise different customerResolution
 * scenarios driven by Contact details.
 * @V0 : B2C Eric Shcultz package
 * @V1.0 : Viseo integration by Mohamed Abdelfadel 
 * @V2.0 : Modified by Abdelkhaled SAIDI
 * @V2.0 : date : February 17th, 2023
 * @V2.0 : Modifications : Review of all test cases to take care of the business matching rule : FirstName+LastName+ContactInformations + Upgrade Version 57
 */
@IsTest
private class B2CIACustomerResolution_Test {

    // Initialize the test variables describing contact attributes
    public static String testCustomerListID1 = 'customerList1';
    public static String testCustomerListID2 = 'customerList2';
    public static String testCustomerListID3 = 'customerList3';
    public static String testCustomerListID4 = 'customerList4';
    public static String testCustomerListID5 = 'customerList5';

    public static String testCustomerID1 = 'customerId1';
    public static String testCustomerID2 = 'customerId2';
    public static String testCustomerID3 = 'customerId3';
    public static String testCustomerID4 = 'customerId4';
    public static String testCustomerID5 = 'customerId5';

    public static String testEmail1 = 'test@one.user.com';
    public static String testEmail2 = 'test@two.user.com';
    public static String testEmail3 = 'test@three.user.com';

    public static String testCustomerNo1 = 'customerNo1';
    public static String testCustomerNo2 = 'customerNo2';
    public static String testCustomerNo3 = 'customerNo3';
    public static String testCustomerNo4 = 'customerNo4';
    public static String testCustomerNo5 = 'customerNo5';

    public static String testLastName1 = 'LastName1';
    public static String testLastName2 = 'LastName2';
    public static String testLastName3 = 'LastName3';
    public static String testLastName4 = 'LastName4';
    public static String testLastName5 = 'LastName5';
    public static String testLastName6 = 'LastName6';
    public static String testLastName7 = 'LastName7';

    // these variables added because the matching logic was changed 
    public static String testPhone1 = '+1 123456789';
    public static String testPhone2 = '+2 123456789';
    public static String testPhone3 = '+3 123456789';
    public static String testPhone4 = '+4 123456789';
    public static String testPhone5 = '+5 123456789';
    public static String testPhone6 = '+6 123456789';
    public static String testPhone7 = '+7 123456789';
    public static String testPhone8 = '+8 123456789';
    public static String testPhone9 = '+9 123456789';

    public static String testFirstName1 = 'FirstName1';
    public static String testFirstName2 = 'FirstName2';
    public static String testFirstName3 = 'FirstName3';
    public static String testFirstName4 = 'FirstName4';
    public static String testFirstName5 = 'FirstName5';
    public static String testFirstName6 = 'FirstName6';
    public static String testFirstName7 = 'FirstName7';


    

    /**
     * @description Setup method that creates the customerList record(s) required to support testing.
     */
    @TestSetup static void setup() {

        // Setup a single customerList we can use for testing / validation
        B2C_CustomerList__c customerList1 = (B2C_CustomerList__c)TestDataFactory.createSObject('B2C_CustomerList__c', new Map<String,Object>{
            'Name' => 'customerList1',
            'Is_Active__c' => true,
            'API_Url__c' => 'https://www.salesforce.com',
            'B2C_Instance__r.Is_Active__c' => true,
            'B2C_Instance__r.API_Url__c' => 'https://www.salesforce.com',
            'Enable_Profile_Publishing__c' => true,
            'Enable_Profile_Creation__c' => true
        });

        // Setup a second customerList for testing / validation
        B2C_CustomerList__c customerList2 = (B2C_CustomerList__c)TestDataFactory.createSObject('B2C_CustomerList__c', new Map<String,Object>{
            'Name' => 'customerList2',
            'Is_Active__c' => true,
            'API_Url__c' => 'https://www.salesforce.com',
            'B2C_Instance__r.Is_Active__c' => true,
            'B2C_Instance__r.API_Url__c' => 'https://www.salesforce.com',
            'Enable_Profile_Publishing__c' => true,
            'Enable_Profile_Creation__c' => true
        });

        // Setup a third customerList for testing / validation
        B2C_CustomerList__c customerList3 = (B2C_CustomerList__c)TestDataFactory.createSObject('B2C_CustomerList__c', new Map<String,Object>{
            'Name' => 'customerList3',
            'Is_Active__c' => true,
            'API_Url__c' => 'https://www.salesforce.com',
            'B2C_Instance__r.Is_Active__c' => true,
            'B2C_Instance__r.API_Url__c' => 'https://www.salesforce.com',
            'Enable_Profile_Publishing__c' => true,
            'Enable_Profile_Creation__c' => true
        });

        // Setup a third customerList for testing / validation
        B2C_CustomerList__c customerList4 = (B2C_CustomerList__c)TestDataFactory.createSObject('B2C_CustomerList__c', new Map<String,Object>{
            'Name' => 'customerList4',
            'Is_Active__c' => true,
            'API_Url__c' => 'https://www.salesforce.com',
            'B2C_Instance__r.Is_Active__c' => true,
            'B2C_Instance__r.API_Url__c' => 'https://www.salesforce.com',
            'Enable_Profile_Publishing__c' => true,
            'Enable_Profile_Creation__c' => true
        });

        // Setup a third customerList for testing / validation
        B2C_CustomerList__c customerList5 = (B2C_CustomerList__c)TestDataFactory.createSObject('B2C_CustomerList__c', new Map<String,Object>{
            'Name' => 'customerList5',
            'Is_Active__c' => true,
            'API_Url__c' => 'https://www.salesforce.com',
            'B2C_Instance__r.Is_Active__c' => true,
            'B2C_Instance__r.API_Url__c' => 'https://www.salesforce.com',
            'Enable_Profile_Publishing__c' => true,
            'Enable_Profile_Creation__c' => true
        });
        
        Contact contact1 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'Email' => testEmail1,
            'LastName' => testLastName1,
            'FirstName' => testFirstName1
        });

        Contact contact2 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'Phone' => testPhone2,
            'LastName' => testLastName2,
            'FirstName' => testFirstName2
        });

        Contact contact3 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'B2C_CustomerList_ID__c' => testCustomerListID3,
            'B2C_Customer_ID__c' => testCustomerID3,
            'B2C_Customer_No__c' => testCustomerNo3,
            'Email' => testEmail3,
            'LastName' => testLastName3,
            'FirstName' => testFirstName3
        });
        
        Contact contact4 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'Phone' => testPhone3,
            'LastName' => testLastName3,
            'FirstName' => testFirstName3
        });

        Contact contact5 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'B2C_CustomerList_ID__c' => testCustomerListID1,
            'B2C_Customer_ID__c' => testCustomerID1,
            'B2C_Customer_No__c' => testCustomerNo1,
            'Phone' => testPhone4,
            'LastName' => testLastName4,
            'FirstName' => testFirstName4
        });

        Contact contact6 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'B2C_CustomerList_ID__c' => testCustomerListID2,
            'B2C_Customer_ID__c' => testCustomerID2,
            'B2C_Customer_No__c' => testCustomerNo2,
            'Phone' => testPhone5,
            'LastName' => testLastName3,
            'FirstName' => testFirstName5
        });

        Contact contact7 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'B2C_CustomerList_ID__c' => testCustomerListID4,
            'B2C_Customer_ID__c' => testCustomerID4,
            'B2C_Customer_No__c' => testCustomerNo4,
            'Phone' => testPhone6,
            'LastName' => testLastName1,
            'FirstName' => testFirstName5
        });

        Contact contact8 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'B2C_CustomerList_ID__c' => testCustomerListID5,
            'B2C_Customer_ID__c' => testCustomerID5,
            'B2C_Customer_No__c' => testCustomerNo5,
            'Phone' => testPhone7,
            'LastName' => testLastName5,
            'FirstName' => testFirstName5
        });

        Contact contact9 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'Phone' => testPhone8,
            'LastName' => testLastName6,
            'FirstName' => testFirstName6
        });

        Contact contact10 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'Phone' => testPhone9,
            'LastName' => testLastName7,
            'FirstName' => testFirstName7
        });



        List<Contact> contactListToUpdate1 = new List<Contact>();
        for (Contact aContact : [SELECT Id, Phone, FirstName FROM Contact WHERE FirstName =:testFirstName5]) {
            contactListToUpdate1.add(new Contact(Id = aContact.Id, LastName =testLastName5, Phone =testPhone5));
        }
        upsert contactListToUpdate1;

        List<Contact> contactListToUpdate2 = new List<Contact>();
        for (Contact aContact : [SELECT Id, Phone, FirstName, LastName FROM Contact WHERE Phone =:testPhone9]) {
            contactListToUpdate2.add(new Contact(Id = aContact.Id, LastName =testLastName6, FirstName =testFirstName6, Phone =testPhone8));
        }
        upsert contactListToUpdate2;

    }


    /**
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * 
     */
    @IsTest
    private static void testResolveByNoMatchedEmailMatchedB2CIDZeroResult() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact testContact;
        
        // Define the Contact record to resolve
        testContact = new Contact(
            Email = testEmail2,
            LastName = testLastName1,
            FirstName = testFirstName1
        );

        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution_TestHelper.executeResolutionProcess(testContact);

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();

        // Validate the zero-result
        System.assert(((List <Contact>) flowResults.get('contactResolvedList')).size()==0, 'Expected to return zero result');

    }

    /**
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * 
     */
    @IsTest
    private static void testResolveByNoMatchedFirstNameAndLastNameNoMatchedB2CIDZeroResult() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact testContact;

        // Define the Contact record to resolve
        testContact = new Contact(
            Email = testEmail1,
            LastName = testLastName2,
            FirstName = testFirstName3
        );

        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution_TestHelper.executeResolutionProcess(testContact);

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();

        // Validate the zero-result details
        System.assert(((List <Contact>) flowResults.get('contactResolvedList')).size()==0, 'Expected to return zero result');

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record 
     */
    @IsTest
    private static void testResolveByMatchedLastNameFirstNameEmailNoMatchedB2CIDOneResultFromOne() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact testContact;

        // Define the Contact record to resolve
        testContact = new Contact(
            Email = testEmail1,
            LastName = testLastName1,
            FirstName = testFirstName1
        );

        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution_TestHelper.executeResolutionProcess(testContact);

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();

        // Validate the one result from one &
        List<Contact> conList = (List<Contact>) flowResults.get('contactResolvedList');
        System.assert(conList.get(0).Id == [select Id From contact where Email=:testContact.Email].Id, 'Not Expected record to return');
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, testContact);

    }

    /** a completed !!
     * @see B2CIACustomerResolution.findDupes
     * @description 
     */
    @IsTest
    private static void testResolveByMatchedFirstNameLastNamePhoneNoMatchedB2CIDOneResultFromOne() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact testContact;

        // Define the Contact record to resolve
        testContact = new Contact(
            Phone = testPhone2,
            LastName = testLastName2,
            FirstName = testFirstName2
        );

        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution_TestHelper.executeResolutionProcess(testContact);

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();
        

        // Validate the single result &
        List<Contact> conList = (List<Contact>) flowResults.get('contactResolvedList');
        System.assert(conList.get(0).Id == [select Id From contact where Phone=:testContact.Phone].Id, 'Not Expected record to return');
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, testContact);
        

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * 
     */
    @IsTest
    private static void testResolveByMatchedLastNameFirstNameEmailMatchedB2CIDOneResultFromMultiple() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact testContact;

        // Define the Contact record to resolve
        testContact = new Contact(
            Phone = testPhone3,
            Email = testEmail3,
            LastName = testLastName3,
            FirstName = testFirstName3
        );
        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution_TestHelper.executeResolutionProcess(testContact);

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();

        // Validate the single result &
        List<Contact> conList = (List<Contact>) flowResults.get('contactResolvedList');
        System.assert(conList.get(0).Id == [select Id, LastName, FirstName From contact where Email=:testContact.Email and LastName=:testContact.LastName and FirstName=:testContact.FirstName].Id, 'Not Expected record to return');
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, testContact);

    }

    /** a completed !!
     * @see B2CIACustomerResolution.findDupes
     * @description 
     */
    @IsTest
    private static void testResolveByMatchedFirstNameLastNamePhoneMatchedB2CIDOneResultFromOne() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact testContact;

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID1,
            B2C_Customer_ID__c = testCustomerID1,
            B2C_Customer_No__c = testCustomerNo1,
            Phone = testPhone4,
            LastName = testLastName4,
            FirstName = testFirstName4
        );

        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution_TestHelper.executeResolutionProcess(testContact);

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();

        // Validate the single result & 
        List<Contact> conList = (List<Contact>) flowResults.get('contactResolvedList');
        System.assert(conList.get(0).Id == [select Id, LastName, FirstName From contact where Phone=:testContact.Phone and LastName=:testContact.LastName and FirstName=:testContact.FirstName].Id, 'Not Expected record to return');
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, testContact);

    }

    /** a completed !!
     * @see B2CIACustomerResolution.findDupes
     * @description 
     */
    @IsTest
    private static void testResolveByMatchedFirstNameLastNamePhoneMatchedB2CIDOneResultFromMultiple() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact testContact;

        // Define the Contact record to resolve
        testContact = new Contact(
            Phone = testPhone5,
            LastName = testLastName5,
            FirstName = testFirstName5
        );
        
        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution_TestHelper.executeResolutionProcess(testContact);

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();

        // Validate the single result & 
        List<Contact> conList = (List<Contact>) flowResults.get('contactResolvedList');
        System.assertEquals(conList.get(0).Id, [select Id From contact where Phone=:testContact.Phone and LastName=:testContact.LastName and FirstName=:testContact.FirstName and B2C_CustomerList_ID__c !=null and B2C_Customer_ID__c !=null ORDER BY CreatedDate DESC LIMIT 1].Id, 'Not Expected record to be returned');
        System.assertEquals(3, [select Id, LastName, FirstName From contact where Phone=:testContact.Phone and LastName=:testContact.LastName and FirstName=:testContact.FirstName].size(), 'Expected to return exactly 3 records');
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, testContact);

    }

    /** a completed !!
     * @see B2CIACustomerResolution.findDupes
     * @description 
     */
    @IsTest
    private static void testResolveByMatchedFirstNameLastNamePhoneNoMatchedB2CIDOneResultFromMultiple() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact testContact;

        // Define the Contact record to resolve
        testContact = new Contact(
            Phone = testPhone8,
            LastName = testLastName6,
            FirstName = testFirstName6
        );
        
        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution_TestHelper.executeResolutionProcess(testContact);

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();

        // Validate the single result & 
        List<Contact> conList = (List<Contact>) flowResults.get('contactResolvedList');
        System.assertEquals(conList.get(0).Id, [select Id From contact where Phone=:testContact.Phone and LastName=:testContact.LastName and FirstName=:testContact.FirstName ORDER BY CreatedDate DESC LIMIT 1].Id, 'Not Expected record to be returned');
        System.assertEquals(2, [select Id, LastName, FirstName From contact where Phone=:testContact.Phone and LastName=:testContact.LastName and FirstName=:testContact.FirstName].size(), 'Expected to return exactly 2 records');
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, testContact);

    }

    /** a completed !!
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * 
     */
    @IsTest
    private static void testResolveError() {

        // Initialize local variables
        List<B2CIACustomerResolutionResult> flowResults;
        Contact testContact1 = new Contact();
        Contact testContact2 = new Contact();


        Test.startTest();
        //-------------------------------------------
        // Test: Start exercising the resolutionFlow
        //-------------------------------------------

            // Execute the flow results
            flowResults = B2CIACustomerResolution.resolve(new List<Contact> {testContact1,testContact2});

        //-------------------------------------------
        // Test: Finish exercising the resolutionFlow
        //-------------------------------------------
        Test.stopTest();

        // Validate the error in the input parameter
        System.assert(flowResults.get(0).isError==true, 'Not expected result');

    } 

}