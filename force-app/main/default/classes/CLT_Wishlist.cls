public with sharing class CLT_Wishlist implements clt_retailInterface{
    
    public Object retrieveDelete(Map<String, String> params){
        return null;
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return upsertItems(body);
    }

    public Object retrieveGet(Map<String, String> params){
        return null;
    }

    public List<Object> upsertItems(Map<String,Object> body) {
        String clientId = (String) body.get('clientId');
        String wishlistType = (String) body.get('wishlistType');
        String externalId = wishlistType + '_' + clientId;
       
        List<Object> modelIds = new List<Object>();
        if (body.get('modelIds') != null ){
            modelIds  = (list<Object>)body.get('modelIds');
        }

        Wishlist__c wishlist = new Wishlist__c( Account__c = clientId, ExternalId__c = externalId);
        Schema.SObjectField f = Wishlist__c.Fields.ExternalId__c;
        Database.upsert(wishlist, f, false);

        insertWishlistItems(wishlist, modelIds, externalId);

        return null;
    }

    public void insertWishlistItems(Wishlist__c wishlist, List<Object> modelIds, string wishlistExternalId){
//     TODO   String userStoreId = CLT_User.getUserStoreId();
//        List<WishlistItem__c> wiToInsert = new List<WishlistItem__c>();
//
//        for(Object modelIdItem : modelIds){
//            string modelId = String.valueOf(modelIdItem);
//            WishlistItem__c wi = new WishlistItem__c(Model__c = modelId, Wishlist__c = wishlist.Id, TECH_uniqueKey__c = wishlistExternalId + modelId);
//            wi.Store__c = userStoreId;
//            wiToInsert.add(wi);
//        }
//
//        if (wiToInsert.size()>0){
//            Database.insert(wiToInsert, false);
//        }
    }


}