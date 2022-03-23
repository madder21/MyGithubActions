/*
 * Created by israel on 6/20/2019.
 */
public class CLT_Utils_TaskTrigger {

    public static void updateLastContactDate(List<Task> newTask) {
        Map<String,Account> accountToUpdate = new Map<String,Account>();
    
        for (Task task : newTask) {
            if (task.Outreach_Type__c != null && task.Outreach_Type__c != 'Wishlist' && task.AccountId != null) {
                Account account = new Account(id = task.AccountId);
                account.LastContactDate__pc = task.ActivityDate;
                if (!accountToUpdate.containsKey(account.Id)) {
                    accountToUpdate.put(account.Id, account);
                } 
                else if (accountToUpdate.containsKey(account.Id) && accountToUpdate.get(account.Id).LastContactDate__pc < account.LastContactDate__pc) {
                    Account acc = accountToUpdate.remove(account.Id);
                    accountToUpdate.put(account.Id, account);
                }
            }
        }
        update accountToUpdate.values();
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

}