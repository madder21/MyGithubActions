@isTest
private class SOM_WS_ShipmentHandler_Test {
    public static Map<String,SOM_WS_ShipmentHandler.ShipmentDataRquest> listRequestInputs = new Map<String,SOM_WS_ShipmentHandler.ShipmentDataRquest>();
    @isTest(seeAllData=true)
    public static void setupData() {
        List<SOM_WS_ShipmentHandler.ShipmentDataRquest> listToProcess = new List<SOM_WS_ShipmentHandler.ShipmentDataRquest>();
        List<SOM_WS_ShipmentHandler.WMS_ShipmentData> listShipmentData = new List<SOM_WS_ShipmentHandler.WMS_ShipmentData>();
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,2);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        for(FulfillmentOrder fulfillOrder : [SELECT Id, FulfillmentOrderNumber, Status, OrderSummaryId, OrderSummary.Status,
                                        (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit, OrderItemSummaryId, Quantity, 
                                        Type, OrderItemSummary.isSerialized__c
                                        FROM FulfillmentOrderLineItems WHERE Quantity > 0 AND Type != :SOM_Constants.FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE) FROM FulfillmentOrder
                                        WHERE Id =: fo.Id]){
            
            if(fulfillOrder.FulfillmentOrderLineItems?.isEmpty()){
                continue;
            }
            SOM_WS_ShipmentHandler.ShipmentDataRquest requestDataLine = new SOM_WS_ShipmentHandler.ShipmentDataRquest();
            requestDataLine.fulfillmentOrderNumber = fulfillOrder.FulfillmentOrderNumber;
            SOM_WS_ShipmentHandler.WMS_ShipmentData shipmentLineData = new SOM_WS_ShipmentHandler.WMS_ShipmentData();
            shipmentLineData.dispatchDate = System.now().addDays(15);
            shipmentLineData.WMSshipmentId = 'EXTR-'+ fulfillOrder.FulfillmentOrderNumber;
            shipmentLineData.carrier = 'UPS';
            shipmentLineData.trackingNumber = 'TRNB-'+ fulfillOrder.FulfillmentOrderNumber;
            shipmentLineData.shippingService = 'Regular';
            
            for(FulfillmentOrderLineItem foli : fulfillOrder.FulfillmentOrderLineItems){
                SOM_WS_ShipmentHandler.WMS_Article article = new SOM_WS_ShipmentHandler.WMS_Article();
                article.productSKU = foli.Product2.StockKeepingUnit;
                article.qty = Integer.valueOf(foli.Quantity);
                article.serialNumber = null;
                article.Sku10Digits  = '1010101010';
                if(foli.OrderItemSummary.isSerialized__c){
                    for(Integer i = 0; i<foli.Quantity; i++){
                        if(article.serialNumber != null){
                            article.serialNumber.add('S'+ foli.Id);
                        }
                        else{
                            article.serialNumber =  new List<String>{'S'+ foli.Id};
                        }
                    }   
                }
                if(shipmentLineData.articles != null && !shipmentLineData.articles.isEmpty()){
                    shipmentLineData.articles.add(article);
                }else{
                    shipmentLineData.articles = new List<SOM_WS_ShipmentHandler.WMS_Article>{article};
                }
                
            }
            requestDataLine.shipments = new List<SOM_WS_ShipmentHandler.WMS_ShipmentData>{shipmentLineData};
            SOM_WS_ShipmentHandler_Test.listRequestInputs.put(fulfillOrder.Id,requestDataLine);
            
            listToProcess.add(requestDataLine);
        }

    }
    
    @isTest(seeAllData=true)
    static void testReponseOK() {
        setupData();
        String JsonMsg=JSON.serialize(SOM_WS_ShipmentHandler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/insertShipments/';
        req.httpMethod = 'POST';
        
        
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        
        SOM_WS_ShipmentHandler.createShipments();
        List<Shipment> createdShipment = [SELECT Id FROM Shipment WHERE FulfillmentOrderId IN : SOM_WS_ShipmentHandler_Test.listRequestInputs.keySet()];
        Test.stopTest();
        System.assertEquals(1,createdShipment.size());
    }
    @isTest
    static void testErrorInputNull() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/insertShipments/';
        req.httpMethod = 'POST';
        
        
        req.requestBody = Blob.valueof('');
        RestContext.request = req;
        RestContext.response= res;
        
        
        SOM_WS_ShipmentHandler.createShipments();
        List<Shipment> createdShipment = [SELECT Id FROM Shipment WHERE FulfillmentOrderId NOT IN : SOM_WS_ShipmentHandler_Test.listRequestInputs.keySet()];
        Test.stopTest();
        System.assertEquals(createdShipment.size(), 0);
    }
    @isTest
    static void testErrorInputListEmpty() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/insertShipments/';
        req.httpMethod = 'POST';
        
        
        req.requestBody = Blob.valueof('[]');
        RestContext.request = req;
        RestContext.response= res;
        
        
        SOM_WS_ShipmentHandler.createShipments();
        List<Shipment> createdShipment = [SELECT Id FROM Shipment WHERE FulfillmentOrderId NOT IN : SOM_WS_ShipmentHandler_Test.listRequestInputs.keySet()];
        Test.stopTest();
        System.assertEquals(createdShipment.size(), 0);
    }
}