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
 * 2.2		|	2023-04-27			|	.PLM			|	.CI-166					|	.Modify the process to avoir vulnerability to SOQL Injection. 2 new methods : getMatchingContacts()	getNonNullableContactsQueryLocator()
 * 2.3		|	2023-10-18			|	.PLM			|	.CI-211					|	.Add OtherEmail in the binding
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
        
        //Get the Matching records
        List<Contact> matchedContactRecords = getMatchingContacts(contactToResolve);
        
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
    
    /**
     * @descriptionFinds and returns a list of Contact records that match the specified Contact, based on non-null values of the
     * LastName, FirstName, Email, and Phone fields. If neither Email nor Phone is present, returns an empty list.
     * 
     * @param contactToResolve The Contact record to match against.
     * @return A list of Contact records that match the specified Contact, or an empty list if no matches are found.
     */
    public static List<Contact> getMatchingContacts(Contact contactToResolve) {
    	// Get a query locator for non-null contacts that match the provided fields
    	Database.QueryLocator queryLocator = getNonNullableContactsQueryLocator(contactToResolve);
        if (queryLocator == null) {
            // Return empty list if neither Email nor Phone is present
            return new List<Contact>();
        }    
        // Iterate over matching records
        List<Contact> matchedContactRecords = new List<Contact>();
        Database.QueryLocatorIterator iterator = queryLocator.iterator();
        while (iterator.hasNext()) {
            matchedContactRecords.add((Contact)iterator.next());
        }        
        return matchedContactRecords;
    }
    
    /**
     * @description Returns a QueryLocator that retrieves non-null Contacts matching the specified criteria.
     *
     * @param contactToResolve A Contact Object with fields to be query in it
     * @return A QueryLocator object containing the matching Contacts.
     * LastUpdate : 18/10/2023 - CI-211 Add OtherEmail in the binding
     */
    public static Database.QueryLocator getNonNullableContactsQueryLocator(Contact contactToResolve) {
    	// Create list to hold the query conditions
        List<String> conditions = new List<String>();
    
        // Add conditions for non-null LastName and FirstName
        if (String.isNotEmpty(contactToResolve.LastName)) {
            conditions.add('LastName = :lastName');
        } else {    
            System.debug('B2CIACustomerResolution.getNonNullableContactsQueryLocator() :LastName can\'t be null');
            return null;
        }
    
        if (String.isNotEmpty(contactToResolve.FirstName)) {
            conditions.add('FirstName = :firstName');
        }
    
        // Add conditions for non-null Email and Phone
        if (String.isNotEmpty(contactToResolve.Email) && String.isNotEmpty(contactToResolve.Phone)) {
            conditions.add('(Email = :email OR Phone = :phone OR OtherEmail__c = :email)');
        } else if (String.isNotEmpty(contactToResolve.Email)) {
            // Add condition for non-null Email
            // #CI-211 : Add Other Email in the binding
            conditions.add('(Email = :email OR OtherEmail__c = :email)');
        } else if (String.isNotEmpty(contactToResolve.Phone)) {
            // Add condition for non-null Phone
            conditions.add('Phone = :phone');
        } 
        else {
            // Return null if neither Email nor Phone is present
            return null;
        }
    
        // Construct the SOQL query string using the conditions
        String soqlQuery = 'SELECT Id, AccountId, B2C_CustomerList__c, B2C_CustomerList_ID__c, B2C_Customer_ID__c, B2C_Customer_No__c, ' +
                           'FirstName, LastName, Email, OtherEmail__c, Phone, B2C_Disable_Integration__c, B2C_Date_Last_Modified__c ' +
                           'FROM Contact WHERE ' + String.join(conditions, ' AND ') + ' ORDER BY CreatedDate DESC';
        System.debug('B2CIACustomerResolution.getNonNullableContactsQueryLocator() soqlQuery = ' + soqlQuery);
    
        // Create map to hold the bind variables and their values
        Map<String, Object> bindVariables = new Map<String, Object>();
        bindVariables.put('lastName', contactToResolve.LastName);
        bindVariables.put('firstName', contactToResolve.FirstName);
        bindVariables.put('email', contactToResolve.Email);
        bindVariables.put('phone', contactToResolve.Phone);
        return Database.getQueryLocatorWithBinds(soqlQuery, bindVariables, AccessLevel.SYSTEM_MODE);
	}
}