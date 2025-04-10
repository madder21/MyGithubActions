public class SOM_UpdateTransactionalEmailsQueueable implements Queueable, Database.AllowsCallouts {
    private List<TransactionalEmail__c> emailsToUpdate;

    public SOM_UpdateTransactionalEmailsQueueable(List<TransactionalEmail__c> emailsToUpdate) {
        this.emailsToUpdate = emailsToUpdate;
    }

    public void execute(QueueableContext context) {
        if (emailsToUpdate != null && !emailsToUpdate.isEmpty()) {
            try {
                update emailsToUpdate;
                Logs.debug('Update Transactional Emails', 'SOM_UpdateTransactionalEmailsQueueable', 'Queueable Execute', '', '', '');
                Logs.info('Update Transactional Emails', 'SOM_UpdateTransactionalEmailsQueueable', 'Queueable Execute', '', '', '');
            } catch (Exception e) {
                Logs.error(e, 'Update Transactional Emails', 'Queueable Execute', '', '', '');
            }
        }
    }
}