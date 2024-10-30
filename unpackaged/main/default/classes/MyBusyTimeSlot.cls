public class MyBusyTimeSlot {

    public String slotId;
    public String booxiId;
    public String day;
    public String range;

    public MyBusyTimeSlot(Event e) {
        this.slotId = e.Id;
        this.booxiId = e.BooxiId__c;
        this.day = e.ActivityDateTime.format('yyyy-MM-dd');
        this.range = e.ActivityDateTime.hour() +':'+ e.ActivityDateTime.minute()
                    + ' - ' + e.EndDateTime.hour() +':'+ e.EndDateTime.minute();
    }
}