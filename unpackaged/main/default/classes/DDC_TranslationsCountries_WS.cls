// /services/apexrest/ddc/v0/translations/{lng}/countries
public with sharing class DDC_TranslationsCountries_WS implements BL_Rest_Router_Factory.DispatchableGET {
    
    private static final Map<String,String> LANG_CODES = new Map<String,String> {
        'zh-Hans' => 'zh_CN',
        'zh-Hant' => 'zh_TW'
    };

    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return getCountriesJson(pathParameters.get('langCode'));
    }

    private Map<String,String> getCountriesJson(String langCode) {
        // convert to SF country code
        if (LANG_CODES.containsKey(langCode)) {
            langCode = LANG_CODES.get(langCode);
        }

        PageReference pr = new PageReference('/apex/DDC_CountriesJson?lang=' + langCode);
        String countriesJson = (!Test.isRunningTest() ? pr.getContent().toString() : '{ "FR": "France" }');

        Map<String,String> countriesMap = (Map<String,String>) Json.deserialize(countriesJson, Map<String,String>.class);
        return countriesMap;
    }

}