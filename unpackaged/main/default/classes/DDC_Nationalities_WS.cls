// /services/apexrest/ddc/v0/nationalities
public with sharing class DDC_Nationalities_WS implements BL_Rest_Router_Factory.DispatchableGET {
    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return getNationalities();
    }

    @TestVisible
    private List<Object> getNationalities() {
        Schema.DescribeFieldResult fieldResult = Contact.Nationality__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        List<Map<String,Object>> items = new List<Map<String,Object>>();
        for(Schema.PicklistEntry pickListVal : ple){
            String nationalityCode = pickListVal.getValue();
            Map<String,Object> item = new Map<String,Object> {
                'identifier'    => nationalityCode,
                'name'          => nationalityCode,
                'geo'           => new Map<String,String> { 'addressNationality' => nationalityCode }
            };
            items.add(item);
        }
        return items;
    }
}