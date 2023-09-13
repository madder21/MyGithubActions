/*
----------------------------------------------------------------------
-- - Name              :  Batch_BackInStock_Test
-- - Author            :  Mohamed Amine El Mandour
-- - Description       :  Test Class for Batch_BackInStock
-- Maintenance History :    
--
-- Date                 Name                        Version          Remarks
-- -----------          -----------                 --------         ----------------------
-- 17-03-2022           Mohamed Amine El Mandour    1.0              Initial version
-- 14-05-2022           Bader Eddine Elkhal         2.0              updated version
-- 24-04-2023			Paul-Louis MONY				3.0				 Add SFMCApiSettings data test and XML Soap Message into the mock & test method for sheduler and wrapper
---------------------------------------------------------------------------------------
*/
@isTest
private class Batch_BackInStock_Test {
    
    private static List<CommSubscriptionConsent> comSub = new List<CommSubscriptionConsent>();
    private static Map<String, Product_Inventory__c> productInventories = new Map<String, Product_Inventory__c>();
    private static Set<String> skutest = new Set<String>();
    
    //Private static 
    	@testSetup
    	private static void setupData(){
        //create a Product_Inventory__c and CommSubscriptionConsent
        Product_Inventory__c productInventorie = new Product_Inventory__c();
        CommSubscriptionConsent comSubConsent = new CommSubscriptionConsent();
        CommSubscriptionConsent comSubConsent2 = new CommSubscriptionConsent();
        
        productInventorie.sku__c = 'sku1';
        productInventorie.Warehouse__c = 'warhouse__c';
        productInventorie.ATS__c = 1;
        productInventorie.UK_product_inventory__c = '50500999_rimowa-inventory-eu';
        
        insert productInventorie;
        
        Account account = new Account(Name = 'accountN1');
        insert account;
        
        Individual individual = new Individual();
        individual.LastName='individual Test';
        individual.FirstName = 'firstName';
        insert individual;
        
        ContactPointEmail contactPointEmail = new ContactPointEmail(AccountId__c = account.Id,ParentId = individual.Id,EmailAddress = 'addressEmail@mail.com');
        insert contactPointEmail;
        
        CommSubscription commSub = new CommSubscription(Name = 'newCommSub');
        insert commSub;
        
        EngagementChannelType engChannelType = new EngagementChannelType(Name = 'engChannelType');
        insert engChannelType;
        
        CommSubscriptionChannelType comSubChannelType = new CommSubscriptionChannelType(AccountId__c = account.Id,Name = 'comSubChType',CommunicationSubscriptionId = commSub.Id,EngagementChannelTypeId = engChannelType.Id);
        insert comSubChannelType;
        
        comSubConsent.sku__c = 'sku1';
        comSubConsent.Name = 'BackInStock';
        comSubConsent.EffectiveFromDate = Date.valueOf('2022-02-22');
        comSubConsent.ContactPointId = contactPointEmail.Id;
        comSubConsent.CommSubscriptionChannelTypeId = comSubChannelType.Id;
        comSubConsent.Warehouse__c = 'warhouse__c';
        Batch_BackInStock_Test.comSub.add(comSubConsent);

        comSubConsent2.sku__c = 'sku1';
        comSubConsent2.Name = 'BackInStock';
        comSubConsent2.EffectiveFromDate = Date.valueOf('2022-02-21');
        comSubConsent2.ContactPointId = contactPointEmail.Id;
        comSubConsent2.CommSubscriptionChannelTypeId = comSubChannelType.Id;
        comSubConsent2.Warehouse__c = 'warhouse__c';
        Batch_BackInStock_Test.comSub.add(comSubConsent2);
            
        insert Batch_BackInStock_Test.comSub;
        
		SFMCAPISetting__c sfmcAPISetting = SFMCAPISetting__c.getOrgDefaults();
        sfmcAPISetting.BackInStockAutomationObjectId__c = '2d83649e-3c68-41de-9f4d-62e6af4f1bc7';
        sfmcAPISetting.LastSentEventId__c = 1;
        sfmcAPISetting.GrantType__c  ='grant_type';
        sfmcAPISetting.clientId__c = 'myclientId';
        sfmcAPISetting.clientSecret__c = 'myclientSecret';
        sfmcAPISetting.AccountId__c = 1010101;
        sfmcAPISetting.BackInStockDEExternalKey__c = '12345678901234567';
        sfmcAPISetting.SoapAPIPerformRequestMsgNs2Attribute__c = 'urn:fault.partner.exacttarget.com';
        sfmcAPISetting.SoapAPIPerformRequestMsgNsAttribute__c = 'http://exacttarget.com/wsdl/partnerAPI';
        sfmcAPISetting.SoapAPIToMustUnderstandAttribute__c = 'https://mcbbs8wnxr8g8rgdkxwky2mxqrq4.soap.marketingcloudapis.com/Service.asmx	';
        sfmcAPISetting.SoapAPIxmlnsaAttribute__c = 'http://schemas.xmlsoap.org/ws/2004/08/addressing';
        sfmcAPISetting.SoapAPIxmlnssAttribute__c = 'http://www.w3.org/2003/05/soap-envelope';
        sfmcAPISetting.SoapAPIxmlnsuAttribute__c='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd';
        sfmcAPISetting.SoapAPIxmlnsxsdAttribute__c='http://www.w3.org/2001/XMLSchema';
        sfmcAPISetting.SoapAPIxmlnsxsiAttribute__c='http://www.w3.org/2001/XMLSchema-instance';
        insert sfmcAPISetting; 
        
        Batch_BackInStock_Test.skutest.add('testSku');

    }
    
    @isTest  static void testBackInStock(){
        
        Product_Inventory__c productInventory = [SELECT sku__c, Warehouse__c, ATS__c 
                                                        FROM Product_Inventory__c 
                                                        WHERE ATS__c > 0 limit 1];
        Batch_BackInStock_Test.productInventories.put(productInventory.sku__c, productInventory); 
        List<CommSubscriptionConsent> commSuub= [SELECT sku__c, Warehouse__c
            FROM CommSubscriptionConsent  
            WHERE Name = 'BackInStock' AND EffectiveToDate = null AND sku__c IN:Batch_BackInStock_Test.productInventories.keyset()];
        
        System.debug('size of comm Sub: ' +  commSuub.size());
        
        Test.startTest();
        Batch_BackInStock batch = new Batch_BackInStock();
        String responseXml = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><RetrieveResponseMsg><Results><StatusMessage>Success</StatusMessage></Results></RetrieveResponseMsg></soap:Body></soap:Envelope>';
		MockHttpResponseGenerator mockResponse = new MockHttpResponseGenerator(responseXml);
		Test.setMock(HttpCalloutMock.class, mockResponse);
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        batch.start(null);
        batch.execute(null,commSuub);
        batch.execute(null);
        batch.finish(null);
        
        Test.stopTest();
        
     	Assert.areEqual(productInventory.sku__c, commSuub[0].sku__c, '');

       }
    
    @isTest
    static void testSchedulerExecution() {
        // Schedule the batch job using the scheduler class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String jobId = System.schedule('BackInStockBatchScheduler_Test', '0 20 01/02 * * ? *', new BackInStockBatchScheduler());
        Test.stopTest();
        
        // Verify that the job was scheduled
        Assert.isNotNull(jobId, 'Job was not scheduled');
        
        // Retrieve the scheduled job details
        CronTrigger scheduledJob = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        
        // Verify that the job has the correct Cron expression
        Assert.areEqual('0 20 01/02 * * ? *', scheduledJob.CronExpression, 'Incorrect Cron expression');
        
        // Verify that the job has the correct name
        Assert.areEqual('BackInStockBatchScheduler_Test', scheduledJob.CronJobDetail.Name, 'Incorrect job name');
    }
    
    @isTest
    static void testWrapperProperties() {
        // Create a new instance of the BackInStockWrapper
        BackInStockWrapper wrapper = new BackInStockWrapper();
        
        // Set values for the properties
        wrapper.sku = 'SKU123';
        wrapper.warehouse = 'Warehouse1';
        wrapper.ats = 10;
        
        // Verify that the properties have been set correctly
        Assert.areEqual('SKU123', wrapper.sku, 'SKU property should be set correctly');
        Assert.areEqual('Warehouse1', wrapper.warehouse, 'Warehouse property should be set correctly');
        Assert.areEqual(10, wrapper.ats, 'ATS property should be set correctly');
    }
    
    @isTest
    static void testWrapperInitialization() {
        // Create a new instance of the BackInStockWrapper
        BackInStockWrapper wrapper = new BackInStockWrapper();
        
        // Verify that the properties are initially null
        Assert.isNull(wrapper.sku, 'SKU property should be initially null');
        Assert.isNull(wrapper.warehouse, 'Warehouse property should be initially null');
        Assert.isNull(wrapper.ats, 'ATS property should be initially null');
    }
}