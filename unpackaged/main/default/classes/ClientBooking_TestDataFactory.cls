/* @author Paul Louis MONY
 * @date May,15th 2024
 * @Type Apex Test Class 
 *****************************************************************************************************************************************************************
 * @description : This class is responsible for creating instances of data objects for all test classes, 
 * 				in order to improve readability and reusability of code components 
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0      |2024/05/17         |.PLM       |..SFMC-425         |.Original Version
*/
@isTest
public class ClientBooking_TestDataFactory {
	@testSetup
    static void testData(){
        ClientBooking_TestDataFactory.createTestSetupData();
    }
    
    public static void createTestSetupData(){
        //Create Account
        Account testAccount = new Account(
            Firstname = 'test',
            LastName = 'Test Account',
            personEmail = 'test@test.com',
			RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert testAccount;
        
        //Create User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        // Create the user
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(), // Ensure unique username
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            BooxiId__c = '1111',
            StaffCode__c = 'US01'
        );
        insert u;

        //Create Store
        Store__c s = new Store__c(
            BooxiId__c = '1111',
            Country__c = 'US',
            Name = 'RimowaStore',
            StoreLabel__c= 'RimowaStore',
            UCRInternalId__c = '1111'
        );
        insert s;

        //Create Service
        AppointmentService__c service = new AppointmentService__c(
            BookingMethod__c = 'Appointment',
            BooxiId__c = '1111',
            Duration__c = 30,
            MerchantId__c = '1111',
            Name = 'Product',
            Status__c = 'Online',
            Store__c = s.id
        );
        insert service;
    }
    public static Account getTestAccount(){
        return [Select Id 
        from Account 
        where personEmail ='test@test.com' 
        and firstname = 'test' 
        and lastname = 'Test Account' Limit 1];
    }
    public static User getTestUser(){
        return [Select Id 
        From User 
        where email = 'testuser@example.com' Limit 1];
    }
    public static Store__c getTestStore(){
        return [Select Id 
        From Store__c 
        Where booxiId__c = '1111' Limit 1];
    }
    public static AppointmentService__c getTestService(){
        return[Select Id
        From AppointmentService__c
        Where booxiId__c = '1111' Limit 1];
    }
    
    public static ClientBooking__c createClientBooking(DateTime AppointmentDateTime){
        Account acc = ClientBooking_TestDataFactory.getTestAccount();
        User us = ClientBooking_TestDataFactory.getTestUser();
        Store__c st = ClientBooking_TestDataFactory.getTestStore();
        AppointmentService__c service = ClientBooking_TestDataFactory.getTestService();
        ClientBooking__c cb = new ClientBooking__c(
            Account__c=acc.id,
            AccountId__c = acc.Id,
            Attendance__c = 'Expecting',
            BookingMethod__c = 'Appointment',
            ClientCommunication__c = 'ClientOnly',
            ConfirmationNumber__c = 'testClass01',
            CreatedBy__c = 'Staff',
            CreatedOn__c = datetime.now(),
            Duration__c = 30,
            Email__c = 'test@test.com',
            Firstname__c = 'test',
            isCompleted__c = false,
            isScheduled__c = false,
            Language__c = 'eng',
            Lastname__c = 'Test Account',
            MerchantAddressCity__c = 'test',
            MerchantAddressCountry__c = 'US',
            MerchantAddressPostalCode__c = '1111',
            MerchantAddressStreet__c = 'test street',
            MerchantId__c = '1111',
            Origin__c = 'InStore',
            PhoneNumber__c = '+33778676272',
            Service__c = service.id,
            ServiceId__c = '1111',
            StaffId__c = '1111',
            StartsOn__c = AppointmentDateTime,
            Status__c = 'Approved',
            Store__c = st.id,
            TimeZone__c = 'Europe/Paris',
            User__c = us.id
        );
		insert cb;
		return cb;        
    }
}