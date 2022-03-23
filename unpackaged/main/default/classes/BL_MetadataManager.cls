/**
 * 
 * @author Shai Fisher
 * @since March 2020
 * @group Field Mapping Manager
 * @description Handles Metadata components.  Using "Apex Metadata API" and "(Soap) Metadata API".
 *      Please avoid inserting specific code to a specific Custom Metedata type
 */
public with sharing class BL_MetadataManager {

    private static final String UIAPI_ENDPOINT = '/services/data/v48.0/ui-api';
    private static final String MDAPI_ENDPOINT = '/services/Soap/m/47.0';
    private static final String DEPLOY_RESULTS_ENDPOINT = '/services/data/v45.0/metadata/deployRequest/';
    

    private BL_MetadataSoapApi.MetadataWebSvc mdSoapApiService;

    /**
     * 
     * @param cmdRecords metadata records to deploy
     * @returns `String` jobId
     * @description Creates or update MDT records
     *  In case of update - the record is identified by the DeveloperName
     *  The field fullName of the records should contain the Custom Metadata type name
     *   e.g. 'CLT_Use_Case.MyUseCaseDevName'
     *  Using Apex Metadata API
     */
    public static String deployCustomMetadata(List<Metadata.CustomMetadata> cmdRecords) {
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for (Metadata.CustomMetadata cmd : cmdRecords) {
            mdContainer.addMetadata(cmd);
            System.debug('createCustomMetadata: container: ' + mdContainer);
        }

        if (Test.isRunningTest()) {
            return 'testJobId';
        }
        String jobId = Metadata.Operations.enqueueDeployment(mdContainer, new CustomMetadataCallback());
        System.debug('createCustomMetadata: jobId: ' + jobId);
        return jobId;
    }
    
    /**
     * 
     * @param cmd the custom metadata
     * @param field 
     * @param value 
     * @description Adds specific field and value to CustomMetadata object
     *  Use this method while converting Custom Metadata record (e.g. CLT_FieldsMapping__mdt to Metadata.CustomMetadata)
     */
    public static void addFieldValue(Metadata.CustomMetadata cmd, String field, Object value) {
        System.debug('addFieldValue:' + field + ': ' + value);
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = field;
        customField.value = value;
        cmd.values.add(customField);
    }

    /**
     * 
     * @param jobId the id of the job to deploy
     * @returns `Object`
     * @description Checks the status of the deployment job
     */
    public static Object checkDeploymentStatus(String jobId){
        BL_HTTP_UTILS httpUtils = new BL_HTTP_UTILS();

        HttpResponse response = 
            httpUtils.get(Url.getOrgDomainUrl().toExternalForm() + DEPLOY_RESULTS_ENDPOINT + jobId + '?includeDetails=true')
                .header('Authorization', 'Bearer ' + getSessionId())
                .call()
                .getResponse();

        System.debug('checkDeploymentStatus: response: ' + response.getBody());
        if (String.isEmpty(response.getBody())) {
            return null;
        }
        return JSON.deserializeUntyped(response.getBody());
    }


    /**************** SOAP MSAPI methods *********************/
    
    /**  
     * @description Creates new instance of BL_MetadataSoapApi
     */
    public void prepareMetadataApiService() {
        // prepare service object
        mdSoapApiService = new BL_MetadataSoapApi.MetadataWebSvc();
        mdSoapApiService.endpoint_x = URL.getOrgDomainUrl().toExternalForm() + MDAPI_ENDPOINT;
        
        mdSoapApiService.SessionHeader = new BL_MetadataSoapApi.SessionHeader_element();
		mdSoapApiService.SessionHeader.sessionId = getSessionId();
    }

    /*
     * Returns Session Id
     * Using VF page (counts as a callout) that includes "{!$Api.Session_ID}"
     *   because UserInfo.getSessionId returns other sessionId that is not good for MDAPI.
     */
    private static String getSessionId() {
        if (Test.isRunningTest()) {
            return '';
        }
        return Page.BL_ApiSessionId.getContent().toString().trim();
    }

    
    /**
     * 
     * @param: mdType: e.g. 'CustomMetadata'
     * @param: mdNames: e.g. ['CLT_FieldsMapping.MyFieldMappingDeveloperName']
     * @returns map: mdName => [errors]
     * @description Deletes Metadata (not only Custom Metadata)
     */
    public Map<String,List<String>> deleteMetadata(String mdType, List<String> mdNames) {
        Map<String,List<String>> errorsMap = new Map<String, List<String>>();
        if (mdSoapApiService == null) {
            prepareMetadataApiService();
        }
        BL_MetadataSoapApi.DeleteResult[] results = mdSoapApiService.deleteMetadata(mdType, mdNames);
        return parseErrors(results);
    }

    /** 
     * 
     * @param: mdType: e.g. 'CustomMetadata'
     * @param: mdNames: e.g. 'CLT_FieldsMapping.MyFieldMappingDeveloperName'
     * @returns list of errors
     * @description Deletes one Metadata object
     */
    public List<String> deleteMetadata(String mdType, String mdName) {
        Map<String,List<String>> errorsMap = deleteMetadata(mdType, new List<String> { mdName });
        return errorsMap.get(mdName);
    }

    /*
     * Converts delete results to map: Name => [errors]
     */
    private Map<String,List<String>> parseErrors(List<BL_MetadataSoapApi.DeleteResult> deleteResults) {
        Map<String,List<String>> errorsMap = new Map<String,List<String>>();
        for (BL_MetadataSoapApi.DeleteResult resultObj : deleteResults) {
            List<String> errors = getErrors(resultObj.errors);
            if (!errors.isEmpty()) {
                errorsMap.put(resultObj.fullName, errors);
            }
        }
        return errorsMap;
    }

    private List<String> getErrors(List<BL_MetadataSoapApi.Error> errorsObjects) {
        List<String> errors = new List<String>();
        if (errorsObjects != null) {
            for (BL_MetadataSoapApi.Error errorObj : errorsObjects) {
                errors.add(errorObj.message);
            }
        }
        return errors;
    }

    
    /**
     * Callback for Apex MDAPI.  Only logs the result
     */
    public class CustomMetadataCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result,
                                Metadata.DeployCallbackContext context) {
        //  utils.log('BL_MetadataManager Callback','MyCallback: Id: ' + result.id);
        //  utils.log('stateDetail',result.stateDetail);
        //  utils.log('details', JSON.serialize(result.details));
        //  utils.log('errorMessage',result.errorMessage);
                                    
        //  utils.log('mappingView.status',result.status);
        //                             if (result.status == Metadata.DeployStatus.Succeeded) {
        //         System.debug(' ===>'+ result);
        //     } else {
        //         // Deployment was not successful
        //         System.debug(' ===> fail '+ result);
        //     }
        }
    }


    /**************** Ui-Api methods ********************/

    private static Object callUiApi(String path) {
        BL_HTTP_UTILS httpUtils = new BL_HTTP_UTILS();
        String endpoint = UIAPI_ENDPOINT + path;
        String response = 
            httpUtils.get(Url.getOrgDomainUrl().toExternalForm() + endpoint)
            .header('Authorization', 'Bearer ' + getSessionId())
            .call()
            .responseBody();
        System.debug('\n\n response: ' + response);
        return JSON.deserializeUntyped(response);
    }

    public static List<Object> getPicklistValuesByRecordType(String objectName, String fieldName, String recordTypeDevName) {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeDevName];
        if (recordTypes.isEmpty() && !Test.isRunningTest()) {
            return null;
        }
        String path = '/object-info/' + objectName + '/picklist-values/' + recordTypes[0].Id + '/' + fieldName;
        System.debug('\n\n path: ' + path);
        Object result = callUiApi(path);
        System.debug('\n\n result: ' + result);
        try {
            Map<String,Object> resultMap = (Map<String,Object>) result;
            return (List<Object>) resultMap.get('values');
        } catch (Exception ex) {
            List<Object> resultList = (List<Object>) result;
            Map<String,Object> errorObj = (Map<String,Object>) resultList[0];
            throw new BL_Exceptions.CLTException((string) errorObj.get('errorCode'), (string) errorObj.get('message'), (string) errorObj.get('message'));
        }
    }
    
    /**************** Demonstration methods ********************
    
    public static void testCreateCustomMetadata() {
        Metadata.CustomMetadata cmd =  new Metadata.CustomMetadata();
        cmd.fullname = 'CLT_FieldsMapping.toto2';
        cmd.label = 'toto';
        addFieldValue(cmd, 'Object_Name__c', 'Case');
        addFieldValue(cmd, 'SFFieldPath__c', 'titaaai');
        
        List<Metadata.CustomMetadata> cmdRecords = new List<Metadata.CustomMetadata> { cmd };

        BL_MetadataManager mdManager = new BL_MetadataManager();
        BL_MetadataManager.createCustomMetadata(cmdRecords);
    }

    public static void testDeleteCustomMetadata(String mdType, List<String> mdNames) {
        BL_MetadataManager mdManager = new BL_MetadataManager();
        system.debug(mdNames[0]);
        mdManager.deleteMetadata(mdType, new List<string> {'CLT_FieldsMapping.'+ mdNames[0]});
    }

    */

}