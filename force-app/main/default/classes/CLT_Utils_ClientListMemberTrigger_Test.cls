/**
 * @author Eric Burté
 * @date March,26th 2023
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test method from CLT_Utils_ClientListMemberTrigger Apex class :
 * testSetup : Creation of Client, ClientList and ClientListMember
 * CLASS			       				|	RELATED TEST METHOD						|	DESCRIPTION
 * CLT_Utils_ClientListMemberTrigger	|	testCreateUniqueClientListMember		|	Add different Client List Members in the CLM list to be updated
 * CLT_Utils_ClientListMemberTrigger	|	testCreateDuplicateClientListMember		|	Add the same Client List Member in the CLM list to be updated, expecting for an exception
 * 										|											|	
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2023/03/26			|.EBU			|.						|.original version
 * 0.1		|					|.				|.						|
 * 																		  
*/

@isTest
private class CLT_Utils_ClientListMemberTrigger_Test {
   
    @testSetup static void setup() {      
        //Client list creation
        ClientList__c clientlist1 = new clientlist__c (name = 'DreamPurse');
        insert clientlist1;
        
        //Client creation
        Account client1 = new Account (firstname = 'Eric', lastname='BurtéTEST');
        insert client1;
        Account client2 = new Account (firstname = 'Ulrich', lastname='SalesforceZane');
        insert client2;
        
        //Client list member creation
        ClientListMember__c clm1 = new ClientListMember__c (Client__c = client1.Id, ClientList__c = clientlist1.Id, Name = 'EricBurtéDreamPurse', Status__c = 'Contacted');
        insert clm1;      
        ClientListMember__c clm2 = new ClientListMember__c (Client__c = client2.Id, ClientList__c = clientlist1.Id, Name = 'UlrichDreamPurse', Status__c = 'Contacted');
        insert clm2;  
    }
    
    @isTest private static void testCreateUniqueClientListMember() {
        Boolean bSuccess = true;
        List<ClientListMember__c> newClientListMembers = new List<ClientListMember__c>();

        ClientListMember__c clientList1 = [SELECT Id FROM ClientListMember__c WHERE Name='EricBurtéDreamPurse' LIMIT 1];
        ClientListMember__c clientList2 = [SELECT Id FROM ClientListMember__c WHERE Name='UlrichDreamPurse' LIMIT 1];
                
        Test.startTest();
        newClientListMembers.add(clientList1);
        newClientListMembers.add(clientList2);
        
        try{
            update newClientListMembers;
        }catch (Exception e) {
        	bSuccess = false;
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        Assert.areEqual(true, bSuccess, 'CLT_Utils_ClientListMemberTrigger_Test - testCreateOnlyOneContactsBasedOnCLMcreation - The ClientListMember list insertion failed');
    }
     
    @isTest private static void testCreateDuplicateClientListMember() {
        Boolean bSuccess = true;
        List<ClientListMember__c> newClientListMembers = new List<ClientListMember__c>();

        ClientListMember__c clientList1 = [SELECT Id FROM ClientListMember__c WHERE Name='EricBurtéDreamPurse' LIMIT 1];
        ClientListMember__c clientList2 = [SELECT Id FROM ClientListMember__c WHERE Name='EricBurtéDreamPurse' LIMIT 1];
        
        newClientListMembers.add(clientList1);
        newClientListMembers.add(clientList2);
        
        Test.startTest();
        try{
            update newClientListMembers;
        }catch (Exception e) {
        	bSuccess = false;
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        Assert.areEqual(false, bSuccess, 'CLT_Utils_ClientListMemberTrigger_Test - testCreateAllContactsBasedOnCLMcreation - The ClientListMember list insertion should have failed');
    }  
}