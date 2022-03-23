/**
 * 
 * @author Shai Fisher
 * @since March 2020
 * @group Field Mapping Manager
 * @description Controller class for Field Mapping Manager aura component
 */
public with sharing class BL_FieldMappingManagerCtrl {

    private static final String FIELD_MAPPING_MDT_PREFIX = 'BL_FieldsMapping.';

    public static String READ = 'readAccess';
    public static String EDIT ='editAccess';

    private static Map<DisplayType,String> DISPLAY_TYPES = new Map<DisplayType,String> {
        DisplayType.String      => 'String',
        DisplayType.Picklist    => 'Picklist',
        DisplayType.Currency    => 'Currency',
        DisplayType.Email       => 'String',
        DisplayType.Boolean     => 'Boolean',
        DisplayType.Date        => 'Date',
        DisplayType.Reference   => 'Reference',
        DisplayType.Phone       => 'String',
        DisplayType.DateTime    => 'DateTime',
        DisplayType.Long        => 'Decimal',
        DisplayType.Percent     => 'Percent'
    };


    /**
     * @param objectName The name of the object for which to return fields
     * @description The function return all fields of the object  getting
     */
    @AuraEnabled(cacheable=true)
    public static List<FieldData> getFields(String objectName) {

        Map<String, SObjectField> sObjectFieldMap = BL_ObjectDescriber.getFields(objectName);

        Map<String,FieldData> optionsByLabel = new Map<String,FieldData>();
        for (SObjectField item : sObjectFieldMap.values()) {
            FieldData fieldData = new FieldData(item.getDescribe());
            optionsByLabel.put(fieldData.label, fieldData);
        }
        List<String> fieldLabels = new List<String>(optionsByLabel.keySet());
        fieldLabels.sort();

        List<FieldData> ret = new List<FieldData>();
        for (String fieldLabel : fieldLabels) {
            ret.add(optionsByLabel.get(fieldLabel));
        }
        return ret;
    }

    /**
     * 
     * @returns `List<String>`
     * @description 
     */
    @AuraEnabled
    public static List<String> getObjectNames() {
        List<String> objectNames = BL_ObjectDescriber.getObjectNames();
        objectNames.sort();
        return objectNames;
    }



    /**
     * 
     * @returns `List<BL_UseCase__mdt>`
     * @description Loads the use cases
     */
    @AuraEnabled
    public static List<BL_UseCase> getUseCases() {
        // load useCases
        String query = 'SELECT Id, MasterLabel, ' + BL_Constants.BL_UC_LABEL + ', ' + BL_Constants.BL_UC_DEVELOPER_NAME + ', '
                    + BL_Constants.BL_UC_OBJECT_NAME + ', ' + BL_Constants.BL_UC_QUERY_CONDITION + ', ' + BL_Constants.BL_UC_QUERY_CONDITION_JSON + ', '
                    + BL_Constants.BL_UC_FIELDS_MAPPING_JSON + ',' + BL_Constants.BL_UC_NOTES
                    /*+ ', (SELECT Id,' + BL_Constants.BL_FM_DEVELOPER_NAME + ', ' + BL_Constants.BL_UC_LABEL + ', ' + BL_Constants.BL_FM_SF_FIELDPATH + ',' + BL_Constants.BL_FM_WRAPPER_FIELD_NAME
                            + ', '+ BL_Constants.BL_FM_SAVE_TO_SF + ', ' +BL_Constants.BL_FM_SEND_TO_CLIENTELING + ', ' + BL_Constants.BL_FM_GET_PICKLIST_LABEL
                            + ', ' + BL_Constants.BL_FM_IS_CURRENCY + ', ' + BL_Constants.BL_FM_USECASE_NAME + ', ' + BL_Constants.BL_FM_USECASE_LABEL
                            + ', ' + BL_Constants.BL_FM_IS_INNER_SELECT + ', ' + BL_Constants.BL_FM_INNER_SELECT_UC_NAME + ', ' + BL_Constants.BL_FM_INNER_SELECT_UC_LABEL
                            + ' FROM ' + BL_Constants.BL_UC_FIELDS_MAPPING_CHILDS +')'*/
                    + ' FROM ' + BL_Constants.BL_USECASE_MDT_NAME;


        List<SObject> UseCasesMdt = Database.query(query);

        List<BL_UseCase> useCases = new List<BL_UseCase>();
        for (SObject useCaseMdt : useCasesMdt) {
            BL_UseCase useCase = new BL_UseCase(useCaseMdt);
            if (useCase.fieldsMappings == null) {
                useCase.fieldsMappings = new List<BL_FieldsMapping>();
                /*for (SObject fieldMappingMdt : useCaseMdt.getSObjects(BL_Constants.BL_UC_FIELDS_MAPPING_CHILDS)) {
                    BL_FieldsMapping fieldMapping = new BL_FieldsMapping(fieldMappingMdt);
                    useCase.fieldsMappings.add(fieldMapping);
                }*/
            }
              
            for (BL_FieldsMapping fieldMapping : useCase.fieldsMappings) {
                // fill type
                if (String.isNotEmpty(fieldMapping.SFFieldPath)) {
                    fieldMapping.FieldType = BL_ObjectDescriber.getFieldType(useCase.ObjectName, fieldMapping.SFFieldPath);
                }
            }
            useCases.add(useCase);
        }
        return UseCases;
    }

    /**
     * 
     * @param useCaseMdtList list of the use cases to update
     * @returns `String`
     * @description Creates or updates UseCase MDT records.  Returns job id
     * @exception 
     */
    @AuraEnabled
    public static String updateUseCases(List<BL_UseCase> useCases){
        System.debug('updateUseCases: ' + useCases);
        try {
            List<Metadata.CustomMetadata> cmdRecords = new List<Metadata.CustomMetadata>();

            for (BL_UseCase useCase : useCases) {
                System.debug('addUseCaseToMeta: ' + useCase);
                Metadata.CustomMetadata cmd = new Metadata.CustomMetadata();

                cmd.fullName = useCase.DeveloperName;
                if (!cmd.fullName.startsWith(BL_Constants.BL_USECASE_MDT_PREFIX)) {
                    cmd.fullName = BL_Constants.BL_USECASE_MDT_PREFIX + cmd.fullName;
                }
                cmd.label = useCase.Label;

                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_UC_OBJECT_NAME, useCase.ObjectName);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_UC_QUERY_CONDITION, useCase.QueryCondition);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_UC_FIELDS_MAPPING_JSON, useCase.FieldsMappingsJson);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_UC_QUERY_CONDITION_JSON, useCase.QueryConditionJson);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_UC_NOTES, useCase.Notes);


                cmdRecords.add(cmd);
            }
            if (Test.isRunningTest()) {
                return null;
            }
            return BL_MetadataManager.deployCustomMetadata(cmdRecords);
        } catch(Exception ex) {
            System.debug('Exception: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }


    /**
     * @description The function return a list of  standard profile.
     */
    @AuraEnabled(cacheable=true)
    public static List<Profile> getProfiles() {
        return [SELECT Name , Id ,UserType FROM Profile WHERE UserType = 'Standard' ];
    }


    /**
     * 
     * @returns `ProfilePermissionsResult`
     * @description The function getting ID of profile and a name of an object and checking for each field if the profile has access - return a map with fields and true(if the profile has access) else-false.
     * @exception 
     */
    @AuraEnabled
    public static ProfilePermissionsResult getPermissions(String profileId, String useCaseName) {
        ProfilePermissionsResult result =  new ProfilePermissionsResult();
        String ucQuery = 'SELECT ' + BL_Constants.BL_UC_OBJECT_NAME + ',' + BL_Constants.BL_UC_FIELDS_MAPPING_JSON
                        /*+ ', (SELECT ' + BL_Constants.BL_FM_SF_FIELDPATH + ' FROM ' + BL_Constants.BL_UC_FIELDS_MAPPING_CHILDS + ')'*/
                        + ' FROM ' + BL_Constants.BL_USECASE_MDT_NAME
                        + ' WHERE ' + BL_Constants.BL_UC_DEVELOPER_NAME + '=\'' + useCaseName + '\'';

        List<SObject> useCases = Database.query(ucQuery);

        if (useCases.isEmpty()) {
            throw new AuraHandledException('Unknown use case: ' + useCaseName);
        }
        BL_UseCase useCase = new BL_UseCase(useCases[0]);
        //List<SObject> fieldsMapping = useCases[0].getSObjects(BL_Constants.BL_UC_FIELDS_MAPPING_CHILDS);
        String objectName = useCase.ObjectName;

        String objects = '\'' + objectName + '\'';
        if (objectName == 'Account') {
            objects += ',\'Contact\'';
        }

        String query = 'SELECT Field, PermissionsEdit, PermissionsRead, SobjectType, ' +
                                'Parent.Label, Parent.Profile.Id ' +
                                'FROM FieldPermissions ' +
                                'WHERE Parent.Profile.Id = :profileId AND SobjectType IN (' + objects + ') '  +
                                'AND (PermissionsEdit = true OR PermissionsRead = true)';

        System.debug('getPermissions: query: ' + query);
        Map<String,FieldPermissions> fieldPermissionsMap = new Map<String,FieldPermissions>();

        for (FieldPermissions item : Database.query(query)) {
            String key =  item.Field.substringAfter('.');
            if (item.SobjectType == 'Contact') {
                key =  key.replace('__c', '__pc');
            }
            fieldPermissionsMap.put(key, item);
        }

        result.found = false;
        result.fieldsPermissions = new Map<String,Object>();

        Map<String,SObjectField> fieldMap = BL_ObjectDescriber.getFields(objectName);
        
        for (BL_FieldsMapping item : useCase.FieldsMappings) {
            // BL_FieldsMapping  item = new BL_FieldsMapping(it);
            Map<String,Boolean> fieldAccessPermission = new Map<String,Boolean>();
            if (!(fieldMap.containsKey(item.SFFieldPath))) {
                continue;
            }
            Boolean isPermissionable = fieldMap.get(item.SFFieldPath).getDescribe().isPermissionable();
            Boolean isAccessible = false;
            if (isPermissionable) {
                fieldAccessPermission.put(READ, fieldPermissionsMap.containsKey(item.SFFieldPath) && fieldPermissionsMap.get(item.SFFieldPath).PermissionsRead);
                fieldAccessPermission.put(EDIT, fieldPermissionsMap.containsKey(item.SFFieldPath) && fieldPermissionsMap.get(item.SFFieldPath).PermissionsEdit);
                if((fieldPermissionsMap.containsKey(item.SFFieldPath) && fieldPermissionsMap.get(item.SFFieldPath).PermissionsRead) || (fieldPermissionsMap.containsKey(item.SFFieldPath) && fieldPermissionsMap.get(item.SFFieldPath).PermissionsEdit))
                {
                    result.found = true;
                }
                system.debug(item.SFFieldPath);
            }
            else {
                fieldAccessPermission.put(READ, true);
                fieldAccessPermission.put(EDIT, true);
                result.found = true;
            }
            system.debug(fieldAccessPermission);
            result.fieldsPermissions.put(item.SFFieldPath, fieldAccessPermission);
        }
        return result;
    }



    /**
     * 
     * @param mappingMdtList list of field mappings
     * @returns `String`
     * @description The function calling to the createCustomMetadata function.
     * @exception 
     */
    @AuraEnabled
    public static String updateFieldMapping(List<BL_FieldsMapping> mappings){
        System.debug('updateFieldMapping: ' + mappings);
        try {
            List<Metadata.CustomMetadata> cmdRecords = new List<Metadata.CustomMetadata>();

            for (BL_FieldsMapping mapping : mappings) {
                Metadata.CustomMetadata cmd = new Metadata.CustomMetadata();

                if (String.isEmpty(mapping.DeveloperName)) {
                    // new MDT record
                    String shortFieldName = mapping.SFFieldPath.removeEnd('__c');
                    shortFieldName = shortFieldName.replaceAll('__r.', '_').replaceAll('\\.','_').replaceAll('__','_');
                    String name = mapping.UseCaseName + '_' + shortFieldName;
                    name = name.left(40);
                    cmd.fullname = FIELD_MAPPING_MDT_PREFIX + name;
                    cmd.label = name;
                } else {
                    // existing record
                    cmd.fullName = mapping.DeveloperName;
                    if (!cmd.fullName.startsWith(FIELD_MAPPING_MDT_PREFIX)) {
                        cmd.fullName = FIELD_MAPPING_MDT_PREFIX + cmd.fullName;
                    }
                    cmd.label = mapping.DeveloperName;
                }

                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_WRAPPER_FIELD_NAME,  mapping.Wrapper_Field_Name);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_USECASE,             mapping.UseCaseName);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_SF_FIELDPATH,        mapping.SFFieldPath);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_SAVE_TO_SF,          mapping.Save_to_SF);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_SEND_TO_CLIENTELING, mapping.Send_to_Clienteling_App);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_GET_PICKLIST_LABEL,  mapping.getPicklistLabel);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_IS_CURRENCY,         mapping.IsCurrency);
                BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_IS_INNER_SELECT,     mapping.Is_InnerSelect);
                if (Mapping.InnerSelect_UseCase != null) {
                    BL_MetadataManager.addFieldValue(cmd, BL_Constants.BL_FM_INNER_SELECT_UC,     mapping.InnerSelect_UseCase.DeveloperName);
                }

                cmdRecords.add(cmd);
            }
            if (Test.isRunningTest()) {
                return null;
            }
            return BL_MetadataManager.deployCustomMetadata(cmdRecords);
        } catch(Exception ex) {
            System.debug('Exception: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }


    /** 
     * 
     * @param: cmdType: Name of Custom Metadata Type e.g. 'BL_FieldsMapping'
     * @param: devNames: list of DeveloperName, can include type (e.g. 'BL_FieldsMapping.SomeDevName' or 'SomeDevName')
     * @description Deletes Custom Metadata records.  If some rcords failed to be deleted - the rest will still be deleted (not all or none)
     * Returns map: Full Dev Name => [errors]
     * 
     */
    @AuraEnabled
    public static Map<String,List<String>> deleteCustomMetadataRecords(String cmdType, List<String> devNames) {
        System.debug('deleteCustomMetadataRecords: ' + cmdType + ', ' + devNames);
        
        // add type prefix (e.g. BL_FieldsMapping.SomeDevName)
        String typePrefix = cmdType + '.';
        for (Integer i=0; i<devNames.size(); i++) {
            if (!devNames[i].startsWith(typePrefix)) {
                devNames[i] = typePrefix + devNames[i];
            }
        }
        BL_MetadataManager mdManager = new BL_MetadataManager();
        Map<String,List<String>> errorsMap = mdManager.deleteMetadata('CustomMetadata', devNames);
        System.debug('deleteCustomMetadataRecords: errors: ' + errorsMap);
        return errorsMap;
    }

    /**
     * 
     * @param jobId Id of the job
     * @returns `Object`
     * @description Checks the status of a deployment job
     */
    @AuraEnabled
    public static Object checkDeploymentStatus(String jobId) {
        return BL_MetadataManager.checkDeploymentStatus(jobId);
    }




    /**
     * 
     * @param useCaseName name of the use case
     * @returns `TestQueryResult`
     * @description The function  return a map with all the fields of the object name that getting, For each field, returns if it exists. (true/false).
     * @exception 
     */
    @AuraEnabled
    public static TestQueryResult performTestQuery(String useCaseName) {
        TestQueryResult result = new TestQueryResult();

        // load use case and fields       
        BL_UseCase useCase = BL_UseCase.getUseCase(useCaseName);
        
        if (useCase == null) {
            throw new AuraHandledException('Unknown use case: ' + useCaseName);
        }
        
        List<BL_FieldsMapping> fieldsMapping = BL_FieldsMapping.getFullMapping(useCase.Id);
        result.linesNum = fieldsMapping.size();

        if (!BL_ObjectDescriber.isValidObject(useCase.ObjectName)) {
            throw new AuraHandledException(useCase.ObjectName + ' is not valid sobject type');
        }
        if (fieldsMapping.size() == 0) {
            return result;
        }

        Set<String> fieldNames = new Set<String>();
        for (BL_FieldsMapping item : fieldsMapping) {
            fieldNames.add(item.SFFieldPath);
        }
        String fieldNamesStr = String.join(new List<String>(fieldNames) , ', ');
        result.query = 'SELECT ' + fieldNamesStr  + ' FROM ' + useCase.ObjectName;
        if (String.isNotEmpty(useCase.QueryCondition)) {
            result.query += ' WHERE ' + useCase.QueryCondition;
        }
        result.query += ' LIMIT 1';
        result.success = true;

        // check fields
        result.fieldResults = new Map<String,Boolean>();
        for (String fieldName : fieldNames) {
            Boolean isFieldExists = BL_ObjectDescriber.isValidField(useCase.ObjectName, fieldName);
            result.fieldResults.put(fieldName, isFieldExists);
            if (!isFieldExists) {
                result.success = false;
                result.errorMessage = 'Unknown field: ' + fieldName;
            }
        }

        // perform query
        if (result.success) {
            try {
                Database.query(result.query);
                BL_EasyQuery easyQuery = new BL_EasyQuery().useCase(useCaseName).limitCount(1).executeQuery();
                result.queryResultSf = easyQuery.getSObjects();
                result.queryResultWrapper = easyQuery.getMappedObjects();
            }
            catch(Exception e) {
                System.debug('performTestQuery: ' + e.getMessage());
                System.debug(e.getStackTraceString());
                result.errorMessage = e.getMessage();
                result.success = false;
            }
        }

        return result;
    }

    /**
     * @description field information
     */
    public class FieldData {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        @AuraEnabled public String fieldType;

        public FieldData(DescribeFieldResult fieldDescribe) {
            value = fieldDescribe.getName();
            label = fieldDescribe.getLabel();
            fieldType = DISPLAY_TYPES.get(fieldDescribe.getType());
        }
    }

    /**
     * @description A struct with the objects that the getpermissions function returns.
     */
    public class ProfilePermissionsResult {
        @AuraEnabled public Map<String,Object> fieldsPermissions;
        @AuraEnabled public boolean found;
    }

    /**
     * @description A struct with the objects that the performTestQuery function returns.
     */
    public class TestQueryResult {
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String query;
        @AuraEnabled public Boolean success;
        @AuraEnabled public Integer linesNum;
        @AuraEnabled public Map<String,Boolean> fieldResults;
        @AuraEnabled public List<SObject> queryResultSf;
        @AuraEnabled public List<Object> queryResultWrapper;
    }

}