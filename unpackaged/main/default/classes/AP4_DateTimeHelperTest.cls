/* @author Paul Louis MONY
 * @date May,15th 2024
 * @Type Apex Test Class 
 *****************************************************************************************************************************************************************
 * @description : Test class for AP4_DateTimeHelper
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0      |2024/05/15         |.PLM       |..SFMC-425         |.Original Version
*/
@isTest
public without sharing class AP4_DateTimeHelperTest {
    
     @isTest
    static void testGetDateTimeByTimeZone() {
        // Create a DateTime object in UTC
        DateTime dateUTC = DateTime.newInstanceGmt(2024, 5, 3, 6, 0, 0);
        
        // Define the time zone for the conversion
        String timeZone = 'Europe/Paris';
        
        // Call the method to convert the DateTime
        DateTime convertedDateTime = AP4_DateTimeHelper.getDateTimeByTimeZone(dateUTC, timeZone);
        
        // Format the expected DateTime in the specified time zone
        DateTime dateParis = DateTime.newInstanceGmt(2024, 5, 3, 8, 0, 0);
        
        // Verify the conversion
        System.assertEquals(dateParis, convertedDateTime, 'The DateTime conversion is not correct.');
    }
}