public with sharing class CLT_WishlistItem implements clt_retailInterface {

    public Object retrieveDelete(Map < String, String > params) {
        // WishlistItem__c wishlistItem = new WishlistItem__c();
        // wishlistItem.Id = params.get('id');
        // wishlistItem.removedItem__c = true;
        // update wishlistItem;
        // delete wishlistItem;
        return true;
    }

    public Object retrievePost(Map < String, String > params, Map < String, Object > body) {
        return upsertItems(body);
    }

    public Object retrieveGet(Map < String, String > params) {
        String clientId = (String) params.get('clientId'); 
        return getWishListItems(clientId);
    }

    public List<Object> upsertItems(Map<String,Object> body) {
        String clientId = (String) body.get('clientId'); 
        List<Object> items = new List<Object> {body};
        Set<String> itemIds = new Set<String>();

        List<Map<String, Object>> mapWishlistItems = CLT_Utils_Mapping.getMapObjectsByWrapperItems('WishlistItem__c', 'WishListItem', items);
        List<WishlistItem__c> wishlistItems = (List<WishlistItem__c>) JSON.deserialize(JSON.serialize(mapWishlistItems), List<WishlistItem__c>.class);
        System.debug('wishlistItems => '+wishlistItems);

        User currentUser = CLT_Utils_Query.getUserInfos();
        Store__c userStore = [SELECT Id FROM Store__c WHERE SourceStoreId__c =: currentUser.StoreCode__c];

        // for(WishlistItem__c item: wishlistItems) {
        //    item.TECH_uniqueKey__c = item.Client__c + '-' + item.Product__c;
        //    item.Store__c = userStore.Id;
        // }
        List<WishlistItem__c> clientWishlistItems = [SELECT id, Name, Product__c, removedItem__c FROM WishlistItem__c WHERE Client__c =: clientId];

        for(WishlistItem__c item: wishlistItems) {
            System.debug('item 0 ===>>> '+ item );
           for(WishlistItem__c clientItem: clientWishlistItems){
               if(item.Product__c == clientItem.Product__c){
                   System.debug('old product');
                   System.debug('item 1 ===>>> '+ item + ' clientItem ===>>> '+clientItem);
                   if(clientItem.removedItem__c == true){
                       System.debug('old product inactiv');
                       item.removedItem__c = false;
                    }
                    if(clientItem.removedItem__c == false){
                       System.debug('old product activ');
                       item.removedItem__c = true;
                   }
                }
           } 
            System.debug('new product ===>>> ' +item);
            item.TECH_uniqueKey__c = item.Client__c + '-' + item.Product__c;
            item.Store__c = userStore.Id;
            System.debug('item end else ===>>> '+item);
       
        }

        Database.upsert(wishlistItems, WishlistItem__c.TECH_uniqueKey__c, false);

        for(WishlistItem__c item: wishlistItems) {
            System.debug('item id => '+item.Id);
            itemIds.add(item.Id);
        }
        System.debug('itemids => '+itemIds);

        return CLT_Utils_Mapping.getStandardWrapperList('WishlistItem__c', 'WishListItem',
                        ' FROM WishlistItem__c WHERE Id IN ' + CLT_Utils.convertToString(itemIds) + ' ORDER BY CreatedDate DESC');

    }

    public static  List<Map<String, Object>> getWishListItems(String clientId){
        return CLT_Utils_Mapping.getStandardWrapperList('WishlistItem__c', 'WishListItem',
                        'FROM WishlistItem__c WHERE Client__c =  \''+ clientId + '\' AND removedItem__c = FALSE ORDER BY CreatedDate DESC');
    }
}