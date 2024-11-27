@isTest
private with sharing class DDC_Config_WS_Test {

    @isTest
    private static void test_DDC_Config_WS() {
        DDC_Config_WS ws = new DDC_Config_WS();
        ws.executeGET(new Map<String, String>(), new Map<String, String>());
    }

    @isTest
    private static void test_DDC_Config_WS_getPilot() {
        DDC_Config_WS ws = new DDC_Config_WS();
        ws.executeGET(new Map<String, String>{'settingName' => 'pilot'}, new Map<String, String>());
    }
}