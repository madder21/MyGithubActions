public class CLT_Utils_ProductDetails {

    //return details of my clients wishlist related to a specific product
    public static List<Map<String, Object>> getMyClientsRelatedWishlist(String productId, String userId) {
        List<Map<String, Object>> wishlists = CLT_Utils_Mapping.getStandardWrapperList('WishlistItem__c', 'WishlistClient', 
            'FROM WishlistItem__c WHERE Product__c = \'' + productId + '\' AND CreatedById = \'' + userId + '\' AND removedItem__c = FALSE ORDER BY CreatedDate DESC');
        return wishlists;
    }

    //return details of my store clients wishlist related to a specific product
    public static List<Map<String, Object>> getStoreClientsRelatedWishlist(String productId, String storeCode) {
        List<Map<String, Object>> wishlists = CLT_Utils_Mapping.getStandardWrapperList('WishlistItem__c', 'WishlistClient', 
            'FROM WishlistItem__c WHERE Product__c = \'' + productId + '\' AND CreatedBy.StoreCode__c = \'' + storeCode + '\' AND removedItem__c = FALSE ORDER BY CreatedDate DESC');
        return wishlists;
    }

    //return details of my clients wishlist related to a product family
    public static List<Map<String, Object>> getMyClientsRelatedFamilyWishlist(String name, String category, String accessoryType, String id, String userId) {
        String productFamilyCond;
        if(category == 'Luggage' || (category == 'Accessories' && accessoryType == 'Extras')) {
            productFamilyCond = 'Product__r.Name = \'' + name + '\'';
        }
        else {
            productFamilyCond = 'Product__r.Id = \'' + id + '\'';
        }
        List<Map<String, Object>> wishlists = CLT_Utils_Mapping.getStandardWrapperList('WishlistItem__c', 'WishlistClient', 
            'FROM WishlistItem__c WHERE ' + productFamilyCond + ' AND Client__r.ClientAdvisor__pc = \'' + userId + '\' ORDER BY CreatedDate DESC');
        return wishlists;
    }

    //return details of my store clients wishlist related to a product family
    public static List<Map<String, Object>> getStoreClientsRelatedFamilyWishlist(String name, String category, String accessoryType, String id, String storeCode) {
        String productFamilyCond;
        if(category == 'Luggage' || (category == 'Accessories' && accessoryType == 'Extras')) {
            productFamilyCond = 'Product__r.Name = \'' + name + '\'';
        }
        else {
            productFamilyCond = 'Product__r.Id = \'' + id + '\'';
        }
        List<Map<String, Object>> wishlists = CLT_Utils_Mapping.getStandardWrapperList('WishlistItem__c', 'WishlistClient', 
            'FROM WishlistItem__c WHERE ' + productFamilyCond + ' AND Client__r.MainStore__pr.SourceStoreId__c = \'' + storeCode + '\' ORDER BY CreatedDate DESC');
        return wishlists;
    }

    //return all my tasks related to a specific product
    public static List<Map<String, Object>> getRelatedTasks(String productId, String userId){
        List<Map<String, Object>> tasks = CLT_Utils_Mapping.getStandardWrapperList('Task', 'productTask', 
            'FROM Task WHERE WhatId != null AND Related_Products__c LIKE \'%' + productId + '%\' AND OwnerId = \'' + userId + '\' AND Outreach_Type__c != \'Wishlist\' ORDER BY ActivityDate DESC');
        return tasks;
    }

    //return all store tasks related to a specific product
    public static List<Map<String, Object>> GetStoreRelatedTasks(String productId, String storeCode){
        List<Map<String, Object>> tasks = CLT_Utils_Mapping.getStandardWrapperList('Task', 'productTask', 
            'FROM Task WHERE WhatId != null AND Related_Products__c LIKE \'%' + productId + '%\' AND OwnerId IN (SELECT Id FROM User WHERE StoreCode__c = \'' + storeCode + '\') AND Outreach_Type__c != \'Wishlist\' ORDER BY ActivityDate DESC');
        return tasks;
    }
}