public with sharing class CLT_CatalogProducts implements CLT_RetailInterface{
    
    public Object retrieveDelete(Map<String, String> params){
        return null;
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){
        String listType = params.get('listType');
        String productId = params.get('productId');
        Boolean isNewVersion = params.containsKey('isNewVersion') ? Boolean.valueOf(params.get('isNewVersion')) : false;

        if(params.get('productId') != null) {
            User user = [SELECT Id, StoreCode__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            return getRelatedProducts(user.Id, user.StoreCode__c, productId);
        }

        if(listType == 'waitedProduct') {
            User user = [SELECT Id, StoreCode__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            return getWaitedProduct(user.Id, user.StoreCode__c);
        }

        else if(listType == 'waitingClients') {
            User user = [SELECT Id, StoreCode__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            return getWaitingClients(user.Id, user.StoreCode__c);
        }

        Map<String, Object> result = new Map<String, Object>();
        list<map<string, object>> catalogProducts = getCatalogProducts();
        result.put('catalogProducts', catalogProducts);
        result.put('catalogColors', getCatalogColors());
        if(isNewVersion) {
            result.put('productTranslations', getProductTranslations());
        }
        system.debug('result: ' + result);
        return result;
    }

    public list<map<string, object>> getCatalogProducts(){    
        return CLT_Utils_Mapping.getStandardWrapperList('Catalog_Product__c', 'CatalogProduct', 'FROM Catalog_Product__c');
    }
    
    public list<map<string, object>> getCatalogColors(){    
        return CLT_Utils_Mapping.getStandardWrapperList('Color__c', 'Color', 'FROM Color__c');
    }

    public list<map<string, object>> getProductTranslations(){    
        return CLT_Utils_Mapping.getStandardWrapperList('Product_Translation__c', 'ProductTranslation', 'FROM Product_Translation__c');
    }

    public List<Map<String, Object>> getRelatedProducts(String userId, String storeCode, String productId){ 
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        System.debug('pro id -->> '+productId);
        System.debug('user id -->> '+userId);
        System.debug('store storeCode -->> '+storeCode);
        Catalog_Product__c product = [SELECT Id,Name,Category__r.Name,Accessory_Type__r.Name FROM Catalog_Product__c WHERE Id = :productId LIMIT 1];
        System.debug('product -->> '+product);
        
        String productFamilyCond;
        if(product.Category__r.name == 'Luggage' || (product.Category__r.name == 'Accessories' && product.Accessory_Type__r.Name == 'Extras')) {
            productFamilyCond = 'Product__r.Name = \'' + product.Name + '\' ';
        }
        else {
            productFamilyCond = 'Product__r.Id = \'' + product.Id + '\' ';
        }
        System.debug('productFamilyCond -->> '+productFamilyCond);

        Map<String, Integer> myWishlistsMap = new Map<String, Integer>();
        String wishlistQuery = 'SELECT Product__c product, COUNT(Id) timesAdded '+
                                'FROM WishlistItem__c '+
                                'WHERE Client__r.ClientAdvisor__pc = ' + '\''+  userId + '\' '+
                                'AND '+ productFamilyCond +
                                'AND removedItem__c = FALSE ' +
                                'GROUP BY Product__c';

        for(AggregateResult ar : Database.query(wishlistQuery)) {
            myWishlistsMap.put((String)ar.get('product'), Integer.ValueOf(ar.get('timesAdded')));
        }
        System.debug('myWishlistsMap -->> '+ myWishlistsMap);
            
        Map<String, Integer> storeWishlistsMap = new Map<String, Integer>();
        String storeQuery = 'SELECT Product__c product, COUNT(Id) timesAdded '+
                            'FROM WishlistItem__c '+
                            'WHERE CreatedBy.StoreCode__c = ' + '\''+  storeCode + '\' '+
                            'AND '+ productFamilyCond +
                            'AND removedItem__c = FALSE '+ 
                            'GROUP BY Product__c';
            
        for(AggregateResult ar : Database.query(storeQuery)) {
            storeWishlistsMap.put((String)ar.get('product'), Integer.ValueOf(ar.get('timesAdded')));
        }
        System.debug('storewish -->> '+ storeWishlistsMap);
        
        String waitedProductQuery = 'SELECT Product__c product, MAX(CreatedDate) addedDate '+
        'FROM WishlistItem__c '+
        'WHERE (CreatedBy.StoreCode__c = ' + '\''+  storeCode + '\' OR Client__r.ClientAdvisor__pc = ' + '\''+  userId + '\') '+
        'AND '+ productFamilyCond +
        'GROUP BY Product__c';
        
        
        for (AggregateResult ar : Database.query(waitedProductQuery)) {
            Map<String, Object> waitedProduct = new Map<String, Object>();
            waitedProduct.put('id', ar.get('product'));
            waitedProduct.put('addedDate', ar.get('addedDate'));
            waitedProduct.put('storeTimesAdded', storeWishlistsMap.containsKey((String)ar.get('product')) ? storeWishlistsMap.get((String)ar.get('product')) : 0);
            waitedProduct.put('myTimesAdded', myWishlistsMap.containsKey((String)ar.get('product')) ? myWishlistsMap.get((String)ar.get('product')) : 0);
            
            result.add(waitedProduct);
        }
        
        System.debug('result -->> '+ result);
            return result;
    }

    public List<Map<String, Object>> getWaitedProduct(String userId, String storeCode){    

        List<Map<String, Object>> result = new List<Map<String, Object>>();

        Map<String, Integer> myWishlistsMap = new Map<String, Integer>();
        
        for(AggregateResult ar : [SELECT Product__c product, COUNT(Id) timesAdded
                                    FROM WishlistItem__c
                                    WHERE CreatedById = :userId AND removedItem__c = FALSE
                                    GROUP BY Product__c]) {
            myWishlistsMap.put((String)ar.get('product'), Integer.ValueOf(ar.get('timesAdded')));
        }
        System.debug('wish -->> '+ myWishlistsMap);


        Map<String, Integer> storeWishlistsMap = new Map<String, Integer>();
        
        for(AggregateResult ar : [SELECT Product__c product, COUNT(Id) timesAdded
                                    FROM WishlistItem__c
                                    WHERE CreatedBy.StoreCode__c = :storeCode AND removedItem__c = FALSE
                                    GROUP BY Product__c]) {
            storeWishlistsMap.put((String)ar.get('product'), Integer.ValueOf(ar.get('timesAdded')));
        }
        System.debug('storewish -->> '+ storeWishlistsMap);


        for (AggregateResult ar : [SELECT Product__c product, MAX(CreatedDate) addedDate
                                    FROM WishlistItem__c
                                    WHERE (CreatedBy.StoreCode__c = :storeCode OR CreatedById = :userId)
                                    AND removedItem__c = FALSE
                                    GROUP BY Product__c]) {
            Map<String, Object> waitedProduct = new Map<String, Object>();
            waitedProduct.put('id', ar.get('product'));
            waitedProduct.put('addedDate', ar.get('addedDate'));
            waitedProduct.put('storeTimesAdded', storeWishlistsMap.containsKey((String)ar.get('product')) ? storeWishlistsMap.get((String)ar.get('product')) : 0);
            waitedProduct.put('myTimesAdded', myWishlistsMap.containsKey((String)ar.get('product')) ? myWishlistsMap.get((String)ar.get('product')) : 0);

            result.add(waitedProduct);
        }
        
        return result;
    }

    public list<map<string, object>> getWaitingClients(String userId, String storeCode){ 

        Map<String, String> wishlistClientMap = new Map<String, String>();
        for(WishlistItem__c wi : [SELECT Id,Client__c 
                                FROM WishlistItem__c
                                WHERE  (CreatedBy.StoreCode__c = :storeCode OR CreatedById = :userId )
                                AND removedItem__c = false
                                ORDER BY CreatedDate DESC]) {
            if(!wishlistClientMap.containsKey(wi.Client__c)) {
                wishlistClientMap.put(wi.Client__c, wi.Id);
            }
            System.debug('wishlistClientMap ===>> '+wishlistClientMap);
        }
        
        
        
        //Eli change
        Map<Object, Object> wishlistClientItems = new Map<Object, Object>();
        for(AggregateResult ar : [SELECT Client__c cli, COUNT(id) numOfProducts
        FROM WishlistItem__c
        WHERE  (CreatedBy.StoreCode__c = :storeCode OR CreatedById = :userId)
        // WHERE  (Client__r.MainStore__pr.SourceStoreId__c = :storeCode OR CreatedById = :userId)
        AND removedItem__c = false
        GROUP BY Client__c]) {
            wishlistClientItems.put(ar.get('cli'), ar.get('numOfProducts'));
        }
        
        //end
        
        List<Map<String, Object>> wishlistClients = CLT_Utils_Mapping.getStandardWrapperList('WishlistItem__c', 'WishlistClient', 
        'FROM WishlistItem__c WHERE Id IN (\'' + String.join(wishlistClientMap.values(), '\',\'') + '\')  ORDER BY CreatedDate DESC');
        
        System.debug('wishlistClients ===>> '+wishlistClients);

       
        for(Map<String, Object> wi : wishlistClients){
            System.debug('i client ==>> '+ wi);
            String clientId = wi.get('clientId').toString();
            wi.put('nbrProducts',wishlistClientItems.get(clientId));
        }

       
        return wishlistClients;
    }
}