/**
 * 
 * @author Shai Fisher
 * @since March 2020
 * @group Field Mapping Manager
 * @description Test class for Field Mapping Manager controller
 */
@IsTest
private class BL_FieldMappingManagerCtrl_Test {

    private static final String TEST_USE_CASE = 'DDC Client';
    
    private static testMethod void test_getFields() {
        List<BL_FieldMappingManagerCtrl.FieldData> fieldsData = BL_FieldMappingManagerCtrl.getFields('Account');

        Map<String,BL_FieldMappingManagerCtrl.FieldData> fieldsDataMap = new Map<String,BL_FieldMappingManagerCtrl.FieldData>();
        for (BL_FieldMappingManagerCtrl.FieldData fieldData : fieldsData) {
            fieldsDataMap.put(fieldData.value, fieldData);
        }

        BL_FieldMappingManagerCtrl.FieldData nameFieldData = fieldsDataMap.get('Name');
        System.assertNotEquals(null, nameFieldData);
        System.assertEquals('String', nameFieldData.fieldType);
    }

    private static testMethod void test_UseCases() {
        List<BL_UseCase> useCases = BL_FieldMappingManagerCtrl.getUseCases();

        BL_UseCase__mdt useCase = new BL_UseCase__mdt(DeveloperName = 'test');
        BL_FieldMappingManagerCtrl.updateUseCases(new List<BL_UseCase> { new BL_UseCase(useCase) });
    }

    private static testMethod void test_ProfilesPermissions() {
        List<Profile> profiles = BL_FieldMappingManagerCtrl.getProfiles();

        try {
            BL_FieldMappingManagerCtrl.ProfilePermissionsResult result = BL_FieldMappingManagerCtrl.getPermissions(profiles[0].Id, 'Contact');
            BL_FieldMappingManagerCtrl.ProfilePermissionsResult result2 = BL_FieldMappingManagerCtrl.getPermissions(profiles[0].Id, 'testUseCase');
        } catch (AuraHandledException ex) {
            System.debug(ex);
        }
    }

    private static testMethod void test_performTestQuery() {
        BL_FieldMappingManagerCtrl.TestQueryResult result = BL_FieldMappingManagerCtrl.performTestQuery(TEST_USE_CASE);
    }

    private static testMethod void test_getObjectNames() {
        List<String> result = BL_FieldMappingManagerCtrl.getObjectNames();
        System.assert(!result.isEmpty());
    }
}