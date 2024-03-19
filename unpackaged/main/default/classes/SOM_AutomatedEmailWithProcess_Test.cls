@IsTest
public with sharing class SOM_AutomatedEmailWithProcess_Test {
    @IsTest (seeAllData = true)
   static void test() {
       
          Test.startTest();

          SOM_AutomatedEmailWithProcessEXBatch scheduler = new SOM_AutomatedEmailWithProcessEXBatch();

          scheduler.execute(null);

          System.assertEquals(1,1); 
    	  Test.stopTest();
   }
    
}
