public with sharing class CLT_UtilsPicklist {

    public static List<PicklistWrapper> getPicklists(list<String> picklistNames){
        List<PicklistWrapper> picklistResults = new List<PicklistWrapper>();

        string query =  'Select Id, giv_FieldName__c, giv_ObjectName__c, giv_Values__c, giv_Exclude_Fields__c, giv_ControllingFieldName__c, giv_Take_All_Object_List__c ' +
            'From CLT_Picklist__mdt ' +
            'WHERE giv_Active__c = TRUE';

        if (picklistNames.size() > 0){
            query += ' AND giv_FieldName__c IN (\'' + String.join(picklistNames, '\',\'') + '\')';
        }
        system.debug(query);
        //Get all picklist from custom setting
        List<CLT_Picklist__mdt> allPicklists = Database.query(query);

        //Order Picklist with Labels
        for( CLT_Picklist__mdt imPl : allPicklists) {
            if(imPl.giv_Take_All_Object_List__c)
                preperObjectListPicklist(imPl, picklistResults);
            else
                preperObjectFieldPicklist(imPl, picklistResults);
        }

        return picklistResults;
    }

    static void preperObjectListPicklist(CLT_Picklist__mdt imPl, List<PicklistWrapper> picklistResults) {
        PicklistWrapper pL = new PicklistWrapper(imPl.giv_ObjectName__c, imPl.giv_FieldName__c, null, null);

        //Get the excluded values
        Set<String> excludeFieldsSet = new Set<String>();
        if(imPl.giv_Exclude_Fields__c != null){
            excludeFieldsSet.addAll(imPl.giv_Exclude_Fields__c.split(';'));
        }

        String query = 'SELECT Id, Name FROM ' + imPl.giv_ObjectName__c + ' WHERE Id NOT IN :excludeFieldsSet';
        List<Object> dataList = Database.query(query);
        List<String> values = new List<String>();
        List<String> labels = new List<String>();
        for(Object obj : dataList) {
            
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            
            pL.Labels += (String)objMap.get('Name') + ';';
            pL.Values += (String)objMap.get('Id') + ';';
        }
        pL.Labels = pL.Labels.removeEnd(';');
        pL.Values = pL.Values.removeEnd(';');
        picklistResults.add(pL);
    }

    static void preperObjectFieldPicklist(CLT_Picklist__mdt imPl, List<PicklistWrapper> picklistResults) {
        PicklistWrapper pL = new PicklistWrapper(imPl.giv_ObjectName__c, imPl.giv_FieldName__c, null, null);
        if( imPl.giv_ControllingFieldName__c == null){
            Map<String,String> picklistValLabelMap = new Map<String,String>();
            //Get the excluded values
            Set<String> excludeFieldsSet = new Set<String>();
            if(imPl.giv_Exclude_Fields__c != null){
                excludeFieldsSet.addAll(imPl.giv_Exclude_Fields__c.split(';'));
            }

            //Get PicklistEntries
            List<Schema.PicklistEntry> pleList = (Schema.getGlobalDescribe())
            .get(imPl.giv_ObjectName__c)
            .getDescribe()
            .fields
            .getMap()
            .get(imPl.giv_FieldName__c)
            .getDescribe()
            .getPicklistValues();

            for(Schema.PicklistEntry sPle:pleList){
                picklistValLabelMap.put(sPle.getValue(), sPle.getLabel());
            }

            //if wanted Values in custom metadata
            if(imPl.giv_Values__c != null){
                for(String s : imPl.giv_Values__c.split(';')){
                    if(excludeFieldsSet.isEmpty() ||
                    (!excludeFieldsSet.isEmpty() && !excludeFieldsSet.contains(s))){
                        pL.Values += s.removeStart('\t')+';';
                        pL.Labels += picklistValLabelMap.get(s) != null ?
                            picklistValLabelMap.get(s).removeStart('\t') + ';' : s.removeStart('\t') + ';';
                    }
                }
            }

            else{
                for(Schema.PicklistEntry sPle : pleList){
                    if(excludeFieldsSet.isEmpty() ||
                    (!excludeFieldsSet.isEmpty() && !excludeFieldsSet.contains(sPle.getValue()))){
                        pL.Labels += (sPle.getLabel() + ';');
                        pL.Values += (sPle.getValue() + ';');
                    }
                }

            }

            pL.Labels = pL.Labels.removeEnd(';');
            pL.Values = pL.Values.removeEnd(';');
            picklistResults.add(pL);

        }
          /*else {
            Map<String, List<MyPickListValues>> dependantPickListMap = getFieldDependencies(imPl.ObjectName__c,imPl.ControllingFieldName__c,imPl.FieldName__c);
            for(String key : dependantPickListMap.keySet()){
                PicklistWrapper dpL = new PicklistWrapper(imPl.ObjectName__c, imPl.FieldName__c, imPl.ControllingFieldName__c, key);

                for(MyPickListValues mypick : dependantPickListMap.get(key)){
                    dpL.Labels += mypick.Label+';';
                    dpL.Values += mypick.Value +';';
                }
                dpL.Labels=dpL.Labels.removeEnd(';');
                dpL.Values=dpL.Values.removeEnd(';');
                picklistResults.add(dpL);
            }
        }*/
    }
/*
    //Dependant Picklist functions algorithms
    public static Map<String, List<MyPickListValues>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        Map<String, List<MyPickListValues>> controllingInfo = new Map<String, List<MyPickListValues>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            controllingInfo.put(currControllingValue.getValue(), new List<MyPickListValues>());
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);

            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            Integer baseCount = 0;

            for(Integer curr : hexString.getChars())
            {
                MyPickListValues mypicklistValues = new MyPickListValues();
                Integer val = 0;

                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }

                if((val & 8) == 8)
                {
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(mypicklistValues);
                }
                if((val & 4) == 4)
                {
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(mypicklistValues);
                }
                if((val & 2) == 2)
                {
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(mypicklistValues);
                }
                if((val & 1) == 1)
                {
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(mypicklistValues);
                }

                baseCount += 4;
            }
        }
        return controllingInfo;
    }
*/
    public class PicklistWrapper{
        public String objectName {get; set;}
        public String fieldName {get;set;}
        public String ControllingFieldName {get;set;}
        public String controllingFieldValue {get;set;}
        public String labels {get;set;}
        public String values {get;set;}
        public String id {get;set;}

        public PicklistWrapper(String objectName, String fieldName, String controllingFieldName, String controllingFieldValue){
            this.fieldName = fieldName != null ? fieldName : '';
            this.objectName = objectName;
            this.ControllingFieldName = controllingFieldName;
            this.controllingFieldValue = controllingFieldValue;
            this.labels = '';
            this.values = '';
            this.id = String.valueof(DateTime.now().getTime()) + this.FieldName + this.ObjectName;
        }
    }

    public class MyPickListInfo { public String validFor; }
    public class MyPickListValues {
        public String Label {get;set;}
        public String Value {get;set;}
    }
}