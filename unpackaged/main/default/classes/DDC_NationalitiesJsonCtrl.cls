public with sharing class DDC_NationalitiesJsonCtrl {
    public String nationalitiesJson {get; set;}

    public DDC_NationalitiesJsonCtrl() {
        Schema.DescribeFieldResult fieldResult = Contact.Nationality__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        Map<String,String> valuesMap = new Map<String,String>();
        for(Schema.PicklistEntry pickListVal : ple){
            // label will be by the vf page language
            valuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        nationalitiesJson = JSON.serialize(valuesMap);
        System.debug('nationalitiesJson: ' + nationalitiesJson);
    }
}