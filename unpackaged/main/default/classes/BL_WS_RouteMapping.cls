/**
 * 
 * @author Jeremy Martiano
 * @since March 2019
 * @description Virtual Class required to translate the web service into the current route
 * @group balink Webservices General
 */
global virtual class BL_WS_RouteMapping implements BL_WS_Interfaces.RouterMapping {
    /**
     * 
     * @returns `Map<String,String>`
     * @description must be implemented in classes that extend this class to return the map of all routes
     */
    global virtual Map<String,String> routesMapping(){ return null; }

    /**
     * 
     * @param requestURI the request path with parameters
     * @returns `Map<String, String>`
     * @description find the request from the requestURI and return a map with the class name that implements it
     */
    global Map<String, String> getCurrentRoute(String requestURI){
        Map<String, String> routes = routesMapping();
        List<String> requestURIList = requestURI.split('/');
        if(!routes.isEmpty()){
            for(String route: routes.keySet()){
                List<String> dispachableURIList = route.split('/');
                Boolean matching = true;
                if (dispachableURIList.size() != requestURIList.size()) {
                    matching = false;
                }
                else {
                    for (Integer i = 0; i < dispachableURIList.size(); i++) {
                        if (!dispachableURIList.get(i).contains('{') && dispachableURIList.get(i) != requestURIList.get(i)) {
                            matching = false;
                        }
                    }
                }
                if (matching) {
                    String className = routes.get(route);
                    if (isClassAccessibleByCurrentUser(className)) {
                        return new Map<String, String>{'path'=>route, 'className' => className};
                    } else {
                        throw new BL_Exceptions.RouterException('User does not have access to ' + className);
                    }
                }
            }
        }
        return null;
    }

    /**
     * 
     * @param className 
     * @returns `Boolean`
     * @description check if the current user's profile has access to the class route.
     */
    private Boolean isClassAccessibleByCurrentUser(String className) {
        //Maybe need to implement appsetting or userSetting to byPass or not
        List<ApexClass> classes = [SELECT Id, Name,
        (SELECT Id, Parent.Name, Parent.Profile.Name
        FROM SetupEntityAccessItems WHERE Parent.ProfileId = :UserInfo.getProfileId())
        FROM ApexClass
        WHERE Name = :className];

        return classes[0].SetupEntityAccessItems.size() > 0;
    }
}