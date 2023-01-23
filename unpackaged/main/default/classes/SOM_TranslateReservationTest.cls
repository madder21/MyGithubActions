@isTest
public with sharing class SOM_TranslateReservationTest {
 
    static testMethod void test() {
 
        List<SOM_ADV_Reservation> inputList = new List<SOM_ADV_Reservation>();
 
        SOM_TranslateReservation.Requests testRequest = new SOM_TranslateReservation.Requests();
 
        testRequest.inputString = '[{"field1":"value1","field2":"value2"},{"field1":"value31","field2":"value4"}]';
        testRequest.inputCollection = inputList;
 
        List<SOM_TranslateReservation.Requests> testRequestList = new List<SOM_TranslateReservation.Requests>();
        testRequestList.add(testRequest);
 
        List<SOM_TranslateReservation.Results> testResponseList = SOM_TranslateReservation.translateADR(testRequestList);
        system.debug('RESPONSE - '+testResponseList);
        system.assertEquals(testResponseList[0].outputCollection.size(), 2);
    }
 
}