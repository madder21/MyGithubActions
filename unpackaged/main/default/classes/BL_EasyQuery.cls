/**
 * 
 * @author Jeremy Martiano
 * @since March 2020
 * @group balink General
 * @description class to faciliate all the SOQL, SOSL and Mapping process
 */
public with sharing class BL_EasyQuery {

    private Integer                                     defaultPageSize = 200;
    private static String                               baseUrl = '/services/data/v46.0/query/';
    private Usage                                       usage;

    private String                                      searchText;
    private String                                      condition;
    private String                                      orderBy;
    private String                                      objectName;
    private String                                      queryId;
    private String                                      useCaseLabel;
    private String                                      query;

    public String                                       parentFieldPath;
    public String                                       parentObjectName;

    private Integer                                     totalSize;
    private Integer                                     limitCount;
    private Integer                                     pageIndex;
    private Integer                                     pageSize;
    private List<SObject>                               sObjects;
    private List<Map<String,Object>>					sObjectsMap;
    private boolean                                     withoutSharing = false;

    private BL_UseCase                                  useCase;
    private List<String>                                fields;
    private Boolean                                     isMapped;
    private Map<String, String>                         conditionValues;
    private Map<String, BL_FieldsMapping>               fieldsMapping;
    private BL_WS_Interfaces.CustomMappingHandler       customMappingHandler;
    private List<Map<String, Object>>                   mappedObjects;

    public enum Usage   {FOR_VIEW, FOR_REFERENCE, FOR_UPDATE}
    
    
   
    

    public BL_EasyQuery() {

    }

    /**
     * 
     * @param objectName 
     * @returns `BL_EasyQuery`
     * @description Set query object entity
     */
    public BL_EasyQuery withoutSharing() {
        this.withoutSharing = true;
        return this;
    }

    /**
     * 
     * @param objectName 
     * @returns `BL_EasyQuery`
     * @description Set query object entity
     */
    public BL_EasyQuery withoutSharing(boolean isWithoutSharing) {
        this.withoutSharing = isWithoutSharing;
        return this;
    }
    /**
    * @description set a searchText for SOSL
    * @param searchText 
    * @returns `BL_EasyQuery`
    */
    public BL_EasyQuery searchText(String searchText) {
        this.searchText = searchText;
        return this;
    }

    /**
    * @description set conditionValues
    * @param conditionValues 
    * @returns `BL_EasyQuery`
    */
    public BL_EasyQuery conditionValues(Map<String, String> conditionValues) {
        this.conditionValues = conditionValues;
        return this;
    }

    /**
     * 
     * @param condition 
     * @returns `BL_EasyQuery`
     * @description Set a query condition
     */
    public BL_EasyQuery condition(String condition) {
        this.condition = condition;
        return this;
    }

    /**
     * 
     * @param orderBy 
     * @returns `BL_EasyQuery`
     * @description Set query order by
     */
    public BL_EasyQuery orderBy(String orderBy) {
        this.orderBy = orderBy;
        return this;
    }

    /**
     * 
     * @param limitCount 
     * @returns `BL_EasyQuery`
     * @description Set query limit
     */
    public BL_EasyQuery limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this;
    }

    /**
     * 
     * @param objectName 
     * @returns `BL_EasyQuery`
     * @description Set query object entity
     */
    public BL_EasyQuery objectName(String objectName) {
        this.objectName = objectName;
        return this;
    }

    /**
     * 
     * @param fields 
     * @returns `BL_EasyQuery`
     * @description Set query fields
     */
    public BL_EasyQuery fields(List<String> fields) {
        this.fields = fields;
        return this;
    }

    /**
     * 
     * @returns `BL_EasyQuery`
     * @description Set all fields
     */
    public BL_EasyQuery allFields() {
        List<String> fields = new List<String>();
        fields.addAll(BL_ObjectDescriber.getFields(this.objectName).KeySet());
        System.debug('BL_EasyQuery: fields: ' + fields);
        if(this.fields != null) {
            this.fields.addAll(fields);
        } else {
            this.fields = fields;
        }
        return this;
    }

    /**
     * 
     * @param fields 
     * @returns `BL_EasyQuery`
     * @description Add fields to be requested in the query
     */
    public BL_EasyQuery addFields(List<String> fields) {
        if(this.fields != null) {
            this.fields.addAll(fields);
        } else {
            this.fields = fields;
        }
        return this;
    }

    /**
     * 
     * @param additionalCondition 
     * @returns `BL_EasyQuery`
     * @description Add AND condition to the query
     */
    public BL_EasyQuery addCondition(String additionalCondition) {
        if(string.isBlank(additionalCondition))
             return this;
        if (!string.isBlank(this.condition)){
            this.condition += ' AND '  + additionalCondition;
        }
        else this.condition = additionalCondition;
        return this;
    }

    /**
     * 
     * @param innerSelect 
     * @returns `BL_EasyQuery`
     * @description Add Inner select to the query fields
     * (https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_relationships_query_using.htm)
     * @example 
     * this.addInnerSelect('Select Id from Contacts')
     * 
     */
    public BL_EasyQuery addInnerSelect(String innerSelect) {
        if(this.fields != null) {
            this.fields.add(innerSelect);
        } else {
            this.fields = new List<String>{innerSelect};
        }
        return this;
    }

    /**
     * 
     * @param pageIndex 
     * @param pageSize 
     * @returns `BL_EasyQuery`
     * @description Set pagination params to the query in order to set the LIMI and OFFSET of the Query
     * @example 
     * this.pagination(2,200) Limit will be 2*200 and offset 200
     */
    public BL_EasyQuery pagination(Integer pageIndex, Integer pageSize) {
        if(pageIndex != null){
            this.pageIndex = pageIndex;
            this.pageSize = pageSize != null ? pageSize : 200;
        } else if(pageSize != null) {
            this.limitCount = pageSize;
        }
        return this;
    }

    /**
     * 
     * @param queryId 
     * @returns `BL_EasyQuery`
     * @description Set the queryId received from a previous call of executeRestQuery(), extract of the queryId from the nextUrlrecords
     * (https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm)
     */
    public BL_EasyQuery queryId(String queryId) {
        this.queryId = queryId;
        return this;
    }

    /**
     * 
     * @param usage 
     * @returns `BL_EasyQuery`
     * @description Set the usage of the query in order to register results of the query to the recentlyviewed table of Salesforce.
     * (https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_view.htm)
     * @example 
     * this.usage(Usage.FOR_VIEW)
     */
    public BL_EasyQuery usage(Usage usage) {
        this.usage = usage;
        return this;
    }

    /**
     * 
     * @returns `BL_EasyQuery`
     * @description Makes aduplicate copy a BL_EasyQuery
     */
    public BL_EasyQuery cloneByValue() {
        BL_EasyQuery queryObj = new BL_EasyQuery();
        queryObj.condition = this.condition;
        queryObj.orderBy = this.orderBy;
        queryObj.limitCount = this.limitCount;
        queryObj.usage = this.usage;
        queryObj.conditionValues = this.conditionValues;
        queryObj.fields = this.fields;
        queryObj.objectName = this.objectName;
        return queryObj;
    }

    /**
     * 
     * @returns `Integer`
     * @description Get the pageSize of the current instance
     */
    public Integer getPageSize(){
        return this.pageSize;
    }

    /**
     * 
     * @returns `Integer`
     * @description Get the pageIndex of the current instance
     */
    public Integer getPageIndex(){
        return this.pageIndex;
    }

    /**
     * 
     * @returns `String`
     * @description Get the queryId of the current instance
     */
    public String getQueryId(){
        return this.queryId;
    }

    /**
     * 
     * @returns `String`
     * @description Returns the count query dynamic string
     * (https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_count.htm)
     */
    public String getCountQuery() {
        String query = 'SELECT COUNT() ';
        query += 'FROM ' + this.objectName + ' ';
        if(this.condition != null) {
            query += 'WHERE ' + this.condition + ' ';
        }
        query = replaceQueryConditionValues(query, this.conditionValues);
        return query;
    }

    /**
     * 
     * @returns `BL_EasyQuery`
     * @description Executes the COUNT Query and assign results to this.totalSize
     * (https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_count.htm)
     */
    public BL_EasyQuery executeCount() {
        String query = getCountQuery();
        string useCaseLbl = this.useCaseLabel != null ? this.useCaseLabel : '';
        useCaseLbl += withoutSharing ? '***withoutSharing***' : ' ' +'\n';
        BL_WS_Log.addLogQuery(query, useCaseLbl);
        this.totalSize = withoutSharing ? new executeWithoutSharing().executeCount(query) : Database.countQuery(query);
        return this;
    }

    /**
     * 
     * @returns `Integer`
     * @description Returns this.totalSize
     */
    public Integer getTotalSize() {
        return this.totalSize;
    }

    /**
     * 
     * @returns `BL_EasyQuery`
     * @description Executes the Query and assign results to this.sObjects
     * (https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_soql.htm)
     */
    public BL_EasyQuery executeQuery() {
        this.getQuery();
        string useCaseLbl = this.useCaseLabel != null ? this.useCaseLabel : '';
        useCaseLbl += withoutSharing ? '***withoutSharing***' : ' ' +'\n';
        BL_WS_Log.addLogQuery(this.query, useCaseLbl);
        this.sObjects = withoutSharing ? new executeWithoutSharing().executeQuery(this.query) : Database.query(this.query);
        return this;
    }

    public without sharing class executeWithoutSharing{

        public list<sObject> executeQuery(string query){
            return Database.query(query);
        }
        public Integer executeCount(string query){
            return Database.countQuery(query);
        }
        public List<List<Sobject>> executeSearch(string query){
            return search.query(query);
        }
    }

    /**
     * 
     * @returns `List<SObject>`
     * @description Returns this.sObjects
     */
    public List<SObject> getSObjects() {
        return this.sObjects;
    }

    /**
     * 
     * @returns `SObject`
     * @description Returns first element of this.sObjects
     */
    public SObject getSObject() {
        if(this.sObjects != null && this.sObjects.size() > 0){
            return this.sObjects[0];
        }
        return null;
    }

    /**
     * 
     * @returns `Map<String, Object>`
     * @description Returns this as Map<String, Object>
     */
    private Map<String, Object> getResponseObject() {
        return new Map<String, Object> {
            'records' => this.isMapped == true ? (Object) this.getMappedObjects() : (Object) this.getSObjects(),
            'totalSize' => this.getTotalSize(),
            'done' => true,
            'pageSize' => this.limitCount!= null ? this.limitCount : this.getPageSize(),
            'currentPage' => this.getPageIndex(),
            'queryId' => this.getQueryId(),
            'isEasyQuery' => true
        };
    }

    /**
     * 
     * @returns `Map<String, Object>`
     * @description Returns this as Map<String, Object>
     */
    public Map<String, Object> getResponseMappedObjects() {
        Map<String, Object> results = getResponseObject();
        results.put('records', (Object) this.getMappedObjects());
        return results;
    }

    /**
     * 
     * @returns `Map<String, Object>`
     * @description Returns this as Map<String, Object>
     */
    public Map<String, Object> getResponseSObjects() {
        Map<String, Object> results = getResponseObject();
        if(this.getSObjects() != null) {
            results.put('records', (Object) this.getSObjects());
        } else {
            results.put('records', (Object) this.sObjectsMap);
        }
        return results;
    }

    /**
     * 
     * @param searchText 
     * @returns `BL_EasyQuery`
     * @description Executes the SOSL and assign results to this.sObjects
     * (https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_sosl.htm)
     */
    public BL_EasyQuery executeSearch() {
        this.getSearchQuery();
        string useCaseLbl = this.useCaseLabel != null ? this.useCaseLabel : '';
        useCaseLbl += withoutSharing ? '***withoutSharing***' : ' ' +'\n';
        BL_WS_Log.addLogQuery(this.query, useCaseLbl);
        List<List<Sobject>> result = withoutSharing ? new executeWithoutSharing().executeSearch(this.query) : search.query(this.query);
        if(!result.isEmpty()){
            this.sObjects = result[0];
        }
        return this;
    }

        /**
     * 
     * @returns `String`
     * @description Returns the soql dynamic string query
     */
    private String getSearchQuery() {
        if (String.isEmpty(this.objectName)) {
            throw new BL_Exceptions.QueryException('QUERY_OBJECT_NAME_NOT_DEFINED', 'An error occured during the query');
        }

        String query = 'FIND \'' + this.searchText + '\' IN ALL FIELDS RETURNING ' +  this.objectName + ' ';

        String queryObj = '';
        queryObj += getFieldsString() + ' ';
        queryObj += getWhereCondition() + ' ';

        query += ' ( ' + queryObj +' ) ';
        this.query = replaceQueryConditionValues(query, this.conditionValues);
        return this.query;
    }

    /**
     * 
     * @param withoutPagination 
     * @returns `String`
     * @description Returns the soql dynamic string query depends on with pagination param
     */
    private String getQuery(Boolean withoutPagination) {
        if (String.isEmpty(this.objectName)) {
            throw new BL_Exceptions.QueryException('QUERY_OBJECT_NAME_NOT_DEFINED', 'An error occured during the query');
        }

        String query = '';
        query += 'SELECT ' + getFieldsString() + ' ';
        query += 'FROM ' + this.objectName + ' ';
        query += getWhereCondition(withoutPagination);

        this.query = replaceQueryConditionValues(query, this.conditionValues);
        return this.query;
    }

        /**
     * 
     * @returns `String`
     * @description Returns the soql dynamic string query with pagination
     */
    private String getQuery() {
        return this.getQuery(false);
    }

    /**
     * 
     * @returns `String`
     * @description Returns the soql dynamic string query without pagination
     */
    private String getRESTQuery() {
        return this.getQuery(true);
    }

    

     /**
     * 
     * @returns `String`
     * @description Returns the soql dynamic string fields
     */
    private String getFieldsString() {
        String fieldsStr = 'Id';
        if(this.fields != null && !this.fields.isEmpty()) {
            fieldsStr = String.join(this.fields, ', ');
        }

        return fieldsStr;
    }

    /**
     * 
     * @param withoutPagination 
     * @returns `String`
     * @description Returns the soql dynamic string where side condition (where, order by, limit, offset, for)
     */
    private String getWhereCondition(Boolean withoutPagination) {
        String query = ' ';
        if(this.condition != null) {
            query += 'WHERE ' + this.condition + ' ';
        }
        if(this.orderBy != null) {
            query += 'ORDER BY ' + this.orderBy + ' ';
        }
        if(withoutPagination){
            if(this.limitCount != null) {
                query += 'LIMIT ' + this.limitCount + ' ';
            }
        } else {
            if( pageIndex != null ) {
                query += 'LIMIT ' + this.pageSize + ' OFFSET ' + (this.pageSize*this.pageIndex) + ' ';
            }
            else if(this.limitCount != null) {
                query += 'LIMIT ' + this.limitCount + ' ';
            }
        }
        
        if(this.usage != null && String.isEmpty(this.searchText)) {
            Map<Usage, String> usageMap = new Map<Usage, String>{BL_EasyQuery.Usage.FOR_VIEW => 'VIEW', BL_EasyQuery.Usage.FOR_REFERENCE => 'REFERENCE', BL_EasyQuery.Usage.FOR_UPDATE => 'UPDATE'};
            query += 'FOR ' + usageMap.get(this.usage) + ' ';
        }
        
        return query;
    }

        /**
     * 
     * @returns `String`
     * @description Returns the soql dynamic string where side condition (where, order by, limit, offset, for)
     */
    private String getWhereCondition() {
        return getWhereCondition(false);
    }


    private static String replaceQueryConditionValues(String query, Map<String, String> conditionValues) {
        if(conditionValues != null) {
            for(String key: conditionValues.keySet()) {
                query = query.replace('{' + key + '}', conditionValues.get(key));
            }
        } 
        if(query.contains('{')) {
            Map<String, String> defaultConditionValues = getDefaultConditionValues();
            if(defaultConditionValues != null){
                BL_WS_Log.addLogNotes('Query Merge Fields: ',JSON.serialize(defaultConditionValues));
                for(String key: defaultConditionValues.keySet()) {
                    query = query.replace('{' + key + '}', defaultConditionValues.get(key));
                }
            }
        }
        return query;
    }

    private static Map<String, String> getDefaultConditionValues() {
        BL_WS_LOG.addLogNotes('notes',BL_WS_QueryMergeFields.getMergeFields());
        return BL_WS_QueryMergeFields.getMergeFields();
    }

    /**
     * 
     * @param useCaseLabel 
     * @returns `BL_EasyQuery`
     * @description Set useCase label in order to get object name and all fields linked to the BL_UseCase__mdt instance
     * @example 
     * this.useCase('Client')
     */
    public BL_EasyQuery useCase(String useCaseLabel) {
        this.useCaseLabel = useCaseLabel;

        if(useCaseLabel != null && !String.isEmpty(useCaseLabel)) {
            this.useCase = BL_UseCase.getUseCase(useCaseLabel);
            this.fieldsMapping = BL_FieldsMapping.getValidMapping(this.useCase);
            this.objectName = this.useCase.ObjectName;
            this.fields = this.getQueryFields();
        }
        
        if(this.useCase.QueryCondition != null) {
            if(this.condition == null) {
                this.condition = this.useCase.QueryCondition;
            } else {
                this.condition += ' AND ' + this.useCase.QueryCondition;
            }
        }
        return this;
    }

    /**
     * 
     * @returns `List<Map<String, Object>>`
     * @description Converts this.sObjects to mapped fields according to the useCase FieldMapping and assign it to this.mappedObjects
     */
    public List<Map<String, Object>> getMappedObjects() {
        if(this.mappedObjects!= null && !this.mappedObjects.isEmpty()){
            return this.mappedObjects;
        }
        this.mapObjects();
        return this.mappedObjects;
    }

    /**
     * 
     * @returns `Map<String, Object>`
     * @description Converts this.sObjects[0] to mapped fields according to the useCase FieldMapping 
     */
    public Map<String, Object> getMappedObject() {
        if(this.mappedObjects!= null && !this.mappedObjects.isEmpty()){
            return this.mappedObjects[0];
        }
        if(this.useCase == null){
            throw new BL_Exceptions.QueryException('Use Case  NOT SET',  'BL_Constants.MapError' , 'USE_CASE_NOT_SET');
        }
        if(this.sObjects != null && this.sObjects.size() > 0){
            return this.convertSObjectToWrapper(new List<SObject>{this.sObjects[0]})[0];
        }
        return null;
    }

         /**
     * 
     * @returns `BL_EasyQuery`
     * @description Converts this.sObjects to mapped fields according to the useCase FieldMapping and assign it to this.mappedObjects
     */
    public BL_EasyQuery mapObjects() {
        if(this.useCase == null){
            throw new BL_Exceptions.QueryException('Use Case  NOT SET',  'RICBL_Constants.MapError' , 'USE_CASE_NOT_SET');
        }
        this.mappedObjects = this.convertSObjectToWrapper(this.sObjects);
        this.isMapped = true;
        return this;
    }

    /**
     * 
     * @param customMappingHandler 
     * @returns `BL_EasyQuery`
     * @description Callback method implemented in other class implementing the BL_WS_Interfaces.CustomMappingHandler in order to avoid over loop for calculated fields
     * @example 
     * this.callBackMapping(ClientListCustomMapping())
     * where ClientListCustomMapping class implememnts Void callback( SObject sobj, Map<String, Object> wrapObj)
     */
    public BL_EasyQuery customMappingProperties(BL_WS_Interfaces.CustomMappingHandler customMappingHandler){
        this.customMappingHandler = customMappingHandler;
        return this;
    }

    /**
     * 
     * @returns `BL_EasyQuery`
     * @description Executes request with pagination on large table. Indeed ref: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_offset.htm 
     * The maximum offset is 2,000 rows. 
     * The workaround is when we need pagination behind 2,000 rows we are using API Standard SF Query that is not limited and returns nextRecordsUrl
     * (https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm)
     * @example 
     * this.paginaion(1,200).executeRestQuery() will execute executeAPIQuery() and will return queryId
     * If a queryId is setted this.queryId('01gD0000002HU6KIAW').executeRestQuery(), executeAPINextUrlRequest() will be executed directly
     */
    public BL_EasyQuery executeRestQuery() {
        this.pageSize = this.pageSize != null ? this.pageSize : 200;
        this.pageSize = this.pageSize > 2000 ? 2000 : this.pageSize;
        if( this.queryId != null && this.pageIndex != null) {
            this.pageSize = this.pageSize < 200 ? 200 : this.pageSize;
            executeAPINextUrlRequest();
        } else {
            this.pageSize = this.pageSize < 200 ? 200 : this.pageSize;
            this.pageIndex = this.pageIndex != null ? this.pageIndex : 0;
            executeAPIQuery();
        }
        return this;
    }

    /**
     * 
     * @returns `BL_EasyQuery`
     * @description Executes request with pagination on large table. Indeed ref: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_offset.htm 
     * The maximum offset is 2,000 rows. 
     * The workaround is when we need pagination behind 2,000 rows we are using API Standard SF Query that is not limited and returns nextRecordsUrl
     * (https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm)
     * @example 
     * this.paginaion(100,200).executeRestQuery() will execute executeAPIQuery() and will return queryId
     * this.paginaion(1,200).executeRestQuery() will execute doSOQLRestResponse()
     * If a queryId is setted this.queryId('01gD0000002HU6KIAW').executeRestQuery(), executeAPINextUrlRequest() will be executed directly
     */
    private BL_EasyQuery executeHybridRestQuery() {
        this.pageSize = this.pageSize != null ? this.pageSize : 200;
        this.pageSize = this.pageSize > 2000 ? 2000 : this.pageSize;
        if( this.queryId != null && this.pageIndex != null) {
            this.pageSize = this.pageSize < 200 ? 200 : this.pageSize;
            executeAPINextUrlRequest();
        } else {
            if(this.pageIndex == null && this.pageSize < 2000 || this.pageIndex*this.pageSize < 2000  ){
                doSOQLRestResponse(); 
            } else {
                this.pageSize = this.pageSize < 200 ? 200 : this.pageSize;
                executeAPIQuery();
            }
        }
        return this;
    }

    private void executeAPIQuery() {
        
        this.getRESTQuery();
        BL_WS_Log.addLogQuery(this.query, this.useCaseLabel);
        BL_HTTP_Utils request = new BL_HTTP_Utils()
        .get(URL.getSalesforceBaseUrl().toExternalForm() + baseUrl + '?q=' + EncodingUtil.urlEncode(this.query, 'UTF-8'))
        .header('Authorization', 'Bearer ' + UserInfo.getSessionId())
        .header('Content-Type', 'application/json')
        .header('Sforce-Query-Options', 'batchSize='+this.pageSize)
        .call();

        if(this.pageIndex != null && this.pageIndex > 0) {
            this.queryId = getQueryId(request);
            executeAPINextUrlRequest();
            return;
        }
        handleResponse(request);
    }

    private void executeAPINextUrlRequest() {
        BL_HTTP_Utils request = new BL_HTTP_Utils()
        .get(URL.getSalesforceBaseUrl().toExternalForm() + baseUrl + this.queryId + '-' + this.pageSize*this.pageIndex)
        .header('Authorization', 'Bearer ' + UserInfo.getSessionId())
        .header('Content-Type', 'application/json')
        .header('Sforce-Query-Options', 'batchSize='+this.pageSize)
        .call();

        handleResponse(request);
    }

    private void handleResponse (BL_HTTP_Utils request) {
        BL_WS_Log.addLogNotes(request.response.getBody());
        system.debug(request);
        Map<String,Object> response = request.getBodyResponse();
        if(request.statusCode() == 200) {
            this.queryId = getQueryId(request);
            this.totalSize = (Integer) response.get('totalSize');
            try{
                this.sObjects = ( List<SObject>) JSON.deserializeStrict(JSON.serialize(response.get('records')), List<SObject>.class);
            } catch (Exception ex){
                system.debug(ex.getMessage());
                for(Object obj : ( List<Object>) response.get('records')){
                    if(this.sObjectsMap == null) {
                        this.sObjectsMap = new List<Map<String, Object>>();
                    }
                    this.sObjectsMap.add((Map<String, Object>) obj);
                }
            }
        }
        else {
            String errorBody = JSON.serializePretty(response);
            BL_WS_Log.addLogNotes(errorBody);
            String errorCode = errorBody.contains('INVALID_QUERY_LOCATOR') ? 'INVALID_QUERY_LOCATOR' : 'ERROR_OCCURRED_IN_REST_QUERY';
            throw new BL_Exceptions.QueryException(errorCode, 'An error occurred during the rest query');//response.get('results') != null ? ((Map<String, Object>)((List<Object>) response.get('results'))[0]).get('message') : response.get('message'));
        }
    }

    private void doSOQLRestResponse() {
        this.executeCount()
        .executeQuery();
    }

    private String getQueryId(BL_HTTP_Utils request){
        Map<String,Object> response = request.getBodyResponse();
        if(response.get('nextRecordsUrl') != null) {
            return ((String) response.get('nextRecordsUrl')).substringBetween('query/','-');
        }
        return null;
    }


    private List<String> getQueryFields() {
        List<String> queryFields = new List<String>();
        for(String key : fieldsMapping.keySet()){
            BL_FieldsMapping mapping = this.fieldsMapping.get(key);
            
            if(mapping.IsCurrency){
                queryFields.add(key);
                queryFields.add('convertCurrency(' + key + ') ' + (key.contains('.') ? key.substringAfterLast('.') : key) + 'Converted');
            }
            else if(mapping.GetPicklistLabel){
                queryFields.add(key);
                queryFields.add('toLabel(' + key + ')' + mapping.Wrapper_Field_Name + 'Label');
            } else if (mapping.Is_InnerSelect){
                BL_EasyQuery innerQuery = new BL_EasyQuery().useCase(mapping.InnerSelect_UseCase.Label);
                innerQuery.objectName(mapping.SFFieldPath);
                List<String> innerFields = innerQuery.getQueryFields();
                String fieldsStr = null;
                if(innerFields != null && !innerFields.isEmpty()) {
                    fieldsStr = '('+ innerQuery.getQuery() +')';
                }
                queryFields.add(fieldsStr);
            } else {
                queryFields.add(key);
            }    
        }
        return queryFields;
    }

    private List<Map<String, Object>> convertSObjectToWrapper( List<SObject> objectList ) {
        List<Map<String, Object>> wrapperList = new  List<Map<String, Object>>();
        if(objectList != null && !objectList.isEmpty()){
            for(SObject item : objectList) {
                Map<String, Object> wrapper = convertSobjectToWrapper(item);
                if( this.customMappingHandler != null ){
                    this.customMappingHandler.addCustomMappingProperties(item, wrapper);
                }
                wrapperList.add(wrapper);
            }
        }
        return wrapperList;
    }
    
    public Map<String, Object> convertSobjectToWrapper(SObject item) {
        Map<String, Object> result = new  Map<String, Object>();
        for(String sfField : fieldsMapping.keySet()) {
            String wrapperFieldName =  fieldsMapping.get(sfField).Wrapper_Field_Name;
            boolean getPicklistLabel =  fieldsMapping.get(sfField).GetPicklistLabel;
            Object value = null;
            if(fieldsMapping.get(sfField).Is_InnerSelect) {
                value = BL_ObjectDescriber.getInnerQueryValue(item, sfField);
            } else {
                value = BL_ObjectDescriber.getValue(item, sfField);
            }

            if (fieldsMapping.get(sfField).IsCurrency == true) {
                result.put(wrapperFieldName + 'Original', value);
                result.put(wrapperFieldName , BL_ObjectDescriber.getValue(item, sfField + 'Converted'));
            } else if(value != null) {
                if (wrapperFieldName.contains('.')) {
                    // sub object
                    List<String> keyParts = wrapperFieldName.split('\\.');
                    Object childObj = result.get(keyParts[0]);
                    Map<String,Object> childObjMap = (Map<String,Object>) childObj;
                    if(childObjMap == null) {
                        childObjMap = new Map<String,Object>();
                        result.put(keyParts[0], childObjMap);
                    }
                    childObjMap.put(keyParts[1], value);
                } else if(fieldsMapping.get(sfField).Is_InnerSelect) {
                    BL_EasyQuery innerQuery = new BL_EasyQuery().useCase(fieldsMapping.get(sfField).InnerSelect_UseCase.Label);
                    result.put(wrapperFieldName, innerQuery.convertSObjectToWrapper((SObject[]) value));
                } else {
                    result.put(wrapperFieldName, value);
                }
            }

            if(getPicklistLabel){
                result.put(wrapperFieldName + 'Label', item.get(wrapperFieldName + 'Label'));
            }
        }
        return result;
    }

    public List<SObject> convertWrapperToSObject( List<Object> wrapperItems) {
        List<SObject> sObjects = new List<SObject>();

        for(Object wrapperItem : wrapperItems) {
            Map<String, Object> wrapperItemMap = (Map<String, Object>) wrapperItem;
            Set<String> wrapperItemMapKeys = wrapperItemMap.keySet();
            Map<String, Object> mapObject = new Map<String, Object>();
            List<SObject> nestedSObjects = new List<SObject>();

            for(BL_FieldsMapping fieldMapping : this.fieldsMapping.values()) {
                if(fieldMapping.Save_to_SF && !fieldMapping.Is_InnerSelect && !fieldMapping.SFFieldPath.contains('.') && wrapperItemMapKeys.contains(fieldMapping.Wrapper_Field_Name)) {
                    mapObject.put(fieldMapping.SFFieldPath, wrapperItemMap.get(fieldMapping.Wrapper_Field_Name));
                }
            }       
            SObject sObj = BL_ObjectDescriber.createSObject(mapObject, this.useCase.ObjectName);
            sObjects.add(sObj);
        }
        return sObjects;
    }

    //TEST

    public Map<SObject,Map<Schema.DescribeFieldResult,List<SObject>>> convertWrapperToSObjectWithChilds( List<Object> wrapperItems) {
        List<SObject> sObjects = new List<SObject>();
        Map<SObject,Map<Schema.DescribeFieldResult,List<SObject>>> mapSobjects = new Map<SObject,Map<Schema.DescribeFieldResult,List<SObject>>>();

        for(Object wrapperItem : wrapperItems) {
            Map<String, Object> wrapperItemMap = (Map<String, Object>) wrapperItem;
            Set<String> wrapperItemMapKeys = wrapperItemMap.keySet();
            Map<String, Object> mapObject = new Map<String, Object>();
            Map<Schema.DescribeFieldResult,List<SObject>> nestedSObjectsMap = new Map<Schema.DescribeFieldResult,List<SObject>>();

            for(BL_FieldsMapping fieldMapping : this.fieldsMapping.values()) {
                if(fieldMapping.Save_to_SF && !fieldMapping.Is_InnerSelect && !fieldMapping.SFFieldPath.contains('.') && wrapperItemMapKeys.contains(fieldMapping.Wrapper_Field_Name)) {
                    mapObject.put(fieldMapping.SFFieldPath, wrapperItemMap.get(fieldMapping.Wrapper_Field_Name));
                } 
                else if (fieldMapping.Is_InnerSelect && fieldMapping.Save_to_SF ){
                    Schema.DescribeFieldResult relationshipDescribe = BL_ObjectDescriber.getRelationshipFieldDescribe(this.objectName, fieldMapping.SFFieldPath);
                    BL_EasyQuery nested = new BL_EasyQuery().useCase(fieldMapping.InnerSelect_UseCase.Label);
                    nestedSObjectsMap.put(relationshipDescribe, nested.convertWrapperToSObject((List<Object>)wrapperItemMap.get(fieldMapping.Wrapper_Field_Name)));
                }
            }        
            SObject sObj = BL_ObjectDescriber.createSObject(mapObject, this.useCase.ObjectName);
            
            if(nestedSObjectsMap.size() > 0){
                for(Schema.DescribeFieldResult C : nestedSObjectsMap.keySet()){
                    for(SObject nsobj : nestedSObjectsMap.get(C)){
                        nsobj.putSObject(C.getRelationshipName(), sObj);
                    }
                }
                
            }
            mapSobjects.put(sObj, nestedSObjectsMap);
        }
        return mapSobjects;
    }

    public static List<SObject> insertSobjectsWithChilds(Map<SObject, Map<Schema.DescribeFieldResult,List<SObject>>> mapSobjects) {
        insert new List<SObject>(mapSobjects.keySet());
        List<SObject> nestedObjs = new List<SObject>();
        List<SObject> results = new List<SObject>();
        for(Map<Schema.DescribeFieldResult,List<SObject>> nestMap : mapSobjects.values()){
            for( Schema.DescribeFieldResult C: nestMap.keySet()){
                for(SObject nSobj : nestMap.get(C)){
                    nSobj.put(C.getName(), nSobj.getSObject(C.getRelationshipName()).Id);
                    nestedObjs.add(nSobj);
                }
            } 
        }
        insert nestedObjs;
        results.addAll(nestedObjs);
        results.addAll(mapSobjects.keySet());
        return nestedObjs;

    }

}