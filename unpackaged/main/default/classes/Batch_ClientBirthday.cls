/**
 * @author (Balink)
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is an Apex Batch (+ it's scheduler) to be run every day and create tasks for CA for his clients having their birthday in 3 days
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 1.0		|2024/05/13			|.Sarah A	|.				    |.add of HQ Task field set to true and Task Type = Birthday						
*/
global class Batch_ClientBirthday implements Database.Batchable<sObject>, Schedulable {

    String query;
    List<String> lcc; 
    Date dat3;
    Integer dat3Day;
    Integer dat3Month;

    /*
     * @METHOD 	: Batch_ClientBirthday
     * @DESC 	: Constractor to define for which clients it is required to create birthday tasks
     * @PARAM 	: none
     * @RETURN 	: build the new Batch with the correct query to run
     */
    public Batch_ClientBirthday() {
        lcc = new List<String> {'VIC', 'Multi-timer', 'One Timer', 'Collab', 'Experimenter'};
        dat3 = date.today().adddays(3);
        dat3Day = dat3.day();
        dat3Month = dat3.month();

        query = 'SELECT Id, Name, PersonBirthdate, ClientAdvisor__pc, OwnerId ' +
                'FROM Account ' +
                'WHERE DAY_IN_MONTH(PersonBirthdate) =: dat3Day ' +
                'AND CALENDAR_MONTH(PersonBirthdate) =: dat3Month '+
                'AND LightCurrentCluster__pc in: lcc';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    /*
     * @METHOD 	: execute
     * @DESC 	: create the birthday task for 200 clients at a time
     * @PARAM 	: List<Account> list of 200 clients for whomm a birthday task needs to be created
     * @RETURN 	: none
     */
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Task> tasks = new List<Task>();
        for (Account acc : scope) {
            tasks.add(createTask(acc, dat3));
        }
        
        insert tasks;  
    }

    /*
     * @METHOD 	: createTask
     * @DESC 	: prepare a Task record for each client assigned to his Main Client Advisor
     * @PARAM 	: Account, the client for whom the task will be created; Date, the birthday date of the client
     * @RETURN 	: Task to insert
     */
    public Task createTask(Account acc, Date dat3){
        Task t = new Task();
        t.Subject = 'Birthday to wish'; //Subject
        t.OwnerId = (acc.ClientAdvisor__pc != null ? acc.ClientAdvisor__pc : acc.OwnerId); //Assigned To Main Client Advisor
        t.WhatId = acc.Id; //Related to the Client
        t.Description = 'Please wish this Client Happy Birthday'; //Description
        t.ActivityDate = dat3; //Due Date
        t.HQTask__c = true; //HQ Task
        t.TaskType__c = 'Birthday'; //Task Type
        t.IsPinned__c = true; //Is Pinned

        return t;
   }

    global void finish(Database.BatchableContext BC) {

    }

    //Apex scheduler
    global void execute(SchedulableContext sc) {
        Batch_ClientBirthday b = new Batch_ClientBirthday();
        Database.executeBatch(b);
    }
}