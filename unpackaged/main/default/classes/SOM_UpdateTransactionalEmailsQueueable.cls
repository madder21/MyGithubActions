public class SOM_UpdateTransactionalEmailsQueueable implements Queueable, Database.AllowsCallouts {
    private List<TransactionalEmail__c> emailsToUpdate;

    public SOM_UpdateTransactionalEmailsQueueable(List<TransactionalEmail__c> emailsToUpdate) {
        this.emailsToUpdate = emailsToUpdate;
    }

    public void execute(QueueableContext context) {
        if (emailsToUpdate != null && !emailsToUpdate.isEmpty()) {
            try {
                update emailsToUpdate;
            } catch (Exception e) {
                System.debug('Error updating Transactional Emails: ' + e.getMessage());
            } 
        }
    }
}