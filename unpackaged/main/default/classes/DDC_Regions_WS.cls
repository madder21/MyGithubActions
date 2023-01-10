public with sharing class DDC_Regions_WS implements BL_Rest_Router_Factory.DispatchableGET {
    
    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return getRegions();
    }

    public static List<Map<String,Object>> getRegions() {
        Map<String,List<Option>> optionsMap = getDependentPicklistValues2(Contact.DDC_Region__c);
        System.debug('value: ' + Json.serialize(optionsMap));

        List<Map<String,Object>> items = new List<Map<String,Object>>();
        for (String countryCode : optionsMap.keySet()) {
            for (Option option : optionsMap.get(countryCode)) {
                Map<String,Object> item = new Map<String,Object> {
                    'identifier'    => option.value,
                    'name'          => option.label,
                    'geo'           => new Map<String,String> { 'addressCountry' => countryCode }
                };
                items.add(item);
            }
        }
        return items;
    }

    public static Map<String,List<Option>> getDependentPicklistValues2(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<Option>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<Option>> valuesMap = new Map<String,List<Option>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!valuesMap.containsKey((String) controlValue)) {
                        valuesMap.put((String) controlValue, new List<Option>());
                    }
                    valuesMap.get((String) controlValue).add(new Option(entry));
                }
            }
        }
        System.debug('valuesMap: ' + valuesMap);
        return valuesMap;
    }

    private class Option {
        public String label;
        public String value;

        public Option(String label, String value) {
            this.label = label;
            this.value = value;
        }

        public Option(Schema.PicklistEntry entry) {
            this.label = entry.getLabel();
            this.value = entry.getValue();
        }
    }
}