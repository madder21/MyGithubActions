public class BusinessHoursCalculator {

    @InvocableMethod
    public static List<Decimal> calculateBusinessMinutes(List<FlowInputs> inputs) {
        List<Decimal> results = new List<Decimal>();
        for (FlowInputs input : inputs) {
            if (input == null || input.businessHoursId == null || input.startTime == null || input.endTime == null) {
                // Si les données sont invalides, on ajoute 0 comme résultat
                results.add(0);
                continue;
            }
            Long millisecondsDifference = BusinessHours.diff(
                input.businessHoursId,
                input.startTime,
                input.endTime
            );
            Decimal secondsDifference = millisecondsDifference != null ? millisecondsDifference / 1000 : 0;
            results.add(secondsDifference);
        }
        return results;
    }

    public class FlowInputs {
        @InvocableVariable
        public Id businessHoursId;
        @InvocableVariable
        public DateTime startTime;
        @InvocableVariable
        public DateTime endTime;
    }
}