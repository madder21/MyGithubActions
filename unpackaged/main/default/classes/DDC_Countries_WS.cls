// /services/apexrest/ddc/v0/countries
public with sharing class DDC_Countries_WS implements BL_Rest_Router_Factory.DispatchableGET {
    
    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return getCountries();
    }

    @TestVisible
    private List<Object> getCountries() {
        Schema.DescribeFieldResult fieldResult = Contact.Nationality__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        List<Map<String,Object>> items = new List<Map<String,Object>>();
        for(Schema.PicklistEntry pickListVal : ple){
            String countryCode = pickListVal.getValue();
            Map<String,Object> item = new Map<String,Object> {
                'identifier'    => countryCode,
                'name'          => countryCode,
                'geo'           => new Map<String,String> { 'addressCountry' => countryCode }
            };
            items.add(item);
        }
        return items;
    }

}