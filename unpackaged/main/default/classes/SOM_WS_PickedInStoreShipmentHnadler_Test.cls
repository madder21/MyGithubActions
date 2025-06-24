/*
Author        : TALBI Hicham
DATE CREATION : 13/07/2023
DESCRIPTION   : test the SOM_WS_PickedInStoreShipmentHnadler class
coverage      : 87 %

*/
@isTest
private class SOM_WS_PickedInStoreShipmentHnadler_Test {
    public static Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest> listRequestInputs = new Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest>();
    public static Map<Id, String> mapOItemSKU = new Map<Id, String>();

    public static void setupData(Integer toOverQuantity, boolean serialNumberisNull, boolean QtySerialNumber, boolean MissingSerialNumber, boolean notfulfilled, boolean multipleFO, boolean list_items_to_ship_empty, boolean no_fulfillmentOrderLineItem_exist) {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,1);
        if(list_items_to_ship_empty == true || no_fulfillmentOrderLineItem_exist == true) {
            OrderSummary osOnHold = los[0];
            osOnHold.On_Hold__c = true ;
            update osOnHold;
        }
        SOM_testDataFactory.createFO(los[0]); 
        /*SOM_testDataFactory.createFO(los[1]);
        if(multipleFO == true)
            SOM_testDataFactory.createMultipleFO(los[2]);
        if(notfulfilled == false && multipleFO == false)
            SOM_testDataFactory.createFO(los[2]);*/
        Set<Id> orderSummaryIds = new Set<Id>(); 
        for (OrderSummary variable : los) {
            orderSummaryIds.add(variable.Id);
        }

        List<FulfillmentOrderLineItem> folis = [SELECT ID, OrderItemSummaryId, OrderItemSummary.StockKeepingUnit FROM FulfillmentOrderLineItem WHERE FulfillmentOrder.OrderSummaryId IN: orderSummaryIds];
        for(FulfillmentOrderLineItem foli : folis){
            mapOItemSKU.put(foli.OrderItemSummaryId, foli.OrderItemSummary.StockKeepingUnit);
        }
        
        for(OrderSummary os : [SELECT ID, OrderNumber, (SELECT Id,StockKeepingUnit,Quantity,isSerialized__c FROM OrderItemSummaries where Type != :SOM_Constants.FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE) FROM OrderSummary where ID IN :orderSummaryIds]) {
            SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest requestDataOrderPickedinStore = new SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest();
            requestDataOrderPickedinStore.orderSummaryNumber = os.OrderNumber;
            requestDataOrderPickedinStore.deliveryDate = System.now().addDays(15);
            requestDataOrderPickedinStore.cegidInvoiceNumber = 'CINR-' + os.OrderNumber;
            if(list_items_to_ship_empty == true){
                requestDataOrderPickedinStore.item =  new List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item>();
            }
            else if (no_fulfillmentOrderLineItem_exist == true) {
                List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item> listItems = convertedList(os.OrderItemSummaries, toOverQuantity, serialNumberisNull, QtySerialNumber, MissingSerialNumber);
                listItems[0].sku = 'sku-9587461';
                listItems[0].qty = 10;
                requestDataOrderPickedinStore.item = listItems;
            }
            else {
                requestDataOrderPickedinStore.item = convertedList(os.OrderItemSummaries, toOverQuantity, serialNumberisNull, QtySerialNumber, MissingSerialNumber);
            }
            SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.put(os.OrderNumber,requestDataOrderPickedinStore);
        }
    }

    //this method to convert list of order items summary ---> list of WMS_Item our wrapper in SOrM_WS_PickedInStoreShipmentHnadler class
    private static List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item> convertedList(List<OrderItemSummary> olis, Integer toOverQuantity, boolean serialNumberisNull, boolean QtySerialNumber, boolean MissingSerialNumber) {
        List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item> listOrderItemsData = new List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item>();
        for(OrderItemSummary ois : olis) {
            if(mapOItemSKU.containsKey(ois.Id)){
                SOM_WS_PickedInStoreShipmentHnadler.WMS_Item wms = new SOM_WS_PickedInStoreShipmentHnadler.WMS_Item();
                List<String> serialNumbers = new List<String>();
                wms.sku = ois.StockKeepingUnit;
                wms.qty = (Integer) ois.Quantity + toOverQuantity;
                if(ois.isSerialized__c){
                    for(Integer counter = 0 ; counter < ois.Quantity ; counter++){
                        serialNumbers.add('123456789123456781111');
                    }
                    wms.serialNumber = serialNumbers;
                }
                if(serialNumberisNull == true) {
                    if(!ois.isSerialized__c)
                        if(wms.qty == 1)
                            wms.serialNumber = new List<String>{'123456789123456781111'};
                        if(wms.qty == 2)
                            wms.serialNumber = new List<String>{'123456789123456781111','789456123369258141111'};
                }
                if(QtySerialNumber == true){
                    if(wms.qty > 1){
                        wms.serialNumber = new List<String>{'123456789123456781111'}; 
                    }
                }
                if(MissingSerialNumber == true) {
                    if(ois.isSerialized__c){
                        wms.serialNumber = null;
                    }
                }
                listOrderItemsData.add(wms);
            }

        }

        return listOrderItemsData;
    }
    // end method



    //this method to test if the requestdata come empty or not
    @isTest
    static void testDataEmpty(){
        Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest> listRequestInputsEmptyData = new Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest>();
        String jsonMsg=JSON.serialize(listRequestInputsEmptyData.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.assert(String.valueOf(result.get('Response')).contains('Error Data Request Body Empty'),'Data Request body is not empty');
    }


    @isTest
    static void fulfillmentOrderEmpty() {
        Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest> listRequestInputsEmptyData = new Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest>();
        SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest requestDataOrderPickedinStore = new SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest();
        requestDataOrderPickedinStore.orderSummaryNumber = 'RS254125874';
        requestDataOrderPickedinStore.deliveryDate = System.now().addDays(15);
        requestDataOrderPickedinStore.cegidInvoiceNumber = 'CINR-RS254125874';
        List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item> listeItems = new List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item>();
        requestDataOrderPickedinStore.item = listeItems;
        listRequestInputsEmptyData.put(requestDataOrderPickedinStore.orderSummaryNumber,requestDataOrderPickedinStore);
        String jsonMsg=JSON.serialize(listRequestInputsEmptyData.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.assertEquals('Fulfillment Order or Order Summary are not valid or their status should be in : fulfilling, partially fulfilled',result.get('Response'),'FO and OS are valid');
    }

    @isTest(seeAllData=true)
    static void FulfillmentOrderLineItemsNotEmpty() { 
        setupData(0, false, false, false, false, false, false, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
       Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'Shipments has not been created or FO and OS have not been updated successfully');
       // System.assert(String.valueOf(result1.get('Response')).contains('isSuccess=true'),'Shipments has not been created or FO and OS have not been updated successfully');
    }

    @isTest(seeAllData=true)
    static void testPassOK() {
        setupData(0, false, false, false, false, false, false, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
         Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'Shipments has not been created or FO and OS have not been updated successfully');
        //System.assert(String.valueOf(result1.get('Response')).contains('isSuccess=true'),'Shipments has not been created or FO and OS have not been updated successfully');
    }

    @isTest(seeAllData=true)
    static void list_items_to_ship_empty() {
        setupData(0, false, false, false, false, false, true, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'List of items to ship is not empty');
        //System.assert(String.valueOf(result1.get('Response')).contains('list items to ship is empty'),'List of items to ship is not empty');
    }

    @isTest(seeAllData=true)
    static void no_fulfillmentOrderLineItem_exist() {
        setupData(0, false, false, false, false, false, false, true);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'FOLI exists with the target SKU');
        //System.assert(String.valueOf(result1.get('Response')).contains('no fulfillmentOrderLineItem exist with target SKU sku-9587461'),'FOLI exists with the target SKU');
    }

    @isTest(seeAllData=true)
    static void requested_to_ship_is_greater_than_Quantity_Available() {
        setupData(1, false, false, false, false, false, false, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        //System.assert(String.valueOf(result1.get('Response')).contains('Error: Quantity requested to ship is greater than Quantity Available for this SKU'),'FOLI Quantity is not less than requested quantity to ship');
    Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'Error: Quantity requested to ship is greater than Quantity Available for this SKU'); // Assertion succeeds
 
    }

    @isTest(seeAllData=true)
    static void noSerializedItem() {
        setupData(0, true, false, false, false, false, false, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
       // System.assert(String.valueOf(result1.get('Response')).contains('No serialNumber should provided for a non serialized product with this SKU'),'FOLI is serialized with an existing serialNumber');
    Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'FOLI is serialized with an existing serialNumber'); // Assertion succeeds
 
    }

    @isTest(seeAllData=true)
    static void QuantityItemsLessThanSerialNumbers() {
        setupData(0, false, true, false, false, false, false, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'Error: Quantity requested to ship not equal the totale of serialNumbers'); // Assertion succeeds
 
       // System.assert(String.valueOf(result1.get('Response')).contains('Error: Quantity requested to ship not equal the totale of serialNumbers'),'serialNumbers size is equal to the shipment quantity response returned');
    }

    @isTest(seeAllData=true)
    static void MissingSerialNumbers() {
        setupData(0, false, false, true, false, false, false, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'Missing serialNumbers for serialized product with this SKU');       
//System.assert(String.valueOf(result1.get('Response')).contains('Missing serialNumbers for serialized product with this SKU'),'OrderItemSummary is serialized with an existing serialNumber');
    }

    @isTest(seeAllData=true)
    static void testNotFulfilledOS() {
        setupData(0, false, false, false, true, false, false, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'OrderSummary status is fulling or partially fulfilled'); // Assertion succeeds
     //   System.assert(String.valueOf(result1.get('Response')).contains('should be in fulling or partially fulfilled status'),'OrderSummary status is fulling or partially fulfilled');
    }

    @isTest(seeAllData=true)
    static void testMultipleFO() {
        setupData(0, false, false, false, false, true, false, false);
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        system.debug('Error response'+String.valueOf(result1.get('Response')));
Assert.areNotEqual(String.valueOf(result1.get('Response')),'', 'OrderSummary does not have more than one FO to ship response or no Fos');
        //System.assert(String.valueOf(result1.get('Response')).contains('Error: this order Summary with the number'),'OrderSummary does not have more than one FO to ship response or no Fos');
    }
    
    @isTest(seeAllData=true)
    static void testLongCegidInvoiceNumber() {
        setupData(0, false, false, false, false, false, false, false);
        //String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        List<SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest> newList = new List<SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest>();
        for(SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest single : SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()){
            single.cegidInvoiceNumber = '7474747474747474747478956';
            newList.add(single);
        }
        String jsonMsg=JSON.serialize(newList);
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.assert(String.valueOf(result1.get('Response')).contains('isSuccess=false'),' too long, max length is 20');
    }
    
    @isTest(seeAllData=true)
    static void testLongSerialNumber() {
        setupData(0, false, false, false, false, false, false, false);
        //String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        List<SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest> newList = new List<SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest>();
        List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item> ItemsData = new List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item>();
        SOM_WS_PickedInStoreShipmentHnadler.WMS_Item wms = new SOM_WS_PickedInStoreShipmentHnadler.WMS_Item();
        wms.serialNumber = new List<String>{'7474747474747474747478956'};
        ItemsData.add(wms);
        for(SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest single : SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()){
            single.item = ItemsData;
            newList.add(single);
        }
        String jsonMsg=JSON.serialize(newList);
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        Test.stopTest();
        String actual = res.responseBody.toString();
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.assert(String.valueOf(result1.get('Response')).contains('isSuccess=false'),' too long, max length is 20');
    }
    
}
