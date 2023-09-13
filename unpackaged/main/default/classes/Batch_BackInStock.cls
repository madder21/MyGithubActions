/*
----------------------------------------------------------------------
-- - Name              :  Batch_BackInStock
-- - Author            :  Abdelaaziz Idaoumahmoud
-- - Description       :  Batch for BackInStock process SFCC
-- Maintenance History :    
--
-- Date                 Name                        Version          Remarks
-- -----------          -----------                 --------         ----------------------
-- 30-05-2022           Abdelaaziz Idaoumahmoud    	1.0              Initial version
-- 22-12-2022           Mohamed Abdelfadel         	2.0              Remove every hard coding, replaced by Custom Setting record fields and usage of a backInStockBatchHelper
---------------------------------------------------------------------------------------
*/
global class Batch_BackInStock implements Database.Batchable<sObject>,  Database.AllowsCallouts, Schedulable, Database.Stateful {

    private Map<String, BackInStockWrapper> productInventories;
    private Set<String> skuWarehouseToSendToSFMC;
    private Set<String> setSkuToGetConsent;
    private Set<String> setWarehouseToGetConsent;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        skuWarehouseToSendToSFMC = new Set<String>();
        setSkuToGetConsent = new Set<String>();
        setWarehouseToGetConsent = new Set<String>();
        productInventories = new Map<String, BackInStockWrapper>();
        for(Product_Inventory__c productInventory : [SELECT sku__c, Warehouse__c, ATS__c 
                                                        FROM Product_Inventory__c 
                                                        WHERE ATS__c > 0 order by sku__c]){

            BackInStockWrapper productLine = new BackInStockWrapper();
            productLine.sku = productInventory.sku__c;
            productLine.warehouse = productInventory.warehouse__c;
            productLine.ats = Integer.valueOf(productInventory.ATS__c);
            productInventories.put(productInventory.sku__c + '|;|' + productInventory.warehouse__c, productLine);
            //fill two new created sets
            //Add Sku to set
            setSkuToGetConsent.add(productInventory.sku__c);
            setWarehouseToGetConsent.add(productInventory.warehouse__c);
        }
       
        return Database.getQueryLocator([
            SELECT sku__c, Warehouse__c
            FROM CommSubscriptionConsent  
            WHERE Name = 'BackInStock' AND EffectiveToDate = null AND sku__c IN: setSkuToGetConsent AND Warehouse__c IN:setWarehouseToGetConsent order by sku__c]);
            
    }

    global void execute(Database.BatchableContext BC, List<CommSubscriptionConsent> scope) {
        for(CommSubscriptionConsent commSubscriptionConsent : scope){
            if(!skuWarehouseToSendToSFMC.contains(commSubscriptionConsent.sku__c +'|;|'+ commSubscriptionConsent.warehouse__c)){
                System.debug('---- sku-Warehouse added : '+commSubscriptionConsent.sku__c +'|;|'+ commSubscriptionConsent.warehouse__c);
                skuWarehouseToSendToSFMC.add(commSubscriptionConsent.sku__c +'|;|'+ commSubscriptionConsent.warehouse__c);
            }
        }
         
    }

    global void finish(Database.BatchableContext BC) {
        if(!skuWarehouseToSendToSFMC.isEmpty()){
            String oAUTHAccessToken = BackInStockBatchHelper.getSFMCAccessToken();
            if(oAUTHAccessToken != null && oAUTHAccessToken != 'Error'){
                Long lastSentEventId = BackInStockBatchHelper.postBackInStockEvent(
                    productInventories, 
                    skuWarehouseToSendToSFMC ,  
                    oAUTHAccessToken
                );
                if(lastSentEventId != null){
                    String backInStockAutomationObjectId = BackInStockBatchHelper.triggerSFMCBackInStockAutomation(oAUTHAccessToken);
                    SFMCAPISetting__c sfmcAPISetting = SFMCAPISetting__c.getOrgDefaults();
                    sfmcAPISetting.BackInStockAutomationObjectId__c = backInStockAutomationObjectId;
                    sfmcAPISetting.LastSentEventId__c = lastSentEventId;
                    update sfmcAPISetting;
                }
            }
        }
    }

    global void execute(SchedulableContext sc) {
        String backInStockAutomationStatus;
        SFMCAPISetting__c sfmcAPISetting = SFMCAPISetting__c.getOrgDefaults();
        if(! String.isBlank(sfmcAPISetting.BackInStockAutomationObjectId__c)){
            String oAUTHAccessToken = BackInStockBatchHelper.getSFMCAccessToken();
            if(oAUTHAccessToken != null && oAUTHAccessToken != 'Error') 
                backInStockAutomationStatus = BackInStockBatchHelper.getSFMCBackInStockAutomationStatus(
                    oAUTHAccessToken, 
                    sfmcAPISetting
                );
        }
        if(
            String.isBlank(sfmcAPISetting.BackInStockAutomationObjectId__c)
            || (!String.isBlank(backInStockAutomationStatus) && backInStockAutomationStatus != 'Executing')
        ){
            Database.executeBatch(new Batch_BackInStock(), 2000);
        }
    }
    
}