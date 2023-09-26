/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 29-08-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
public with sharing class ProductManagementUTL {
    
    public static String upsertProduct(Product2 product) {
        List<Product2> retrievedProductList = [SELECT Id FROM Product2 WHERE StockKeepingUnit =: product.StockKeepingUnit LIMIT 1];
        // Get the SObject describe result
		Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('WS_ProductFields__c').getDescribe();
		Map<String, SObjectField> fieldsMap = describeResult.fields.getMap();
		Database.SaveResult srList;
        if(!retrievedProductList.isEmpty()) {
            Product2 retrievedProduct = retrievedProductList[0];
        	for (String fieldName : fieldsMap.keySet()) {
                System.debug('*** fieldName ***: '+fieldName);
                // Check if the field is custom
				Boolean isCustomField = describeResult.fields.getMap().get(fieldName).getDescribe().isCustom();
                if(isCustomField) {
                    if(fieldName.contains('_s__c')) {
                    	fieldName = fieldName.substring(0, fieldName.length() - 5); 
                    }
                    if(product.get(fieldName)!=null) {
                       retrievedProduct.put(fieldName, product.get(fieldName));
                    }
                	
                }
        	}
            
            srList = Database.update(retrievedProduct);
            System.debug('*** srList ***: '+srList);
        }else {
            product.Id = null;
            srList = Database.insert(product);
            System.debug('*** srList ***: '+srList);
        }
        
        return srList.getId();
    }
}