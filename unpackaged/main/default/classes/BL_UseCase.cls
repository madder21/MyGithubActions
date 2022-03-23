/**
 * 
 * @author 
 * @since 
 */
public class BL_UseCase {
    @AuraEnabled public Id Id;
    @AuraEnabled public String DeveloperName        {get; set;}
    @AuraEnabled public String ObjectName           {get; set;}
    @AuraEnabled public String QueryCondition       {get; set;}
    @AuraEnabled public String QueryConditionJson   {get; set;}
    @AuraEnabled public String Label                {get; set;}
    @AuraEnabled public String FieldsMappingsJson   {get; set;}
    @AuraEnabled public List<BL_FieldsMapping> FieldsMappings    {get; set;}
    @AuraEnabled public String Notes    {get; set;}
    
    public BL_UseCase() {
    }

    /**
     * 
     * @param objectName 
     * @param query 
     * @param label 
     * @param id 
     */
    public BL_UseCase(String objectName, String query, String label, Id id, String fieldsMappingsJson) {
        this.ObjectName = objectName;
        this.QueryCondition = query;
        this.Label = label;
        this.Id = id;
        this.FieldsMappingsJson = fieldsMappingsJson;
    }

    /**
     * 
     * @param useCase
     * @description constuctor convert SObject to BL_UseCase
     */
    public BL_UseCase(SObject useCase){
        if (useCase == null) {
            return;
        }
        this.ObjectName = (useCase!= null && useCase.isSet(BL_Constants.BL_UC_OBJECT_NAME) ) ? (String)useCase.get(BL_Constants.BL_UC_OBJECT_NAME) : null;
        this.QueryCondition = useCase!= null && useCase.isSet(BL_Constants.BL_UC_QUERY_CONDITION)  ? (String)useCase.get(BL_Constants.BL_UC_QUERY_CONDITION) : null; 
        this.QueryConditionJson = useCase!= null && useCase.isSet(BL_Constants.BL_UC_QUERY_CONDITION_JSON)  ? (String)useCase.get(BL_Constants.BL_UC_QUERY_CONDITION_JSON) : null; 
        this.Label = useCase!= null && useCase.isSet(BL_Constants.BL_UC_LABEL)  ? (String)useCase.get(BL_Constants.BL_UC_LABEL) : null; 
        this.Id = useCase!= null && useCase.isSet('Id')  ? useCase.Id : null; 
        this.DeveloperName       = (String) getValue(useCase, BL_Constants.BL_UC_DEVELOPER_NAME);
        this.Notes       = (String) getValue(useCase, BL_Constants.BL_UC_NOTES);
        this.FieldsMappingsJson = (String) getValue(useCase, BL_Constants.BL_UC_FIELDS_MAPPING_JSON);
        if (String.isNotEmpty(this.FieldsMappingsJson)) {
            // parse fields mapping from Json
            this.fieldsMappings = (List<BL_FieldsMapping>) Json.deserialize(this.FieldsMappingsJson, List<BL_FieldsMapping>.class);
        } else {
            this.fieldsMappings = new List<BL_FieldsMapping>();
        }
    }

    /**
     * 
     * @param label 
     * @returns `BL_UseCase`
     * @description get useCase By Label
     */
    public static BL_UseCase getUseCase(String label) {        
        SObject useCase = new BL_EasyQuery()
        .objectName(BL_Constants.BL_USECASE_MDT_NAME)
        .allFields()
        .condition(BL_Constants.BL_UC_LABEL + '=\'' + label + '\' ')
        .limitCount(1)
        .executeQuery()
        .getSObject();

        if(useCase != null){
            return new BL_UseCase(useCase);
        }
        throw new BL_Exceptions.QueryException('Use Case ' + label + ' NOT FOUND ', 'Error occured during the query of ' + label);
    }

    private Object getValue(SObject useCase, String fieldName) {
        if (useCase != null && useCase.isSet(fieldName)) {
            return useCase.get(fieldName);
        }
        return null;
    }
}