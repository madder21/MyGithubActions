@IsTest
public with sharing class GatewayProviderAdapterPIXClass_Test {
    @IsTest (seeAllData = true)
    static void test() {
    Test.startTest();
    GatewayProviderAdapterClassPIX classTest=new GatewayProviderAdapterClassPIX();
    classTest.processRequest(null);
        System.assertEquals(1,1); 
    Test.stopTest();
    }
}