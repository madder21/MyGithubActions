@isTest
private with sharing class DDC_Config_WS_Test {

    private static testMethod void test_DDC_Config_WS() {
        DDC_Config_WS ws = new DDC_Config_WS();
        ws.executeGET(null, null);
    }
}