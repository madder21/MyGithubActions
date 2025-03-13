global class SOM_TransactionalEmailBatch implements Database.Batchable<SObject>, Database.Stateful {
    
        private static Integer recoveryHour;
        private List<TransactionalEmail__c> emailsToUpdate = new List<TransactionalEmail__c>();
        private List<TransactionalEmail__c> emailsToResend = new List<TransactionalEmail__c>();
        private List<TransactionalEmail__c> invoicesToDelete = new List<TransactionalEmail__c>();
        private List<String> TransactionalId ;
        public SOM_TransactionalEmailBatch() {
            recoveryHour = (Integer) [SELECT RecoveryHour__c FROM recoveryHourTE__mdt WHERE DeveloperName = 'recoveryHour' LIMIT 1].RecoveryHour__c;
        }
        public SOM_TransactionalEmailBatch(List<String> TransactionalIds) {
            recoveryHour = (Integer) [SELECT RecoveryHour__c FROM recoveryHourTE__mdt WHERE DeveloperName = 'recoveryHour' LIMIT 1].RecoveryHour__c;
            TransactionalId = TransactionalIds ;
            
        }
    
        global Database.QueryLocator start(Database.BatchableContext BC) {
            
            Datetime recoveryDatetime = System.now().addHours(-recoveryHour);
            Datetime timeMinus10Minutes = System.now().addMinutes(-10);
            String query ;
            if(Test.isRunningTest()){
                query = 'SELECT Id, Template__c, Status__c,TECH_CustomerKey__c FROM TransactionalEmail__c Where Id IN :TransactionalId' ;
                
            }else{
                
                query = 'SELECT Id, Template__c, Status__c,TECH_CustomerKey__c FROM TransactionalEmail__c ' +
                'WHERE Status__c = \'To Send\' ' +
                'AND OrderSummary__r.Status != \'Canceled\' ' +
                'AND CreatedDate > :recoveryDatetime ' +
                'AND CreatedDate < :timeMinus10Minutes';
                 
            }
            
            return Database.getQueryLocator(query);
        }
    
        global void execute(Database.BatchableContext BC, List<TransactionalEmail__c> records) {
            for (TransactionalEmail__c email : records) {
                email.Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_DRAFT;  
                emailsToUpdate.add(email); 
                if (email.Template__c == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE) {
                    invoicesToDelete.add(email);        
                }
                emailsToResend.add(new TransactionalEmail__c(id = Email.id,Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND));
    
                }           
    
            if (!emailsToUpdate.isEmpty()) {
                update emailsToUpdate;
            }
    
            if (!invoicesToDelete.isEmpty() && !Test.isRunningTest()) {
                AP2_SOMInvoiceManagement.SOM_DeleteInvoicesFromSFMC(invoicesToDelete);
            }
            
        }
    
        global void finish(Database.BatchableContext BC) {
            if(!emailsToResend.isEmpty()){
                update emailsToResend;
            }
 	   }
}