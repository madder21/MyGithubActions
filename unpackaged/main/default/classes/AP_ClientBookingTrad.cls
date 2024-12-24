/**
 * @author Ulrich NDONG NGOMO
 * @date 09/23/2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is used to manage Client Booking translated fields
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|09/23/2024			|.UMNN		|.					|.
*/
public with sharing class AP_ClientBookingTrad {
    
    @invocableMethod(label='SF Manage client Booking translation')
    public static List<BookingEventWrapper> initTranslationProcess(List<BookingEventWrapper> flowInputs) {
        System.debug('flowInput  '+flowInputs);
        BookingEventWrapper wrapper = flowInputs[0];
        wrapper.subjectLabel = (wrapper.bookingNumber<>null)?
            Label.translationExists(null, wrapper.subjectLabel, wrapper.language)?
            Label.get(null, wrapper.subjectLabel, wrapper.language) : wrapper.subjectLabel : Label.get(null, wrapper.subjectLabel, wrapper.language) 
            //+ wrapper.bookingNumber: wrapper.subjectLabel : Label.get(null, wrapper.subjectLabel, wrapper.language) 
            + ' '+wrapper.firstName + ' '+ wrapper.lastName;
        if(wrapper.bookingNumber==null){
            String labelToUse = wrapper.outreachReason;//=='Product'?'LABS_AP_Product': 'LABS_AP_Repair';
            wrapper.outreachReason = Label.translationExists(null, labelToUse, wrapper.language)?Label.get(null, labelToUse, wrapper.language):labelToUse;
        }
        List<BookingEventWrapper> flowOutputs = new List<BookingEventWrapper>();
        flowOutputs.add(wrapper);
        return flowOutputs;   
    }
    
    public class BookingEventWrapper {
        @invocableVariable
        public String subjectLabel;
        @invocableVariable
        public String outreachReason;
        @invocableVariable
        public String lastName;
        @invocableVariable
        public String firstName;
        @invocableVariable
        public String bookingNumber;
        @invocableVariable
        public String language;
    }
}