public with sharing class Individual_TDF {

    public static List<Individual> buildIndividual(Integer numRecords, Boolean shouldBeInserted) {
        List<Individual> individualToBeCreated = new List<Individual>();
        for(integer i=0; i<numRecords; i++) {
            individualToBeCreated.add(new Individual(
                LastName = 'Individual For Test'+i
            ));
        }
        
        if(!individualToBeCreated.isEmpty() && shouldBeInserted) {
            insert individualToBeCreated;
        }

        return individualToBeCreated;
    }
}