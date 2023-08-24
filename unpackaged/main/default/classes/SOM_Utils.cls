public with sharing class SOM_Utils {

    public static Map<String,String> getCountryKeyValueMap(String objectName, String fieldName){
        Map<String,String> countryName = new Map<String,String>();
		List<Schema.PicklistEntry> values = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : values){
            countryName.put(entry.getValue(), entry.getLabel());
		}

		return countryName;
    }
    
    //Convert a number into a formatted string
    public static String getCents(Decimal x){
        Decimal dec = x;
        String amount;
        if (!string.valueof(dec.format()).right(3).contains('.') && !string.valueof(dec.format()).right(3).contains(',') ){
            amount = string.valueof(dec.format()) + '.00';
        }else if (string.valueof(dec.format()).right(2).contains('.')){
            amount = string.valueof(dec.format()) + '0';
        }else if (string.valueof(dec.format()).right(2).contains(',')){
            amount = string.valueof(dec.format()) + '0';
        }else {
            amount = string.valueof(dec.format());
        }
        return amount;
        
    }


}