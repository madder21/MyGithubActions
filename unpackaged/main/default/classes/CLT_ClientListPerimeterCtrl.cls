/**
 * @author Sarah AYOUN(Balink)
 * @date July,25 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is the controller for the LWC clt_clientListPerimeter
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 1.0		|2024/07/25			|.Sarah A	|.RCLIENT-1085	    |.original version
*/
public with sharing class CLT_ClientListPerimeterCtrl {
    /*
     * @METHOD 	: getInitializationPerimeter
     * @DESC 	: Return the values to display in the picklist of the component according to the client list displayed
     * @PARAM 	: clientListId: the record Id of the client list on which the component is displayed
     * @RETURN 	: Map<String, Object> : wrapped values of picklists to display
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInitializationPerimeter(String clientListId){
        Map<String, Object> initializationPerimeter = new Map<String, Object>();
        try {
            List<Map<String,string>> regions = getPicklistValuesFromFieldName('ClientList__c', 'Region__c');
            initializationPerimeter.put('regions', regions);
            ClientList__c clientList = [SELECT Region__c,Country__c,Stores__c FROM ClientList__c WHERE Id = :clientListId LIMIT 1];
            List<String> selectedRegions = !String.isEmpty(clientList.Region__c) ? clientList.Region__c.split(';') : new List<String>();
            initializationPerimeter.put('selectedRegions', selectedRegions);
            initializationPerimeter.put('countries', (selectedRegions.size() > 0 ? getCountryValuesFromSelectedRegions(selectedRegions) : new List<Map<String,string>>()));
            List<String> selectedCountries = !String.isEmpty(clientList.Country__c) ? clientList.Country__c.split(';') : new List<String>();
            initializationPerimeter.put('selectedCountries', selectedCountries);
            initializationPerimeter.put('stores', (selectedCountries.size() > 0 ? getStoreValuesFromSelectedCountries(selectedCountries) : new List<Map<String,string>>()));
            initializationPerimeter.put('selectedStores', !String.isEmpty(clientList.Stores__c) ? clientList.Stores__c.split(';') : new List<String>());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return initializationPerimeter;
    }

    /*
     * @METHOD 	: getPicklistValuesFromFieldName
     * @DESC 	: Return the picklist values for a sent fiels
     * @PARAM 	: objectName: the sObject on which the field is, fieldName: the field for which return the picklist values
     * @RETURN 	: List<Map<String,string>> : wrapped values of a picklist field
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,string>> getPicklistValuesFromFieldName(String objectName, String fieldName){
        List<Map<String,string>> picklistOptions = new List<Map<String,string>>();
        try {
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            Map<String,string> option = new Map<String,string>();
            for (Schema.PicklistEntry pickListVal : ple) {
                picklistOptions.add(new Map<String,string>{
                    'label' => pickListVal.getLabel(),
                    'value' => pickListVal.getValue()
                });
            }   
                
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return picklistOptions;
    }

    /*
     * @METHOD 	: getCountryValuesFromSelectedRegions
     * @DESC 	: Return the country values for a selected region
     * @PARAM 	: regions: a list of region that is selected on the client list
     * @RETURN 	: List<Map<String,string>> : wrapped values of countries that are related to the selected Regions
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,string>> getCountryValuesFromSelectedRegions(List<String> regions){
        List<Map<String,string>> picklistOptions = new List<Map<String,string>>();
        try {
            for(AggregateResult ar : [SELECT Country__c countryValue, toLabel(Country__c) countryLabel
                                    FROM Store__c
                                    WHERE Region__c IN :regions AND Country__c != NULL AND Closed__c = false
                                    GROUP BY Country__c]) {
                picklistOptions.add(new Map<String,string>{
                    'label' => String.valueOf(ar.get('countryLabel')),
                    'value' => String.valueOf(ar.get('countryValue'))
                });
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return picklistOptions;
    }

    /*
     * @METHOD 	: getStoreValuesFromSelectedCountries
     * @DESC 	: Return the store values for a selected country
     * @PARAM 	: countries: a list of countries that is selected on the client list
     * @RETURN 	: List<Map<String,string>> : wrapped values of stores that are related to the selected countries
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,string>> getStoreValuesFromSelectedCountries(List<String> countries){
        List<Map<String,string>> picklistOptions = new List<Map<String,string>>();
        try {
            for(Store__c store : [SELECT StoreLabel__c, SourceStoreId__c
                                    FROM Store__c
                                    WHERE Country__c IN :countries AND StoreLabel__c != NULL AND SourceStoreId__c != NULL AND Closed__c = false]) {
                picklistOptions.add(new Map<String,string>{
                    'label' => store.StoreLabel__c,
                    'value' => store.SourceStoreId__c
                });
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return picklistOptions;
    }

    /*
     * @METHOD 	: updateClientListPerimeter
     * @DESC 	: update the selected perimeter on the client list
     * @PARAM 	: clientListId: the Id of the client list to update, regions: the selected regions, countries: the selected countries, stores: the selected stores
     * @RETURN 	: ---
     */
    @AuraEnabled
    public static void updateClientListPerimeter(String clientListId, List<String> regions, List<String> countries, List<String> stores){
        try {
            ClientList__c clientList = [SELECT Id,Region__c,Country__c,Stores__c FROM ClientList__c WHERE Id = :clientListId LIMIT 1];
            clientList.Region__c = regions.size() > 0 ? String.join(regions, ';') : '';
            clientList.Country__c = countries.size() > 0 ? String.join(countries, ';') : '';
            clientList.Stores__c = stores.size() > 0 ? String.join(stores, ';') : '';

            update clientList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}