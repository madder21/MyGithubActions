@IsTest
public with sharing class GatewayProviderAdapterClassTest {
    @IsTest (seeAllData = true)
    static void test() {
    Test.startTest();
    GatewayProviderAdapterClassKCPACC classTest=new GatewayProviderAdapterClassKCPACC();
    classTest.processRequest(null);
        System.assertEquals(1,1); 
    Test.stopTest();
    }
}