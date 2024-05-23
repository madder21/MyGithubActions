/* @author Paul Louis MONY
 * @date May,15th 2024
 * @Type Apex Class 
 *****************************************************************************************************************************************************************
 * @description : This Apex class, is a DateT & ime helper. the get Method is Converting UTC
 * date to Timezone date & Time
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0      |2024/05/15         |.PLM       |.          |.Original Version
*/
public without sharing class AP4_DateTimeHelper {
        
    public static DateTime getDateTimeByTimeZone (DateTime dateUTC, String TimeZone){
        
        String dateFormat = 'yyyy-MM-dd HH:mm:ss';
        String localDateFormatGMT = dateUTC.format(dateFormat,timezone);
        return Datetime.valueOfGMT(localDateFormatGMT);
    }
}