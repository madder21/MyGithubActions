@IsTest
public with sharing class SOM_SalesPaymentsReportSchedule_Test {

   // CRON expression: midnight on March 15 2023
   // Because this is a test, job executes immediately after Test.stopTest() regardless of date
   public static String CRON_EXP = '0 0 0 15 3 ? 2023';

   @IsTest (seeAllData = true)
   static void test() {
      Test.startTest();

      SOM_SalesAndPaymentsReportSchedule re = new SOM_SalesAndPaymentsReportSchedule();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, re);

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2023-03-15 00:00:00', 
      String.valueOf(ct.NextFireTime));

      // Verify the scheduled job hasn't run yet.
      Integer beforeInvocations = Limits.getEmailInvocations();
      System.assertEquals(0,beforeInvocations,'no email sent');

      Test.stopTest();
}
}