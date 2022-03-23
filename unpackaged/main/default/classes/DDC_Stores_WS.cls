// /services/apexrest/ddc/v0/stores
public with sharing class DDC_Stores_WS implements BL_Rest_Router_Factory.DispatchableGET {
    
    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return new BL_EasyQuery()
        .useCase('DDC_Store')
        .executeQuery()
        .getMappedObjects();
    }

}