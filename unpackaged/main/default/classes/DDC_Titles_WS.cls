// /services/apexrest/ddc/v0/titles
public with sharing class DDC_Titles_WS implements BL_Rest_Router_Factory.DispatchableGET {

    private static final String LABEL_PREFIX = 'customer.data.fields.salutation.options.';
    private static final String CONFIG_KEY = 'customise.fields.salutation';
    
    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return getPicklistOptions('Contact', 'Salutation', LABEL_PREFIX, CONFIG_KEY);
    }

    private static List<BL_ObjectDescriber.Option> getPicklistOptions(String objectName, String fieldName, String labelPrefix, String configKey) {
        // get values from config
        Set<String> configValues = getvaluesFromConfig(configKey);
        Boolean returnAllValues = configValues == null || configValues.isEmpty();

        List<BL_ObjectDescriber.Option> options = BL_ObjectDescriber.getPicklistOptions(objectName, fieldName);
        List<BL_ObjectDescriber.Option> returnOptions = new List<BL_ObjectDescriber.Option>();
        for (BL_ObjectDescriber.Option option : options) {
            if (returnAllValues || configValues.contains(option.value)) {
                option.label = labelPrefix + option.label.toLowerCase().removeEnd('.');
                option.sortByValue = true;
                returnOptions.add(option);
            }
        }
        returnOptions.sort();
        return returnOptions;
    }

    private static Set<String> getvaluesFromConfig(String configKey) {
        try {
            if (String.isEmpty(configKey)) {
                return null;
            }
            List<DDC_Config__mdt> config = [SELECT Value__c FROM DDC_Config__mdt 
                WHERE Key__c = :configKey];
            if (config.isEmpty() || String.isEmpty(config[0].Value__c)) {
                return null;
            }
            return (Set<String>) JSON.deserialize(config[0].Value__c, Set<String>.class);
        } catch (Exception ex) {
            System.debug('getValuesFromConfig: Exception: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return null;
    }

}