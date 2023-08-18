global with sharing class CLT_PersonalClientList implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return CLT_Utils_PersonalClientList.deletePersonalClientList(params);
    }

    global Object retrievePost(Map<String, String> params, Map<String,Object> body){
        Boolean clientsFilters = params.containsKey('clientsFilters') ? Boolean.valueOf(params.get('clientsFilters')) : false;
        if(clientsFilters) {
            return CLT_Utils_PersonalClientList.getClientsByFilters(body);
        }
        return CLT_Utils_PersonalClientList.upsertPersonalClientList(params,body);
    }

    global Object retrieveGet(Map<String, String> params){
        return CLT_Utils_PersonalClientList.getPersonalClientList();
    }

   
}