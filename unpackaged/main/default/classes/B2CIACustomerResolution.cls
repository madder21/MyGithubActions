/**
 * @author Eric Schultz
 * @date April 28th, 2021
 *
 * @description This class helps identify relevant duplicates for a contact which can be used to decide how to process updates or inserts
 * @Modifications : 
 * 2022-11-29 :  Method ConnectorBToCNewLogic() => add a return case, when contacts are found with the same email, and no B2C Customer ID or No, 
 *               return the first contact found ordered by created date  
 * @V2.0 : Modified by Abdelkhaled SAIDI
 * @V2.0 : date : February 17th, 2023
 * @V2.0 : Modifications : Method ConnectorBToCNewLogic() => changing the logic of matching contacts + Upgrade Version 57
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

        List<Contact> matchedContactRecords = [Select Id, AccountId, B2C_CustomerList__c, B2C_CustomerList_ID__c, B2C_Customer_ID__c, 
                                        B2C_Customer_No__c, FirstName, LastName, Email, Phone, B2C_Disable_Integration__c
                                        From Contact where
                                        (FirstName =: contactToResolve.FirstName AND LastName =: contactToResolve.LastName) 
                                        AND 
                                        (((Phone != null) AND (Phone =: contactToResolve.Phone)) 
                                        OR
                                        ((Email != null) AND (Email =: contactToResolve.Email)))
                                        ORDER BY CreatedDate DESC];
        
        if(matchedContactRecords.size()==1){
            return matchedContactRecords;
        }
        else if(matchedContactRecords.size()>1){
            //Look for contacts with B2C Ids
            for(Contact contactLine : matchedContactRecords){
                if(contactLine.B2C_Customer_ID__c != null && contactLine.B2C_Customer_No__c != null){
                    contactsListWithIds.put(contactLine.Id,contactLine);
                    
                }
            }
            //IF one contact with B2C Ids is Found return it
            if(contactsListWithIds.size()==1){
                return contactsListWithIds.values();
            }
            //IF multiple contact with B2C Ids is Found return the last modified
            else if(contactsListWithIds.size()>1){
                    return  [Select Id, AccountId, B2C_CustomerList__c, B2C_CustomerList_ID__c, B2C_Customer_ID__c, 
                    B2C_Customer_No__c, FirstName, LastName, Email, Phone, B2C_Disable_Integration__c
                     From Contact
                     Where Id IN : contactsListWithIds.keySet()
                     ORDER BY createdDate DESC
                     limit 1];
                    
            }
            //No contact with B2C Ids return the first matched contact by Query
            else{
                    return new List<Contact>{matchedContactRecords.get(0)};
                }
        }
        else{
            return contactListToReturn;
        }
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