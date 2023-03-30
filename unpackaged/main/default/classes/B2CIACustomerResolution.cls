/**
 * @author Eric Schultz
 * @date April 28th, 2021
 *
 * @description This class helps identify relevant duplicates for a contact which can be used to decide how to process updates or inserts
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|	Date of modication	|	Modified By		|	Related Jira Ticket		|	Description of changes			
 * 0.0		|	?					|	Eric Shcultz 	|	.						|	.original version B2C Eric Shcultz package
 * 1.0		|	2022-11-29			|	.MA				|	.						|	.Viseo Method ConnectorBToCNewLogic() => add a return case, when contacts are found with the same email, and no B2C Customer ID or No, return the first contact found ordered by created date  
 * 2.0		|	2023-02-17			|	.AS				|	.CI-74					|	.Devoteam : Method ConnectorBToCNewLogic() => changing the logic of matching contacts + Upgrade Version 57
 * 2.1		|	2023-03-20			|	.PLM			|	.CI-163					|	.Rimowa : Query of ConnectorBToCNewLogic modified to remove null possibilities and remove all return case, by on return at the end of the method + add comments
 *			|						|	.				|	.						|	.	
*/
public inherited sharing class B2CIACustomerResolution {

    /**
     * @description Runs B2C duplicate rules, retrieve potential duplicates, and filter through a companion Flow
     *
     * @param pContact {Contact} A specific contact to run find duplicates on
     * @returns {List<Contact>} The final list of contacts that exist that are relevant duplicates
     */
    public static List<Contact> findDupes(Contact pContact) {
        return B2CIACustomerResolution.ConnectorBToCNewLogic(pContact);
    }
    
    public static List<Contact> ConnectorBToCNewLogic(Contact contactToResolve) {
        
        List<Contact> contactListToReturn = new List<Contact>();
        Map<Id,Contact> contactsListWithIds = new  Map<Id,Contact>();
        //Query return list of contacts have the same email of entred contact
        //******2022-11-29 Add Ordering by LastModifiedDate************
        //******2022-02-17 upgrade matching rules --> LastName && FirstName && (Email || Phone)************
        //******2023-03-20 upgrade query to remove null possibilities 
		String firstNameCondition = !String.isBlank(contactToResolve.FirstName) ? ' AND firstname = \'' + contactToResolve.FirstName + '\')' : ')';
        String emailAndPhoneCondition = '';
        //IF EMAIL AND PHONE
        if(!String.isBlank(contactToResolve.Email) && !String.isBlank(contactToResolve.Phone))
           emailAndPhoneCondition = ' AND (Email = \'' + contactToResolve.Email + '\' OR Phone = \'' +  contactToResolve.Phone + '\')';
        //ELSE IF EMAIL BUT NO PHONE
        else if(!String.isBlank(contactToResolve.Email) && String.isBlank(contactToResolve.Phone))
           emailAndPhoneCondition = ' AND Email = \'' + contactToResolve.Email + '\'';
        //ELSE IF PHONE BUT NO EMAIL
        else if(String.isBlank(contactToResolve.Email) && !String.isBlank(contactToResolve.Phone))
           emailAndPhoneCondition = ' AND Phone = \'' +  contactToResolve.Phone + '\'';
        else return null;//IF No Email AND NO Phone Reject the rest of the Method
        
        String query = 'Select Id, AccountId, B2C_CustomerList__c, B2C_CustomerList_ID__c, B2C_Customer_ID__c,'+ 
                       'B2C_Customer_No__c, FirstName, LastName, Email, Phone, B2C_Disable_Integration__c, 	B2C_Date_Last_Modified__c '+
                       'From Contact where (LastName = \'' + contactToResolve.LastName + '\''
            			+ firstNameCondition + emailAndPhoneCondition + ' ORDER BY CreatedDate DESC ';
        System.debug('*** B2CIACustomerResolution.ConnectorBToCNewLogic() Query : ' + query);
        List<Contact> matchedContactRecords = Database.query(query, AccessLevel.SYSTEM_MODE);
        
        //Case 1 : One Contact Found => Return the found contact
        if(matchedContactRecords.size()==1) contactListToReturn = matchedContactRecords;
        
        //Case 2 : Multiple Contact Found
        else if(matchedContactRecords.size()>1){
            //Look for contacts with B2C Ids
            for(Contact contactLine : matchedContactRecords){
                if(contactLine.B2C_Customer_ID__c != null && contactLine.B2C_Customer_No__c != null){
                    contactsListWithIds.put(contactLine.Id,contactLine);
                }
            }
            //Case 2.1 : IF one contact with B2C Ids is Found return it
            if(contactsListWithIds.size()==1){
                contactListToReturn = contactsListWithIds.values();
            }
            //Case 2.2 : IF multiple contact with B2C Ids are Found return the First Created
            else if(contactsListWithIds.size()>1){
                    contactListToReturn = [Select Id, AccountId, B2C_CustomerList__c, B2C_CustomerList_ID__c, B2C_Customer_ID__c, 
                    B2C_Customer_No__c, FirstName, LastName, Email, Phone, 	B2C_Date_Last_Modified__c
                     From Contact
                     Where Id IN : contactsListWithIds.keySet()
                     ORDER BY createdDate DESC
                     limit 1];
            }
            //Case 2.3 : No contact with B2C Ids return the first matched contact by Query
            else contactListToReturn.add(matchedContactRecords.get(0));
        }
        //Case 3 : No contact Found by the Query => Return an empty list
        else contactListToReturn = new List<Contact>();
        
        return contactListToReturn;
        
    }
    
    

    /**
     * @description Invocable action to retrieve relevant contact duplicates for standard and person account models
     *
     * @param contactList {List<Contact>} A list of contacts but is expected to have only 1 item. This is to support use within Flow.
     * @returns {List<List<Contact>>} Returns a list of list of contacts. This is expected to have only 1 item in the main list to support use with Flow.
     */
    @InvocableMethod(Label='B2C: Customer Resolution' Description='Finds matching contacts based on B2C matching rules')
    public static List<B2CIACustomerResolutionResult> resolve(List<Contact> contactList) {

        // Initialize local variables
        B2CIACustomerResolutionResult resolutionResults;
        List<B2CIACustomerResolutionResult> output;

        // Initialize the output variable
        output = new List<B2CIACustomerResolutionResult>();

        // Initialize the resolution results
        resolutionResults = new B2CIACustomerResolutionResult();
        resolutionResults.isError = false;

        // Was a contact found in the input parameter?
        if (contactList.size() != 1) {

            // If not, indicate an error occurred
            resolutionResults.isError = true;
            resolutionResults.errorMessage = 'No sourceContact provided to B2CIACustomerResolution class.  Check your input and please try again.';

        } else {

            // Otherwise, access the first contact
            Contact c = contactList[0];

           try {

                // Add the resolution results to the output class
                resolutionResults.contactList = B2CIACustomerResolution.findDupes(c);

            } catch (System.HandledException e) {

                // Indicate that an error occurred
                resolutionResults.isError = true;

                // Capture the error message from the exception
                resolutionResults.errorMessage = e.getMessage();

            }

        }

        // Build the output variable with the processing results
        output.add(resolutionResults);

        // Return the output variable
        return output;

    }
    
}