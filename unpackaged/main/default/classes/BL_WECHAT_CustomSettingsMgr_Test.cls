@isTest
public with sharing class BL_WECHAT_CustomSettingsMgr_Test {
    @isTest
    static void test_customsttings()  {
         String defaultCreationStore = BL_WECHAT_CustomSettingsMgr.self().getDefaultCreationStore();
         String defaultCreationSA = BL_WECHAT_CustomSettingsMgr.self().getDefaultCreationSA();
        
    }
}