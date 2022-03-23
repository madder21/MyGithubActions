@isTest
public with sharing class BL_TestCommon { 
       

    public static BL_Translation__c createTranslation ( String lang ){
        BL_Translation__c trans = new BL_Translation__c();
        trans.Language__c = lang;
        insert trans;
        return trans; 
    }
    
    public static ContentDocumentLink createContentDocumentLink(Id recordId, String body){
        ContentVersion cv = createContentVersion(Blob.valueOf(body));
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=recordId;
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        return contentlink;
    }
    
    public static ContentVersion createContentVersion(Blob body){
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content';      
        cv.PathOnClient ='test';           
        cv.VersionData = body;          
        insert cv;
        return cv;
    }
    @isTest
    static void UtilsTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
         Test.startTest();
        RestRequest request = RestContext.request;
                Account account = new Account(Name = 'acc1');
        		insert account;
                List <Account> ac = new List<Account>();
         		ac.add(account);
        		List <String> acc = new List<String>();
         		acc.add('Account');
        		Set <String> accset = new Set<String>();
        		accset.add('Account');
                BL_Utils.getCurrentOrgLimits();
                BL_Utils.log('Success', account);
        Test.stopTest();
    }
    
}