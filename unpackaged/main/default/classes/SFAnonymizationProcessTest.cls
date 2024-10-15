@isTest(seeAllData=false)
public class SFAnonymizationProcessTest {
    
    @TestSetup
    public static void initDate() {
        
        Individual individual = new Individual();
        individual.LastName='individual';
        insert individual;
        
        Account testAcc = new Account();
        testAcc.LastName = 'test';
        testAcc.PersonEmail = 'test@email.com';
        testAcc.PersonIndividualId = individual.Id;
        insert testAcc;
    }
    
    @isTest
    static void testAnonymization() {
        Account acc = [SELECT Id, LastName, PersonEmail FROM Account LIMIT 1];
        List<SFAnonymizationProcessWrapper> wrapperList = new List<SFAnonymizationProcessWrapper>();
        SFAnonymizationProcessWrapper wrapper = new SFAnonymizationProcessWrapper();
        wrapper.clientIdStr = acc.Id;
        wrapper.objectList = 'Account';
        wrapper.timeStamp = 1728459249;
        wrapper.separator = ';';
        wrapperList.add(wrapper);
        Test.StartTest();
        SFAnonymizationProcess.initAnonymizationProcess(wrapperList);
        Test.StopTest();
        Account retrievedAcc = [SELECT Id, PersonEmail FROM Account WHERE Id =: acc.Id];
        System.assertEquals('1728459249@1728459249.1728459249', retrievedAcc.PersonEmail, 'PersonEmail field has not been anonymized');
    }
    
    @isTest
    static void testAnonymizationCommonVal() {
        Account acc = [SELECT Id, LastName, PersonEmail FROM Account LIMIT 1];
        List<SFAnonymizationProcessWrapper> wrapperList = new List<SFAnonymizationProcessWrapper>();
        SFAnonymizationProcessWrapper wrapper = new SFAnonymizationProcessWrapper();
        wrapper.clientIdStr = acc.Id;
        wrapper.objectList = 'Account';
        //wrapper.timeStamp = 1728459249;
        wrapper.separator = ';';
        wrapperList.add(wrapper);
        Test.StartTest();
        SFAnonymizationProcess.initAnonymizationProcess(wrapperList);
        Test.StopTest();
        Account retrievedAcc = [SELECT Id, PersonEmail FROM Account WHERE Id =: acc.Id];
        System.assertEquals('xxxxxxxxxx@xxx.xxx', retrievedAcc.PersonEmail, 'PersonEmail field has not been anonymized');
    }
}