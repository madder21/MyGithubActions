/* @author Paul Louis MONY
 * @date September,20th 2023
 * @Type Apex Test Class 
 *****************************************************************************************************************************************************************
 * @description : This Apex class, Test class for AP3_SFMCSynchronisation
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0		|2023/09/19			|.PLM		|.JIRA CI-202			|.Original Version
*/
@isTest
public class AP3_SFMCSynchronisation_Test {

    @isTest
    static void testManageSynchronisation_byContactability_true() {
        // Create a test Account
        Account testAccount = new Account(
            LastName = 'Test Account',
            ContactableByEmail__pc= true,
            BackInStock__pc = false, // Set initial value of BackInStock__pc
            PersonMailingCountry = 'United States', // Set the mailing country
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
		Boolean isSync = false;
        // Call the manageSynchronisation method
        Test.startTest();
        isSync = AP3_SFMCSynchronisation.manageSynchronisation(testAccount);
        Test.stopTest(); 
        
        // Assert that the BackInStock__pc field is updated as expected
        Assert.isTrue(isSync, 'isSFMC__pc should be true');
    }
    @isTest
    static void testManageSynchronisation_byContactabilityAndBIS_false() {
        // Create a test Account
        Account testAccount = new Account(
            LastName = 'Test Account',
            ContactableByEmail__pc= false,
            BackInStock__pc = false, // Set initial value of BackInStock__pc
            PersonMailingCountry = 'United States', // Set the mailing country
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        
		Boolean isSync = false;
        // Call the manageSynchronisation method
        Test.startTest();
        isSync = AP3_SFMCSynchronisation.manageSynchronisation(testAccount);
        Test.stopTest(); 
        
        // Assert that the isSFMC__pc field is updated as expected
        Assert.isFalse(isSync, 'isSFMC__pc should be false');
    }
    @isTest
	static void testManageSynchronisation_byCountry_false() {
        // Create a test Account
        Account testAccount = new Account(
            LastName = 'Test Account',
            ContactableByEmail__pc= true,
            BackInStock__pc = false, // Set initial value of BackInStock__pc
            PersonMailingCountry = 'Chine', // Set the mailing country
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        
		Boolean isSync = false;
        // Call the manageSynchronisation method
        Test.startTest();
        isSync = AP3_SFMCSynchronisation.manageSynchronisation(testAccount);
        Test.stopTest(); 
        
        // Assert that the isSFMC__pc field is updated as expected
        Assert.isFalse(isSync, 'isSFMC__pc should be false');

    }
    @isTest
	static void testManageSynchronisation_byBackInStock_true() {
        // Create a test Account
        Account testAccount = new Account(
            LastName = 'Test Account',
            ContactableByEmail__pc= false,
            BackInStock__pc = true, // Set initial value of BackInStock__pc
            PersonMailingCountry = 'United States', // Set the mailing country
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        
		Boolean isSync = false;
        // Call the manageSynchronisation method
        Test.startTest();
        isSync = AP3_SFMCSynchronisation.manageSynchronisation(testAccount);
        Test.stopTest(); 
        
        // Assert that the BackInStock__pc field is updated as expected
        Assert.isTrue(isSync, 'isSFMC__pc should be true');

    }
    
    @isTest
    static void testAccountTriggerBeforeInsert_SyncSFMC_UnitTest_True(){
        //Create a test Accounts
        //
        //Case 1 : Contactable by email + SFMC Country + no Back In Stock
        Account testAccount_contactableNoBIS = new Account(
            LastName = 'testAccount_contactableNoBIS',
            ContactableByEmail__pc = true,
            PersonMailingCountry = 'United States', // Set the mailing country
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        //Case 2 : Not Contactable by email + Back In Stock
        Account testAccount_noContactableBIS = new Account(
            LastName = 'testAccount_noContactableBIS',
            BackInStock__pc = true,
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        Test.startTest();
        //Launch the trigger on account
        insert testAccount_contactableNoBIS;
        insert testAccount_noContactableBIS;
        Test.stopTest(); 
        Account testAccountAfterInsert1 = [SELECT ID, isSFMC__pc FROM Account Where LastName = 'testAccount_contactableNoBIS'][0];
        Account testAccountAfterInsert2 = [SELECT ID, isSFMC__pc FROM Account Where LastName = 'testAccount_noContactableBIS'][0];
        // Assert that the BackInStock__pc field is updated as expected
        Assert.isTrue(testAccountAfterInsert1.isSFMC__pc, 'isSFMC__pc should be true');
        Assert.isTrue(testAccountAfterInsert2.isSFMC__pc, 'isSFMC__pc should be true');
    }
    @isTest
    static void testAccountTriggerBeforeInsert_SyncSFMC_UnitTest_False(){
        //Create a test Accounts
        //
        //Case 1 : Contactable by email + SFMC Country + no Back In Stock
        Account testAccount_contactableNoBIS_WrongCountry = new Account(
            LastName = 'testAccount_contactableNoBIS_WrongCountry',
            ContactableByEmail__pc = true,
            PersonMailingCountry = 'China', // Set the mailing country
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        //Case 2 : Not Contactable by email + Back In Stock
        Account testAccount_noContactableNoBIS = new Account(
            LastName = 'testAccount_noContactableNoBIS',
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        Test.startTest();
        //Launch the trigger on account
        insert testAccount_contactableNoBIS_WrongCountry;
        insert testAccount_noContactableNoBIS;
        Test.stopTest(); 
        Account testAccountAfterInsert1 = [SELECT ID, isSFMC__pc FROM Account Where LastName = 'testAccount_contactableNoBIS_WrongCountry'][0];
        Account testAccountAfterInsert2 = [SELECT ID, isSFMC__pc FROM Account Where LastName = 'testAccount_noContactableNoBIS'][0];
        // Assert that the BackInStock__pc field is updated as expected
        Assert.isFalse(testAccountAfterInsert1.isSFMC__pc, 'isSFMC__pc should be false');
        Assert.isFalse(testAccountAfterInsert2.isSFMC__pc, 'isSFMC__pc should be false');
    }
	
    @isTest
    static void testAccountTriggerBeforeInsert_SyncSFMC_MassTest_True(){
        Integer nbToMassTest = 100;
        //Create a test Accounts
        //Case 1 : Contactable by email + SFMC Country + no Back In Stock
        List<Account> testAccounts_contactableNoBis= new List<Account>();
        //Case 2 : Not Contactable by email + Back In Stock
        List<Account> testAccount_noContactableBIS = new List<Account>();
        for(Integer i = 0; i < nbToMassTest; i++){
        	 testAccounts_contactableNoBis.add(new Account(LastName = 'testAccounts_contactableNoBis' + String.valueOf(i),
                                                     ContactableByEmail__pc = true,
                                                     PersonMailingCountry = 'United States',// Set the mailing country
													 RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()));
             testAccount_noContactableBIS.add(new Account(LastName = 'testAccount_noContactableBIS' + String.valueOf(i),
                                                          BackInStock__pc = true,
													 RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()));
        }
        
        Test.startTest();
        //Launch the trigger on account
        insert testAccounts_contactableNoBis;
        insert testAccount_noContactableBIS;
        Test.stopTest(); 
        List<Account> testAccountsAfterInsert1 = [SELECT ID, isSFMC__pc FROM Account Where LastName LIKE 'testAccounts_contactableNoBis%'];
        List<Account> testAccountsAfterInsert2 = [SELECT ID, isSFMC__pc FROM Account Where LastName LIKE 'testAccount_noContactableBIS%'];
        // Assert that the BackInStock__pc field is updated as expected
        for(Integer i = 0; i < nbToMassTest; i++){
            Assert.isTrue(testAccountsAfterInsert1[i].isSFMC__pc, 'isSFMC__pc should be true');
            Assert.isTrue(testAccountsAfterInsert2[i].isSFMC__pc, 'isSFMC__pc should be true');
        }
    }
    @isTest
    static void testAccountTriggerBeforeInsert_SyncSFMC_MassTest_False(){
        Integer nbToMassTest = 100;
        //Create a test Accounts
        //Case 1 : Contactable by email + SFMC Country + no Back In Stock
        List<Account> testAccounts_contactableNoBis_WrongCountry= new List<Account>();
        //Case 2 : Not Contactable by email + Back In Stock
        List<Account> testAccount_noContactableNoBIS = new List<Account>();
        for(Integer i = 0; i < nbToMassTest; i++){
        	 testAccounts_contactableNoBis_WrongCountry.add(new Account(LastName = 'testAccounts_contactableNoBis_WrongCountry' + String.valueOf(i),
                                                     ContactableByEmail__pc = true,
                                                     PersonMailingCountry = 'China',// Set the mailing country
													 RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()));
             testAccount_noContactableNoBIS.add(new Account(LastName = 'testAccount_noContactableNoBIS' + String.valueOf(i),
													 RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()));
        }
        
        Test.startTest();
        //Launch the trigger on account
        insert testAccounts_contactableNoBis_WrongCountry;
        insert testAccount_noContactableNoBIS;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
        Test.stopTest(); 
        List<Account> testAccountsAfterInsert1 = [SELECT ID, isSFMC__pc FROM Account Where LastName LIKE 'testAccounts_contactableNoBis_WrongCountry%'];
        List<Account> testAccountsAfterInsert2 = [SELECT ID, isSFMC__pc FROM Account Where LastName LIKE 'testAccount_noContactableNoBIS%'];
        // Assert that the BackInStock__pc field is updated as expected
        for(Integer i = 0; i < nbToMassTest; i++){
            Assert.isFalse(testAccountsAfterInsert1[i].isSFMC__pc, 'isSFMC__pc should be false');
            Assert.isFalse(testAccountsAfterInsert2[i].isSFMC__pc, 'isSFMC__pc should be false');
        }
    }
    @isTest
    static void testAccountTriggerBeforeUpdate_SyncSFMC_MassTest_True(){
        Integer nbToMassTest = 100;
        //Create a test Accounts
        //Case 1 : Contactable by email + SFMC Country + no Back In Stock
        List<Account> testAccounts_contactableNoBis= new List<Account>();
        //Case 2 : Not Contactable by email + Back In Stock
        List<Account> testAccount_noContactableBIS = new List<Account>();
        for(Integer i = 0; i < nbToMassTest; i++){
        	 testAccounts_contactableNoBis.add(new Account(LastName = 'testAccounts_contactableNoBis' + String.valueOf(i),
                                                           ContactableByEmail__pc = false,
                                                           PersonMailingCountry = 'China',
													 RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()));
             testAccount_noContactableBIS.add(new Account(LastName = 'testAccount_noContactableBIS' + String.valueOf(i),
                                                          BackInStock__pc = false,
													 RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()));
        }
        insert testAccounts_contactableNoBis;
        insert testAccount_noContactableBIS;
        Test.startTest();
        //Launch the trigger on account
        for(Integer i = 0; i < nbToMassTest; i++){
        	testAccounts_contactableNoBis[i].ContactableByEmail__pc = true;
            testAccounts_contactableNoBis[i].PersonMailingCountry = 'France';
            testAccount_noContactableBIS[i].BackInStock__pc = true;
        }
		update testAccounts_contactableNoBis;
        update testAccount_noContactableBIS;
        Test.stopTest(); 
        List<Account> testAccountsAfterUpdate1 = [SELECT ID, isSFMC__pc FROM Account Where LastName LIKE 'testAccounts_contactableNoBis%'];
        List<Account> testAccountsAfterUpdate2 = [SELECT ID, isSFMC__pc FROM Account Where LastName LIKE 'testAccount_noContactableBIS%'];
        // Assert that the BackInStock__pc field is updated as expected
        for(Integer i = 0; i < nbToMassTest; i++){
            Assert.isTrue(testAccountsAfterUpdate1[i].isSFMC__pc, 'isSFMC__pc should be true');
            Assert.isTrue(testAccountsAfterUpdate2[i].isSFMC__pc, 'isSFMC__pc should be true');
        }
    }
     @isTest
    static void testAccountTriggerBeforeUpdate_SyncSFMC_MassTest_False(){
        Integer nbToMassTest = 100;
        //Create a test Accounts
        //Case 1 : Contactable by email + SFMC Country + no Back In Stock
        List<Account> testAccounts_contactableNoBis_WrongCountry= new List<Account>();
        //Case 2 : Not Contactable by email + Back In Stock
        List<Account> testAccount_noContactableNoBIS = new List<Account>();
        for(Integer i = 0; i < nbToMassTest; i++){
        	 testAccounts_contactableNoBis_WrongCountry.add(new Account(LastName = 'testAccounts_contactableNoBis_WrongCountry' + String.valueOf(i),
                                                           ContactableByEmail__pc = true,
                                                           PersonMailingCountry = 'United States',
													 RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()));
             testAccount_noContactableNoBIS.add(new Account(LastName = 'testAccount_noContactableNoBIS' + String.valueOf(i),
                                                          BackInStock__pc = true,
													 RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()));
        }
        insert testAccounts_contactableNoBis_WrongCountry;
        insert testAccount_noContactableNoBIS;
        Test.startTest();
        //Launch the trigger on account
        for(Integer i = 0; i < nbToMassTest; i++){
        	testAccounts_contactableNoBis_WrongCountry[i].ContactableByEmail__pc = true;
            testAccounts_contactableNoBis_WrongCountry[i].PersonMailingCountry = 'China';
            testAccount_noContactableNoBIS[i].BackInStock__pc = false;
        }
		update testAccounts_contactableNoBis_WrongCountry;
        update testAccount_noContactableNoBIS;
        Test.stopTest(); 
        List<Account> testAccountsAfterUpdate1 = [SELECT ID, isSFMC__pc FROM Account Where LastName LIKE 'testAccounts_contactableNoBis_WrongCountry%'];
        List<Account> testAccountsAfterUpdate2 = [SELECT ID, isSFMC__pc FROM Account Where LastName LIKE 'testAccount_noContactableNoBIS%'];
        // Assert that the BackInStock__pc field is updated as expected
        for(Integer i = 0; i < nbToMassTest; i++){
            Assert.isFalse(testAccountsAfterUpdate1[i].isSFMC__pc, 'isSFMC__pc should be false');
            Assert.isFalse(testAccountsAfterUpdate2[i].isSFMC__pc, 'isSFMC__pc should be false');
        }
    }
}