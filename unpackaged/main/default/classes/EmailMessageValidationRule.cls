/***********************************
 * 
 * Creation date : 22/02/2023
 * Created By : JBR
 * Company : RIMOWA
 * 
 * Date        | By                   | Company        | Modifications description
 * ------------|----------------------|----------------|-------------------------
 * 12/10/2023  | Julien Breuleux      | Vo2-group      | Initial Creation
 * 
 * Description : 
 *      Validation rule triggered before sending an email for SME.
 *      User cannot send an email to a customer email domain 
 *      --> i.e : ToAddress email domain must match the CMDT 'Admin_Email__mdt ' list.
 *      Triggered by : EmailMessage.apxt
 * 
************************************/


public class EmailMessageValidationRule {
    
    /**
     * Processes a list of EmailMessage records to enforce domain validation rules,
     * except for users with the 'ByPassVR' custom permission.
     * 
     * @param emailMessages The list of EmailMessage records to process.
     */
    public static void errorMessageSME(List<EmailMessage> emailMessages) {
        // Log the start of processing and the count of email messages.
        System.debug('Start processing email messages, total count: ' + emailMessages.size());
        
        // Check for the 'ByPassVR' custom permission to determine if validation should be skipped.
        if(FeatureManagement.checkPermission('ByPassVR')) {
            // If the user has the permission, log this and skip further processing.
            System.debug('User has ByPassVR permission, skipping validation.');
            return;
        }
        
        // Initialize a set to store all unique email domains extracted from the email messages.
        Set<String> allEmailDomains = new Set<String>();
        
        // Iterate over each email message to extract domains from the 'ToAddress' field.
        for(EmailMessage emailMessage : emailMessages) {
            if(String.isNotBlank(emailMessage.ToAddress)) {
                // Split the 'ToAddress' field by comma or semicolon to handle multiple email addresses.
                List<String> emailAddresses = new List<String>(emailMessage.ToAddress.split('[;,]'));
                for(String emailAddress : emailAddresses) {
                    // Ensure domains start with '@' and extract the domain from each email address.
                    String domain = '@' + getEmailDomain(emailAddress);
                    if(String.isNotBlank(domain)) {
                        // Add the domain in lowercase to the set for consistent comparison.
                        allEmailDomains.add(domain.toLowerCase());
                        System.debug('Domain to verify: ' + domain);
                    }
                }
            }
        }
        
        // Proceed if there are any domains to verify against the allowed list.
        if(!allEmailDomains.isEmpty()) {
            // Fetch the allowed domains from Custom Metadata for comparison.
            Set<String> allowedDomains = fetchAllowedDomains(allEmailDomains);
            System.debug('Allowed domains from Custom Metadata: ' + allowedDomains);
            
            // Iterate over the email messages again to check domain restrictions.
            for(EmailMessage emailMessage : emailMessages) {
                if(emailMessage.ToSme__c) {
                    // Check if any of the domains are not allowed.
                    boolean isDomainNotAllowed = checkDomainRestrictions(emailMessage, allowedDomains);
                    if(isDomainNotAllowed) {
                        // If any domain is not allowed, log this and add an error message to the email message.
                        System.debug('Disallowed domain found for EmailMessage: ' + emailMessage.Id);
						emailMessage.addError('At least one email address contains a domain name that does not correspond to an SME recipient.');
                    }
                }
            }
        } else {
            // Log if no email domains were extracted for validation.
            System.debug('No email domains extracted to check against Custom Metadata.');
        }
    }
    
    /**
     * Fetches allowed domains from Custom Metadata based on the provided set of domains.
     * 
     * @param allEmailDomains The set of domains to check against the allowed list.
     * @return A set of allowed domains in lowercase.
     */
    private static Set<String> fetchAllowedDomains(Set<String> allEmailDomains) {
        Set<String> allowedDomains = new Set<String>();
        for(Admin_Email__mdt adminEmail : [SELECT EmailDomain__c FROM Admin_Email__mdt WHERE EmailDomain__c IN :allEmailDomains]) {
            allowedDomains.add(adminEmail.EmailDomain__c.toLowerCase());
        }
        return allowedDomains;
    }
    
    /**
     * Checks if any of the domains from the email message are allowed.
     * 
     * @param emailMessage The EmailMessage being processed.
     * @param allowedDomains The set of allowed domains for comparison.
     * @return True if any domain is not allowed, otherwise false.
     */
    private static boolean checkDomainRestrictions(EmailMessage emailMessage, Set<String> allowedDomains) {
        List<String> emailAddresses = new List<String>(emailMessage.ToAddress.split('[;,]'));
        for(String emailAddress : emailAddresses) {
            String domain = '@' + getEmailDomain(emailAddress);
            if(String.isNotBlank(domain) && !allowedDomains.contains(domain.toLowerCase())) {
                // Return true if any domain is not found in the allowed list.
                return true;
            }
        }
        // Return false if all domains are allowed.
        return false;
    }
    
    /**
     * Extracts the domain from a given email address.
     * 
     * @param emailAddress The email address from which to extract the domain.
     * @return The extracted domain, or null if the email address is invalid.
     */
    private static String getEmailDomain(String emailAddress) {
        if(String.isNotBlank(emailAddress) && emailAddress.contains('@')) {
            // Extract and return the domain part of the email address.
            String domain = emailAddress.substring(emailAddress.indexOf('@') + 1);
            System.debug('Extracting domain: ' + domain + ' from emailAddress: ' + emailAddress);
            return domain;
        }
        return null;
    }
}