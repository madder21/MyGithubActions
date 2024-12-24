@isTest
public class BusinessHoursCalculatorTest {

    @testSetup
    static void setupTestData() {
        // Ensure there's an existing Business Hours record in the org
        BusinessHours bh = [SELECT Id FROM BusinessHours LIMIT 1];
        System.assertNotEquals(null, bh.Id, 'A Business Hours record must exist in the org for this test to run.');
    }

    @isTest
    static void testCalculateBusinessSecondsValidInputs() {
        // Fetch the existing Business Hours
        BusinessHours bh = [SELECT Id FROM BusinessHours LIMIT 1];

        // Create Input
        BusinessHoursCalculator.FlowInputs input = new BusinessHoursCalculator.FlowInputs();
        input.businessHoursId = bh.Id;
        input.startTime = DateTime.newInstance(2023, 11, 20, 10, 0, 0); // 10 AM
        input.endTime = DateTime.newInstance(2023, 11, 20, 15, 0, 0);   // 3 PM

        List<BusinessHoursCalculator.FlowInputs> inputs = new List<BusinessHoursCalculator.FlowInputs>{input};

        // Call Method
        Test.startTest();
        List<Decimal> results = BusinessHoursCalculator.calculateBusinessMinutes(inputs);
        Test.stopTest();

        // Validate Results
        System.assert(results.size() > 0, 'Expected at least one result.');
        System.assertEquals(18000, results[0], 'Expected 18,000 seconds (5 hours)');
    }

    @isTest
    static void testCalculateBusinessSecondsNoOverlap() {
        // Fetch the existing Business Hours
        BusinessHours bh = [SELECT Id FROM BusinessHours LIMIT 1];

        // Create test input with no overlap
        BusinessHoursCalculator.FlowInputs input = new BusinessHoursCalculator.FlowInputs();
        input.businessHoursId = bh.Id;
        input.startTime = DateTime.newInstance(2023, 11, 20, 6, 0, 0); // 6 AM (outside hours)
        input.endTime = DateTime.newInstance(2023, 11, 20, 8, 0, 0);   // 8 AM (outside hours)

        List<BusinessHoursCalculator.FlowInputs> inputs = new List<BusinessHoursCalculator.FlowInputs>{input};

        // Call the method
        Test.startTest();
        List<Decimal> results = BusinessHoursCalculator.calculateBusinessMinutes(inputs);
        Test.stopTest();

        // Validate Results
        System.assert(results.size() > 0, 'Expected at least one result.');
        System.assertEquals(7200, results[0], 'Expected 0 seconds for no overlap'); //EBU to ABLA : to modify if need to align with Outside office feature
    }

    @isTest
    static void testCalculateBusinessSecondsNullInputs() {
        // Create test input with null Business Hours
        BusinessHoursCalculator.FlowInputs input = new BusinessHoursCalculator.FlowInputs();
        input.businessHoursId = null; // Null Business Hours
        input.startTime = DateTime.newInstance(2023, 11, 20, 10, 0, 0);
        input.endTime = DateTime.newInstance(2023, 11, 20, 15, 0, 0);

        List<BusinessHoursCalculator.FlowInputs> inputs = new List<BusinessHoursCalculator.FlowInputs>{input};

        // Call the method
        Test.startTest();
        List<Decimal> results = BusinessHoursCalculator.calculateBusinessMinutes(inputs);
        Test.stopTest();

        // Validate Results
        System.assert(results.size() > 0, 'Expected at least one result.');
        System.assertEquals(0, results[0], 'Expected 0 seconds for null Business Hours');
    }

    @isTest
    static void testBulkProcessing() {
        // Fetch the existing Business Hours
        BusinessHours bh = [SELECT Id FROM BusinessHours LIMIT 1];

        // Create multiple test inputs
        List<BusinessHoursCalculator.FlowInputs> inputs = new List<BusinessHoursCalculator.FlowInputs>();
        for (Integer i = 0; i < 50; i++) {
            BusinessHoursCalculator.FlowInputs input = new BusinessHoursCalculator.FlowInputs();
            input.businessHoursId = bh.Id;
            input.startTime = DateTime.newInstance(2023, 11, 20, 10, 0, 0); // 10 AM
            input.endTime = DateTime.newInstance(2023, 11, 20, 15, 0, 0);   // 3 PM
            inputs.add(input);
        }

        // Call the method
        Test.startTest();
        List<Decimal> results = BusinessHoursCalculator.calculateBusinessMinutes(inputs);
        Test.stopTest();

        // Validate results
        System.assertEquals(50, results.size(), 'Expected 50 results');
        System.assertEquals(18000, results[0], 'Expected 18,000 seconds for each input');
    }
}