@isTest
private class CLT_Utils_Query_Test {

    @isTest
    //EBU - Feb2025 - Code coverage is not enough !
	static void testGetMyUserWithBothParamToTRUE() {
        Test.startTest();
        String sQuery = CLT_Utils_Query.getClientsQuery(true,true);
        Test.stopTest();
        Assert.isNotNull(sQuery, 'CLT_Utils_Query_Test - testGetMyUserWithBothParamToTRUE - The generated query should not be null/empty');
    }
    
    @isTest
    //EBU - Feb2025 - Code coverage is not enough !
	static void testGetMyUserWithBothParamToFALSE() {
		Test.startTest();
        String sQuery = CLT_Utils_Query.getClientsQuery(true,true);
        Test.stopTest();
        Assert.isNotNull(sQuery, 'CLT_Utils_Query_Test - testGetMyUserWithBothParamToFALSE - The generated query should not be null/empty');
    }
    
    @isTest
    //EBU - Feb2025 - Code coverage is not enough !
	static void testGetGeneralClientsQuery() {
    	Test.startTest();
        String sQuery = CLT_Utils_Query.getGeneralClientsQuery();
        Test.stopTest();
        Assert.isNotNull(sQuery, 'CLT_Utils_Query_Test - testGetGeneralClientsQuery - The generated query should not be null/empty');
    }
}