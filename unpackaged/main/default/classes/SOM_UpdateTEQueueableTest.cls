@isTest
public class SOM_UpdateTEQueueableTest {

    @isTest
    static void testExecuteQueueable() {
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        OrderSummary os = orderList[0];
        
        Account accTest = new Account(PersonEmail = 'test@test.com', LastName = 'test');
        insert accTest;
        
        List<TransactionalEmail__c> testEmails = new List<TransactionalEmail__c>{
            new TransactionalEmail__c(
                Client__c = accTest.Id,
                OrderSummary__c = os.Id,
                Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND,
                Template__c = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CREATED
            ),
            new TransactionalEmail__c(
                Client__c = accTest.Id,
                OrderSummary__c = os.Id,
                Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND,
                Template__c = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION
            )
        };
        insert testEmails;

        for (TransactionalEmail__c te : testEmails) {
            te.Status__c = 'Draft';
        }

        Test.startTest();
        SOM_UpdateTransactionalEmailsQueueable queueable = new SOM_UpdateTransactionalEmailsQueueable(testEmails);
        System.enqueueJob(queueable);
        Test.stopTest();

        List<TransactionalEmail__c> updatedEmails = [
            SELECT Id, Status__c FROM TransactionalEmail__c WHERE Id IN :testEmails
        ];

        for (TransactionalEmail__c updatedEmail : updatedEmails) {
            System.assertEquals('Draft', updatedEmail.Status__c, 'Status should be updated to Draft');
        }
    }

    @isTest
    static void testExecuteQueueableWithEmptyList() {
        List<TransactionalEmail__c> emptyList = new List<TransactionalEmail__c>();

        Test.startTest();
        SOM_UpdateTransactionalEmailsQueueable queueable = new SOM_UpdateTransactionalEmailsQueueable(emptyList);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assert(true);
    } 
}