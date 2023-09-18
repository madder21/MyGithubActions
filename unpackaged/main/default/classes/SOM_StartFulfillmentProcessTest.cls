@isTest
public with sharing class SOM_StartFulfillmentProcessTest {

@isTest
    static void TestPushEvent() {
     
      test.enablechangedatacapture();
      test.starttest ();
      Start_Fulfillment_Process__e fulfillmentEvent = new Start_Fulfillment_Process__e (OrderSummaryID__c = 'TEST' );
	  list<Database.SaveResult> sr = eventbus.publish (new List< Start_Fulfillment_Process__e > {FulfillmentEvent} );
      test.geteventbus().deliver();
      test.stoptest ();
      system.assertEquals(1, sr.size(),'Expected one fulfillmentEvent to be published') ;
      system.assertEquals(true, sr[0].isSuccess(),'FulfillmentEvent has not been published') ;
      
    }
}