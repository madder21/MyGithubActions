/*
Author : NAIMY BOUCHAIB
DATE CREATION : 07/09/2022
DESCRIPTION : test the SOM_WS_PickedInStoreShipmentHnadler class
coverage : 91 %

*/
@isTest
private class SOM_WS_PickedInStoreShipmentHnadler_Test {
    public static Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest> listRequestInputs = new Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest>();
    public static Integer toOverQuantity = 0 ;
    public static boolean serialNumberisNull = false ;
    public static boolean QtySerialNumber = false ;
    public static boolean MissingSerialNumber = false ;
    public static boolean notfulfilled = false ;
    public static boolean multipleFO = false ;
    public static boolean FulfillmentOrderLineItemsNotEmpty = false ;
    public static boolean testPassOK = false ;
    public static boolean list_items_to_ship_empty = false ;
    public static boolean no_fulfillmentOrderLineItem_exist = false ;

    @isTest(seeAllData = true)
    public static void setupData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,3);
        if(list_items_to_ship_empty == true || no_fulfillmentOrderLineItem_exist == true) {
            OrderSummary osOnHold = los[0];
            osOnHold.On_Hold__c = true ;
            update osOnHold;
        }
        SOM_testDataFactory.createFO(los[0]); 
        SOM_testDataFactory.createFO(los[1]);
        if(multipleFO == true)
            SOM_testDataFactory.createMultipleFO(los[2]);
        if(notfulfilled == false && multipleFO == false)
            SOM_testDataFactory.createFO(los[2]);
        Set<Id> orderSummaryIds = new Set<Id>(); 
        for (OrderSummary variable : los) {
            orderSummaryIds.add(variable.Id);
        }
        System.debug('ordersummaryIds  +'+orderSummaryIds);
        for(OrderSummary os : [SELECT ID, OrderNumber, (SELECT Id,StockKeepingUnit,Quantity,isSerialized__c FROM OrderItemSummaries where Type != :SOM_Constants.FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE) FROM OrderSummary where ID IN :orderSummaryIds]) {
            SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest requestDataOrderPickedinStore = new SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest();
            requestDataOrderPickedinStore.orderSummaryNumber = os.OrderNumber;
            requestDataOrderPickedinStore.deliveryDate = System.now().addDays(15);
            requestDataOrderPickedinStore.cegidInvoiceNumber = 'CINR-' + os.OrderNumber;
            if(list_items_to_ship_empty == true){
                requestDataOrderPickedinStore.item =  new List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item>();
            }
            else if (no_fulfillmentOrderLineItem_exist == true) {
                List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item> listItems = convertedList(os.OrderItemSummaries);
                listItems[0].sku = 'sku-9587461';
                listItems[0].qty = 10;
                requestDataOrderPickedinStore.item = listItems;
            }
            else {
                requestDataOrderPickedinStore.item = convertedList(os.OrderItemSummaries);
            }
            SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.put(os.OrderNumber,requestDataOrderPickedinStore);
        }
    }

    //this method to convert list of order items summary ---> list of WMS_Item our wrapper in SOrM_WS_PickedInStoreShipmentHnadler class
    private static List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item> convertedList(List<OrderItemSummary> olis) {
        List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item> listOrderItemsData = new List<SOM_WS_PickedInStoreShipmentHnadler.WMS_Item>();
        for(OrderItemSummary ois : olis) {
            SOM_WS_PickedInStoreShipmentHnadler.WMS_Item wms = new SOM_WS_PickedInStoreShipmentHnadler.WMS_Item();
            List<String> serialNumbers = new List<String>();
            wms.sku = ois.StockKeepingUnit;
            wms.qty = (Integer) ois.Quantity + toOverQuantity;
            if(ois.isSerialized__c){
                for(Integer counter = 0 ; counter < ois.Quantity ; counter++){
                    serialNumbers.add('12345678912345678');
                }
                wms.serialNumber = serialNumbers;
            }
            if(serialNumberisNull == true) {
                if(!ois.isSerialized__c)
                    if(wms.qty == 1)
                        wms.serialNumber = new List<String>{'12345678912345678'};
                    if(wms.qty == 2)
                        wms.serialNumber = new List<String>{'12345678912345678','78945612336925814'};
            }
            if(QtySerialNumber == true){
                if(wms.qty > 1){
                    wms.serialNumber = new List<String>{'12345678912345678'}; 
                }
            }
            if(MissingSerialNumber == true) {
                if(ois.isSerialized__c){
                    wms.serialNumber = null;
                    System.debug('yoyoyo');
                }
            }
            listOrderItemsData.add(wms);
        }
        return listOrderItemsData;
    }
    // end method



    //this method to test if the requestdata come empty or not
    @isTest
    static void testDataEmpty(){
        Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest> listRequestInputsEmptyData = new Map<String,SOM_WS_PickedInStoreShipmentHnadler.WMS_OrderPickedinStoreRequest>();
        System.debug(' listRequestInputsEmptyData :' + listRequestInputsEmptyData);
        String jsonMsg=JSON.serialize(listRequestInputsEmptyData.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        //System.assert(String.valueOf(result.get('Response')).contains('Error Data Request Body Empty'));
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
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        //System.assertEquals('Fulfillment Order or Order Summary are not valid - there status should be in : fulfilling, partially fulfilled',result.get('Response'));
    }

    @isTest(seeAllData=true)
    static void FulfillmentOrderLineItemsNotEmpty() { 
        setupData();
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('isSuccess=true'));
    }

    @isTest(seeAllData=true)
    static void testPassOK() {
        testPassOK = true ;
        setupData();
        testPassOK = false;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('isSuccess=true'));
    }

    @isTest(seeAllData=true)
    static void list_items_to_ship_empty() {
        list_items_to_ship_empty = true ;
        setupData();
        list_items_to_ship_empty = false ;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('list items to ship is empty'));
    }

    @isTest(seeAllData=true)
    static void no_fulfillmentOrderLineItem_exist() {
        no_fulfillmentOrderLineItem_exist = true ;
        setupData();
        no_fulfillmentOrderLineItem_exist = false ;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('no fulfillmentOrderLineItem exist with target SKU sku-9587461'));
    }

    @isTest(seeAllData=true)
    static void requested_to_ship_is_greater_than_Quantity_Available() {
        toOverQuantity = 1 ;
        setupData();
        toOverQuantity = 0 ;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('Error: Quantity requested to ship is greater than Quantity Available for this SKU'));
    }

    @isTest(seeAllData=true)
    static void noSerializedItem() {
        serialNumberisNull = true ;
        setupData();
        serialNumberisNull = false ;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact noserialitem'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('No serialNumber should provided for a non serialized product with this SKU'));
    }

    @isTest(seeAllData=true)
    static void QuantityItemsLessThanSerialNumbers() {
        QtySerialNumber = true ;
        setupData();
        QtySerialNumber = false ;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('Error: Quantity requested to ship not equal the totale of serialNumbers'));
    }

    @isTest(seeAllData=true)
    static void MissingSerialNumbers() {
        MissingSerialNumber = true ;
        setupData();
        MissingSerialNumber = false ;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('Missing serialNumbers for serialized product with this SKU'));
    }

    @isTest(seeAllData=true)
    static void testNotFulfilledOS() {
        notfulfilled = true ;
        setupData();
        notfulfilled = false ;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('should be in fulling or partially fulfilled status'));
    }

    @isTest(seeAllData=true)
    static void testMultipleFO() {
        multipleFO = true ;
        setupData();
        multipleFO = false ;
        System.debug('SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values()'+SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        String jsonMsg=JSON.serialize(SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs.values());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/shipments/orderPickedinStore/';
        req.httpMethod = 'POST';
        System.debug(' $$ JsonMsg :' + jsonMsg);
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        SOM_WS_PickedInStoreShipmentHnadler.createPickedInStoreShipments();
        System.debug(' $$ testReponseOK RestContext.response :' + RestContext.response);
        System.debug(' $$ testReponseOK :');
        Test.stopTest();
        String actual = res.responseBody.toString();
        System.debug(' $$ SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs :' + SOM_WS_PickedInStoreShipmentHnadler_Test.listRequestInputs);
        Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(RestContext.response.responseBody.tostring());
        System.debug('testact'+result1.get('Response'));
        //System.assert(String.valueOf(result1.get('Response')).contains('Error: this order Summary with the number'));
    }
}