@isTest
public class LogCleanBatch_Test {
    @isTest
    static void testOne() {

    Log__c log = new Log__c();
    insert log;
    Test.setCreatedDate(log.Id, Date.today().addDays(-10));
    String sch = '0  00 1 3 * ?';

    Test.startTest();
    system.schedule('Test', sch, new LogCleanScheduler());
    Test.stopTest();
  }
}