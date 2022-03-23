@isTest
public with sharing class BL_EasyQuery_Test {  
    @isTest
    static void Test_Method1() {    
        Test.startTest();
       List<String> fields = new List<String>();
       fields.add('FirstName');
       BL_EasyQuery bl = new BL_EasyQuery()
           .useCase('Me')
           .condition('Id != NULL')
           .addCondition('Id != NULL')
           .pagination(2, 2)
           .cloneByValue()
           .orderBy('CreatedDate')
           .limitCount(3)
           .objectName('User')
           .fields(fields)
           .addInnerSelect('Id')
           .allFields();
       
       BL_EasyQuery bl2 = new BL_EasyQuery()
           .useCase('Me')
           .queryId('123')
           .pagination(null, 2)
           .usage(null)
           .searchText('test')
           .conditionValues(null)
           .withoutSharing()
           .addCondition('Id != NULL')
           .addCondition(null);
           //.addInnerSelect('Id');
       
        Map<String, Object> mappedObj  = bl2.getMappedObject();
       List<Map<String, Object>>  mappingList = (List<Map<String, Object>>) bl2.executeQuery().getResponseMappedObjects().get('records');
       
        List<Object> wrapperItems= new List<Object>();
        Map<String,String> mapItem = new Map<String,String>();
        mapItem.put('Me_Firstname','Me_Firstname');
        wrapperItems.add(mapItem);
       
       Map<SObject,Map<Schema.DescribeFieldResult,List<SObject>>> item = new BL_EasyQuery()
           .useCase('Me').convertWrapperToSObjectWithChilds(wrapperItems);
       
       Integer pageSize = bl.getPageSize();
        Map<String, String> conditionValues = new Map<String, String> ();
        conditionValues.put('Firstname', 'sarah');
       BL_EasyQuery bleasyQuery = new BL_EasyQuery()
           .useCase('Me')
           .queryId('123')
           .pagination(3, 2)
           .usage(null)
           .searchText('test')
           .conditionValues(conditionValues)
           .withoutSharing()
           .addCondition('Id != NULL')
           .addCondition(null)
           //.addInnerSelect('Id')
           .executeSearch();
       Integer pageIndex = bl.getPageIndex();
       String QueryId = bl2.getQueryId();
       Integer totalsize = bl.getTotalSize();
        SObject obj = new BL_EasyQuery().getSObject();
        BL_EasyQuery.executeWithoutSharing blExecuteSharing = new BL_EasyQuery.executeWithoutSharing();
       
       list<sObject> lst = blExecuteSharing.executeQuery('SELECT ID FROM USER');
       BL_EasyQuery bl4 = bl2.executeSearch();
       Map<String, Object> mapResponse = bl2.getResponseSObjects();
       mapResponse = bl2.getResponseMappedObjects();
      bl4 = bl2.executeCount();
       
       
        List<String> fieldsToInsert =  new List<String>();
        fields.add('Name');
        BL_EasyQuery easyQuery = new BL_EasyQuery()
           .useCase('Me')
           .addFields(new List<String> ())
           .addFields(fieldsToInsert)
           .withoutSharing(false)
           .pagination(2, 2)
            .condition('Id != {test}')
           .cloneByValue()
           .orderBy('CreatedDate')
           .limitCount(3)
           .objectName('User')
           .fields(fields)
           .addInnerSelect('Id')
           .allFields();
       
        //Map<String, Object> mappedObj = easyQuery.getMappedObject();
               
        Map<String, String> queryMergeFieldsMap =new Map<String, String> ();
        queryMergeFieldsMap.put('test','123');
        BL_WS_QueryMergeFields.init(queryMergeFieldsMap);
       
        String queryConditions = easyQuery.getCountQuery();
        BL_WS_Interfaces.CustomMappingHandler customMappingHandler;
        BL_EasyQuery easyQuery2 = easyQuery.customMappingProperties(customMappingHandler);
       
        Map<String,Object> mapItems = new Map<String,Object>();
        List<Object> wrapperList = new List<Object>();
        List<SObject> objList = easyQuery.convertWrapperToSObject(wrapperList);
       
        Map<SObject, Map<Schema.DescribeFieldResult,List<SObject>>> mapSobj = new Map<SObject, Map<Schema.DescribeFieldResult,List<SObject>>>();
        List<SObject> SobjList = BL_EasyQuery.insertSobjectsWithChilds(mapSobj);
       
         try{
            BL_EasyQuery bl3 = bl.executeRestQuery();
        }
        catch(Exception ex){
            system.debug(ex);
        }
        Test.stopTest();
    }
}