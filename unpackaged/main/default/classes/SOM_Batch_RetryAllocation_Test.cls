@isTest
public with sharing class SOM_Batch_RetryAllocation_Test {


    public static List<OrderSummary> makeData(){

        List<OrderSummary> osList = new List<OrderSummary>();
        List<ProcessException> pes = new List<ProcessException>();

        // HD
        List<OrderSummary> osHDList = new List<OrderSummary>();
        osHDList = SOM_testDataFactory.createOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,1);
        List<OrderItemSummary> oisHDList = [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId =: osHDList[0].Id AND Type =: 'Order Product'];
        ProcessException peToCreate = new ProcessException();
        peToCreate.Category         = 'Fulfillment';
        peToCreate.Status           = 'New';
        peToCreate.Severity         = 'High';
        peToCreate.Message          = 'Insufficient Stock';
        peToCreate.Priority         = 'High';
        peToCreate.AttachedToId     = oisHDList[0].Id;
        peToCreate.OrderSummaryId   = osHDList[0].Id;
        pes.add(peToCreate);
        osList.addAll(osHDList);

        //STW
        List<OrderSummary> osSTWList = new List<OrderSummary>();
        osSTWList = SOM_testDataFactory.createSTWOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,1);
        List<OrderItemSummary> oisSTWList = [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId =: osSTWList[0].Id AND Type =: 'Order Product'];
        ProcessException peToCreate2 = new ProcessException();
        peToCreate2.Category         = 'Fulfillment';
        peToCreate2.Status           = 'New';
        peToCreate2.Severity         = 'High';
        peToCreate2.Message          = 'Insufficient Stock';
        peToCreate2.Priority         = 'High';
        peToCreate2.AttachedToId     = oisSTWList[0].Id;
        peToCreate2.OrderSummaryId   = osSTWList[0].Id;
        pes.add(peToCreate2);
        osList.addAll(osSTWList);

        insert pes;

        return osList;
    }


    @isTest (seeAllData = true)
    public static void batchTest(){
        List<OrderSummary> orderSummaryFromSetup = makeData();
        
        List<String> osIds = new List<String>();
        for(OrderSummary os : orderSummaryFromSetup){
            osIds.add(os.Id);
        }

        Test.startTest();
        Database.executeBatch(new SOM_Batch_RetryAllocation(), 100);
        Test.stopTest();
        List<OrderSummary> OS = [SELECT Id, Status FROM OrderSummary WHERE Id IN: osIds AND tech_PE_Fulfillment_Count__c > 0 AND On_Hold__c = false Order by CreatedDate desc];
        System.assertEquals( SOM_Constants.ORDER_SUMMARY_VALIDATED, OS[0].Status);
    }
}