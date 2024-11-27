/**
 * @author (Balink)
 * @date February,12 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test methods from Batch_ClientBirthday :
 * testSetup : Creation of test user and store
 * TEST METHOD				        |	DESCRIPTION
 * testBatch_ClientBirthday       	|	Test of Batch Batch_ClientBirthday initialization and running
 * testSchedBatch_ClientBirthday    |	Test the implementation of the scheduler of Batch_ClientBirthday
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 1.0		|2024/05/13			|.Sarah A		|.						|.add of assert equals and comments
*/
@isTest
private class Batch_ClientBirthday_Test {
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);

		List<Account> clients = new List<Account>();
        Account client1 = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, false);
		client1.PersonBirthdate = Date.today().addDays(3).addYears(-25);
        client1.LightCurrentCluster__pc = 'One Timer';
		clients.add(client1);
		Account client2 = CLT_TestDateFactory.createTestClient('Test client 2', 'Test Last Name2', sa.Id, store.Id, false);
		client2.PersonBirthdate = Date.today().addDays(10).addYears(-25);
        client2.LightCurrentCluster__pc = 'One Timer';
		clients.add(client2);
		insert clients;
	}

    @isTest
    static void testBatch_ClientBirthday() {
        Test.startTest();
        Batch_ClientBirthday testBatch = new Batch_ClientBirthday();
        Database.executeBatch(testBatch);
        Test.stopTest();

        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        List<Task> testBirthdayTasks = [SELECT Id FROM Task WHERE OwnerId = :sa.Id AND ActivityDate = :Date.today().addDays(3) AND HQTask__c = TRUE AND TaskType__c = 'Birthday'];

        System.assertEquals(1, testBirthdayTasks.size(), 'Batch_ClientBirthday_Test:testBatch_ClientBirthday: birthday tasks list size is not 1');
    }

    @isTest
    static void testSchedBatch_ClientBirthday() {
        Test.startTest();
        Batch_ClientBirthday schedBatch = new Batch_ClientBirthday();
        String sch = '0 0 23 * * ?'; 
        Id jobId = System.schedule('Test Batch_ClientBirthday Sched', sch, schedBatch);
        CronTrigger cronTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(sch, cronTrig.CronExpression, 'Batch_ClientBirthday_Test:testSchedBatch_ClientBirthday: cron expression is not the same as the scheduled one');
        Test.stopTest();
    }
}