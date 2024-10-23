/**************************************************************************************

-- - Author        : Fatima-Ezzahra LAFTOUMI

-- - Description   : A Controller for the LWC som_ExchangeOrderCreation_Component to get Order Summary, Order Delievry Method and Order Delievry Group Data

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 05-08-2022    FEL    1.0          Initial version

***************************************************************************************/
public with sharing class SOM_LWC_ExchangeOrderController {
    @AuraEnabled(cacheable=true)
    public static OrderSummary getOSDetails(String OsId){
        return [SELECT Id,(SELECT OrderDeliveryMethodId, OrderDeliveryMethod.Name FROM OrderDeliveryGroupSummaries), OriginalOrderId, BillingStreet, BillingPostalCode, BillingCity, BillingCountry,Complementary__c,RI_Neighborhood__c,StreetNumber__c, BillingEmailAddress, BillingPhoneNumber, BillingContactFirstName__c, BillingContactLastName__c,BillingState, AccountId, Pricebook2Id FROM OrderSummary WHERE Id =: OsId];
    }

    @AuraEnabled(cacheable=true)
    public static OrderDeliveryGroupSummary getOrderDelievryGroupDetails(String OsId){
        return [SELECT Description, EmailAddress, PhoneNumber, DeliverToName, DeliverToStreet, DeliverToPostalCode, DeliverToCity, DeliverToCountry,Complementary__c,RI_Neighborhood__c,StreetNumber__c,DeliverToState FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: OsId];
    }

    @AuraEnabled(cacheable=true)
    public static List<OrderDeliveryMethod> getOrderDelievryMethods(String country){
        if (country.equalsIgnoreCase('UK')) country='GB';
        return [SELECT Id, Name FROM OrderDeliveryMethod WHERE Country__c =: country and isHomeDelivery__c = true];
    }

    @AuraEnabled(cacheable=true)
    public static OrderDeliveryMethod getOrderDelievryMethodName(String mId){
        return [SELECT Id, Name FROM OrderDeliveryMethod WHERE Id =: mId];
    }
}