/**
 * @author Ulrich NDONG NGOMO
 * @date 09/23/2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is used as a test class for AP_ClientBookingTrad
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|09/23/2024			|.UMNN		|.					|.
*/
@IsTest(SeeAllData=false)
public class AP_ClientBookingTrad_TST {
    
    @isTest
    static void initSuppressionProcessTest() {
        List<AP_ClientBookingTrad.BookingEventWrapper> flowInputs = new List<AP_ClientBookingTrad.BookingEventWrapper>();
        AP_ClientBookingTrad.BookingEventWrapper wrapper = new AP_ClientBookingTrad.BookingEventWrapper();
        wrapper.bookingNumber = 'AB001';
        wrapper.firstName = 'Jean';
        wrapper.lastName = 'Blunt';
        wrapper.language = 'en';
        wrapper.outreachReason = 'LABS_AP_Product';
        wrapper.subjectLabel = 'LABS_AP_eventSubject';
        flowInputs.add(wrapper);
        Test.startTest();
        List<AP_ClientBookingTrad.BookingEventWrapper> flowOutputs = AP_ClientBookingTrad.initTranslationProcess(flowInputs);
        Test.stopTest();
        System.assertEquals(1, flowOutputs.size(), 'List not null');
    }
    
    @isTest
    static void initSuppressionProcessWithoutBookingNumberTest() {
        List<AP_ClientBookingTrad.BookingEventWrapper> flowInputs = new List<AP_ClientBookingTrad.BookingEventWrapper>();
        AP_ClientBookingTrad.BookingEventWrapper wrapper = new AP_ClientBookingTrad.BookingEventWrapper();
        wrapper.firstName = 'Jean';
        wrapper.lastName = 'Blunt';
        wrapper.language = 'en';
        wrapper.outreachReason = 'LABS_AP_Product';
        wrapper.subjectLabel = 'LABS_AP_eventSubject';
        flowInputs.add(wrapper);
        Test.startTest();
        List<AP_ClientBookingTrad.BookingEventWrapper> flowOutputs = AP_ClientBookingTrad.initTranslationProcess(flowInputs);
        Test.stopTest();
        System.assertEquals(1, flowOutputs.size(), 'List not null');
    }
}