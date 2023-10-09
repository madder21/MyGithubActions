/* @author Paul Louis MONY
 * @date September,20th 2023
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description : This Apex class, AP3_SFMCSynchronisation, is responsible for managing the synchronization of the "isSFMC__pc" field
 * on Salesforce Account records. The main purpose is to determine whether this field should be set to true or false
 * based on specific conditions involving the client's data.
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0		|2023/09/19			|.PLM		|.JIRA CI-202			|.Original Version
*/
public with sharing class AP3_SFMCSynchronisation {
     
	/**
     * @METHOD   : manageSynchronisation
     * @DESC     : Manages the synchronization of the "	isSFMC__pc" field for a given client Account.
     * @PARAM    : client - The Account object representing the client.
     * @RETURN   : None
     */
    public static void manageSynchronisations (List<Account> clients){
        for(Account client : clients){
            manageSynchronisation(client);
        }
    }    
    /**
     * @METHOD   : manageSynchronisation
     * @DESC     : Manages the synchronization of the "	isSFMC__pc" field for a given client Account.
     * @PARAM    : client - The Account object representing the client.
     * @RETURN   : None
     */
    public static boolean manageSynchronisation (Account client){
        Boolean returnStatus =  toSync(client);
        client.isSFMC__pc = returnStatus;
        return returnStatus;
    }
    
    /**
     * @METHOD   : toSync
     * @DESC     : Calculates whether the "isSFMC__pc" field should be synchronized for a client Account.
     *             It evaluates conditions such as the current value of "isSFMC__pc," "ContactableByEmail__pc," and
     *             the client's mailing country against valid countries specified in the custom metadata type SFMCCountry__mdt.
     * @PARAM    : client - The Account object representing the client.
     * @RETURN   : True if the "isSFMC__pc" field should be set to true, false otherwise.
     */
    @TestVisible
    private static boolean toSync (Account client){
        Boolean isBackInStock = client.BackInStock__pc;
        Boolean isContactableByEmail = client.ContactableByEmail__pc;
        Boolean isValidCountry = false;
        
        for(SFMCCountry__mdt validCountry : SFMCCountry__mdt.getall().values()){
            if(validCountry.Label == client.personMailingCountry)
                isValidCountry = true;
        }

		Boolean result = (isBackInStock || (isContactableByEmail && isValidCountry));
        return result;
    }
}