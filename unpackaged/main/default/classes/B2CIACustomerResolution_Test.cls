/**
 * @author Eric Schultz
 * @date Feb 27, 2020
 *
 * @see B2CIACustomerResolution.resolve
 * @description This testClass is used to exercise different customerResolution
 * scenarios driven by Contact details.
 * @Last Modified by Mohamed Amine El Mandour
 * @Last Modified date March 17th, 2022
 */
@IsTest
private class B2CIACustomerResolution_Test {

    // Initialize the test variables describing contact attributes
    public static String testCustomerListID = 'customerList';
    public static String testCustomerListID1 = 'customerList1';
    public static String testCustomerListID2 = 'customerList2';
    public static String testCustomerID = 'customerId';
    public static String testCustomerID1 = 'customerId1';
    public static String testCustomerID2 = 'customerId2';
    public static String testEmail = 'test@user.com';
    public static String testEmail1 = 'test@one.user.com';
    public static String testEmail2 = 'test@two.user.com';
    public static String testCustomerNo = 'customerNo';
    public static String testCustomerNo1 = 'customerNo1';
    public static String testCustomerNo2 = 'customerNo2';
    public static String testLastName = 'LastName';
    public static String testLastName1 = 'LastName1';
    public static String testLastName2 = 'LastName2';
    public static String testLastName3 = 'LastName3';
    public static String testLastNameDefault = 'Unknown';

    /**
     * @description Setup method that creates the customerList record(s) required to support testing.
     */
    @TestSetup static void setup() {

        // Setup a single customerList we can use for testing / validation
        B2C_CustomerList__c customerList = (B2C_CustomerList__c)TestDataFactory.createSObject('B2C_CustomerList__c', new Map<String,Object>{
            'Name' => 'customerList',
            'Is_Active__c' => true,
            'API_Url__c' => 'https://www.salesforce.com',
            'B2C_Instance__r.Is_Active__c' => true,
            'B2C_Instance__r.API_Url__c' => 'https://www.salesforce.com',
            'Enable_Profile_Publishing__c' => true,
            'Enable_Profile_Creation__c' => true
        });

        // Setup a second customerList for testing / validation
        B2C_CustomerList__c customerList1 = (B2C_CustomerList__c)TestDataFactory.createSObject('B2C_CustomerList__c', new Map<String,Object>{
            'Name' => 'customerList1',
            'Is_Active__c' => true,
            'API_Url__c' => 'https://www.salesforce.com',
            'B2C_Instance__r.Is_Active__c' => true,
            'B2C_Instance__r.API_Url__c' => 'https://www.salesforce.com',
            'Enable_Profile_Publishing__c' => true,
            'Enable_Profile_Creation__c' => true
        });

        // Setup a third customerList for testing / validation
        B2C_CustomerList__c customerList2 = (B2C_CustomerList__c)TestDataFactory.createSObject('B2C_CustomerList__c', new Map<String,Object>{
            'Name' => 'customerList2',
            'Is_Active__c' => true,
            'API_Url__c' => 'https://www.salesforce.com',
            'B2C_Instance__r.Is_Active__c' => true,
            'B2C_Instance__r.API_Url__c' => 'https://www.salesforce.com',
            'Enable_Profile_Publishing__c' => true,
            'Enable_Profile_Creation__c' => true
        });

    }

    @IsTest
    private static void testResolveByB2CCustomerIDZeroResultsFromMultiple() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('B2C_Customer_ID__c', testCustomerID1);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Create a second contact record with a different customerId
        contactToResolveMap.put('B2C_Customer_ID__c', testCustomerID2);
        contactToResolveMap.put('B2C_Customer_No__c',testCustomerNo);
        B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            B2C_Customer_ID__c = testCustomerID,
            B2C_Customer_No__c = testCustomerNo
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
        B2CIACustomerResolution_TestHelper.validateZeroResultsFromMultiple(flowResults);

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList and customerNo.  It resolves no records from
     * multiple records due to mis-matched customerId values.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDB2CCustomerNoZeroResultsFromMultiple() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('B2C_Customer_No__c', testCustomerNo1);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Create a second contact record with a different customerId
        contactToResolveMap.put('B2C_Customer_No__c', testCustomerNo2);
        B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            B2C_Customer_No__c = testCustomerNo
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
        B2CIACustomerResolution_TestHelper.validateZeroResultsFromMultiple(flowResults);

    }
    @IsTest
    private static void createTestContacts(){
        
        List <Account> accounts = new List <Account>();
        List <Individual> individuals = new List <Individual>();
        Individual individual = new Individual();
        individual.LastName='individual Test';
        individual.FirstName = 'firstName';
        individuals.add(individual);
        Individual individual2 = new Individual();
        individual2.LastName='individual Test22';
        individuals.add(individual2);
        insert individuals;
        RecordType personAccount = [Select Id, Name from recordType where IsPersonType = true limit 1];
        
        Account account =  new Account();
        account.LastName = 'accountName1';
        account.FirstName = 'firstName1';
		account.PersonEmail = 'Account.test@gmail.com';
        account.B2C_Customer_ID__pc = 'abKveEa2SaQRM0000';
		account.B2C_Customer_No__pc = '000170000';
        account.Country__pc = 'DE';
        account.LastUpdateOptinEmailing__pc = System.now();
        account.RecordTypeId  = personAccount.Id;
        account.OptinEmailing__pc = true;
        account.PersonIndividualId = individual.Id;
        accounts.add(account);
        
         Account account2 =  new Account();
        account2.LastName = 'accountName2';
        account2.FirstName = 'firstName2';
		account2.PersonEmail = 'Account.test@gmail.com';
        account2.B2C_Customer_ID__pc = 'abKveEa2SaQRM0001';
		account2.B2C_Customer_No__pc = '000170001';
        account2.Country__pc = 'DE';
        account2.LastUpdateOptinEmailing__pc = System.now();
        account2.RecordTypeId  = personAccount.Id;
        account2.OptinEmailing__pc = true;
        account2.PersonIndividualId = individual2.Id;
        accounts.add(account2);
        
        insert accounts;
        
        Test.startTest();
        List<Contact> listContacts = [Select Id, AccountId, B2C_CustomerList__c, B2C_CustomerList_ID__c, B2C_Customer_ID__c, 
                                               B2C_Customer_No__c, FirstName, LastName, Email, B2C_Disable_Integration__c
                                               From Contact where AccountId =: accounts[0].Id];
        System.debug('List contacts: ' + listContacts);
        List<Contact> result = B2CIACustomerResolution.ConnectorBToCNewLogic(listContacts[0]);
        Test.stopTest();
        System.assertEquals(listContacts, result); 
    }
    
    @IsTest
    private static void createTestContactsWithOnlyOneContactWithIds(){
        
        List <Account> accounts = new List <Account>();
        List <Individual> individuals = new List <Individual>();
        Individual individual = new Individual();
        individual.LastName='individual Test';
        individual.FirstName = 'firstName';
        individuals.add(individual);
        Individual individual2 = new Individual();
        individual2.LastName='individual Test22';
        individuals.add(individual2);
        insert individuals;
        RecordType personAccount = [Select Id, Name from recordType where IsPersonType = true limit 1];
        
        Account account =  new Account();
        account.LastName = 'accountName1';
        account.FirstName = 'firstName1';
		account.PersonEmail = 'Account.test@gmail.com';
        account.B2C_Customer_ID__pc = 'abKveEa2SaQRM0000';
		account.B2C_Customer_No__pc = '000170000';
        account.Country__pc = 'DE';
        account.LastUpdateOptinEmailing__pc = System.now();
        account.RecordTypeId  = personAccount.Id;
        account.OptinEmailing__pc = true;
        account.PersonIndividualId = individual.Id;
        accounts.add(account);
        
         Account account2 =  new Account();
        account2.LastName = 'accountName2';
        account2.FirstName = 'firstName2';
		account2.PersonEmail = 'Account.test@gmail.com';
		account2.B2C_Customer_No__pc = '000170001';
        account2.Country__pc = 'DE';
        account2.LastUpdateOptinEmailing__pc = System.now();
        account2.RecordTypeId  = personAccount.Id;
        account2.OptinEmailing__pc = true;
        account2.PersonIndividualId = individual2.Id;
        accounts.add(account2);
        
        insert accounts;
        
        Test.startTest();
        List<Contact> listContacts = [Select Id, AccountId, B2C_CustomerList__c, B2C_CustomerList_ID__c, B2C_Customer_ID__c, 
                                               B2C_Customer_No__c, FirstName, LastName, Email, B2C_Disable_Integration__c
                                               From Contact where AccountId =: accounts[0].Id];
        System.debug('List contacts: ' + listContacts);
        List<Contact> result = B2CIACustomerResolution.ConnectorBToCNewLogic(listContacts[0]);
        Test.stopTest();
		System.assertEquals(listContacts, result);      
    }
	
    
    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList, Email, and LastName.  It resolves a single record from
     * a single record.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailLastNameSingleResult() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            Email = testEmail,
            LastName = testLastName
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

        // Validate the single result details
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, contactToResolve);

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList, Email, and LastName.  It resolves no records from
     * multiple records due to mis-matched email values.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailLastNameZeroResultsFromMultipleEmails() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Create a second contact record with a different Email / LastName
        contactToResolveMap.put('Email', testEmail1);
        B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            Email = testEmail2,
            LastName = testLastName
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
        B2CIACustomerResolution_TestHelper.validateZeroResultsFromMultiple(flowResults);

    }
    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList, Email, and LastName.  It throws an error resulting from
     * mismatched secondary ID values.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailLastNameNoValidationErrorCustomerID() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('B2C_Customer_ID__c', testCustomerID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            B2C_Customer_ID__c = testCustomerID1,
            Email = testEmail,
            LastName = testLastName
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

        // Validate the validationError occurred
        B2CIACustomerResolution_TestHelper.validateValidationError(flowResults);

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList, Email, and LastName.  It throws an error resulting from
     * mismatched secondary ID values.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailLastNameNoValidationErrorCustomerNo() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('B2C_Customer_No__c', testCustomerNo);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
                B2C_CustomerList_ID__c = testCustomerListID,
                B2C_Customer_No__c = testCustomerNo1,
                Email = testEmail,
                LastName = testLastName
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

        // Validate the validationError occurred
        B2CIACustomerResolution_TestHelper.validateValidationError(flowResults);

    }

    // TODO: Add a section in the flow for lastNames evaluating the default only before customerList and Email

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList, Email, and LastName.  It resolves a single record from
     * a single record that has the default lastName.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailLastNameSingleResultDefaultLastName() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastNameDefault);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            Email = testEmail,
            LastName = testLastName
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

        // Validate the single result details
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, contactToResolve);

    }

    //----------------------------------------------------------------
    //   END: B2C CustomerListID / Email / LastName
    //----------------------------------------------------------------

    //----------------------------------------------------------------
    // START: B2C CustomerListID / Email
    //----------------------------------------------------------------

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList and Email.  It resolves a single record from
     * a single record.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailSingleResult() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            Email = testEmail
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

        // Validate the single result details
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, contactToResolve);

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList and Email.  It resolves a single record from
     * a single record with the default lastName.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailSingleResultLastNameDefault() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastNameDefault);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            Email = testEmail
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

        // Validate the single result details
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, contactToResolve);

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList and Email.  It resolves no records from
     * multiple records due to mis-matched email values.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailZeroResultsFromMultipleEmails() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Create a second contact record with a different Email / LastName
        contactToResolveMap.put('Email', testEmail1);
        B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            Email = testEmail2
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
        B2CIACustomerResolution_TestHelper.validateZeroResultsFromMultiple(flowResults);

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record Email from multiple customer sites. 
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailFromMultipleB2CCustomerListIDs() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Create a second contact record with a different Customer List ID
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID1);
        B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID2,
            Email = testEmail
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

        // Validate the resolved contact details
        B2CIACustomerResolution_TestHelper.validateMultipleResults(flowResults);

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList and Email.  It throws an error resulting from
     * mismatched secondary ID values.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailNoValidationErrorCustomerID() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('B2C_Customer_ID__c', testCustomerID);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            B2C_Customer_ID__c = testCustomerID1,
            Email = testEmail
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

        // Validate the validationError occurred
        B2CIACustomerResolution_TestHelper.validateValidationError(flowResults);

    }

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList and Email.  It throws an error resulting from
     * mismatched secondary ID values.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailNoValidationErrorCustomerNo() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('B2C_CustomerList_ID__c', testCustomerListID);
        contactToResolveMap.put('B2C_Customer_No__c', testCustomerNo);
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            B2C_Customer_No__c = testCustomerNo1,
            Email = testEmail
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

        // Validate the validationError occurred
        B2CIACustomerResolution_TestHelper.validateValidationError(flowResults);

    }

    //----------------------------------------------------------------
    //   END: B2C CustomerListID / Email
    //----------------------------------------------------------------

    //----------------------------------------------------------------
    // BEGIN: Misc Tests (edge cases)
    //----------------------------------------------------------------

    /**
     * @see B2CIACustomerResolution.findDupes
     * @description This test-case exercises the CustomerResolution IA and attempts to resolve
     * a Contact record via a customerList, Email, and LastName.  It should resolve a contact record
     * that matches on email and lastName -- but has no customerList association.
     */
    @IsTest
    private static void testResolveByB2CCustomerListIDEmailLastNameSingleResultByEmailLastNameNoCustomerList() {

        // Initialize local variables
        Map<String, Object> flowResults;
        Contact contactToResolve;
        Contact testContact;
        Map<String, Object> contactToResolveMap;

        // Initialize the map describing the contact to create
        contactToResolveMap = new Map<String, Object>();

        // Define the map representing the Account / Contact record
        contactToResolveMap.put('Email', testEmail);
        contactToResolveMap.put('LastName', testLastName);

        // Create the Contact record to resolve
        contactToResolve = B2CIACustomerResolution_TestHelper.createContact(contactToResolveMap);

        // Define the Contact record to resolve
        testContact = new Contact(
            B2C_CustomerList_ID__c = testCustomerListID,
            Email = testEmail,
            LastName = testLastName
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

        // Validate the contact was successfully resolved
        B2CIACustomerResolution_TestHelper.validateSingleResult(flowResults, contactToResolve);

    }


    

}