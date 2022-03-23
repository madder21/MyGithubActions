// /services/apexrest/ddc/v0/person
public with sharing class DDC_Person_WS implements BL_Rest_Router_Factory.DispatchableGET {
    
    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        String userCode = pathParameters.get('userCode');
        if (String.isEmpty(userCode)) {
            throw new BL_Rest_Router_Factory.RouterException(new Map<String, Object> {
                'message'=>'Invalid User Code', 
                'errorCode' => 'INVALID_USER_CODE',
                'statusCode' => 404
            });
        }
        List<User> users = [SELECT Id FROM User WHERE StaffCode__c = :userCode];
        if (users.isEmpty()) {
            throw new BL_Rest_Router_Factory.RouterException(new Map<String, Object> {
                'message'=>'USER NOT FOUND', 
                'errorCode' => 'USER_NOT_FOUND',
                'statusCode' => 404
            });
        }
        return '';
    }

}