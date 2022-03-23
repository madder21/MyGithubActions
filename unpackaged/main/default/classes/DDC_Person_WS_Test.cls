@isTest
private with sharing class DDC_Person_WS_Test {

    private static testMethod void test_DDC_Person_WS() {
        User user = prepareUser();
        user.StaffCode__c = '1234';
        insert user;
        DDC_Person_WS ws = new DDC_Person_WS();
        Map<String, String> pathParameters = new Map<String, String> { 'userCode' => '1234' };
        ws.executeGET(pathParameters, null);
        Boolean isFailed = false;
        try {
            pathParameters.put('userCode', 'fdfngksgkjdfg');
            ws.executeGET(pathParameters, null);
        } catch (BL_Rest_Router_Factory.RouterException ex) {
            isFailed = true;
        }
        System.assert(isFailed);
    }

    private static User prepareUser() {
        List<Profile> profiles = [select Id from Profile];
        User user = new User(
            Username = 'test4564566@test.com',
            LastName = 'test',
            Email = 'test@test.com',
            Alias = 'test',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = profiles[0].Id,
            LanguageLocaleKey = 'en_US'
        );
        return user;
    }
}