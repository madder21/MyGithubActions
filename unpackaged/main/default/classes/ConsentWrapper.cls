/**
 * @author AbdelKhalek Saidi
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class plays a role in achieving cleaner, modular code and promoting efficient development practices by
 * 			    consolidating all necessary objects in one place to effectively manage the consent process
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
*/
public with sharing class ConsentWrapper {
    
    //All objects
    public Account oldClient { get; set; }
    public Account client { get; set; }
    public Individual indiv { get; set; }
    public ContactPointEmail cpEmail { get; set; }
    public ContactPointPhone cpPhone { get; set; }
    public ContactPointAddress cpAddress { get; set; }
    public ContactPointTypeConsent cpTypeConsent { get; set; }
    public ContactPointConsent cpConsent { get; set; }
    public B2CCustomInput__c customInput { get; set; }
    public CommSubscriptionConsent commSubConsent; 
 	
    //All primitive data
    public  DateTime optDate = DateTime.now(); 
    public  Boolean doubleOptin = false;
    public  Boolean clientToUpdate = false;
    public  String captureContactPointType = 'Web';
    public  String captureSource = 'SFDC Contact Process';
    public  String customContactPointType = 'SFDC';
    public  String contactPointType = 'Email'; 
	
    //Constractors
    public ConsentWrapper(B2CCustomInput__c customInput, Account client) {
        this.customInput = customInput;
        this.client = client;
    }
    public ConsentWrapper(Account client) {
        this.client = client;
    }
    public ConsentWrapper(B2CCustomInput__c customInput) {
        this.customInput = customInput;
    }
    
}