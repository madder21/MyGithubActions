public with sharing class BL_WECHAT_CustomSettingsMgr { 
    /**
     * The SINGLETON handle to the instance
     */
    private static BL_WECHAT_CustomSettingsMgr self;

    /**
     * Initialize the SINGLETON instance or return it if already exists
     *
     * @returns {SSCSiteCustomSettingHelper}
     */
    public static BL_WECHAT_CustomSettingsMgr self() {
        if (self != null) {
            return self;
        }

        // To create org wide defaults in new org automatically. This will prevent NPE's in future.
        if (BL_WECHAT_Configurations__c.getInstance() == null) {
            upsert new BL_WECHAT_Configurations__c(SetupOwnerId = Userinfo.getOrganizationId());
        }

        self = new BL_WECHAT_CustomSettingsMgr();
        return self;
    }

    /**
    * BL_WECHAT_CustomSettingsMgr: private constructor of singleton 
    * to disable class standard instantiation
    */
    private BL_WECHAT_CustomSettingsMgr() {}

    /**
    * getDefaultCreationStore: return String defalt lastname
    * @return {String}
    */
    public String getDefaultLastname() {
        return String.valueOf(BL_WECHAT_Configurations__c.getInstance().default_lastname__c);
    }
    
    /**
    * getDefaultCreationSA: return String code of the default sa
    * @return {String}
    */
    public String getDefaultCreationSA() {
        return String.valueOf(BL_WECHAT_Configurations__c.getInstance().default_creation_sa__c);
    }

    /**
    * getDefaultCreationStore: return String code of the wechat store
    * @return {String}
    */
    public String getDefaultCreationStore() {
        return String.valueOf(BL_WECHAT_Configurations__c.getInstance().default_creation_store__c);
    }
}