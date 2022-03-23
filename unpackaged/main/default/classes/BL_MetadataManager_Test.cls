/**
 * 
 * @author Shai Fisher
 * @since March 2020
 * @group Field Mapping Manager
 * @description Test class for the Metadata Manager
 */
@isTest
public class BL_MetadataManager_Test {

    @isTest
    private static void test_BL_MetadataManager() {
        Metadata.CustomMetadata cmd = new Metadata.CustomMetadata();
        cmd.fullName = 'BL_UseCase.test';
        cmd.label = 'test';
        BL_MetadataManager.addFieldValue(cmd, 'ObjectName__c', 'Account');
        List<Metadata.CustomMetadata> cmdRecords = new List<Metadata.CustomMetadata> { cmd };
         
        Test.startTest();
            String jobId = BL_MetadataManager.deployCustomMetadata(cmdRecords);
            BL_MetadataManager.checkDeploymentStatus(jobId);

            Metadata.DeployResult deployResult = new Metadata.DeployResult();
            Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
            BL_MetadataManager.CustomMetadataCallback callback = new BL_MetadataManager.CustomMetadataCallback();
            callback.handleResult(deployResult, context);

            BL_MetadataManager metadataManager = new BL_MetadataManager();
            Test.setMock(WebServiceMock.class, new DeleteMetadataMock());
            metadataManager.deleteMetadata('CLT_FieldsMapping', 'Case');
        Test.stopTest();
    }

    public class DeleteMetadataMock implements WebServiceMock {
        public void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {

            BL_MetadataSoapApi.DeleteResult result = new BL_MetadataSoapApi.DeleteResult();
            result.success = true;
            //BL_MetadataSoapApi.DeleteResult[] results = new BL_MetadataSoapApi.DeleteResult[] { result };
            BL_MetadataSoapApi.deleteMetadataResponse_element respElem = new BL_MetadataSoapApi.deleteMetadataResponse_element();
            respElem.result = new BL_MetadataSoapApi.DeleteResult[] { result };
            response.put('response_x', respElem); 
        }
    }

}