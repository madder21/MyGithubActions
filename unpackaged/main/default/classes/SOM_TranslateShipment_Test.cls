@IsTest
global with sharing class SOM_TranslateShipment_Test {

    @IsTest
    global static void testTranslate() {
 
        List<SOM_Wr_ShipmentTranslation> inputList = new List<SOM_Wr_ShipmentTranslation>();
        SOM_Wr_ShipmentTranslation input = new SOM_Wr_ShipmentTranslation();
        Product2 product2Item = SOM_testDataFactory.createProduct('Standard delivery', 'ProductCode1','sku10002',false);
        OrderDeliveryMethod oDeliveryMethod = SOM_testDataFactory.createOrderDeliveryMethod('standard_AE',product2Item.Id,'standard_AE');
        insert oDeliveryMethod; 
        input.foliNumber     = 'foli1';
        input.sku            = 'sku1';
        input.quantity       = 1;
        input.serialNumber   = 'ser1';
        input.tracking       = 'trc1';
        input.dispatchDate   = System.Datetime.now();
        input.deliveryMethod = oDeliveryMethod.Id;
        inputList.add(input);
        SOM_TranslateShipment.Requests testRequest = new SOM_TranslateShipment.Requests();
        testRequest.inputCollection = inputList;
 
        List<SOM_TranslateShipment.Requests> testRequestList = new List<SOM_TranslateShipment.Requests>();
        testRequestList.add(testRequest);
 
        List<SOM_TranslateShipment.Results> testResponseList = SOM_TranslateShipment.translateADR(testRequestList);
        System.assertEquals(testResponseList[0].outputCollection.size(), 1);
    }
}