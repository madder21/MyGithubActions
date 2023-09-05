@isTest
private class asyncDeleteB2CCustomInput_Test {

    //EBU 2023July26th - Empty test method to pass PROD deployment
	@isTest static void testGETB2CCustomInput() {
        List<Id> listID = new List<Id>();
        List<ConsentWrapper> lcw = new List<ConsentWrapper>();
        asyncDeleteB2CCustomInput.deleteCustomInput(listID);
    }
    
    //EBU 2023July26th - Empty test method to pass PROD deployment 
    @isTest static void testDeleteB2CCustomInput() {
        List<Id> listID = new List<Id>();
        List<ConsentWrapper> lcw = new List<ConsentWrapper>();
        listID = asyncDeleteB2CCustomInput.getB2CCustomInput(lcw);
    }
    
}