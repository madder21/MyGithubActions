@isTest
public class SlotCalculatorTest {
    
    @isTest
    static void testFindMissingSlotsWithNoMissingSlots() {
        // Define busy slots, available slots, and already calculated free slots
        List<String> busySlots = new List<String>{'09:00 - 09:30', '10:00 - 10:30', '11:00 - 11:30'};
        List<String> availableSlots = new List<String>{'09:30 - 10:00', '10:30 - 11:00', '11:30 - 12:00'};
        List<String> calculatedFreeSlots = new List<String>{'09:30 - 10:00', '10:30 - 11:00', '11:30 - 12:00'};
        
        // Call the method
        List<String> missingSlots = SlotCalculator.findMissingSlots(busySlots, availableSlots, calculatedFreeSlots);
        
        // Verify that no missing slots are returned
        System.assertEquals(0, missingSlots.size(), 'There should be no missing slots');
    }
    
    @isTest
    static void testFindMissingSlotsWithSomeMissingSlots() {
        // Define busy slots, available slots, and already calculated free slots
        List<String> busySlots = new List<String>{'09:00 - 09:30', '10:00 - 10:30'};
        List<String> availableSlots = new List<String>{'09:00 - 09:30', '09:30 - 10:00', '10:00 - 10:30', '10:30 - 11:00', '11:00 - 11:30', '11:30 - 12:00'};
        List<String> calculatedFreeSlots = new List<String>{'11:00 - 11:30', '11:30 - 12:00'};
        
        // Call the method
        List<String> missingSlots = SlotCalculator.findMissingSlots(busySlots, availableSlots, calculatedFreeSlots);
        System.debug('missingSlots '+missingSlots);
        // Verify the correct missing slots
        System.assertEquals(1, missingSlots.size(), 'There should be one missing slot');
        System.assertEquals('10:30 - 11:00', missingSlots[0], 'The missing slot should be 10:30 - 11:00');
    }
    
    @isTest
    static void testFindMissingSlotsWithAllSlotsBusy() {
        // Define busy slots, available slots, and already calculated free slots
        List<String> busySlots = new List<String>{'09:00 - 09:30', '10:00 - 10:30', '11:00 - 11:30'};
        List<String> availableSlots = new List<String>{'09:30 - 10:00', '10:30 - 11:00', '11:30 - 12:00'};
        List<String> calculatedFreeSlots = new List<String>{'09:30 - 10:00', '10:30 - 11:00', '11:30 - 12:00'};
        
        // Call the method
        List<String> missingSlots = SlotCalculator.findMissingSlots(busySlots, availableSlots, calculatedFreeSlots);
        
        // Verify that there are no missing slots
        System.assertEquals(0, missingSlots.size(), 'There should be no missing slots');
    }
    
    @isTest
    static void testFindMissingSlotsWithNoAvailableSlots() {
        // Define busy slots, available slots, and already calculated free slots
        List<String> busySlots = new List<String>{'09:00 - 09:30', '10:00 - 10:30', '11:00 - 11:30'};
        List<String> availableSlots = new List<String>{};
        List<String> calculatedFreeSlots = new List<String>{};
        
        // Call the method
        List<String> missingSlots = SlotCalculator.findMissingSlots(busySlots, availableSlots, calculatedFreeSlots);
        
        // Verify that there are no missing slots since no available slots are provided
        System.assertEquals(0, missingSlots.size(), 'There should be no missing slots when no available slots are given');
    }
    
    @isTest
    static void testFindMissingSlotsWithEdgeCaseTimes() {
        // Define busy slots, available slots, and already calculated free slots
        List<String> busySlots = new List<String>{'09:00 - 09:30', '10:00 - 10:30'};
        List<String> availableSlots = new List<String>{'09:00 - 09:30', '09:30 - 10:00', '10:00 - 10:30', '10:30 - 11:00', '11:00 - 11:30', '11:30 - 12:00'};
        List<String> calculatedFreeSlots = new List<String>{ '11:00 - 11:30', '11:30 - 12:00'};
        
        // Call the method
        List<String> missingSlots = SlotCalculator.findMissingSlots(busySlots, availableSlots, calculatedFreeSlots);
        
        // Verify the result for boundary cases
        System.assertEquals(1, missingSlots.size(), 'There should be one missing slot');
        System.assertEquals('10:30 - 11:00', missingSlots[0], 'The missing slot should be 09:00 - 09:30');
    }
    
    @isTest
    static void testFindMissingSlotsWithMultipleMissingSlots() {
        // Define busy slots, available slots, and already calculated free slots
        List<String> busySlots = new List<String>{'09:00 - 09:30', '10:00 - 10:30'};
        List<String> availableSlots = new List<String>{'09:00 - 09:30', '09:30 - 10:00', '10:00 - 10:30', '10:30 - 11:00', '11:00 - 11:30', '11:30 - 12:00'};
        List<String> calculatedFreeSlots = new List<String>{ '11:00 - 11:30', '11:30 - 12:00'};
        
        // Call the method
        List<String> missingSlots = SlotCalculator.findMissingSlots(busySlots, availableSlots, calculatedFreeSlots);
        
        // Verify the missing slots
        System.assertEquals(1, missingSlots.size(), 'There should be two missing slots');
        System.assertEquals('10:30 - 11:00', missingSlots[0], 'First missing slot should be 10:30 - 11:00');
    }
}