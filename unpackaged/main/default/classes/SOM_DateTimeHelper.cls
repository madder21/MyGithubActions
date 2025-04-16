public with sharing class SOM_DateTimeHelper {
    public static Datetime convertISO8601ToDateTime(String isoDateTime){
        return (DateTime) JSON.deserialize('"' + isoDateTime + '"', DateTime.class);
	}

@InvocableMethod(label='Convert DateTime To Other TimeZone' description='Convert DateTime Based on specific TimeZone')
public static List<DateTime> convertDateTimeByTimeZone(List<SOM_DateConvertionInput> dataInput){
    try{
        if(dataInput?.isEmpty()){
            return null;
        }
        List<DateTime> dateTimeToReturnList = new List<DateTime>();
        for( SOM_DateConvertionInput singleInput : dataInput ){
            SOM_DateConvertionInput inputLine = singleInput;
            if(String.isBlank(String.valueOf(inputLine.dateToConvert)) || String.isBlank(inputLine.targetTimeZone)){
                continue;
            }
            String strConvertedDate = inputLine.dateToConvert.format('yyyy-MM-dd\'T\'HH:mm:ss',inputLine.targetTimeZone);
            DateTime dateValueToReturn = Datetime.valueOf(strConvertedDate.replace('T',' '));
            dateTimeToReturnList.add(dateValueToReturn);
        }

        Logs.debug('Convert Date Time By TimeZone','SOM_DateTimeHelper','convertDateTimeByTimeZone','','',''); 
        Logs.info('Convert Date Time By TimeZone','SOM_DateTimeHelper','convertDateTimeByTimeZone','','','');

        return dateTimeToReturnList;  
    } catch(Exception e){
        Logs.error(e,'SOM_DateTimeHelper','convertDateTimeByTimeZone','','','');  
        return null; 
    }
}
}