/**
 * @File Name          : BL_Constants.cls
 * @Description        : 
 * @Author             : Aliza Reishtein
 * @group     balink WS General
 * @Last Modified By   : Aliza Reishtein
 * @Last Modified On   : 23/03/2020, 9:04:48
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/03/2020   Aliza Reishtein     Initial Version
**/
public class BL_Constants {
    /**
     * Global Constants
     */
    public static final String BL_MULTIFIELD_SEPARATOR      = '/';
    public static final String BL_EMPTY_FIELD_VALUE         = 'field.emptyValue';
    
    /**
     * Objects name
     */
    public static final String BL_PICKLIST_MDT_NAME         = 'BL_Picklist__mdt';
    public static final String BL_APP_SETTING_MDT_NAME      = 'BL_App_Setting__mdt';
    public static final String BL_FIELD_MAPPING_MDT_NAME    = 'BL_FieldsMapping__mdt';
    public static final String BL_USECASE_MDT_NAME          = 'BL_UseCase__mdt';
    public static final String BL_TRANSLATION_NAME          = 'BL_Translation__c';
    //public static final String BL_LOG_NAME                = 'BL_Log__c';
    public static final String BL_LOG_NAME                  = 'Log__c';
    public static final String BL_USECASE_MDT_PREFIX        = 'BL_UseCase.';

    /**
     * App Settings
     */
    public static final String BL_AS_APPLICATION            = 'Application__c';
    public static final String BL_AS_CUSTOM_PARAMS          = 'Custom_Parameters__c';
    public static final String BL_AS_IMMEDIATE_LOG          = 'Immediate_Log__c';
    public static final String BL_AS_LOG_ACTIVE             = 'Is_LogActive__c';
    public static final String BL_AS_LOG_HISTORY_DAYS       = 'LogHistoryDays__c';
    public static final String BL_AS_FULL_ERROR             = 'Return_Full_Error__c';
    public static final String BL_AS_PROFILES_MANAGER       = 'ProfilesManager__c';
    public static final String BL_AS_PROFILES_SA            = 'ProfilesSA__c';

    /**
     * UseCase fields
     */
    public static final String BL_UC_OBJECT_NAME            = 'ObjectName__c';
    public static final String BL_UC_NOTES                  = 'Notes__c';
    public static final String BL_UC_QUERY_CONDITION        = 'QueryCondition__c';
    public static final String BL_UC_QUERY_CONDITION_JSON   = 'QueryConditionJson__c';
    public static final String BL_UC_LABEL                  = 'Label';
    public static final String BL_UC_DEVELOPER_NAME         = 'DeveloperName';
    public static final String BL_UC_FIELDS_MAPPING_JSON    = 'FieldsMappingJson__c';
    public static final String BL_UC_FIELDS_MAPPING_CHILDS  = 'BL_FieldsMappings__r';

    /**
     * FieldsMapping fields
     */
    public static final String BL_FM_SF_FIELDPATH           = 'SFFieldPath__c';
    public static final String BL_FM_WRAPPER_FIELD_NAME     = 'Wrapper_Field_Name__c';
    public static final String BL_FM_USECASE                = 'UseCase__c';
    public static final String BL_FM_USECASE_NAME           = 'UseCase__r.DeveloperName';
    public static final String BL_FM_SAVE_TO_SF             = 'Save_to_SF__c';
    public static final String BL_FM_SEND_TO_CLIENTELING    = 'Send_to_Clienteling_App__c';
    public static final String BL_FM_GET_PICKLIST_LABEL     = 'GetPicklistLabel__c';
    public static final String BL_FM_IS_CURRENCY            = 'IsCurrency__c';
    public static final String BL_FM_INNER_SELECT_UC        = 'InnerSelect_UseCase__c';
    public static final String BL_FM_INNER_SELECT_UC_NAME   = 'InnerSelect_UseCase__r.DeveloperName';
    public static final String BL_FM_IS_INNER_SELECT        = 'Is_InnerSelect__c';
    public static final String BL_FM_USECASE_LABEL          = 'UseCase__r.Label';
    public static final String BL_FM_INNER_SELECT_UC_LABEL  = 'InnerSelect_UseCase__r.Label';
    public static final String BL_FM_DEVELOPER_NAME         = 'DeveloperName';
    public static final String BL_FM_FORMAT                 = 'Format';
    public static final String BL_FM_TRANSLATIONKEY         = 'TranslationKey';

    /**
     * Translations fields
     */
    public static final String BL_TL_LANGUAGE               = 'Language__c';

    /**
     * Log fields
     */
    public static final String BL_LOG_MOBILE_TZ             = 'Mobile_Time_Zone__c';
    public static final String BL_LOG_MOBILE_LANG           = 'Mobile_Language__c';
    public static final String BL_LOG_REQUEST_SIZE          = 'Request_Size__c';
    public static final String BL_LOG_CLASSNAME             = 'Class_Name__c';
    public static final String BL_LOG_METHOD                = 'Method__c';
    public static final String BL_LOG_USER_AGENT            = 'User_Agent__c';
    public static final String BL_LOG_QUERY_PARAMS          = 'Query_Parameters__c';
    public static final String BL_LOG_REQUEST               = 'Request__c';
    public static final String BL_LOG_REQUEST_HEADERS       = 'Request_Headers__c';
    public static final String BL_LOG_REQUEST_URI           = 'Request_URI__c';
    public static final String BL_LOG_APPLICATION           = 'Application__c';
    public static final String BL_LOG_HAS_ERROR             = 'Has_Error__c';
    public static final String BL_LOG_STACK_TRACE           = 'Stack_Trace__c';
    public static final String BL_LOG_ERROR_MESSAGE         = 'Error_Message__c';
    public static final String BL_LOG_QUERY                 = 'Query__c';
    public static final String BL_LOG_NOTES                 = 'Notes__c';
    public static final String BL_LOG_RESPONSE_SIZE         = 'Response_Size__c';
    public static final String BL_LOG_RESPONSE              = 'Response__c';
    public static final String BL_LOG_SFDC_LIMITS           = 'SFDC_Limits__c';
    public static final String BL_LOG_DURATION              = 'Duration__c';

    /**
     * Error messages
     */
    public static final String BL_AS_INSTANTIATION_ERROR    = System.Label.BL_AppSettings_Instantiation_Error;
}