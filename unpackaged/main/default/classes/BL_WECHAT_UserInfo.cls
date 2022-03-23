/**
 * 
 * @author Jeremy Martiano
 * @since March 2020
 * @description Class to handle all the User Info 
 * required for the webservices (i:e Profile,Role stores reference,... ) 
 * in order to retrieve the right data. Each application will have his User Info that can extends and inherits this class.
 * @group Clienteling
 */
global with sharing class BL_WECHAT_UserInfo extends BL_UserInfo{
    
    global override Map<String,Object> extendInfos(){
        return new Map<String,Object>{'storeCode' => 'test1233'};
    }

    global override Map<String, String> userMergeFields() {
        return new Map<String, String>{
            'USER_ID'    => BL_Utils.toString(basicInfos.Id),
            'STORE_CODE' => BL_Utils.toString(extendInfos.get('storeCode')),
            'PROFILE_ID' => BL_Utils.toString(basicInfos.ProfileId)
        };
    }
}