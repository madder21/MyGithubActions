/**
 * @author (Balink)
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is called from R-Client App at the endpoint /retail/activities and let the SA get and manage his activities
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 1.0		|2024/05/12			|.Sarah A	|.RCLIENT-1063	    |.add method getEvent to return specific event details
 * 1.1		|2024/07/19			|.Sarah A	|.RCLIENT-1157	    |.add delta param to retrieve only activities that got updated after the sent value
 * 1.2		|2025/01/02			|.Sarah A	|.RCLIENT-1618	    |.check the showInAgenda only for birthday tasks of needed segments
*/
public with sharing class CLT_Activities implements CLT_RetailInterface{
    
    public Object retrieveDelete(Map<String, String> params){
        string objName = params.get('objectName');
        
        sobject activity = new Event();
        if(objName == 'Task'){
            activity = new Task();
        }
        activity.Id = params.get('id');    
        
        delete activity; 
        return true;
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return upsertItems(body);
    }

    public Object retrieveGet(Map<String, String> params){
        String taskId = params.containsKey('taskId') ? params.get('taskId') : '';
        String eventId = params.containsKey('eventId') ? params.get('eventId') : '';

        String firstDayOfLastYear = Date.today().addYears(-1).year() + '-01-01';
        String lastDayOfNextYear = Date.today().addYears(1).year() + '-12-31';

        if(!String.isEmpty(taskId)) {
            return getTask(taskId);
        }
        else if(!String.isEmpty(eventId)) {
            return getEvent(eventId);
        }
        else if(params.containsKey('deltaFrom')) {
            String deltaFrom = params.get('deltaFrom');//received format need to be YYYY-MM-DDTHH:MM:SSZ

            Map<String, Object> deltaResponse = new Map<String, Object>();

            List<Map<String, Object>> deltaActivities = new List<Map<String, Object>>();
            deltaActivities.addAll(getTasks(firstDayOfLastYear, lastDayOfNextYear, deltaFrom));
            deltaActivities.addAll(getEvents(firstDayOfLastYear, lastDayOfNextYear, deltaFrom));

            deltaResponse.put('updatedActivities', deltaActivities);

            return deltaResponse;
        }
        else {
            List<Map<String, Object>> activities = new List<Map<String, Object>>();
            activities.addAll(getTasks(firstDayOfLastYear, lastDayOfNextYear, null));
            activities.addAll(getEvents(firstDayOfLastYear, lastDayOfNextYear, null));
        
            return activities;
        }
    }

    /*
     * @METHOD 	: getTasks
     * @DESC 	: Return the wrapped list of tasks related to the connected user that should be displayed in R-Client
     * @PARAM 	: no params
     * @RETURN 	: List<Map<String, Object>> : wrapped list of tasks
     */
    public List<Map<String, Object>> getTasks(String firstDayOfLastYear, String lastDayOfNextYear, String deltaFrom){
        String taskQuery = 'FROM Task WHERE OwnerId = \'' + UserInfo.getUserId() + '\' AND Outreach_Type__c = NULL' + 
                            ' AND Status__c != \'Cancelled\' AND (CompletedDateTime = NULL OR CompletedDateTime = LAST_N_DAYS:3)' +
                            ' AND ((Status != \'Completed\' AND Status__c != \'Completed\') OR (Status = \'Completed\' AND Status__c = \'Completed\'))' +
                            ' AND (TaskType__c != \'Birthday\' OR (TaskType__c = \'Birthday\' AND (ActivityDate = NEXT_N_DAYS:3 OR ActivityDate  = TODAY)))'  +
                            ' AND ActivityDate >= ' + firstDayOfLastYear + ' AND ActivityDate <= ' + lastDayOfNextYear;
        if(!String.isEmpty(deltaFrom)) {
            taskQuery += ' AND LastModifiedDate >= ' + deltaFrom;
        }
        
        return CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task', taskQuery);   
        
        /*EBU - Interference ICU & Dev Balink in UAT
        List<String> birthdayTasksInAgendaForSegments = RClientConfigurations__c.getOrgDefaults().BirthdayTasksInAgendaForSegments__c.split(',');
        List<Map<String, Object>> wrappedTasks = CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task', taskQuery);
        for(Map<String, Object> wrappedTask : wrappedTasks) {
            if(wrappedTask.containsKey('taskType') && wrappedTask.containsKey('clientSegment') && 
                (String)wrappedTask.get('taskType') == 'Birthday' && birthdayTasksInAgendaForSegments.contains((String)wrappedTask.get('clientSegment'))) {
                wrappedTask.put('showOnAgenda', true);
            }
            else {
                wrappedTask.put('showOnAgenda', false);
            }
        }
        return wrappedTasks;*/
    }
    
    /*
     * @METHOD 	: getEvents
     * @DESC 	: Return the wrapped list of events related to the connected user that should be displayed in R-Client
     * @PARAM 	: firstDayOfLastYear: date string of the first day of the last year, lastDayOfNextYear: date string of the last day of the next year, deltaFrom: String date of the last update
     * @RETURN 	: List<Map<String, Object>> : wrapped list of events
     */
    public List<Map<String, Object>> getEvents(String firstDayOfLastYear, String lastDayOfNextYear, String deltaFrom){
        Map<String, Map<String, Object>> clientCegidIdsMap = new Map<String, Map<String, Object>>();
        Integer sixMonthAgoInterval = (Date.today().addMonths(-6)).daysBetween(Date.today());
        String eventQuery = 'FROM Event WHERE OwnerId = \'' + UserInfo.getUserId() + '\'' +
                            ' AND (Status__c != \'Cancelled\' OR (Status__c = \'Cancelled\' AND CancelledDateTime__c = LAST_N_DAYS:' + sixMonthAgoInterval + '))'  +
                            ' AND ActivityDate >= ' + firstDayOfLastYear + ' AND ActivityDate <= ' + lastDayOfNextYear;
        if(!String.isEmpty(deltaFrom)) {
            eventQuery += ' AND LastModifiedDate >= ' + deltaFrom;
        }
        List<Map<String, Object>> events = CLT_Utils_Mapping.getStandardWrapperList('Event', 'Event', eventQuery);
        for(Map<String, Object> eventMap : events) {
            if(eventMap.containsKey('clientSFId') && (!String.isEmpty((String)eventMap.get('clientSFId')))) {
                clientCegidIdsMap.put((String)eventMap.get('clientSFId'), new Map<String, Object>());
            }
        }

        // retrieve the oldest CEGID Id related to the client in ClientSource__c object
        if(clientCegidIdsMap.keySet().size() > 0) {
            clientCegidIdsMap = getClientCegidIdsMap(clientCegidIdsMap);

            for(Map<String, Object> eventMap : events) {
                if(eventMap.containsKey('clientSFId') && clientCegidIdsMap.containsKey((String)eventMap.get('clientSFId')) && (clientCegidIdsMap.get((String)eventMap.get('clientSFId'))).containsKey('cegidId')) {
                    eventMap.put('clientCegidId', (clientCegidIdsMap.get((String)eventMap.get('clientSFId'))).get('cegidId'));
                }
            }
        }
        return events;
    }

    /*
     * @METHOD 	: getClientCegidIdsMap
     * @DESC 	: Return a map with the first created cegid id for the list of clients
     * @PARAM 	: clientCegidIdsMap: clients key set for whom we need to find the cegid ids
     * @RETURN 	: Map<String, Map<String, Object>> : map of client id as key and the valueis a map of ceid id and the source creation datetime
     */
    public static Map<String, Map<String, Object>> getClientCegidIdsMap(Map<String, Map<String, Object>> clientCegidIdsMap) {
        for(ClientSource__c clientSource: [SELECT Id,SourceCode__c,SourceCreationDate__c,Client__c
                                            FROM ClientSource__c 
                                            WHERE Source__c = '001' AND Client__c IN :clientCegidIdsMap.keySet()
                                            ORDER BY SourceCreationDate__c ASC]) {
                                                
            if(!clientCegidIdsMap.get(clientSource.Client__c).containsKey('cegidId') || 
                (clientCegidIdsMap.get(clientSource.Client__c).containsKey('cegidId') && 
                clientSource.SourceCreationDate__c < (Datetime)(clientCegidIdsMap.get(clientSource.Client__c).get('cegidCreationDate')))) {
                (clientCegidIdsMap.get(clientSource.Client__c)).put('cegidId', clientSource.SourceCode__c);
                (clientCegidIdsMap.get(clientSource.Client__c)).put('cegidCreationDate', clientSource.SourceCreationDate__c);
            }
        }

        return clientCegidIdsMap;
    }

    /*
     * @METHOD 	: getTask
     * @DESC 	: Return the Task of the receiven id wrapped
     * @PARAM 	: taskId : Id of the task
     * @RETURN 	: List<Map<String, Object>> : wrapped Task fields
     */
    public list<map<string, object>> getTask(String taskId){
        List<Map<String, Object>> returningTask = CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task', 'FROM Task WHERE Id = \'' + taskId + '\'');
        
        Map<String, Object> tasksAttachments = getTasksAttachments(taskId);
        if(tasksAttachments != null){
            returningTask.add(tasksAttachments);
        }
        
        return returningTask;
    }

    /*
     * @METHOD 	: getEvent
     * @DESC 	: Return the Event of the receiven id wrapped
     * @PARAM 	: eventId : Id of the event
     * @RETURN 	: List<Map<String, Object>> : wrapped Event fields
     */
    public List<Map<String, Object>> getEvent(String eventId) {
        Map<String, Map<String, Object>> clientCegidIdsMap = new Map<String, Map<String, Object>>();
        List<Map<String, Object>> event = CLT_Utils_Mapping.getStandardWrapperList('Event', 'Event', 'FROM Event WHERE Id = \'' + eventId + '\'');
        //filtered according to Id, there will always be only one record
        Map<String, Object> eventMap = event[0];
        if(eventMap.containsKey('clientSFId') && (!String.isEmpty((String)eventMap.get('clientSFId')))) {
            clientCegidIdsMap.put((String)eventMap.get('clientSFId'), new Map<String, Object>());
        }
        // retrieve the oldest CEGID Id related to the client in ClientSource__c object
        if(clientCegidIdsMap.keySet().size() > 0) {
            clientCegidIdsMap = getClientCegidIdsMap(clientCegidIdsMap);

            if(eventMap.containsKey('clientSFId') && clientCegidIdsMap.containsKey((String)eventMap.get('clientSFId')) && (clientCegidIdsMap.get((String)eventMap.get('clientSFId'))).containsKey('cegidId')) {
                eventMap.put('clientCegidId', (clientCegidIdsMap.get((String)eventMap.get('clientSFId'))).get('cegidId'));
            }
        }

        //R-Client structure expects a list
        return new List<Map<String, Object>> {eventMap};
    }

    public List<Object> upsertItems(Map<String,Object> body) {
        String objectName = (String) body.get('objectName');
        List<Object> items = (List<Object>) body.get('items');
        Set<String> itemIds = new Set<String>();
        Store__c myStore = CLT_Utils.getMyStore(); 
        String userStoreId = myStore == null ? '' : myStore.Id;
        Boolean isMultipleCATask = body.get('isMultipleCATask') != null ? (Boolean)body.get('isMultipleCATask') : false;
        Boolean isMultipleClientsTask = body.get('isMultipleClientsTask') != null ? (Boolean)body.get('isMultipleClientsTask') : false;
  
        List<sObject> objects;
        if(objectName == 'Task') {
            if(isMultipleCATask) {
                List<String> caIds = body.get('caIds') != null ? ((String)body.get('caIds')).split(';') : new String[]{ UserInfo.getUserId() };
                objects = upsertMultipleCATasks(items, caIds, userStoreId);
            }
            else if(isMultipleClientsTask) {
                List<String> clientsIds = body.get('clientsIds') != null ? ((String)body.get('clientsIds')).split(';') : new List<String>();
                objects = upsertMultipleClientsTasks(items, clientsIds, userStoreId);
            }
            else {
                objects = upsertTasks(items, userStoreId);
            }            

        }
        else if(objectName == 'Event') {
            objects = upsertEvents(items, userStoreId);

        }

        for(sObject item: objects) {
            itemIds.add(item.Id);
        }

        if(itemIds.size() > 0) {
            List<Map<String, Object>> returningMap =  CLT_Utils_Mapping.getStandardWrapperList(objectName, objectName,
                'FROM ' + objectName + ' WHERE Id IN ' + CLT_Utils.convertToString(itemIds) + ' ORDER BY ActivityDate, CreatedDate DESC');

            if(objectName == 'Task' && !isMultipleCATask) {
                Map<String, Object> tasksAttachments = getTasksAttachments((new List<String>(itemIds))[0]);
                if(tasksAttachments != null){
                    returningMap.add(tasksAttachments);
                }
            }

            return returningMap;
        }
        return null;
    }

    public static List<Task> upsertTasks(List<Object> items, String userStoreId) {
        List<Map<String, Object>> mapTasks = CLT_Utils_Mapping.getMapObjectsByWrapperItems('Task', 'Task', items);
        List<Task> tasks = (List<Task>) JSON.deserialize(JSON.serialize(mapTasks), List<Task>.class);
        for (Task item : tasks) {

            if(String.isNotEmpty(userStoreId)){
                item.Store__c = userStoreId;
            }

            if (item.ActivityDate == null) {
                item.ActivityDate = null;
            }
            if (item.OwnerId == null) {
                item.OwnerId = UserInfo.getUserId();
            }
        }

        upsert tasks;

        Map<String, Object> ItemMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(items[0]));
        
        if(ItemMap.containsKey('taskAttachments')) {
            List<Object> taskAttachments = (List<Object>) JSON.deserializeUntyped(JSON.serialize(ItemMap.get('taskAttachments')));
            manageTaskAttachments(taskAttachments, tasks[0]);
        }

        return tasks;  
    }

    public static List<Task> upsertMultipleClientsTasks(List<Object> items, List<String> clientsIds, String userStoreId) {
        List<Map<String, Object>> mapTasks = CLT_Utils_Mapping.getMapObjectsByWrapperItems('Task', 'Task', items);
        List<Task> tasksToUpsert = new List<Task>();
        for(String clientId : clientsIds) {
            List<Task> tasks = (List<Task>) JSON.deserialize(JSON.serialize(mapTasks), List<Task>.class);
            for(Task task : tasks) {
                if(String.isNotEmpty(userStoreId)){
                    task.Store__c = userStoreId;
                }
                
                if (task.ActivityDate == null) {
                    task.ActivityDate = null;
                }
                
                task.WhatId = clientId;
                tasksToUpsert.add(task);
            }
        }
        upsert tasksToUpsert; 
        return tasksToUpsert; 
    }

    public static List<Task> upsertMultipleCATasks(List<Object> items, List<String> caIds, String userStoreId) {
        List<Map<String, Object>> mapTasks = CLT_Utils_Mapping.getMapObjectsByWrapperItems('Task', 'Task', items);
        List<Task> tasksToUpsert = new List<Task>();
        for(String caId : caIds) {
            List<Task> tasks = (List<Task>) JSON.deserialize(JSON.serialize(mapTasks), List<Task>.class);
            for(Task task : tasks) {
                if(String.isNotEmpty(userStoreId)){
                    task.Store__c = userStoreId;
                }
                
                if (task.ActivityDate == null) {
                    task.ActivityDate = null;
                }
                
                task.OwnerId = caId;
                tasksToUpsert.add(task);
            }
        }
        upsert tasksToUpsert; 
        return tasksToUpsert;  
    }

    public static List<Event> upsertEvents(List<Object> items, String userStoreId) {
        List<Map<String, Object>> mapEvents = CLT_Utils_Mapping.getMapObjectsByWrapperItems('Event', 'Event', items);
        List<Event> events = (List<Event>) JSON.deserialize(JSON.serialize(mapEvents), List<Event>.class);

        for (Event item : events) {

            if(String.isNotEmpty(userStoreId)){
                item.Store__c = userStoreId;
            }
            
            if (item.OwnerId == null) {
                item.OwnerId = UserInfo.getUserId();
            }
        }

        upsert events;
        return events;
    }    

    public static void manageTaskAttachments(List<Object> taskAttachments, Task task) {
        deleteAttachmentFromTask(task.Id);

        if(taskAttachments != null && taskAttachments.size() > 0) {
            addAttachmentToTask(taskAttachments, task);
        }
    }

    public static void deleteAttachmentFromTask(String taskId) {
        List<ContentDocumentLink> attachmentsToDelete = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId=:taskId AND ShareType ='V'];

        if(attachmentsToDelete.size() > 0) {
            delete attachmentsToDelete;
        }
    }

    public static void addAttachmentToTask(List<Object> taskAttachments, Task task) {
        List<Attachment> attachments = new List<Attachment>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        Integer i = 1;
        for(Object taskAtt : taskAttachments) {
            String AttachmentStr = String.valueOf(taskAtt);

            if(!String.isEmpty(AttachmentStr)) {
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                conVer.PathOnClient = 'att_' + i + '.png'; // The files name
                conVer.Title = 'Attachment ' + i; // Display name of the files
                conVer.VersionData = EncodingUtil.base64Decode(AttachmentStr); // converting your binary string to Blob

                contentVersions.add(conVer);
                i++;
            }
        }

        insert contentVersions;

        contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersions];

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(Integer index = 0; index < contentVersions.size(); index++){
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = contentVersions[index].ContentDocumentId;
            cDe.LinkedEntityId = task.Id;
            cDe.ShareType = 'V'; 

            contentDocumentLinks.add(cDe);
        }

        insert contentDocumentLinks;
    }

    public static Map<String, Object> getTasksAttachments(String taskId) {
        List<String> contentDocIds = new List<String>();
        List<String> taskAttachment = new List<String>();

        for(ContentDocumentLink cdl : [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:taskId]) {
            contentDocIds.add(cdl.ContentDocumentId);
        }
        
        if(contentDocIds.isEmpty()) {
            return null;
        }

        for(ContentVersion cv : [SELECT IsLatest,versionData,ContentDocumentId FROM ContentVersion WHERE IsLatest=true AND ContentDocumentId IN:contentDocIds]) {
            taskAttachment.add(EncodingUtil.base64Encode(cv.versionData));
        }

        return new Map<String, Object> {'tasksAttachments' => taskAttachment};
    }

}