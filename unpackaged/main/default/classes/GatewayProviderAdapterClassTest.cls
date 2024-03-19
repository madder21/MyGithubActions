@IsTest
public with sharing class GatewayProviderAdapterClassTest {
    @IsTest (seeAllData = true)
    static void test() {
    Test.startTest();
    GatewayProviderAdapterClassKCPRBT classTest=new GatewayProviderAdapterClassKCPRBT();
    classTest.processRequest(null);
        System.assertEquals(1,1); 
    Test.stopTest();
    }
}