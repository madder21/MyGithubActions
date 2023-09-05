@isTest
private with sharing class DDC_TranslationsNationalities_WS_Test {
    @isTest
    private static void test_DDC_TranslationsNationalities_WS() {
        Map<String,String> pathParameters = new Map<String,String> { 'langCode' => 'fr' };
        DDC_TranslationsNationalities_WS ws = new DDC_TranslationsNationalities_WS();
        Map<String,Object> nationalities = (Map<String,Object>) ws.executeGET(pathParameters, null);
        System.assert(!nationalities.isEmpty());
    }

    @isTest
    private static void test_DDC_NationalitiesJsonCtrl() {
        DDC_NationalitiesJsonCtrl ctrl = new DDC_NationalitiesJsonCtrl();
        Map<String,String> valuesMap = (Map<String,String>) Json.deserialize(ctrl.nationalitiesJson, Map<String,String>.class);
        System.assert(!valuesMap.isEmpty());
    }
}