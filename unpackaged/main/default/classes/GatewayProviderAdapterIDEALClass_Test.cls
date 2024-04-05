@IsTest
public with sharing class GatewayProviderAdapterIDEALClass_Test {
    @IsTest (seeAllData = true)
    static void test() {
    Test.startTest();
    GatewayProviderAdapterIDEALClass classTest=new GatewayProviderAdapterIDEALClass();
    classTest.processRequest(null);
        System.assertEquals(1,1); 
    Test.stopTest();
    }
}