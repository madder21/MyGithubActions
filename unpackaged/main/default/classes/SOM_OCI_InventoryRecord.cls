/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
public with sharing class SOM_OCI_InventoryRecord {
    
    @AuraEnabled // unique identifier for the inventory record
    public String recordId { get; set; }

    @AuraEnabled //Quantity On Hand
    public Integer onHand { get; set; }

    @AuraEnabled //Product SKU
    public String sku { get; set; }

    @AuraEnabled // Product Effective From Date
    public DateTime effectiveDate { get; set; }

    @AuraEnabled // Product safety Stock Count
    public Integer safetyStockCount { get; set; }

    @AuraEnabled
    public List<Wr_Future_Stock> futures { get; set; }

    /*@AuraEnabled // Product location Id
    public String locationId;*/

    public class Wr_Future_Stock{
        public DateTime expectedDate;
        public Decimal quantity;
    }
}