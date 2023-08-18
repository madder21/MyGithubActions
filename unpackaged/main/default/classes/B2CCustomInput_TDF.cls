/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description 
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12062023			|.UMNN		|.					|.
*/
public with sharing class B2CCustomInput_TDF {

    public static List<B2CCustomInput__c> buildB2CCustomInput(Integer numRecords, Boolean shouldBeInserted) {
        List<B2CCustomInput__c> b2ccustomInputToBeCreated = new List<B2CCustomInput__c>();
        for(Integer i=0; i<numRecords; i++) {
            Account acc = (Account)TestDataFactory.createSObject('Account');
            B2CCustomInput__c customInput = new B2CCustomInput__c(
                CaptureContactPointType__c = 'Web',
                CaptureSource__c = 'Account Creation'+i,
                EmailConsent__c = false,
                OptinCGI__c = true,
                SubscriptionName__c = '',
                CustomContactPointType__c = '0021',
                AccountId__c = acc.Id
            );
            b2ccustomInputToBeCreated.add(customInput);
        }
        
        if(!b2ccustomInputToBeCreated.isEmpty() && shouldBeInserted) {
            insert b2ccustomInputToBeCreated;
        }

        return b2ccustomInputToBeCreated;
    }
}