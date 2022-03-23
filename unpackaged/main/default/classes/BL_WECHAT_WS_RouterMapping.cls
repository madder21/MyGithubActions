public class BL_WECHAT_WS_RouterMapping extends BL_WS_RouteMapping {

    public override Map < String,String > routesMapping() {
        return new Map < String,String > {
           
            // OFFICIAL ACCOUNT
            '/offiaccount/register' => 'BL_WECHAT_Register', 
            '/offiaccount/follow' => 'BL_WECHAT_Follow', 

            // EXTERNAL CONTACT
            '/externalcontact/bind' => 'BL_WECHAT_Bind'
            
        };
    }

}