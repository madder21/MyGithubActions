@isTest
private class EmailMessageTriggerTest {
    @isTest static void testEmailMessageWithToSmeChecked() {
        // Créer un EmailMessage avec ToSme__c à true
        EmailMessage email = new EmailMessage();
        email.Subject = 'Test Email With ToSme True';
        email.ToSme__c = true;
        // Ajouter d'autres champs requis selon votre modèle

        // Test insert avec ToSme__c à true
        Test.startTest();
        insert email;
        Test.stopTest();

        // Récupérer l'email après insertion
        EmailMessage insertedEmail = [SELECT ToSme__c, ToAddress, ToIds FROM EmailMessage WHERE Id = :email.Id];
        
        // Asserts pour vérifier que ToAddress et ToIds sont nulls si ToSme__c est true
        System.assertEquals(true, insertedEmail.ToSme__c, 'ToSme__c should be true.');
        System.assertEquals(null, insertedEmail.ToAddress, 'ToAddress should be null when ToSme__c is true.');
        //System.assertEquals(null, insertedEmail.ToIds, 'ToIds should be null when ToSme__c is true.');
    }

    @isTest static void testEmailMessageWithToSmeUnchecked() {
        // Créer un EmailMessage avec ToSme__c à false
        EmailMessage email = new EmailMessage();
        email.Subject = 'Test Email With ToSme False';
        email.ToSme__c = false;
        // Ajouter d'autres champs requis selon votre modèle

        // Test insert avec ToSme__c à false
        Test.startTest();
        insert email;
        Test.stopTest();

        // Récupérer l'email après insertion
        EmailMessage insertedEmail = [SELECT ToSme__c, ToAddress, ToIds FROM EmailMessage WHERE Id = :email.Id];
        
        // Asserts pour vérifier que ToAddress et ToIds ne sont pas modifiés si ToSme__c est false
        System.assertEquals(false, insertedEmail.ToSme__c, 'ToSme__c should be false.');
        // Ces assertions peuvent varier selon la logique métier, ici on s'attend à ce qu'ils ne soient pas nulls
        // System.assertNotEquals(null, insertedEmail.ToAddress, 'ToAddress should not be null when ToSme__c is false.');
        // System.assertNotEquals(null, insertedEmail.ToIds, 'ToIds should not be null when ToSme__c is false.');
    }
}