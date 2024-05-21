/* @author Paul Louis MONY
 * @date May,15th 2024
 * @Type Apex Test Class 
 *****************************************************************************************************************************************************************
 * @description : This test class is testing ClientBooking Scalable Vector extension. 
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0      |2024/05/17         |.PLM       |..SFMC-425         |.Original Version
*/
@isTest
public without sharing class ClientBooking_SVE_Test {
	@testSetup
    static void testData(){
        ClientBooking_TestDataFactory.createTestSetupData();
    }
    @isTest
    static void testNewClientBooking(){
        DateTime AppointmentDateTime = DateTime.newInstanceGMT(2024,6,1,7,0,0);
		ClientBooking__c cb = new ClientBooking__c();
        test.StartTest();            
        	cb = ClientBooking_TestDataFactory.createClientBooking(AppointmentDateTime);
        test.StopTest();
        ClientBooking__c actualCB = [SELECT Account__c, ConfirmationNumber__c,StartsOn__c,TimeZone__c,LocaleDateTime__c
                                    From ClientBooking__c 
                                    Where ConfirmationNumber__c = 'testClass01' Limit 1];
        DateTime expectedLocalDateTime = DateTime.newInstanceGMT(2024,6,1,9,0,0);
        Assert.AreEqual(actualCB.ConfirmationNumber__c, cb.ConfirmationNumber__c,'The ConfirmationNumber is not the same');
        Assert.AreEqual(actualCB.Account__c,cb.Account__c, 'the account is not the same');
        Assert.AreEqual(expectedLocalDateTime,actualCB.LocaleDateTime__c,'the LocaleDateTime__c is not well calculated');
    }
    
    @isTest 
    static void testExistingClientBooking_ModifyStartsOn(){
        DateTime AppointmentDateTime = DateTime.newInstanceGMT(2024,6,1,7,0,0);
		ClientBooking__c cb = ClientBooking_TestDataFactory.createClientBooking(AppointmentDateTime);
        cb.StartsOn__c = DateTime.newInstanceGMT(2024,6,5,10,0,0);
        
        test.StartTest();
        	update cb;
        test.StopTest();
        ClientBooking__c actualCB = [SELECT Account__c, ConfirmationNumber__c,StartsOn__c,TimeZone__c,LocaleDateTime__c
                                    From ClientBooking__c 
                                    Where ConfirmationNumber__c = 'testClass01' Limit 1];
        DateTime expectedLocalDateTime = DateTime.newInstanceGMT(2024,6,5,12,0,0);
        Assert.AreEqual(actualCB.ConfirmationNumber__c, cb.ConfirmationNumber__c,'The ConfirmationNumber is not the same');
        Assert.AreEqual(actualCB.Account__c,cb.Account__c, 'the account is not the same');
        Assert.AreEqual(expectedLocalDateTime,actualCB.LocaleDateTime__c,'the LocaleDateTime__c is not well calculated');
    }
    
    @isTest 
    static void testExistingClientBooking_ModifyTimeZone(){
        DateTime AppointmentDateTime = DateTime.newInstanceGMT(2024,6,1,7,0,0);
		ClientBooking__c cb = ClientBooking_TestDataFactory.createClientBooking(AppointmentDateTime);
        cb.TimeZone__c = 'America/New_York';
        
        test.StartTest();
        	update cb;
        test.StopTest();
        ClientBooking__c actualCB = [SELECT Account__c, ConfirmationNumber__c,StartsOn__c,TimeZone__c,LocaleDateTime__c
                                    From ClientBooking__c 
                                    Where ConfirmationNumber__c = 'testClass01' Limit 1];
        DateTime expectedLocalDateTime = DateTime.newInstanceGMT(2024,6,1,3,0,0);
        Assert.AreEqual(actualCB.ConfirmationNumber__c, cb.ConfirmationNumber__c,'The ConfirmationNumber is not the same');
        Assert.AreEqual(actualCB.Account__c,cb.Account__c, 'the account is not the same');
        Assert.AreEqual(expectedLocalDateTime,actualCB.LocaleDateTime__c,'the LocaleDateTime__c is not well calculated');
    }
    
    @isTest
    static void testDeleteClientBooking() {
        DateTime AppointmentDateTime = DateTime.newInstanceGMT(2024, 6, 1, 7, 0, 0);
        
        // Create the ClientBooking record
        ClientBooking__c cb = ClientBooking_TestDataFactory.createClientBooking(AppointmentDateTime);
        
        test.StartTest();
            // Delete the ClientBooking record
            delete cb;
        test.StopTest();
        
        // Query the ClientBooking record to verify it has been deleted
        List<ClientBooking__c> deletedBookingList = [SELECT Id FROM ClientBooking__c WHERE Id = :cb.Id LIMIT 1];
        
        // Assert that the list is empty, meaning the record has been deleted
        System.assert(deletedBookingList.isEmpty(), 'ClientBooking hasn\'t been deleted properly');
    }
    
    @isTest
    static void testUndeleteClientBooking() {
        DateTime AppointmentDateTime = DateTime.newInstanceGMT(2024, 6, 1, 7, 0, 0);
        
        // Create the ClientBooking record
        ClientBooking__c cb = ClientBooking_TestDataFactory.createClientBooking(AppointmentDateTime);
        
        test.StartTest();
            // Delete the ClientBooking record
            delete cb;
            
            // Undelete the ClientBooking record
            undelete cb;
        test.StopTest();
        
        // Query the ClientBooking record to verify it has been undeleted
        ClientBooking__c undeletedBooking = [SELECT Id, ConfirmationNumber__c FROM ClientBooking__c WHERE Id = :cb.Id LIMIT 1];
        
        // Assert that the record has been restored correctly
        System.assertNotEquals(null, undeletedBooking, 'ClientBooking hasn\'t been undeleted properly');
        System.assertEquals(cb.ConfirmationNumber__c, undeletedBooking.ConfirmationNumber__c, 'ClientBooking data mismatch after undelete');
    }

}