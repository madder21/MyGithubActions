@isTest
public with sharing class BL_UserInfo_Test {
    @isTest
    static void Test_Method1() { 
         // User adminUser = CLT_Test_common.createTestUser();
     // System.RunAs(adminUser){
        BL_AppSettings blApp = BL_AppSettings.setAppSettings('WeChat');
        BL_UserInfo bl = (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance();
        boolean b = bl.isSM();
        b = bl.isSA();
        Map<String,Object> mapInfos = bl.extendInfos();
        Map<String,Object> mapInfos2 = new Map<String,Object>();
        mapInfos2.put('test','test');
        bl.extendInfos = mapInfos2;
        mapInfos = bl.getuserDetails();
     // }
        
    }
    

}