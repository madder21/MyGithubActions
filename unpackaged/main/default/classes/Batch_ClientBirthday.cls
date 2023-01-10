global class Batch_ClientBirthday implements Database.Batchable<sObject>, Schedulable {

    String query;
    List<String> lcc; 
    Date dat3;
    Integer dat3Day;
    Integer dat3Month;

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

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Task> tasks = new List<Task>();
        for (Account acc : scope) {
            tasks.add(createTask(acc, dat3));
        }
        
        insert tasks;  
    }

    public Task createTask(Account acc, Date dat3){
        Task t = new Task();
        t.Subject = 'Birthday to wish'; //Subject
        t.OwnerId = (acc.ClientAdvisor__pc != null ? acc.ClientAdvisor__pc : acc.OwnerId); //Assigned To Main Client Advisor
        t.WhatId = acc.Id; //Related to the Client
        t.Description = 'Please wish this Client Happy Birthday'; //Description
        t.ActivityDate = dat3; //Due Date

        return t;
   }

    global void finish(Database.BatchableContext BC) {

    }

    global void execute(SchedulableContext sc) {
        Batch_ClientBirthday b = new Batch_ClientBirthday();
        Database.executeBatch(b);
    }
}