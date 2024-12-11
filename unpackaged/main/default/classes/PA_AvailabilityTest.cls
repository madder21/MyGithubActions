/* @author Paul Louis MONY
 * @date April,18th 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description : This Apex class, is a Test Class for PA_Availability Class
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0		|2024/04/18			|.PLM		|.JIRA SFMC-392			|.Original Version
*/
@isTest
private class PA_AvailabilityTest {

    static String calculatedFreeSlots;
    @testSetup
    static void testData(){
        // Create a test profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		
        User testStaff = new User(
            Username = 'testuser-rimowa@example.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testProfile.Id,
            LanguageLocaleKey = 'en_US',
            StaffCode__c = '123', 
            FirstName = 'Test',
            LastName = 'Staff'
        );
        insert testStaff;
        
        Store__c testStore = new Store__c(
            Name = 'Test Store',
            AppointmentEnable__c = true,
            AppointmentHours__c = '[{"dow": 1, "start": "09:00", "end": "17:00"}, {"dow": 2, "start": "09:00", "end": "17:00"}, {"dow": 3, "start": "09:00", "end": "17:00"}, {"dow": 4, "start": "09:00", "end": "17:00"}, {"dow": 5, "start": "09:00", "end": "17:00"}]', // Adjust appointment hours as needed
            AppointmentDuration__c = 30, // Appointment duration in minutes
            AppointmentBookingInterval__c = 60, // Booking interval in minutes
            SourceStoreId__c = 'TestStore123' // Unique identifier for the store
        );
        insert testStore;
        
        Store__c testStoreClosed = new Store__c(
            Name = 'Test Store CLOSED',
            AppointmentEnable__c = false,
            AppointmentHours__c = '[{"dow": 1, "start": "09:00", "end": "17:00"}, {"dow": 2, "start": "09:00", "end": "17:00"}, {"dow": 3, "start": "09:00", "end": "17:00"}, {"dow": 4, "start": "09:00", "end": "17:00"}, {"dow": 5, "start": "09:00", "end": "17:00"}]', // Adjust appointment hours as needed
            AppointmentDuration__c = 30, // Appointment duration in minutes
            AppointmentBookingInterval__c = 60, // Booking interval in minutes
            SourceStoreId__c = 'TestStore1234' // Unique identifier for the store
        );
        insert testStoreClosed;
        
        Date myDate = Date.newInstance(2011, 11, 18);
		Time myTime = Time.newInstance(3, 3, 3, 0);
		DateTime dt = DateTime.newInstance(myDate, myTime);
        
        Event testEvent = new Event(
        	OwnerId = testStaff.Id,
            Store__c = testStore.Id,
            ActivityDateTime = DateTime.newInstance(2024, 1, 1, 10, 30, 0),
            DurationInMinutes = 30,
            ShowAs = 'Busy',
            Subject = 'Private Appointment'
        );
        insert testEvent;
    }
    
    // Test method for getStoreAvailability
    @isTest
    static void testGetStoreAvailability() {
        String staffCode = '123';
        String storeCode = 'TestStore123';
		Date startDate = date.newinstance(2024, 1, 1);
        Date endDate = date.newinstance(2024, 2, 1);
        Test.startTest();
        // Make a callout to the getStoreAvailability method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String response = PA_Availability.getStoreAvailability(storeCode,staffCode,startDate,endDate);
        Test.stopTest();

        // Assert that the response is not empty
        System.assertNotEquals(null, response);
    }
    
    // Test method for error StartDate after EndDate 
    @isTest
    static void testGetStoreAvailability_ErrorStartDateAfterEndDate() {
        String staffCode = '123';
        String storeCode = 'TestStore123';
		Date startDate = date.newinstance(2024, 3, 1);
        Date endDate = date.newinstance(2024, 2, 1);
        Test.startTest();
        // Make a callout to the getStoreAvailability method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String response = PA_Availability.getStoreAvailability(storeCode,staffCode,startDate,endDate);
        Test.stopTest();
		
        // Assert that the response is not empty
        Assert.AreEqual('{"error": "The startDate should be before the endDate."}', response);
    }
    
    // Test method for error StartDate = EndDate 
    @isTest
    static void testGetStoreAvailability_ErrorStartDateEqualEndDate() {
        String staffCode = '123';
        String storeCode = 'TestStore123';
		Date startDate = date.newinstance(2024, 2, 1);
        Date endDate = date.newinstance(2024, 2, 1);
        Test.startTest();
        // Make a callout to the getStoreAvailability method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String response = PA_Availability.getStoreAvailability(storeCode,staffCode,startDate,endDate);
        Test.stopTest();
		
        // Assert that the response is not empty
        Assert.AreEqual('{"error": "The startDate and the endDate shouldn\'t be the same."}', response);
    }
    
        // Test method for error Date of Range.
    @isTest
    static void testGetStoreAvailability_ErrorDateOutOfRange() {
        String staffCode = '123';
        String storeCode = 'TestStore123';
		Date startDate = date.newinstance(2024, 1, 1);
        Date endDate = date.newinstance(2024, 4, 1);
        Test.startTest();
        // Make a callout to the getStoreAvailability method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String response = PA_Availability.getStoreAvailability(storeCode,staffCode,startDate,endDate);
        Test.stopTest();
		
        // Assert that the response is not empty
        Assert.AreEqual('{"error": "The startDate and the endDate should have a maximum gap of 31 days."}', response);
    }
    // Test method for error Store Offline.
    @isTest
    static void testGetStoreAvailability_ErrorStoreOffline() {
        String staffCode = '123';
        String storeCode = 'TestStore1234';
		Date startDate = date.newinstance(2024, 1, 1);
        Date endDate = date.newinstance(2024, 2, 1);
        Test.startTest();
        // Make a callout to the getStoreAvailability method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String response = PA_Availability.getStoreAvailability(storeCode,staffCode,startDate,endDate);
        Test.stopTest();
		
        // Assert that the response is not empty
        Assert.AreEqual('{"error": "Store unable to receive appointment."}', response);
    }
    
    // Test method for sortMapByDate
    @isTest
    static void testSortMapByDate() {
        // Create test data
        Map<Date, String> testMap = new Map<Date, String>{
            Date.today() => 'Today',
            Date.today().addDays(1) => 'Tomorrow'
        };

        // Call the sortMapByDate method
        Map<Date, String> sortedMap = PA_Availability.sortMapByDate(testMap);

        // Assert that the sorted map is not empty
        Assert.isNotNull(sortedMap);
    }

    // Test method for timeToMinutes
    @isTest
    static void testTimeToMinutes() {
        // Call the timeToMinutes method with a test time
        Integer minutes = PA_Availability.timeToMinutes('10:30');

        // Assert that the result is as expected
        Assert.AreEqual(630, minutes);
    }

    // Test method for minutesToTime
    @isTest
    static void testMinutesToTime() {
        // Call the minutesToTime method with a test number of minutes
        String aTime = PA_Availability.minutesToTime(630);

        // Assert that the result is as expected
        Assert.AreEqual('10:30', aTime);
    }
    
        @IsTest
        static void testAdjustAvailableSlots() {
            // Create test data
            String availableSlots = '08:00 - 08:30;08:30 - 09:00;09:00 - 09:30;09:30 - 10:00;10:00 - 10:30;10:30 - 11:00';
            String busySlots = '08:00 - 08:30;10:30 - 11:00';
            Integer appointmentBookingInterval = 30; // Interval of 30 minutes
            Integer appointmentDuration = 30; // Duration of 30 minutes
    
            // Call the method to test
            String result = PA_Availability.adjustAvailableSlots(availableSlots, busySlots, appointmentBookingInterval, appointmentDuration);
    
            // Define the expected result based on the input data
            String expectedFreeSlots = '09:00 - 09:30;09:30 - 10:00'; // Only these slots should be free
    
            // Perform assertion
            Assert.AreEqual(expectedFreeSlots, result, 'Adjusted available slots should match expected free slots');
        }
    
    @isTest
    static void testGetStoreAvailabilityBySelectedSlot() {
        String staffCode = '123';
        String storeCode = 'TestStore123';
		Date startDate = date.newinstance(2024, 1, 1);
        Date endDate = date.newinstance(2024, 2, 1);
        Test.startTest();
        // Make a callout to the getStoreAvailability method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String response = PA_Availability.getStoreAvailability(storeCode,staffCode,startDate,endDate);
        Test.stopTest();

        // Assert that the response is not empty
        System.assertNotEquals(null, response);
    }

}