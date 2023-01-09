public class DataMigrationHelper {
    
    public static String buildDataMigrationBatchQuery(Boolean isFirstRun, DateTime lastBatchExecutionDateTime){
       	String query = 'SELECT id,LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, PersonBirthdate, PersonEmail, Country__pc, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, PersonContactId';
        query += ', (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)';
        query += ' FROM Account WHERE PersonEmail != null AND IsPersonAccount = true';
        if(isFirstRun){
            query += ' AND OptinEmailing__pc =true AND LastUpdateOptinEmailing__pc != null';
        }else if(lastBatchExecutionDateTime != null){
            query += ' AND LastUpdateOptinEmailing__pc >=:lastBatchExecutionDateTime ';
        }else{
            query += ' AND LastUpdateOptinEmailing__pc >= YESTERDAY';
        }
		return query;
    }
    
    public static DateTime formatDateTime(DateTime dateTimeValue){
        if(dateTimeValue != null){
            String dateVal = dateTimeValue.format('yyyy-MM-dd\'T\'hh:mm:ss');
           Datetime valToreturn = Datetime.valueOf(dateVal.replace('T',' '));
            return valToreturn;
        }
        else{
            return null;
        }
     
    }
    
}