/**
 * @author Paul-Louis Mony
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description The primary function of this class is to either activate or deactivate a trigger
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|29062023			|.PLM		|.					|.
*/
public class BypassTrigger {
	
    /*
    * @description Check if the class either bypassed or not by the current user
    *
    * @param className name of the class to be checked
    * @return a boolean value indicating whether the class has been bypassed by the user (true) or not (false).
    */
    public static Boolean checkBypassClass(String className) {

        TriggerBypass__mdt bypass = TriggerBypass__mdt.getInstance(UserInfo.getName().replace(' ', '_'));
        if (bypass != null) {
            return bypass.ApexBypass__c?.split(';')?.contains(className);
        }
      	return false;
    }
    
}