/**
 * @author : Eric B
 * @date : January 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts only basic testing for technical Logs creation related class
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25012024			|.EBU		|.					|.
 */

@IsTest
private class Logs_Test {
    
   /*
    * @Description : Create one info log
    * @param  : none
    * @return : none
    * @Expected behaviour : test that one info log as been created
    */
    @IsTest
    static void TestCreationOneInfoLog() {
    	String sMessage = 'Info Message Sample', sClassName = 'Class', sMethodName = 'Method()', sRequestName = 'Request', sResponse = 'Response', sType='info';
  
        LogLevel__mdt cmdtLogLevel = [SELECT Id, DeveloperName, level__c FROM LogLevel__mdt LIMIT 1];
        String sConfiguredLogLevel = cmdtLogLevel.level__c;
        String sClassMethodValue = 'Class: ' + sClassName + ', Method: ' + sMethodName;
        
        Logs.info(sMessage,sClassName,sMethodName,sRequestName,sResponse);     
        List<Log__c> lstLogInfo = [Select ID, Class_Name__c, Debug_message__c, LogLevel__c from Log__c where LogLevel__c = :sType and Class_Name__c = :sClassMethodValue];
        
     	Integer iTargetExpectedValue = (sConfiguredLogLevel == sType ? 1 : 0);
        System.AssertEquals(iTargetExpectedValue, lstLogInfo.size(), 'LOGS_TEST - TestCreationOneInfoLog - Number of Info logs in base is different from the number of created logs');
    }
    
    /*
    * @Description : Create one Debug log
    * @param  : none
    * @return : none
    * @Expected behaviour : test that one Debug log as been created
    */
    @IsTest
    static void TestCreationOneDebugLog() {
    	String sMessage = 'Debug Message Sample', sClassName = 'Class', sMethodName = 'Method()', sRequestName = 'Request', sResponse = 'Response', sType='debug';
       
        LogLevel__mdt cmdtLogLevel = [SELECT Id, DeveloperName, level__c FROM LogLevel__mdt LIMIT 1];
        String sConfiguredLogLevel = cmdtLogLevel.level__c;
        String sClassMethodValue = 'Class: ' + sClassName + ', Method: ' + sMethodName;
        
        Logs.debug(sMessage,sClassName,sMethodName,sRequestName,sResponse);
        List<Log__c> lstDebugInfo = [Select ID, Class_Name__c, Debug_message__c, LogLevel__c from Log__c where LogLevel__c = :sType and Class_Name__c = :sClassMethodValue];
        
        Integer iTargetExpectedValue = (sConfiguredLogLevel == sType ? 1 : 0);
        System.AssertEquals(iTargetExpectedValue, lstDebugInfo.size(), 'LOGS_TEST - TestCreationOneDebugLog - Number of Debug logs in base is different from the number of created logs');
    }
    
    /*
    * @Description : Create one Error log
    * @param  : none
    * @return : none
    * @Expected behaviour : test that one Error log as been created
    */
    @IsTest
    static void TestCreationOneErrorLog() {
    	String sMessage = 'Error Message Sample', sClassName = 'Class', sMethodName = 'Method()', sRequestName = 'Request', sResponse = 'Response', sType='error';
       
        LogLevel__mdt cmdtLogLevel = [SELECT Id, DeveloperName, level__c FROM LogLevel__mdt LIMIT 1];
        String sConfiguredLogLevel = cmdtLogLevel.level__c;
        String sClassMethodValue = 'Class: ' + sClassName + ', Method: ' + sMethodName;
                         
        // Perform test
		Test.startTest();
        
        try { 
            Integer i = 1/0; 
        } catch (Exception e) {
        	Logs.error(e,sClassName,sMethodName,sRequestName,sResponse);
            system.debug(e);
        } 
        
        List<Log__c> lstErrorInfo = [Select ID, Class_Name__c, Debug_message__c, LogLevel__c from Log__c where LogLevel__c = :sType and Class_Name__c = :sClassMethodValue and isdeleted = false];     

        Test.stopTest();
		
        // Verify always created
        System.AssertEquals(1, lstErrorInfo.size(), 'LOGS_TEST - TestCreationOneErrorLog - Number of Error logs in base is different from the number of created logs');
    }
}