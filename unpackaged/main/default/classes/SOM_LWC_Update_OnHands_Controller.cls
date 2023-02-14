public with sharing class SOM_LWC_Update_OnHands_Controller {


    @AuraEnabled
    public static List<String> getValidSkus(){
        List<Product2> skus = new List<Product2>([SELECT StockKeepingUnit FROM product2]);
        Set<String> setSkus         = new Set<String>();
        for(Product2 sku : skus){
            setSkus.add(sku.StockKeepingUnit);
        }         
        List<String> listSkus = new List<String>(setSkus);
        System.debug('list skus ::::::::::::::::: ' + listSkus);
        return listSkus;
    }

    @AuraEnabled (cacheable=true)
    public static List<Wr_PicklistValue> getLocations(){

        List<Wr_PicklistValue> listPicklistValues = new List<Wr_PicklistValue>();
        List<Schema.Location> listLocation = [SELECT Id, Name, CustomCountry__c, LocationType, ExternalReference 
                                                FROM Location  ORDER BY Name ASC
                                            ];
        if(listLocation?.isEmpty()){
            return listPicklistValues;
        }
        for(Schema.Location location : listLocation){
            listPicklistValues.add(
                    new Wr_PicklistValue(location.Name,
                    location.ExternalReference)
                );
        }         
                
        return listPicklistValues;
    }

    @AuraEnabled
    public static SOM_OCI_InventoryRecord getOnHand(String locationEntry, String skuEntry){
        ConnectApi.OCIGetInventoryAvailabilityInputRepresentation inventoryAvailabilityInput = new ConnectApi.OCIGetInventoryAvailabilityInputRepresentation();
        inventoryAvailabilityInput.stockKeepingUnits = new List<String>();
        inventoryAvailabilityInput.locationIdentifiers = new List<String>();
        
        inventoryAvailabilityInput.stockKeepingUnits.add(skuEntry);
        inventoryAvailabilityInput.locationIdentifiers.add(locationEntry);
        inventoryAvailabilityInput.useCache	= false;
        SOM_OCI_InventoryRecord inventoryRec = new SOM_OCI_InventoryRecord();

        ConnectApi.OCIInventoryRecordOutputRepresentation inventoryRecordOutput;
        try{
            ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation inventoryAvailabilityOutput = ConnectApi.OmnichannelInventoryService.getInventoryAvailability(inventoryAvailabilityInput);
            if(inventoryAvailabilityOutput.locations?.isEmpty()){
                return inventoryRec;
            }
            List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locationAvailabilityOutput = inventoryAvailabilityOutput.locations;
            if(locationAvailabilityOutput[0].inventoryRecords?.isEmpty()){
                return inventoryRec;
            }
            inventoryRecordOutput  = locationAvailabilityOutput[0].inventoryRecords[0];
            inventoryRec.onHand           =  (Integer)inventoryRecordOutput.onHand;
            inventoryRec.effectiveDate    = inventoryRecordOutput.effectiveDate;
            inventoryRec.safetyStockCount = (Integer)inventoryRecordOutput.safetyStockCount;
            
            System.debug('inveeeeeeeenttt' + inventoryRec);
               
        }
        catch(Exception e){
            String errorMsg = e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
        
        return inventoryRec;
        
    }

    @AuraEnabled
    public static Boolean updateOnHand(String locationEntry, String skuEntry, Integer newOnHands, SOM_OCI_InventoryRecord invRecord){

        String outputJson = '';
        Wr_FileHeader fileHeader = new Wr_FileHeader();
        fileHeader.mode = SOM_Constants.OCI_UPLOAD_MODE;
        fileHeader.location = locationEntry;
        outputJson = outputJson + JSON.serialize(fileHeader) + '\n';
        SOM_OCI_InventoryRecord inventoryRecords = new SOM_OCI_InventoryRecord();


        inventoryRecords.sku = skuEntry;
        inventoryRecords.onHand = newOnHands;
        inventoryRecords.effectiveDate = invRecord.effectiveDate;
        inventoryRecords.safetyStockCount = invRecord.safetyStockCount;
        SOM_OCI_InventoryRecord.Wr_Future_Stock future;

        inventoryRecords.futures = new List<SOM_OCI_InventoryRecord.Wr_Future_Stock>();

        for(Future_Stock__c futureStock : [SELECT Id, Name, SKU__c, Quantity__c, Location__r.ExternalReference, Date_of_Release__c 
                                    FROM Future_Stock__c 
                                    WHERE sku__c =: skuEntry 
                                    AND Location__r.ExternalReference =: locationEntry]){

            if(futureStock != null && futureStock.Quantity__c>0){
                future = new SOM_OCI_InventoryRecord.Wr_Future_Stock();
                future.expectedDate = futureStock.Date_of_Release__c;
                future.quantity = futureStock.Quantity__c;
    
                inventoryRecords.futures.add(future);
            }
                                
        }
        

        inventoryRecords.recordId = generateUUID();
        outputJson = outputJson + JSON.serialize(inventoryRecords) + '\n';
        System.debug('$$$$$ outputJson : ' + outputJson);

        
        ConnectApi.OCIUploadInventoryAvailabilityOutputRepresentation submitOutpUt = ConnectApi.OmnichannelInventoryService.submitInventoryAvailabilityUpload(new ConnectApi.BinaryInput( Blob.valueof(outputJson), SOM_Constants.FILE_TYPE ,'fileUpdateOnHands.json'));
        ConnectApi.OCIUploadInventoryAvailabilityStatusOutputRepresentation statusOutput = ConnectApi.OmnichannelInventoryService.getInventoryAvailabilityUploadStatus(submitOutpUt.uploadId);
        if(submitOutpUt.success || (statusOutput.recordsProcessedCount > 0 && (statusOutput.status.equals(SOM_Constants.STATUS_PENDING) || statusOutput.status.equals(SOM_Constants.STATUS_COMPLETED)))){
            return true;
        }
        else{
            return false;
        }
    }

    public static String generateUUID(){
         
        String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
         
         return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + 
                '-' + h.substring(20);
        } 


    public class Wr_PicklistValue{

        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public Wr_PicklistValue(String labelVal, String valueVal){
            this.label = labelVal;
            this.value = valueVal;
        }
        
    }

    public class Wr_FileHeader{
        public String mode;
        public String location;
    }

   
}