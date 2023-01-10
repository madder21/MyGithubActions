@isTest
public with sharing class SOM_StartFulfillmentProcessTest {

@isTest

    static void TestPushEvent() {
      test.enablechangedatacapture();
      test.starttest ();
          
      
        Start_Fulfillment_Process__e fulfillmentEvent = new Start_Fulfillment_Process__e (OrderSummaryID__c = 'TEST' );

        eventbus.publish (new List< Start_Fulfillment_Process__e > {FulfillmentEvent} );
     test.geteventbus ().deliver();
        test.stoptest ();
    }
}