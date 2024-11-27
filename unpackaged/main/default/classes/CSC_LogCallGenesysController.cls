public class CSC_LogCallGenesysController {
    /**
    * get data task
    * @param
    * @return
    */
    @AuraEnabled
    public static List<Task> getTasks() {
        Id userId = userInfo.getUserId();
        Id taskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Genesys_Task').getRecordTypeId();
        
        List<Task> listTask = [SELECT id, Service_Name__c, CreatedDate, Status, OwnerId , Subject, Customer_Phone_Number__c, WhatId, RecordTypeId
                                FROM Task
                                WHERE OwnerId =: userId
                                AND RecordTypeId =: taskRecordType
                                AND WhatId = null
                                ORDER BY CreatedDate DESC
                                LIMIT 7 ];
        return listTask;
    }

    /**
    *
    * @param
    * @return
    */
    @AuraEnabled
    public static void updateTask(List<Task> tasks, String urlCase){
        List<Case> caseToLink = new List<Case>();
        String codeCase = urlCase.substringAfter('/Case/').substringBefore('/view');
        Id caseId;
        caseId = Id.valueOf(codeCase);
        caseToLink =[SELECT Id FROM Case WHERE id =: caseId ];
        
        //update task/case
        for(Task task : tasks){
            if(task.WhatId == null){
                task.WhatId =caseToLink[0].Id;
            }
        }
        update tasks[0];
    }
}