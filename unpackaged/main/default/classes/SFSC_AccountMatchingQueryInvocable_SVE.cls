/***********************************
 * 
 * Creation date : 12/10/2023
 * Created By : UND
 * Company : RIMOWA
 * 
 * Date        | By                   | Company        | Modifications description
 * ------------|----------------------|----------------|-------------------------
 * 12/10/2023  | Ulrich Ndong         | RIMOWA         | Initial Creation
 * 12/10/2023  | Julien Breuleux      | Vo2-Group      | Modification of Dynamic conditions
 * 16/10/2023  | Inan Diktas          | Vo2-Group      | Modification of Dynamic conditions (adding the OR conditions)
 * 18/10/2023  | Julien Breuleux      | Vo2-Group      | Modification of query Phones parameters (delete: Phone2/Phone3/MobilePhone because of non indexed fields)
 * 
 * Description : 
 *      This method queries the Account object based on the input provided.
 *      The input can contain customer's first name, last name, phone, and email.
 *      The query is constructed dynamically based on the non-empty input values.
 *      @param input List of CaseProcessInput instances containing the customer details.
 *      @return List of Account records that match the criteria. 
 * 
************************************/

public class SFSC_AccountMatchingQueryInvocable_SVE {

    @InvocableMethod(label='SFSC - Account Matching Apex Query' category='Account' description='Returns the list of account')
    public static List<List<Account>> runProcess(List<CaseProcessInput> input) {
        // Get the first input instance from the list
        CaseProcessInput inp = input[0];
        // Debug log to print the input values
        System.debug('**** inp ****: ' + inp);

        // List to hold the WHERE clause conditions
        List<String> conditions = new List<String>();

        // Construct the conditions for first name and last name based on their values
        if (!String.isBlank(inp.customerFirstName) && !String.isBlank(inp.customerLastName)) {
            conditions.add('(FirstName=\'' + String.escapeSingleQuotes(inp.customerFirstName) + '\' AND LastName=\'' + String.escapeSingleQuotes(inp.customerLastName) + '\')');
        } else if (!String.isBlank(inp.customerFirstName)) {
            conditions.add('FirstName=\'' + String.escapeSingleQuotes(inp.customerFirstName) + '\'');
        } else if (!String.isBlank(inp.customerLastName)) {
            conditions.add('LastName=\'' + String.escapeSingleQuotes(inp.customerLastName) + '\'');
        }

        // Construct the conditions for phone and email based on their values
        List<String> phoneAndEmailConditions = new List<String>();
        
		/******* Phones fields are not indexed yet ******
        if (!String.isBlank(inp.customerPhone)) {
            phoneAndEmailConditions.add('(Phone =\'' + String.escapeSingleQuotes(inp.customerPhone) + '\' OR Phone2__pc =\'' + String.escapeSingleQuotes(inp.customerPhone) + '\' OR Phone3__pc =\'' + String.escapeSingleQuotes(inp.customerPhone) + '\' OR PersonMobilePhone =\'' + String.escapeSingleQuotes(inp.customerPhone) + '\')');
        }
		*******/
        
        if (!String.isBlank(inp.customerPhone)) {
            phoneAndEmailConditions.add('((Phone != null AND Phone =\'' + String.escapeSingleQuotes(inp.customerPhone) + '\'))');
        }

        if (!String.isBlank(inp.customerEmail)) {
            phoneAndEmailConditions.add('(OtherEmail__pc =\'' + String.escapeSingleQuotes(inp.customerEmail) + '\' OR PersonEmail =\'' + String.escapeSingleQuotes(inp.customerEmail) + '\')');
        }

        if (!phoneAndEmailConditions.isEmpty()) {
            conditions.add('(' + String.join(phoneAndEmailConditions, ' OR ') + ')');
        }

        // Construct the main query
        String query = 'SELECT Id, Name, Phone, Phone2__pc, Phone3__pc, PersonMobilePhone, OtherEmail__pc, PersonEmail, FirstName, LastName FROM Account';
        // Add the WHERE clause if there are conditions
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        // Debug log to print the constructed query
        System.debug('**** query ****: ' + query);
        List<Account> accountList = new List<Account>();
        if (!conditions.isEmpty()) {
            // Execute the query if there are conditions
            accountList = Database.query(query);
        }
        
        // Prepare the result in the required format
        List<List<Account>> itemListList = new List<List<Account>>();
        itemListList.add(accountList);

        return itemListList;
    }

    /**
     * Inner class to represent the input parameters.
     */
    public class CaseProcessInput {
        @InvocableVariable(label='Customer Phone')
        public String customerPhone;

        @InvocableVariable(label='Customer FirstName')
        public String customerFirstName;

        @InvocableVariable(label='Customer LastName')
        public String customerLastName;

        @InvocableVariable(label='Customer Email')
        public String customerEmail;
    }
}