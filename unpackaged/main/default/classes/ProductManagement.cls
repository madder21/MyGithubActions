/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 29-08-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@RestResource(urlMapping='/Products/*')
global with sharing class ProductManagement {
    
    @HttpPost
    global static String upsertProducts() {
    	RestRequest req = RestContext.request;
        System.debug('*** req.requestBody ***: '+req.requestBody);
        System.debug('*** req.requestBody.toString() ***: '+req.requestBody.toString());
        Object jsonMaps = (Object) JSON.deserializeUntyped(req.requestBody.toString());
        System.debug('*** jsonMaps ***:  '+jsonMaps);
        String productObjectToBeCreatedContent = JSON.serialize(jsonMaps);
        Product2 productObjectToBeCreated = (Product2)JSON.deserialize(productObjectToBeCreatedContent, Product2.class);
        System.debug('*** productObjectToBeCreated ***:  '+productObjectToBeCreated);
        
       	return ProductManagementUTL.upsertProduct(productObjectToBeCreated);
    }
}