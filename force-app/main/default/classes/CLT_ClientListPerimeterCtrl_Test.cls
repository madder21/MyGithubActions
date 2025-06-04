/**
 * @author Sarah AYOUN (Balink)
 * @date July,25 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_ClientListPerimeterCtrl :
 * testSetup : Creation of test store
 * TEST METHOD				        		|	DESCRIPTION
 * getInitializationPerimeterTest           |	Test the get of initializaion perimeter
 * getPicklistValuesFromFieldNameTest       |	Test the get of picklist values 
 * getCountryValuesFromSelectedRegionsTest  |	Test the get of countries for a region
 * getStoreValuesFromSelectedCountriesTest  |	Test the get of stores for a country
 * updateClientListPerimeterTest			|	Test the update of perimeter values on a client list
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 1.0		|2024/07/25			|.Sarah A.		|.RCLIENT-1085			|.original version
*/
@isTest
private class CLT_ClientListPerimeterCtrl_Test {
    @TestSetup
    static void createTestData() {
        Store__c store = CLT_TestDateFactory.createTestStore('FR01', false);
        store.Region__c = '001';
        store.Country__c = 'FR';
        store.StoreLabel__c = 'TEST_FR01';
        insert store;
    }

    @isTest
    static void getInitializationPerimeterTest() {
        ClientList__c cl = CLT_TestDateFactory.createTestClientList('Test Perimeter List', 'Id != NULL', false);
        cl.Region__c = '001;';
        cl.Country__c = 'FR;';
        cl.Stores__c = 'FR01';
        insert cl;

        Map<String, Object> result = CLT_ClientListPerimeterCtrl.getInitializationPerimeter(cl.Id);
    
        List<Object> regionsFromResult = (List<Object>)JSON.deserializeUntyped(JSON.serialize(result.get('selectedRegions')));
        System.assertEquals(1, regionsFromResult.size(), 'CLT_ClientListPerimeterCtrl_Test:getInitializationPerimeterTest: client list is set to one region and not returned from perimeter');
    }

    @isTest
    static void getPicklistValuesFromFieldNameTest() {
        List<Map<String,string>> storeRegionPicklistValuesCalculated = CLT_ClientListPerimeterCtrl.getPicklistValuesFromFieldName('Store__c', 'Region__c');
        List<Schema.PicklistEntry> storeRegionPicklistValues = Schema.getGlobalDescribe().get('Store__c').getDescribe().fields.getMap().get('Region__c').getDescribe().getPicklistValues();
        System.assertEquals(storeRegionPicklistValues.size(), storeRegionPicklistValuesCalculated.size(), 'CLT_ClientListPerimeterCtrl_Test:getPicklistValuesFromFieldNameTest: picklist values size is not the same as calculated one');

    }

    @isTest
    static void getCountryValuesFromSelectedRegionsTest() {
        List<Map<String,string>> countries = CLT_ClientListPerimeterCtrl.getCountryValuesFromSelectedRegions(new List<String> {'001'});
        System.assertEquals(1, countries.size(), 'CLT_ClientListPerimeterCtrl_Test:getCountryValuesFromSelectedRegionsTest: only one country with the sent region');
    }

    @isTest
    static void getStoreValuesFromSelectedCountriesTest() {
        List<Map<String,string>> stores = CLT_ClientListPerimeterCtrl.getStoreValuesFromSelectedCountries(new List<String> {'FR'});
        System.assertEquals(1, stores.size(), 'CLT_ClientListPerimeterCtrl_Test:getStoreValuesFromSelectedCountriesTest: only one store with the sent country');
    }

    @isTest
    static void updateClientListPerimeterTest() {
        ClientList__c cl = CLT_TestDateFactory.createTestClientList('Test Perimeter List', 'Id != NULL', true);
        Test.startTest();
        CLT_ClientListPerimeterCtrl.updateClientListPerimeter(cl.Id, new List<String> {'001'}, new List<String> {'FR'}, new List<String> {'FR01'});
        Test.stopTest();

        ClientList__c clAfterUpdate = [SELECT Region__c FROM ClientList__c WHERE Id = :cl.Id LIMIT 1];
        System.assertEquals(1, (clAfterUpdate.Region__c.split(';')).size(),'CLT_ClientListPerimeterCtrl_Test:updateClientListPerimeterTest: only one region is sent');
    }
}