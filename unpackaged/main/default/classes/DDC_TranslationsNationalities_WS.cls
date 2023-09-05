// /services/apexrest/ddc/v0/translations/{lng}/nationalities
public with sharing class DDC_TranslationsNationalities_WS implements BL_Rest_Router_Factory.DispatchableGET {
    private static final Map<String,String> LANG_CODES = new Map<String,String> {
        'zh-Hans' => 'zh_CN',
        'zh-Hant' => 'zh_TW'
    };

    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return getNationalitiesJson(pathParameters.get('langCode'));
    }

    private Map<String,String> getNationalitiesJson(String langCode) {
        // convert to SF nationality code
        if (LANG_CODES.containsKey(langCode)) {
            langCode = LANG_CODES.get(langCode);
        }

        PageReference pr = new PageReference('/apex/DDC_NationalitiesJson?lang=' + langCode);
        String nationalitiesJson = (!Test.isRunningTest() ? pr.getContent().toString() : '{ "FR": "France" }');

        Map<String,String> nationalitiesMap = (Map<String,String>) Json.deserialize(nationalitiesJson, Map<String,String>.class);
        return nationalitiesMap;
    }
}