/**
 * 
 * @author Jeremy Martiano
 * @since March 2019
 * @description Class containing interfaces connected to the web service
 * @group balink Webservices General
 * 
 */
global class BL_WS_Interfaces { 
    /**
	* @description the base for all dispatchable interfaces (GET, PUT, etc.)
	*/
	global interface Dispatchable {
    }

    /**
     * @description required for executing an HTTP Get call
     */
    global interface DispatchableGET extends Dispatchable {
        Object executeGET();
    }
    /**
     * @description required for executing an HTTP Post call
     */
    global interface DispatchablePOST extends Dispatchable {
        Object executePOST();
    }
    /**
     * @description required for executing an HTTP Patch call
     */
    global interface DispatchablePATCH extends Dispatchable {
        Object executePATCH();
    }
    /**
     * @description required for executing an HTTP Put call
     */
    global interface DispatchablePUT extends Dispatchable {
        Object executePUT();
    }
    /**
     * @description required for executing an HTTP Delete call
     */
    global interface DispatchableDELETE extends Dispatchable {
        Object executeDELETE();
    }

    /**
     * @description interface to define the mapping between a web service call 
     *      and parameters to the implementation class
     */
    global interface RouterMapping {
        Map<String,String> routesMapping();
        Map<String, String> getCurrentRoute(String requestURI);
    }

    /**
     * @description required for web service router to execute HTTP calls
     */
    global interface  Routable {
        void doGET();
        void doPOST();
        void doPATCH();
        void doPUT();
        void doDELETE();
    }

    /**
     * @description used for getting both basic User info and extended
     */
    public interface Userable {
        Map<String,Object> extendInfos();
        String useCase();
    }

    
    public interface CustomMappingHandler {
        Void addCustomMappingProperties( SObject sobj, Map<String, Object> wrapObj);
    }

}