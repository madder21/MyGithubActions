public class TimeIntervalSorter {

    // Method to convert time in HH:mm format to total minutes since 00:00
    public static Integer convertTimeToMinutes(String cTime) {
        // Ensure the time string is in HH:mm format (e.g., '9:00')
        Integer hours = Integer.valueOf(cTime.substring(0, cTime.indexOf(':')));  // Get the hours
        Integer minutes = Integer.valueOf(cTime.substring(cTime.indexOf(':') + 1));  // Get the minutes
        return (hours * 60) + minutes;
    }

    // Method to sort the list of time intervals
    public static List<String> sortTimeIntervals(List<String> timeIntervals) {
        List<TimeInterval> intervals = new List<TimeInterval>();

        // Parse each interval and convert times to total minutes
        for (String interval : timeIntervals) {
            List<String> times = interval.split(' - ');
            Integer startMinutes = convertTimeToMinutes(times[0]);
            Integer endMinutes = convertTimeToMinutes(times[1]);
            intervals.add(new TimeInterval(startMinutes, endMinutes, interval));
        }

        // Sort intervals by start time in minutes (using Comparable)
        intervals.sort();

        // Rebuild the sorted time intervals in "HH:mm - HH:mm" format
        List<String> sortedIntervals = new List<String>();
        for (TimeInterval t : intervals) {
            sortedIntervals.add(t.originalInterval);
        }

        return sortedIntervals;
    }

    // Helper class to hold the interval and start time in minutes
    public class TimeInterval implements Comparable {
        public Integer startMinutes;
        public Integer endMinutes;
        public String originalInterval;

        // Constructor
        public TimeInterval(Integer startMinutes, Integer endMinutes, String originalInterval) {
            this.startMinutes = startMinutes;
            this.endMinutes = endMinutes;
            this.originalInterval = originalInterval;
        }

        // Implement compareTo method to sort by start time in minutes
        public Integer compareTo(Object obj) {
            TimeInterval other = (TimeInterval) obj;  // Ensure we're comparing a TimeInterval object
            return this.startMinutes - other.startMinutes;  // Compare based on startMinutes
        }
    }
}