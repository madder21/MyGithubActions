/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts comprehensive testing for the class ConsentWrapper
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
*/
@isTest
public class ConsentWrapper_Test {
    
    @isTest
    static void test(){
        
        Account aAccount = new Account(LastName='Client', OptinCalling__pc = false);
        B2CCustomInput__c customInput = new B2CCustomInput__c(AccountId__c = aAccount.Id);
        ConsentWrapper consentWithClient = new ConsentWrapper(aAccount);
        ConsentWrapper consentWithCustomInput= new ConsentWrapper(customInput);
        ConsentWrapper consentWithClientAndCustomInput = new ConsentWrapper(customInput, aAccount);
        
        Assert.isNotNull(consentWithClient.client);
        Assert.isNotNull(consentWithCustomInput.customInput);
        Assert.isNotNull(consentWithClientAndCustomInput.client);
        Assert.isNotNull(consentWithClientAndCustomInput.customInput);
        
        Assert.isNotNull(consentWithClient.optDate);
        Assert.areEqual(false, consentWithClient.doubleOptin);
        Assert.areEqual(false, consentWithClient.clientToUpdate);
        Assert.areEqual('Web', consentWithClient.captureContactPointType);
        Assert.areEqual('SFDC Contact Process', consentWithClient.captureSource);
        Assert.areEqual('SFDC', consentWithClient.customContactPointType);
        Assert.areEqual('Email', consentWithClient.contactPointType);
        
        
        Assert.isNull(consentWithClient.indiv);
        Assert.isNull(consentWithClient.cpEmail);
        Assert.isNull(consentWithClient.cpPhone);
        Assert.isNull(consentWithClient.cpAddress);
        Assert.isNull(consentWithClient.cpTypeConsent);
        Assert.isNull(consentWithClient.cpConsent);
        Assert.isNull(consentWithClient.customInput);
        Assert.isNull(consentWithClient.commSubConsent);
            
    }

}