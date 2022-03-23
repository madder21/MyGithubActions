@isTest
private with sharing class DDC_Countries_WS_Test {

    private static testMethod void test_getCountries() {
        DDC_Countries_WS ws = new DDC_Countries_WS();
        List<Map<String,Object>> result = (List<Map<String,Object>>) ws.executeGET(null, null);
        System.assert(!result.isEmpty());

        String identifier = (String) result[0].get('identifier');
        System.assert(String.isNotEmpty(identifier));
        String name = (String) result[0].get('name');
        System.assert(String.isNotEmpty(name));
        System.assert(result[0].get('geo') != null);
    }
}