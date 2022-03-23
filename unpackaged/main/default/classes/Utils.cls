public class  Utils {
    
     public static void log(string title, object o) {
        system.debug(LoggingLevel.INFO,'\n### ' + title + ' ###\n' + o + '\n### END ###\n');
    }
    
      public static String getHttpHeaderRequestString(RestRequest request){
        string headers = '##### Headers #####';
        for(String key : request.headers.Keyset()){
            if(key != 'QUERY')   
           	 headers+= '\n' + key + ' : ' + request.headers.get(key) ;
        }
        return headers;
    }
    public static void addCustomHeader(string Key,string value,RestRequest request){
        if(request !=null){
            if(request.headers.get(Key) == null) request.addHeader(key, value);
            else{
				string str = request.headers.get(key) + '\n\n\n' + value;
                request.addHeader(key, str); 
            }
            
        }
        
    }
     public static string getCurrentOrgLimits(){

                string limits = '****CURRENT LIMITS****\n' +
        				'CPU : ' + Limits.getCpuTime()+ ' Of ' + Limits.getLimitCpuTime() + '\n' +
        				'FUTURES : ' + Limits.getFutureCalls()+ ' Of ' + Limits.getLimitFutureCalls() + '\n' +
            			'AGGREGATE QUERIES : ' + Limits.getAggregateQueries() + ' Of ' + Limits.getLimitAggregateQueries()+ '\n' +
            			'DML ROWS : ' + Limits.getDMLRows() + ' Of ' + Limits.getLimitDMLRows()+ '\n' +
            			'DML STATEMENT : ' + Limits.getDMLStatements() + ' Of ' + Limits.getLimitDMLStatements() + '\n' +
            			'QUERIES : ' + Limits.getQueries() + ' Of ' + Limits.getLimitQueries() + '\n' +
            			'QUERY ROWS : ' + Limits.getQueryRows() + ' Of ' + Limits.getLimitQueryRows() + '\n' +
            			'SOSL(SEARCH) : ' + Limits.getSoslQueries() + ' Of ' + Limits.getLimitSoslQueries() + '\n' +
            			'HEAP SIZE : ' + Limits.getHeapSize() + ' Of ' + Limits.getLimitHeapSize() + '\n' +
            			'MOBILE PUSH : ' + Limits.getMobilePushApexCalls() + ' Of ' + Limits.getLimitMobilePushApexCalls() + '\n';

       return limits;
    }


    public static String getOrgLimits(String limitName){
        //Only if Admin & Future method
        return '\n#####CURRENT ORG LIMITS#####\n'+
                'DailyApiRequests : ' + OrgLimits.getMap().get(limitName).getValue() +
                '\n#####\n';
    }
}