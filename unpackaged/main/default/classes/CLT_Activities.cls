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
        String taskId = params.get('taskId');

        if(!String.isEmpty(taskId)) {
            return getTask(taskId);
        }
        else {
            list<map<string, object>> activities = new list<map<string, object>>();
            activities.addAll(getTasks());
            activities.addAll(getEvents());
        
            return activities;
        }
    }

    public list<map<string, object>> getTasks(){
        return CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task', 'FROM Task WHERE OwnerId = \'' + UserInfo.getUserId() + '\' AND Outreach_Type__c = NULL AND Status__c != \'Canceled\'');
        
    }
    
    public list<map<string, object>> getEvents(){
        return CLT_Utils_Mapping.getStandardWrapperList('Event', 'Event', 'FROM Event WHERE OwnerId = \'' + UserInfo.getUserId() + '\' AND Status__c != \'Canceled\'');
    }

    public list<map<string, object>> getTask(String taskId){
        List<Map<String, Object>> returningTask = CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task', 'FROM Task WHERE Id = \'' + taskId + '\'');
        
        Map<String, Object> tasksAttachments = getTasksAttachments(taskId);
        if(tasksAttachments != null){
            returningTask.add(tasksAttachments);
        }
        
        return returningTask;
    }

    public List<Object> upsertItems(Map<String,Object> body) {
        String objectName = (String) body.get('objectName');
        List<Object> items = (List<Object>) body.get('items');
        Set<String> itemIds = new Set<String>();
        Store__c myStore = CLT_Utils.getMyStore(); 
        String userStoreId = myStore == null ? '' : myStore.Id;
        Boolean isMultipleCATask = body.get('isMultipleCATask') != null ? (Boolean)body.get('isMultipleCATask') : false;
  
        List<sObject> objects;
        if(objectName == 'Task') {
            if(isMultipleCATask) {
                List<String> caIds = body.get('caIds') != null ? ((String)body.get('caIds')).split(';') : new String[]{ UserInfo.getUserId() };
                objects = upsertMultipleCATasks(items, caIds, userStoreId);
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