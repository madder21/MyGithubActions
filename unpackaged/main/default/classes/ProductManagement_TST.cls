/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 29-08-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@IsTest(SeeAllData=false)
public class ProductManagement_TST {

    @isTest
    static void testUpsertProducts() {
        String jsonInput = '{"Name": "Test Product", "StockKeepingUnit": "TEST-SKU"}';
        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf(jsonInput);
        RestContext.request = mockRequest;
        RestResponse mockResponse = new RestResponse();
        RestContext.response = mockResponse;
        String response = ProductManagement.upsertProducts();
        System.assertNotEquals(null, response, 'Response should not be null');
    }
}