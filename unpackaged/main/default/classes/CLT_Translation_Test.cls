@isTest
public class CLT_Translation_Test {
    @TestSetup
    static void createTranslation(){
        BL_Translation__c trans = new BL_Translation__c();
        trans.Language__c = 'en_US';
        trans.Target__c = 'CLT';
        insert trans;

        String body = '\"[x] days ago\" = \"[x] 天前\"';
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content';      
        cv.PathOnClient ='test';           
        cv.VersionData = Blob.valueOf(body);          
        insert cv;
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = trans.Id;
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

    }

    @isTest
    static void testEnTranslationWS(){
        User enSA = CLT_TestDateFactory.createTestUser('Store User', true);

        System.runAs(enSA) {
            CLT_Translation clt_translation = new  CLT_Translation();
            Test.startTest();
            
            clt_translation.retrieveGet(new Map<String, String>{'target' => 'CLT'});
            clt_translation.retrieveDelete(new Map<String, String>());
            clt_translation.retrievePost(new Map<String, String>(),new Map<String,Object>());

            Test.stopTest();
        }
    }

    @isTest
    static void testDefaultTranslationWS(){
        User frSA = CLT_TestDateFactory.createTestUser('Store User', 'fr', true);

        System.runAs(frSA) {
            CLT_Translation clt_translation = new  CLT_Translation();
            Test.startTest();
            
            clt_translation.retrieveGet(new Map<String, String>{'target' => 'CLT'});
            clt_translation.retrieveDelete(new Map<String, String>());
            clt_translation.retrievePost(new Map<String, String>(),new Map<String,Object>());

            Test.stopTest();
        }
    }
}