/**
 * 
 * @author Jeremy Martiano
 * @since March 2020
 * @description Class to handle all the User Info 
 * required for the webservices (i:e Profile,Role stores reference,... ) 
 * in order to retrieve the right data. Each application will have his User Info that can extends and inherits this class.
 * @group balink WS General
 */
public virtual class BL_UserInfo implements BL_WS_Interfaces.Userable{
    private BL_EasyQuery userQuery;
    private String useCase = 'Me';
    public User basicInfos;
    public Map<String,Object> extendInfos;
    public Map<String, Object> userDetails;
    public Map<String, String> userMergeFields;

    public boolean isSA {
        get{
           return isSA();
        }
        private set;
    } 
    
    public boolean isManager {
        get{
           return isSM();
        }
        private set;
    }      

    public BL_UserInfo() {

        this.useCase = useCase() != null ? useCase() : 'Me';
        this.basicInfos = basicInfos();
        this.extendInfos = extendInfos();
        this.userDetails = getuserDetails();
        this.userMergeFields = userMergeFields();
    }

    public virtual boolean isSM(){
        if(BL_AppSettings.currentAppSettings != null && BL_AppSettings.currentAppSettings.profileIdsManager != null)
            return isManager = BL_AppSettings.currentAppSettings.profileIdsManager.contains(basicInfos.profileId); 
        return false;    
    }

    public virtual boolean isSA(){
        if(BL_AppSettings.currentAppSettings != null && BL_AppSettings.currentAppSettings.profileIdsSA != null)
           return BL_AppSettings.currentAppSettings.profileIdsSA.contains(basicInfos.profileId);
        return false;    
    }

    /**
     * 
     * @param useCase 
     * @returns `String`
     * @description Override this method to set the useCase for user info query
     */
    public virtual String useCase(){ return null; }
    /**
     * 
     * @returns `User`
     * @description Fetch the basic/common User info. Fields are taken dynamically from the this.useCase.
     */
    private Virtual User basicInfos(){
        String runningUserId = checkRunningUser();
        this.userQuery = new BL_EasyQuery()
            .useCase(this.useCase)
            .condition('id = \'' + runningUserId + '\'')
            .executeQuery();

            List<SObject> sObjects = this.userQuery.getSObjects();
        system.debug('**sObjects:'+sObjects);
            return (User)(sObjects.size() > 0 ? sObjects[0] : null);
    }

  /** 
   * @returns Map<String,Object>
   * @description Override this method to add additional parameter to the user Info. Return Map of the properties
   */
    public virtual Map<String,Object> extendInfos(){ return null;}

    /**
     * 
     * @returns `Map<String, Object>`
     * @description Merge basic infos and extended infos into this.userDetails
     */
    public Map<String, Object> getuserDetails(){
        Map<String,Object> details = new Map<String,Object>();
        details.putAll(this.extendInfos);
        List<Map<String, Object>> mappedObjs = this.userQuery.getMappedObjects();
        if(mappedObjs.size() > 0) {
            details.putAll(this.userQuery.getMappedObjects()[0]);
        }
        details.put('isManager' , isManager);
            
        return details;
    }

    /** 
     * @returns Map<String,String>
     * @description Override this method to set queryMergeFields.
     */
    public virtual Map<String,String> userMergeFields(){ return null;}



    public static String checkRunningUser(){
        RestRequest request = RestContext.request;
        if(request !=null && request.params.containsKey('runningUser')){
            return request.params.get('runningUser');
        }
        else{
            return UserInfo.getUserId();
        }
    }
}