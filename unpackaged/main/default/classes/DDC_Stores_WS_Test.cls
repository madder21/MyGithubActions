@isTest
private with sharing class DDC_Stores_WS_Test {

    private static testMethod void test_DDC_Stores_WS() {
        DDC_Stores_WS ws = new DDC_Stores_WS();
        List<Map<String,Object>> stores = (List<Map<String,Object>>) ws.executeGET(null, null);
    }
}