@isTest
public with sharing class SOM_Utils_Test {

    @isTest
    public static void getCountryKeyValueMap() {
        Map<String,String> getCountryKeyValueMap = SOM_Utils.getCountryKeyValueMap('OrderSummary','OrderNumber');
        System.assertEquals(new List<String>(),getCountryKeyValueMap.values());
    }
}