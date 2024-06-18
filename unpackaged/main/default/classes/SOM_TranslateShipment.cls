public with sharing class SOM_TranslateShipment {
    public class Requests {
     
        @InvocableVariable
        public String inputString;
 
        @InvocableVariable
        public List<SOM_Wr_ShipmentTranslation> inputCollection;
 
    }
 
    // Attributes passed back to the Flow
    public class Results {
 
        @InvocableVariable
        public String outputString;
 
        @InvocableVariable
        public List<SOM_Wr_ShipmentTranslation> outputCollection;
    }
 
    @InvocableMethod
    public static List<Results> translateADR(List<Requests> requestList) {
 
        // Instantiate the record collection
        List<SOM_Wr_ShipmentTranslation> collectionOutput = new List<SOM_Wr_ShipmentTranslation>();  
        List<OrderDeliveryMethod> odms = [SELECT Id, Name FROM OrderDeliveryMethod];
        Map<Id,String> mapOdms = new Map<Id, String>();
        for(OrderDeliveryMethod odm : odms){
            mapOdms.put(odm.Id,odm.Name);
        }
        for(Requests req : requestList){
            for(SOM_Wr_ShipmentTranslation input : req.inputCollection){
                SOM_Wr_ShipmentTranslation outp = new SOM_Wr_ShipmentTranslation();
                outp.deliveryMethod = mapOdms.get(input.deliveryMethod);
                outp.foliNumber     = input.foliNumber;
                outp.sku            = input.sku;
                outp.quantity       = input.quantity;
                outp.serialNumber   = input.serialNumber;
                outp.tracking       = input.tracking;
                outp.dispatchDate   = input.dispatchDate;
                outp.sku10Digits    = input.sku10Digits;
                collectionOutput.add(outp);
            }
        }
 
        // Prepare the response to send back to the Flow
        Results response = new Results();
        List<Results> responseWrapper = new List<Results>();
 
        // Bulkify proccessing of multiple requests
        for (Requests req : requestList) {
            // Convert Record Collection to Serialized String
            String stringOutput = JSON.serialize(collectionOutput);

            // Set Output Values
            response.outputString = stringOutput;
            response.outputCollection = collectionOutput;
            responseWrapper.add(response);
 
        }
        // Return values back to the Flow
        return responseWrapper;
    }
}