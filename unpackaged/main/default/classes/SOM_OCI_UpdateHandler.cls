/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
public with sharing class SOM_OCI_UpdateHandler {

    public static final String UUID_CHAR_CONCAT = '-';
    
        /**
    * @description  
    * @author BADER EDDINE ELKHAL | 05-27-2022 
    **/
    @InvocableMethod(label='Update OCI On Hand Quantities' description='Callout to update the On hand Quantity for each SKU' callout = true)
    public static List<Boolean> updateOciOnHandQuantities(List<SOM_OCI_Wr_InputData> ociUpdateInputData){
        System.debug('$$$$$ Class :: SOM_OCI_UpdateHandler -- Method :: updateOciOnHandQuantities Start At :: ' + System.now() );
        Map<String, SOM_OCI_ProductLine> productLineBySkuAndLocation = new Map<String, SOM_OCI_ProductLine>();
        Map<String, List<SOM_OCI_InventoryRecord.Wr_Future_Stock>> futureStocks = new Map<String, List<SOM_OCI_InventoryRecord.Wr_Future_Stock>>();
        List<SOM_OCI_ProductLine> ociProductLines = !ociUpdateInputData[0].ociProductLines?.isEmpty() ? ociUpdateInputData[0].ociProductLines : new List<SOM_OCI_ProductLine>();
        List<SOM_OCI_LocationAvailability> ociLocationAvailabilities =!ociUpdateInputData[0].ociLocationAvailabilities?.isEmpty() ? ociUpdateInputData[0].ociLocationAvailabilities : new List<SOM_OCI_LocationAvailability>();
        Set<String> setOfSku = new Set<String>();
        Set<String> setOfLocation = new Set<String>();
        String roNumber = ociUpdateInputData[0].returnOrderNumber != null ? ociUpdateInputData[0].returnOrderNumber + '.json' : 'fileToUpload.json' ;
        String outputJson = '';
                

        //Prepare OCIGetInventoryAvailabilityInputRepresentation for GetAvailibility Action
        for(SOM_OCI_ProductLine productLine : ociProductLines){
            if(productLine.sku == null || productLine.locationId == null){
                continue;
            }
            productLineBySkuAndLocation.put(productLine.sku + '&&' +  productLine.locationId, productLine);  
            setOfSku.add(productLine.sku);
            setOfLocation.add(productLine.locationId);
        }
        SOM_OCI_InventoryRecord.Wr_Future_Stock future;
        //Get future Stocks
        for(Future_Stock__c futureStock : [SELECT Id, Name, SKU__c, Quantity__c, Location__r.ExternalReference, Date_of_Release__c 
                                    FROM Future_Stock__c 
                                    WHERE sku__c IN: setOfSku 
                                    AND Location__r.ExternalReference IN : setOfLocation]){

            future = new SOM_OCI_InventoryRecord.Wr_Future_Stock();
            future.expectedDate = futureStock.Date_of_Release__c;
            future.quantity = futureStock.Quantity__c;
            if(!futureStocks.containsKey(futureStock.SKU__c + '&&' +  futureStock.Location__r.ExternalReference)){
                futureStocks.put(futureStock.SKU__c + '&&' +  futureStock.Location__r.ExternalReference, new List<SOM_OCI_InventoryRecord.Wr_Future_Stock>{future});
                continue; 
            }
            futureStocks.get(futureStock.SKU__c + '&&' +  futureStock.Location__r.ExternalReference).add(future);
            
        }
        System.debug('$$$$$ futureStocks : ' + futureStocks);
        //Loop over LocationAvailability to prepare json file
        for(SOM_OCI_LocationAvailability locationLine : ociLocationAvailabilities){
            Wr_FileHeader fileHeader = new Wr_FileHeader();
            fileHeader.mode = SOM_Constants.OCI_UPLOAD_MODE;
            fileHeader.location = locationLine.location;
            outputJson = outputJson + JSON.serialize(fileHeader) + '\n';
            System.debug('$$$$$ outputJson 111 : ' + outputJson);
            for(SOM_OCI_InventoryRecord inventoryRecords : locationLine.ociInventoryRecords){
                if(productLineBySkuAndLocation.containsKey(inventoryRecords.sku + '&&' + locationLine.location)){
                    inventoryRecords.onHand = inventoryRecords.onHand + productLineBySkuAndLocation.get(inventoryRecords.sku + '&&' + locationLine.location).onHandQuantity;
                    inventoryRecords.futures = new List<SOM_OCI_InventoryRecord.Wr_Future_Stock>();
                    //check if any future stock exist
                    if(futureStocks.containsKey(inventoryRecords.sku + '&&' + locationLine.location)){
                        inventoryRecords.futures = futureStocks.get(inventoryRecords.sku + '&&' + locationLine.location); 
                    }
                    
                    inventoryRecords.recordId = generateUUID();
                    outputJson = outputJson + JSON.serialize(inventoryRecords) + '\n';
                }
            }
            System.debug('$$$$$ outputJson 2222 : ' + outputJson);
        }

        
        ConnectApi.OCIUploadInventoryAvailabilityOutputRepresentation submitOutpUt = ConnectApi.OmnichannelInventoryService.submitInventoryAvailabilityUpload(new ConnectApi.BinaryInput( Blob.valueof(outputJson), SOM_Constants.FILE_TYPE ,roNumber));
        System.debug('$$$$$ submitOutpUt ' + submitOutpUt.uploadId);

        if(!Test.isRunningTest()){
            ConnectApi.OCIUploadInventoryAvailabilityStatusOutputRepresentation statusOutput = ConnectApi.OmnichannelInventoryService.getInventoryAvailabilityUploadStatus(submitOutpUt.uploadId);
            System.debug('$$$$$ statusOutput ' + statusOutput);
            System.debug('$$$$$ Class :: SOM_OCI_UpdateHandler -- Method :: updateOciOnHandQuantities End At :: ' + System.now());

            if(statusOutput.recordsProcessedCount>0 && (statusOutput.status.equals(SOM_Constants.STATUS_PENDING) || statusOutput.status.equals(SOM_Constants.STATUS_COMPLETED))){
                return new List<Boolean>{true};
            }
            else{
                return new List<Boolean>{false};
            }
        }

        else{
            return new List<Boolean>{true};
        }
        
        
        
        
    }

    
    public static String generateUUID(){
         
        String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
         
         return h.SubString(0,8)+ UUID_CHAR_CONCAT + h.SubString(8,12) + 
                UUID_CHAR_CONCAT + h.SubString(12,16) + UUID_CHAR_CONCAT + 
                h.SubString(16,20) + 
                UUID_CHAR_CONCAT + 
                h.substring(20);
        } 
   
    public class Wr_FileHeader{
        public String mode;
        public String location;
    }
    

   
   

    
}