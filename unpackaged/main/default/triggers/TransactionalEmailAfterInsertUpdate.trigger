/**
 * @author Paul Louis MONY
 * @date March,6th 2023
 * @Type Trigger on TransactionalEmail__c After Insert Update
 *****************************************************************************************************************************************************************
 * @description : Separate Trigger for Transactional Email to avoid modification on SOM component SOM_TransactionalEmailHandler.generateOrderTransactionalEmails();
 * 				  generate Invoice in SFMC Content Builder When TransactionalEmail__c Template__c = Invoice and Status__c = To send and the flag TECH_GenerateInvoice__c = false;
 * 				  When the Invoice is generated in SFMC Content Builder flag the record with TECH_GenerateInvoice = true;
 * 				  Then the email is sent the flag Status => Sent, at this moment SFDC have to delete the Invoice in Content builder to available the resend of the email.
 * This class need class : *SOM_Constants 
 * 
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|	Date of modication	|	Modified By		|	Related Jira Ticket		|		Description of changes			
 * 0.0		|	2023/03/06			|	.PLM			|	.						|		.original version 
 * 0.1		|	2023/03/08			|	.PLM			|	.						|		.add List deleteInvoiceTransactionalEmails to launch deletion of Asset in SFMC
*/
trigger TransactionalEmailAfterInsertUpdate on TransactionalEmail__c (After insert,After Update) {
	List<TransactionalEmail__c> generateInvoiceTransactionalEmails = new List<TransactionalEmail__c>();
    List<TransactionalEmail__c> deleteInvoiceTransactionalEmails = new List <TransactionalEmail__c>();
    For(TransactionalEmail__c transacEmail : Trigger.New){
        
        if(transacEmail.Template__c == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE &&
          transacEmail.Status__c == SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND &&
           !transacEmail.TECH_GenerateInvoice__c){
               generateInvoiceTransactionalEmails.add(transacEmail);
        }
        
        if(transacEmail.Template__c == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE &&
          transacEmail.Status__c == SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_SENT &&
           transacEmail.TECH_GenerateInvoice__c &&  transacEmail.TECH_CustomerKey__c != null){
               deleteInvoiceTransactionalEmails.add(transacEmail);
        }
    }
    
    if(generateInvoiceTransactionalEmails.size()>0){
        AP2_SOMInvoiceManagement.SOM_GenerateInvoicesInSFMC(generateInvoiceTransactionalEmails);
    }
    
    if(deleteInvoiceTransactionalEmails.Size()>0){
        AP2_SOMInvoiceManagement.SOM_DeleteInvoicesFromSFMC(deleteInvoiceTransactionalEmails);
    }
}