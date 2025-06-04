public interface CLT_RetailInterface {
    Object retrievePost(Map<String, String> params, Map<String,Object> body);
    Object retrieveGet(Map<String, String> params); 
    Object retrieveDelete(Map<String, String> params);   
}