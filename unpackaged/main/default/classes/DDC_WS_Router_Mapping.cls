public class DDC_WS_Router_Mapping implements BL_Rest_Router_Factory.RouterMapping {

    public Map<String,String> getRoutes() {
        return new Map<String,String> {
            '/config'                            => 'DDC_Config_WS',
            '/ddcconfig'                         => 'DDC_Config_WS',
            '/translations/{langCode}/common'    => 'DDC_TranslationsCommon_WS',
            '/translations/{langCode}/countries' => 'DDC_TranslationsCountries_WS',
            '/translations/{langCode}/regions'   => 'DDC_TranslationsRegions_WS',
            '/countries'                         => 'DDC_Countries_WS',
            '/regions'                           => 'DDC_Regions_WS',
            '/customer/{customerId}'             => 'DDC_Customers_WS',
            '/customer'                          => 'DDC_Customers_WS',
            '/stores'                            => 'DDC_Stores_WS',
            '/person/{userCode}'                 => 'DDC_Person_WS',
            '/advisor/{userCode}'                 => 'DDC_Person_WS',
            '/advisors/{userCode}'                 => 'DDC_Person_WS',
            '/titles'                            => 'DDC_Titles_WS'
        };
    }

}