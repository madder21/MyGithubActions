public with sharing class DDC_RegionsJsonCtrl {

    public String countriesJson {get; set;}

    public DDC_RegionsJsonCtrl() {
        Schema.DescribeFieldResult fieldResult = Contact.DDC_Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        Map<String,String> valuesMap = new Map<String,String>();
        for(Schema.PicklistEntry pickListVal : ple){
            // label will be by the vf page language
            valuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        countriesJson = JSON.serialize(valuesMap);
        System.debug('countriesJson: ' + countriesJson);
    }
}