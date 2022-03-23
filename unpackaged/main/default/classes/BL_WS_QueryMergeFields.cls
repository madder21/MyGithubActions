/**
 * 
 */

public with sharing class BL_WS_QueryMergeFields {
    
    private static Map<String, String> queryMergeFields;

    public static void init(Map<String, String> queryMergeFieldsMap) {
        queryMergeFields = queryMergeFieldsMap;
    }

    public static Map<String, String> getMergeFields() {
        return queryMergeFields;
    }
}