@isTest
public class CLT_WishlistItem_Test {


    @isTest static void test_method_one() {
		Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
		User u = new User();
		u.UserName = '' + UserInfo.getOrganizationId() + System.now().millisecond() + 'test@rimowa.com';
		u.Email ='test@rimowa.com';
		u.LastName = 'test';
		u.ProfileId = sysAdmin.Id;
		u.LocaleSidKey = 'en_US';
		u.LanguageLocaleKey = 'en_US';
		u.TimeZoneSidKey = 'GMT';
		u.EmailEncodingKey = 'UTF-8';
		u.Alias = 'user4t_';
		u.StoreCode__c = 'TE1';
		insert u;
        
        System.runAs(u){
        	Test.startTest();
            Store__c s = new Store__c();
            s.Name = 'Test Store';
            s.SourceStoreId__c = 'TE1';
            insert s;      
            
            Account acc = new Account();
            acc.LastName = 'Test';
            insert acc;
            
            Catalog_Product__c pdt = new Catalog_Product__c();
            pdt.Name = 'RTW';
            pdt.CurrencyIsoCode = 'EUR';
            pdt.Product_SKU__c = 'TestSKU';
            insert pdt;

        	Map <String, String> params = new Map <String, String>();
        	params.put('clientId', acc.Id);
        	String jsonString  = '{"clientId" : "' + acc.Id + '", "productId" : "' + pdt.Id + '"}';
       
        	CLT_WishlistItem cltWli = new CLT_WishlistItem();
            
            cltWli.retrievePost(params, (Map<String, Object>)JSON.deserializeUntyped(jsonString));
        	cltWli.retrieveGet(params);
            
            params.clear();
            // WishlistItem__c wi = [SELECT Id FROM WishlistItem__c WHERE Client__c =: acc.Id AND Product__c =: pdt.Id limit 1];
            // params.put('id', wi.Id);
            cltWli.retrieveDelete(params);
            Test.stopTest();
        }
        
    }


}