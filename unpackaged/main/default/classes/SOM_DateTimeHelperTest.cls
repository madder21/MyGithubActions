@isTest
public class SOM_DateTimeHelperTest {
    public static SOM_DateConvertionInput dateinput  = new SOM_DateConvertionInput();
    @isTest(seeAllData = true)
    static void makeData(){
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Order myOrder = [ select id,CreatedDate from Order where Id =: los[0].OriginalOrderId ];
        dateinput.targetTimeZone           = 'Asia/Dubai';
        dateinput.dateToConvert            = myOrder.CreatedDate;
    }
    @isTest(seeAllData = true)
    public static void callConstructor() {
        makeData();
        date expectedDate  				   = SOM_DateTimeHelper.convertDateTimeByTimeZone(new List<SOM_DateConvertionInput>{dateinput})[0].date();
        Datetime expectedDateTime = SOM_DateTimeHelper.convertISO8601ToDateTime('2022-05-20T17:15:58.000Z');
        System.assertNotEquals(expectedDate,null, 'Date Updated');
        System.assertNotEquals(expectedDateTime,null, 'DateTime Updated');
        
    }
    
}