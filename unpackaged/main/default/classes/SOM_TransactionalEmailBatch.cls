global class SOM_TransactionalEmailBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private Integer recoveryHour;
    Map<Id, TransactionalEmail__c> emailsToUpdate = new Map<Id, TransactionalEmail__c>();
    private List<TransactionalEmail__c> emailsToResend = new List<TransactionalEmail__c>();
    private List<TransactionalEmail__c> invoicesToDelete = new List<TransactionalEmail__c>();
    Map<Id, String> deletionResults = new Map<Id, String>();
    private List<String> TransactionalId;

    public SOM_TransactionalEmailBatch() {
        recoveryHour = (Integer) [SELECT RecoveryHour__c FROM recoveryHourTE__mdt WHERE DeveloperName = 'recoveryHour' LIMIT 1].RecoveryHour__c;
    }

    public SOM_TransactionalEmailBatch(List<String> TransactionalIds) {
        recoveryHour = (Integer) [SELECT RecoveryHour__c FROM recoveryHourTE__mdt WHERE DeveloperName = 'recoveryHour' LIMIT 1].RecoveryHour__c;
        TransactionalId = TransactionalIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Datetime recoveryDatetime = System.now().addHours(-recoveryHour);
        Datetime timeMinus10Minutes = System.now().addMinutes(-10);
        String query;

        if (Test.isRunningTest()) {
            query = 'SELECT Id, Template__c, Status__c, TECH_CustomerKey__c FROM TransactionalEmail__c WHERE Id IN :TransactionalId';
        } else {
            query = 'SELECT Id, Template__c, Status__c, TECH_CustomerKey__c FROM TransactionalEmail__c ' +
                    'WHERE Status__c = \'To send\' ' +
                    'AND OrderSummary__r.Status != \'Canceled\' ' +
                    'AND CreatedDate > :recoveryDatetime ' +
                    'AND CreatedDate < :timeMinus10Minutes';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<TransactionalEmail__c> records) {
        Set<Id> emailsToResendIds = new Set<Id>(); // Track IDs to avoid duplicates

        for (TransactionalEmail__c email : records) {
            email.Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_DRAFT;
            emailsToUpdate.put(email.Id, email);

            if (email.Template__c == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE) {
                invoicesToDelete.add(email);
            }


            if (!emailsToResendIds.contains(email.Id)) {
                emailsToResend.add(new TransactionalEmail__c(Id = email.Id, Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND));
                emailsToResendIds.add(email.Id);
            }
        }

        if (!invoicesToDelete.isEmpty() && !Test.isRunningTest()) {
            String oAUTHAccessToken = BackInStockBatchHelper.getSFMCAccessToken();
            deletionResults = AP2_SOMInvoiceManagement.SOM_DeleteInvoicesFromSFMC2(invoicesToDelete, oAUTHAccessToken);
        }

        for (Id EmailId : deletionResults.keySet()) {
            if (deletionResults.get(EmailId) == 'OK' && emailsToUpdate.containsKey(EmailId)) {
                emailsToUpdate.get(EmailId).TECH_GenerateInvoice__c = false;
                emailsToUpdate.get(EmailId).TECH_CustomerKey__c = null;
            }
        }
        if (!emailsToUpdate.isEmpty()) {
            update emailsToUpdate.values();
            System.enqueueJob(new SOM_UpdateTransactionalEmailsQueueable(emailsToUpdate.values()));
        }
    }

    global void finish(Database.BatchableContext BC) {



        if (!emailsToResend.isEmpty()) {
            System.enqueueJob(new SOM_UpdateTransactionalEmailsQueueable(emailsToResend));
           // update emailsToResend;
        }
        system.debug('emailsToResend'  + emailsToResend) ;
    }
}