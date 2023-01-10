@isTest
public with sharing class DataMigrationScheduleTest {

    @isTest
    public static void jobScheduleTest() {        
        test.starttest();
        DataMigrationSchedule myClass = new DataMigrationSchedule ();   
        String chron = '0 0 11 * * ?';        
        String cronID = system.schedule('Test Sched', chron, myClass);
        CronTrigger job = [SELECT Id, CronJobDetail.Name, PreviousFireTime,StartTime, CreatedDate 
                          FROM CronTrigger 
                          WHERE Id=:cronID];
        
        test.stopTest();
        System.assertEquals(job.CronJobDetail.Name, 'Test Sched');
        System.assertEquals(job.PreviousFireTime, null);
    }

}