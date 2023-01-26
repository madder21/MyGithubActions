public with sharing class SOM_TranslateReservation {   
 
    public class Requests {
     
        @InvocableVariable(label='Input Record String')
        public String inputString;
 
        @InvocableVariable(label='Input Record Collection')
        public List<SOM_ADV_Reservation> inputCollection;  
 
    }
 
    public class Results {
 
        @InvocableVariable
        public String outputString;
 
        @InvocableVariable
        public List<SOM_ADV_Reservation> outputCollection;
    }
 
    @InvocableMethod
    public static List<Results> translateADR(List<Requests> requestList) {
 
        List<SOM_ADV_Reservation> tcdList = new List<SOM_ADV_Reservation>();
 
        Results response = new Results();
        List<Results> responseWrapper = new List<Results>();
 
        for (Requests req : requestList) {
 
            // Get Input Value(s)
            String inputString = req.inputString;
            tcdList = req.inputCollection;
 
            List<SOM_ADV_Reservation> collectionOutput = new List<SOM_ADV_Reservation>();
            if (inputString != null && inputString.length() > 0) {
                collectionOutput = (List<SOM_ADV_Reservation>)System.JSON.deserialize(inputString, List<SOM_ADV_Reservation>.class);
            }
 
            String stringOutput = JSON.serialize(tcdList);
            
            response.outputString = stringOutput;
            response.outputCollection = collectionOutput;
            responseWrapper.add(response);
 
        }
        return responseWrapper;
    }
}