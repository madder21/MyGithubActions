public with sharing class SOM_DynamicTreeGridController {
    
    @AuraEnabled(cacheable=true)
    public static List<STWNurembergDeliveryMethod__c> getAllParentCases() {
        return [SELECT Id, storeOrigin__c, country__c, postalCode__c, parentId__c, deliveryMethodId__r.ReferenceNumber, DeliveryMethodName__c 
                FROM STWNurembergDeliveryMethod__c 
                WHERE parentId__c = NULL ];
    }
    
    @AuraEnabled
    public static List<STWNurembergDeliveryMethod__c> getChildCases(String parentId) {
        return [
            SELECT Id, storeOrigin__c, country__c, postalCode__c, parentId__c, deliveryMethodId__r.ReferenceNumber, DeliveryMethodName__c
            FROM STWNurembergDeliveryMethod__c
            WHERE parentId__c = :parentId
        ];
    }
    
    @AuraEnabled
    public static void delSTW(String recordIdToDelete) {
        List<Id> IdList = new List<Id>();
        List<STWNurembergDeliveryMethod__c> firstListToD = [SELECT Id, storeOrigin__c, country__c, postalCode__c, parentId__c
                                                            FROM STWNurembergDeliveryMethod__c
                                                            WHERE Id = :recordIdToDelete
                                                           ];
        List<STWNurembergDeliveryMethod__c> secondListToD = [SELECT Id, storeOrigin__c, country__c, postalCode__c, parentId__c
                                                             FROM STWNurembergDeliveryMethod__c
                                                             WHERE parentId__c = :firstListToD[0].Id
                                                            ];
        FOR(STWNurembergDeliveryMethod__c stw :secondListToD ){
            IdList.add(stw.id);
        }
        
        List<STWNurembergDeliveryMethod__c> thirdListToD = [SELECT Id, storeOrigin__c, country__c, postalCode__c, parentId__c
                                                            FROM STWNurembergDeliveryMethod__c
                                                            WHERE parentId__c IN :IdList
                                                           ];
        delete firstListToD;
        delete secondListToD;
        delete thirdListToD;
        
    }
    
    @AuraEnabled
    public static String getCreateRecordLevel(String recId) {
        String Level = 'L0';
        STWNurembergDeliveryMethod__c stw = [SELECT Id, storeOrigin__c, country__c, postalCode__c, parentId__c
                                             FROM STWNurembergDeliveryMethod__c
                                             WHERE Id = :recId
                                            ];
        if(stw.country__c!= '' && stw.country__c!= null){
            Level ='L2';
        }else if(stw.storeOrigin__c!= '' && stw.storeOrigin__c!= null){
            Level = 'L1';
        }
        return Level;
        
    }
    
    
    @AuraEnabled (cacheable=true)
    public static List<Wr_PicklistValue> getOrderDeliveryMethod(String stwList){
        
        System.debug('gridData'  + stwList);
        
        STWNurembergDeliveryMethod__c stw = [SELECT Id, storeOrigin__c, country__c, postalCode__c, parentId__c, deliveryMethodId__r.ReferenceNumber, DeliveryMethodName__c 
                                             FROM STWNurembergDeliveryMethod__c 
                                             WHERE Id =: stwList];
        
        
        List<Wr_PicklistValue> listPicklistValues = new List<Wr_PicklistValue>();
        list<String> CountryCode = new list<String>();
        
        List<OrderDeliveryMethod> listLocation = [SELECT Id, Name, ReferenceNumber 
                                                  FROM OrderDeliveryMethod where Country__c  =: stw.country__c
                                                 ];
        if(listLocation?.isEmpty()){
            return listPicklistValues;
        }
        
        
        for(OrderDeliveryMethod location : listLocation){
            
            listPicklistValues.add(
                new Wr_PicklistValue(location.Name,
                                     location.Id)
            );
        }         
        
        return listPicklistValues;
    }
    
    
    public class Wr_PicklistValue{
        
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public Wr_PicklistValue(String labelVal, String valueVal){
            this.label = labelVal;
            this.value = valueVal;
        }
        
    }
    
    @AuraEnabled
    public static Void createSTW(String recordToCreate) {
        STWNurembergDeliveryMethod__c STW_ToCreate = new STWNurembergDeliveryMethod__c();
        system.debug('acc'+recordToCreate);
        STWWrapper wrapper=(STWWrapper)JSON.deserialize(recordToCreate,STWWrapper.class);
        if(wrapper.recordID == null || wrapper.recordID ==''){
            STW_ToCreate.storeOrigin__c = wrapper.storeOrigin;
            
            
        }else {
            STWNurembergDeliveryMethod__c stw = [SELECT Id, storeOrigin__c, country__c, postalCode__c, parentId__c, deliveryMethodId__r.ReferenceNumber, DeliveryMethodName__c 
                                                 FROM STWNurembergDeliveryMethod__c 
                                                 WHERE Id =: wrapper.recordID];
            if(wrapper.country!= '' && wrapper.country!= null){
                STW_ToCreate.country__c = wrapper.country;
                STW_ToCreate.parentId__c = wrapper.recordID;
            }else if(wrapper.deliveryMethod!= '' && wrapper.deliveryMethod!= null){
                STW_ToCreate.deliveryMethodId__c = wrapper.deliveryMethod;
                STW_ToCreate.parentId__c = wrapper.recordID;
                STW_ToCreate.postalCode__c = wrapper.postalCode;
            }
        }
        system.debug('wrapper'+wrapper);
        system.debug('STW_ToCreate'+STW_ToCreate);
        system.debug('wrapper'+wrapper);
        
        insert STW_ToCreate;
    }
    
    
    public class STWWrapper{
        @auraenabled
        public string storeOrigin{get;set;}
        @auraenabled
        public string country{get;set;}
        @auraenabled
        public string postalCode{get;set;}
        @auraenabled
        public string recordID{get;set;}
        @auraenabled
        public string deliveryMethod{get;set;}
    }
        
}