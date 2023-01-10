public with sharing class SOM_Utils {

    public static Map<String,String> getCountryKeyValueMap(String objectName, String fieldName){
        Map<String,String> countryName = new Map<String,String>();
		List<Schema.PicklistEntry> values = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : values){
            countryName.put(entry.getValue(), entry.getLabel());
		}

		return countryName;
    }

   

}