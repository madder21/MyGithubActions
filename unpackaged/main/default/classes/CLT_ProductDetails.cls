global with sharing class CLT_ProductDetails implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
     
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){
        User user = [SELECT Id, StoreCode__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        String productId = params.get('productId');
        Catalog_Product__c product = [SELECT Id,Name,Category__r.Name,Accessory_Type__r.Name FROM Catalog_Product__c WHERE Id = :productId LIMIT 1];
        

        Map<String, Object> result = new Map<String, Object>();

        if(!String.isEmpty(productId)) {
            result.put('myClientsRelatedWishlist', CLT_Utils_ProductDetails.GetMyClientsRelatedWishlist(productId, user.Id));
            result.put('storeClientsRelatedWishlist', CLT_Utils_ProductDetails.GetStoreClientsRelatedWishlist(productId, user.StoreCode__c));
            result.put('myClientsRelatedFamilyWishlist', 
                CLT_Utils_ProductDetails.GetMyClientsRelatedFamilyWishlist(product.Name, product.Category__r.Name, product.Accessory_Type__r.Name, product.Id, user.Id));
            result.put('storeClientsRelatedFamilyWishlist', 
                CLT_Utils_ProductDetails.GetStoreClientsRelatedFamilyWishlist(product.Name, product.Category__r.Name, product.Accessory_Type__r.Name, product.Id, user.StoreCode__c));
            result.put('myRelatedTasks',CLT_Utils_ProductDetails.GetRelatedTasks(productId, user.Id));
            result.put('storeRelatedTasks',CLT_Utils_ProductDetails.GetStoreRelatedTasks(productId, user.StoreCode__c));
        }

        return result;  
    }
}