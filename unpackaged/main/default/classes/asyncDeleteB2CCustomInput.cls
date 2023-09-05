public class asyncDeleteB2CCustomInput {
	
    /*
    * @description delete the B2CCustomInput__c
    *
    * @param customInputIds list of B2CCustomInput__c Ids to be deleted
    */
    @future
    public static void deleteCustomInput(List<Id> customInputIds) {
		List<B2CCustomInput__c> customInputList = [SELECT Id FROM B2CCustomInput__c WHERE Id in :customInputIds];
        system.debug('Ids='+customInputList);
        if (!customInputList.isEmpty()) {
            delete customInputList;   
			//Database.emptyRecycleBin(customInputList);
        }
	}
    
    public static List<Id> getB2CCustomInput(List<ConsentWrapper> consentList) {
        
        List<Id> customInputIds = new List<Id>();
		for (ConsentWrapper consent : consentList) {
			customInputIds.add(consent.customInput.Id);
		}
        return customInputIds;
    }

}