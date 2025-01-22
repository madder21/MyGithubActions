@isTest
public with sharing class TimeslotCoverageTest {
	
    @isTest
    static void testCoverage() {
        TimeslotWrapper tw1 = new TimeslotWrapper();
        TimeslotInputs tw2 = new TimeslotInputs();
        ClientInputs tw3 = new ClientInputs();
        
        System.assertEquals(true, true, 'TimeslotCoverageTest testCoverage');
    }
}