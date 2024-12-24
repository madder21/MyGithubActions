public with sharing class emailTemplateFilterController {

    @AuraEnabled
    public static List<EmailTemplate> getEmailTemplates(Id recordId, String templateType) {
        Case cc = [SELECT Id, CaseLanguage__c, Hub_Origin__c, Type FROM Case WHERE Id =: recordId];
        
        // Utilisez la méthode helper pour remplacer les espaces par des underscores
        String typeWithUnderscores = replaceSpacesAndDashesWithUnderscores(cc.Type);
        
        // Créez le modèle de nom d'origine avec DeveloperName
        String concatenateString =  templateType + '_' + cc.Hub_Origin__c + '_' + cc.CaseLanguage__c + '_' + typeWithUnderscores;
        List<EmailTemplate> options = [SELECT  DeveloperName, HtmlValue, Name FROM EmailTemplate WHERE DeveloperName LIKE :concatenateString + '%'];
        
        // Si aucun modèle n'est trouvé, essayez le modèle de nom par défaut avec DeveloperName
        if (options.isEmpty()) {
            String defaultTemplateName = templateType + '_' + cc.Hub_Origin__c + '_' + cc.CaseLanguage__c + '_Empty';
            options = [SELECT  DeveloperName, HtmlValue, Name FROM EmailTemplate WHERE DeveloperName LIKE :defaultTemplateName +'%'];
            system.debug('test : '+defaultTemplateName);
        }
        
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getEmailTemplatesBody(Id templateId) {
        // Cette méthode semble correcte, car elle n'utilise pas le Name pour la recherche
        List<EmailTemplate> body = [SELECT HtmlValue, Subject, EnhancedLetterhead.LetterheadFooter FROM EmailTemplate WHERE Id =:templateId];
        return body;
    }

    @AuraEnabled
    public static void saveEmailAsDraft(String ParentId, String Subject, String HtmlBody ) {
        // Cette partie du code reste inchangée, car elle ne concerne pas la recherche par Name ou DeveloperName
        List<EmailMessage> existingDrafts = [SELECT Id, CreatedDate, Subject, HtmlBody
                                            FROM EmailMessage
                                            WHERE ParentId = :ParentId AND Status = '5'
                                            ORDER BY CreatedDate DESC
                                            LIMIT 2];
        
        if (!existingDrafts.isEmpty()) {
            EmailMessage latestDraft = existingDrafts[0];

            // Update the HTML body
            latestDraft.HtmlBody = HtmlBody;

            // Check if the provided subject is not blank or null, and if so, update it
            if (!String.isBlank(Subject)) {
                latestDraft.Subject = Subject;
            }

            // Only perform an update if there are actual changes to the email
            update latestDraft;
        } else {
            // No existing drafts found; create a new draft
            EmailMessage draft = new EmailMessage();
            draft.Subject = Subject;
            draft.HtmlBody = HtmlBody;
            draft.ParentId = ParentId;
            draft.Status = '5'; // '5' corresponds to "Draft"

            try {
                insert draft;
            } catch (Exception e) {
                System.debug('Error message: ' + e.getMessage());
            }
        }
    }

    // Méthode helper modifiée pour remplacer à la fois les espaces et les tirets par des underscores
    private static String replaceSpacesAndDashesWithUnderscores(String input) {
        // Remplace d'abord les espaces par des underscores
        String replacedSpaces = input.replace(' ', '_');
        // Ensuite, remplace les tirets par des underscores
        String replacedDashes = replacedSpaces.replace('-', '_');
        return replacedDashes;
    }
}