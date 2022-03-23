/** 
 * @description Class to keep track of app specific settings 
 * @author Jeremy Martiano
 * @since March 2020
 * @group balink WS General
 */
public class BL_AppSettings {

    public String                  applicationName;
    public Boolean                 isImmediateLog;
    public Boolean                 isLogActive;
    public Decimal                 logHistoryDays;
    public Boolean                 isReturnFullError;
    public Set<string>             profileIdsManager;
    public Set<string>             profileIdsSA;
    public Map<String,Object>      customParams;

    /**
     * BL_AppSettings constrictor from SObject
     * @param settings 
     */
    public BL_AppSettings(SObject settings){
        if(settings!=null){
            this.applicationName    = (settings!= null && settings.isSet(BL_Constants.BL_AS_APPLICATION) ) ? (String)settings.get(BL_Constants.BL_AS_APPLICATION) : null;
            this.customParams       = settings!= null && settings.isSet(BL_Constants.BL_AS_CUSTOM_PARAMS)  ? getCustomParams(settings.get(BL_Constants.BL_AS_CUSTOM_PARAMS))           : null;
            this.isImmediateLog     = settings!= null && settings.isSet(BL_Constants.BL_AS_IMMEDIATE_LOG)  ? (Boolean)settings.get(BL_Constants.BL_AS_IMMEDIATE_LOG) : null; 
            this.isLogActive        = settings!= null && settings.isSet(BL_Constants.BL_AS_LOG_ACTIVE)  ? (Boolean)settings.get(BL_Constants.BL_AS_LOG_ACTIVE) : null;
            this.logHistoryDays     = settings!= null && settings.isSet(BL_Constants.BL_AS_LOG_HISTORY_DAYS)  ? (Decimal)settings.get(BL_Constants.BL_AS_LOG_HISTORY_DAYS) : null;
            this.isReturnFullError  = settings!= null && settings.isSet(BL_Constants.BL_AS_FULL_ERROR)  ? (Boolean)settings.get(BL_Constants.BL_AS_FULL_ERROR) : null;
            this.profileIdsManager  = settings!= null && settings.isSet(BL_Constants.BL_AS_PROFILES_MANAGER)     ? getProfiles((String)settings.get(BL_Constants.BL_AS_PROFILES_MANAGER))    : null;
            this.profileIdsSA       = settings!= null && settings.isSet(BL_Constants.BL_AS_PROFILES_SA)          ? getProfiles((String)settings.get(BL_Constants.BL_AS_PROFILES_SA))         : null;
        }
    }
    
    public static BL_AppSettings currentAppSettings{
      get
      {
       if(currentAppSettings == null)
            throw new BL_Exceptions.BL_Exception(BL_Constants.BL_AS_INSTANTIATION_ERROR);
        return currentAppSettings;
      }
      private set;
    }
    public static string currentApplicationName{
        get
        {
            if(currentAppSettings == null)
                throw new BL_Exceptions.BL_Exception(BL_Constants.BL_AS_INSTANTIATION_ERROR);
            return currentAppSettings.applicationName;
        }
        private set;
    }

    public static Map<String, Object> customParams{
        get
        {            
            if(currentAppSettings == null)
                throw new BL_Exceptions.BL_Exception(BL_Constants.BL_AS_INSTANTIATION_ERROR);
            return currentAppSettings.customParams;
        }
        private set;
    }
    
     
    /**
     * 
     * @param application name of the application for which to get the settings
     * @returns `sObject`
     * @description Return the list of application specific settings from the custom metadata
     */
    public static BL_AppSettings setAppSettings(String application){   
        if(string.isBlank(application))
            return null;
        
        SObject AppSettingsObject  = new BL_EasyQuery()
        .objectName(BL_Constants.BL_APP_SETTING_MDT_NAME)
        .allFields()
        .condition(BL_Constants.BL_AS_APPLICATION + ' = \'' + application  + '\'')
        .limitCount(1)
        .executeQuery()
        .getSObject();

        currentAppSettings = new BL_AppSettings(AppSettingsObject);
        return currentAppSettings;
    }

    /**
     * 
     * @param customParameters
     * @returns `Map<String, Object>`
     * @description returns JSON Custom Params of the current AppSettings
     */
    private static Map<String, Object> getCustomParams(object customParameters) {
        if(customParameters == null){
            return null; 
        }
        return (Map<String,Object>) JSON.deserializeUntyped((String)customParameters);
    }

    private static Set<String> getProfiles(string profiles) {
        if(profiles == null){
            return null; 
        }
        return BL_Utils.toSet(profiles.split('\n'));
    }
}