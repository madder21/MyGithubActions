/**************************************************************************************

-- - Author        : Fatima-Ezzahra LAFTOUMI

-- - Description   : A Wrapper class for Shipment and Shipment Item

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 18-08-2022    FEL    1.0          Initial version

***************************************************************************************/
public with sharing class SOM_Wr_ShipmentShipmentItems {
    
    /**
     * Attributes for Shipment Data
     */
    @InvocableVariable @AuraEnabled
    public String shipmentExternalId;
    @InvocableVariable @AuraEnabled
    public String trackingNumber;
    @InvocableVariable @AuraEnabled
    public Datetime dispatchDate;
    @InvocableVariable @AuraEnabled
    public String timezone;
    @InvocableVariable @AuraEnabled
    public String orderMethodId;
    @InvocableVariable @AuraEnabled
    public String foId;
    @InvocableVariable @AuraEnabled
    public Boolean S10Digits;

    /**
     * Attributes for Shipment Item Data
     */
    @InvocableVariable @AuraEnabled
    public Integer quantity;
    @InvocableVariable @AuraEnabled
    public String foliId;
    @InvocableVariable @AuraEnabled
    public String productId;
    @InvocableVariable @AuraEnabled
    public String osItemId;
    @InvocableVariable @AuraEnabled
    public String serialNumber;         // concatenated
    @InvocableVariable @AuraEnabled
    public String sku10Digits;
    @InvocableVariable @AuraEnabled
	public String CrossBorderId;

}