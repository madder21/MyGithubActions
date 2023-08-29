public with sharing class SOM_Utils {
    
    public static Map<String,String> getCountryKeyValueMap(String objectName, String fieldName){
        Map<String,String> countryName = new Map<String,String>();
        List<Schema.PicklistEntry> values = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : values){
            countryName.put(entry.getValue(), entry.getLabel());
        }
        
        return countryName;
    }
    
    
    //Apply the AmountsFormat
    public static String getTotalFormatted(Decimal amountToFormat, String AmountsFormat ){
        Decimal input = amountToFormat;
        if (amountToFormat.scale() > 2) {
            input = amountToFormat.setScale(2, RoundingMode.HALF_UP);
        }
        return formatDecimalNumber((input),AmountsFormat);
    }
    
    //Apply the AmountsFormat
    public static String formatDecimalNumber(Decimal myDecimal, String AmountsFormat){
        if(AmountsFormat == SOM_Constants.AMOUNT_FORMAT1){
            if (myDecimal == null) return '0,00';
            String myDecimalString = myDecimal.toPlainString();
            String intValue = myDecimalString.substringBefore('.');
            List<String> intValueList = new List<String>();
            for(Integer i=intValue.length(); i>0; i-=3) {
                integer startIndex = i>3?i-3:0;
                if(intValueList.isEmpty()){
                    intValueList.add(intValue.substring(startIndex, i));
                }else{
                    intValueList.add(0,intValue.substring(startIndex, i));
                }
                
            }
            String valueToReturn = '';
            for(String intValueItem: intValueList){
                valueToReturn = valueToReturn + intValueItem + '.';
            }
            valueToReturn = valueToReturn.removeEnd('.');
            valueToReturn = valueToReturn + ',' + myDecimalString.substringafter('.');
            
            Return valueToReturn;
            
        }else if(AmountsFormat == SOM_Constants.AMOUNT_FORMAT2){
            if (myDecimal == null) return '0.00';
            String myDecimalString = myDecimal.toPlainString();
            // exemple ###.###,##
            String intValue = myDecimalString.substringBefore('.');
            List<String> intValueList = new List<String>();
            for(Integer i=intValue.length(); i>0; i-=3) {
                integer startIndex = i>3?i-3:0;
                if(intValueList.isEmpty()){
                    intValueList.add(intValue.substring(startIndex, i));
                }else{
                    intValueList.add(0,intValue.substring(startIndex, i));
                }
                
            }
            String valueToReturn = '';
            for(String intValueItem: intValueList){
                valueToReturn = valueToReturn + intValueItem + ',';
            }
            
            valueToReturn = valueToReturn.removeEnd(',');
			valueToReturn = valueToReturn + '.' + myDecimalString.substringafter('.');
            
            Return valueToReturn;
            
        }else{
            Return myDecimal.toPlainString();
        }
    }
    
    
    
}