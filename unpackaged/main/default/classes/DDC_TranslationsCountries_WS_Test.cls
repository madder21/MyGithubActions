@isTest
private with sharing class DDC_TranslationsCountries_WS_Test {

    private static testMethod void test_DDC_TranslationsCountries_WS() {
        Map<String,String> pathParameters = new Map<String,String> { 'langCode' => 'fr' };
        DDC_TranslationsCountries_WS ws = new DDC_TranslationsCountries_WS();
        Map<String,Object> countries = (Map<String,Object>) ws.executeGET(pathParameters, null);
        System.assert(!countries.isEmpty());
    }

    private static testMethod void test_DDC_CountriesJsonCtrl() {
        DDC_CountriesJsonCtrl ctrl = new DDC_CountriesJsonCtrl();
        Map<String,String> valuesMap = (Map<String,String>) Json.deserialize(ctrl.countriesJson, Map<String,String>.class);
        System.assert(!valuesMap.isEmpty());
    }
}