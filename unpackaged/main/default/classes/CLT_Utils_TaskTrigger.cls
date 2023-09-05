/*
 * Created by israel on 6/20/2019.
 */
public class CLT_Utils_TaskTrigger {

    public static void updateLastContactDate(List<Task> newTask) {  
        Map<String, Date> clientContactedDateMap = new Map<String, Date>();  
        for (Task task : newTask) {
            Boolean accToUpdateFlag = false;
            if (task.Outreach_Type__c != null && task.AccountId != null && task.Outreach_Type__c != 'Wishlist' 
                && task.Outreach_Type__c != 'Event' && task.Outreach_Type__c != 'Gift') {
                Account account = new Account(id = task.AccountId);
                if(task.ActivityDate != null && (!clientContactedDateMap.containsKey(task.AccountId) || (clientContactedDateMap.containsKey(task.AccountId) && clientContactedDateMap.get(task.AccountId) < task.ActivityDate))) {
                    clientContactedDateMap.put(task.AccountId, task.ActivityDate);
                }
            }
        }

        List<Account> clientsToUpdate = new List<Account>();
        if(clientContactedDateMap.size() > 0) {
            for(Account client : [SELECT Id,LastContactDate__pc FROM Account WHERE Id IN :clientContactedDateMap.keySet()]) {
                if(client.LastContactDate__pc == null || (client.LastContactDate__pc != null && clientContactedDateMap.get(client.Id) > client.LastContactDate__pc)) {
                    client.LastContactDate__pc = clientContactedDateMap.get(client.Id);
                    clientsToUpdate.add(client);
                }
            }
        }

        if(clientsToUpdate.size() > 0) {
            update clientsToUpdate;
        }
    }
    
    public static void updateRelatedProductDetails(List<Task> newTasks) {
        List<Task> tasksWithProducts = new List<Task>();
        Map<String,String> productDetailsMap = new Map<String, String>();
        List<String> productIds = new List<String>();

        for(Task t : newTasks) {
            if(!String.isEmpty(t.Related_Products__c)) {
                List<String> taskProducts = new List<String>(t.Related_Products__c.split(';'));
                productIds.addAll(taskProducts);
                tasksWithProducts.add(t);
            }
        }

        for(Catalog_Product__c p : [SELECT Id,Name,Product_SKU__c FROM Catalog_Product__c WHERE Id IN :productIds]) {
            productDetailsMap.put(p.Id, p.Product_SKU__c + ' - ' + p.Name);
        }  
        
        for(Task t : tasksWithProducts) {
            String productDetail = '';
            Integer productNum = 0;
            for(String pId : new List<String>(t.Related_Products__c.split(';'))) {
                if(productDetailsMap.containsKey(pId)) {
                    productDetail += productDetailsMap.get(pId) + ';';
                    productNum ++;
                }
            }
            t.Related_Products_Details__c = productDetail;
            t.Related_Products_Num__c = productNum;
        }
    }

    public static void updateENOutreachReason(List<Task> newTasks, Map<Id, Task> oldTasksMap) {
        Map<String, List<String>> reasonsMap = getReasonsMap();

        for(Task newTask : newTasks) {
            if((newTask.Outreach_Type__c == 'Gift' || newTask.Outreach_Type__c == 'Event') &&
                String.isEmpty(newTask.EN_Outreach_Reason__c) && !String.isEmpty(newTask.Outreach_Reason__c)) {
                newTask.EN_Outreach_Reason__c = newTask.Outreach_Reason__c;
            }
            if((newTask.Outreach_Type__c != 'Gift' && newTask.Outreach_Type__c != 'Event') && 
                !String.isEmpty(newTask.Outreach_Reason__c) && 
                (!oldTasksMap.containsKey(newTask.Id) || (oldTasksMap.containsKey(newTask.Id) && 
                newTask.Outreach_Reason__c != oldTasksMap.get(newTask.Id).Outreach_Reason__c))) {
                newTask.EN_Outreach_Reason__c = getENReasonFromMap(reasonsMap, newTask.Outreach_Reason__c);
            }
        }
    }

    public static Map<String, List<String>> getReasonsMap() {
        String reasonsQuery = 'SELECT ';
       
        Set<String> categoryMdtFields = Schema.SObjectType.CLT_EmailTemplateCategory__mdt.fields.getMap().keySet();
        for(String categoryMdtField : categoryMdtFields) {
            if(!categoryMdtField.endsWith('_category__c')){
                categoryMdtFields.remove(categoryMdtField);
            }
        }
        reasonsQuery += String.join((Iterable<String>)categoryMdtFields, ',') + ' FROM CLT_EmailTemplateCategory__mdt';

        Map<String, List<String>> reasonsMap = new Map<String, List<String>>();
        for(CLT_EmailTemplateCategory__mdt etc : Database.query(reasonsQuery)) {
            reasonsMap.put(etc.en_US_category__c,new List<String>());
            for(String categoryMdtField : categoryMdtFields) {
                if(!String.isEmpty((String)etc.get(categoryMdtField))) {
                    reasonsMap.get(etc.en_US_category__c).add((String)etc.get(categoryMdtField));
                }
            }
        }

        return reasonsMap;
    }

    public static String getENReasonFromMap(Map<String, List<String>> reasonsMap, String translatedReason) {
        for (String enReason : reasonsMap.keySet()) {
            if(reasonsMap.get(enReason).contains(translatedReason)) {
                return enReason;
            }
        }
        return '';
    }

    public static void updateRelatedClientListMembersStatus(List<Task> newTasks) {
        Map<String, List<String>> clientClientListsMap = new Map<String, List<String>>();
        List<String> clientListIds = new List<String>();
        for(Task task : newTasks) {
            if(!String.isEmpty(task.ClientList__c) && !String.isEmpty(task.AccountId)) {
                if(!clientClientListsMap.containsKey(task.AccountId)) {
                    clientClientListsMap.put(task.AccountId, new List<String>());
                }
                clientClientListsMap.get(task.AccountId).add(task.ClientList__c);
                clientListIds.add(task.ClientList__c);
            }
        }
        if(clientClientListsMap.size() > 0) {
            List<ClientListMember__c> clmToUpdate = new List<ClientListMember__c>();
            for(ClientListMember__c clm : [SELECT Client__c, ClientList__c, Status__c
                                        FROM ClientListMember__c
                                        WHERE Client__c IN :clientClientListsMap.keySet() AND ClientList__c IN :clientListIds]) {
                if(clientClientListsMap.get(clm.Client__c).contains(clm.ClientList__c)) {
                    clm.Status__c = 'Contacted';
                    clmToUpdate.add(clm);
                }
            }
            if(clmToUpdate.size() > 0) {
                update clmToUpdate;
            }
        }
    }
}