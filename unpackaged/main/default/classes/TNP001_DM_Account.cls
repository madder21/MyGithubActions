/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP001_DM_Account  
-- - Author             : Ilhem Zraiga
-- - Description        : Data Managment Account Object
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 01/04/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
public class TNP001_DM_Account {
    public Static Account getAccountById (Id AccountId){
          Account acc = [SELECT AccountNumber,AccountSource,AllChannelBlocked__pc,AnnualRevenue,Audit_OCAPI_API_Response__pc,B2C_Company_Name__pc,B2C_CustomerList_ID__pc,B2C_CustomerList__pc,B2C_Customer_ID__pc,B2C_Customer_No__pc,B2C_Date_Created__pc,B2C_Date_Last_Modified__pc,B2C_Date_Last_Visited__pc,B2C_Date_Previous_Visit__pc,
                         B2C_Disable_Integration__pc,B2C_Gender_ID__pc,B2C_Instance__pc,B2C_Integration_Status__pc,B2C_Is_Enabled__pc,
                         B2C_Is_Locked__pc,B2C_Job_Title__pc,B2C_Preferred_Locale__pc,B2C_Salutation__pc,B2C_Second_Name__pc,B2C_Site_ID__pc,
                         B2C_Suffix__pc,B2C_Title__pc,B2C_UserName__pc,BillingAddress,BillingCity,BillingCountry,BillingGeocodeAccuracy,
                         BillingLatitude,BillingLongitude,BillingPostalCode,BillingState,BillingStreet,Birthday__pc,Birthmonth__pc,Birthyear__pc,
                         Buyer__pc,ClientAdvisorFullName__pc,ClientAdvisorId__pc,ClientAdvisor__pc,ClientType__pc,Comments__pc,Compagny__pc,
                         ContactableByEmail__pc,ContactableByInstantMessaging__pc,ContactableByMailing__pc,ContactableByPhone__pc,Contactable__c,Contactable__pc,CountryIso2__pc,Country__pc,CreatedById,CreatedDate,CurrencyIsoCode,CurrentCluster__pc,Description,EmailValid__pc,
                         Email_Bounce__pc,EReceipt__pc,et4ae5__HasOptedOutOfMobile__pc,et4ae5__Mobile_Country_Code__pc,FAI__c,Fax,FirstName,
                         FirstPurchaseDate__pc,FirstSecondTransactionInterval__pc,FiscalIdentificationNumber__pc,FraudDetection__pc,
                         FullAccount__pc,Gender__pc,Gifter__pc,HardBounce__pc,Id,Industry,IsDeleted,IsPersonAccount,Is_in_My_Clients__c,
                         Itelios_External_Id__c,Jigsaw,JigsawCompanyId,JobTitle__pc,Language__pc,LastActivityDate,LastContactDate__pc,
                         LastModifiedById,LastModifiedDate,LastName,LastPreviousTransactionInterval__pc,LastPurchaseDate__pc,LastReferencedDate,
                         LastUpdateHardBounce__pc,LastUpdateNewsletterSubscription__pc,LastUpdateOptinCalling__pc,LastUpdateOptinEmailing__pc,
                         LastUpdateOptinInstantMessaging__pc,LastUpdateOptinMailing__pc,LastUpdateOptoutCalling__pc,LastUpdateOptoutEmailing__pc,
                         LastUpdateOptoutInstantMessaging__pc,LastUpdateOptoutMailing__pc,LastViewedDate,Last_Platform_Event_Applied_Updates__pc,
                         Last_Platform_Event_Processed_Date__pc,Last_Transaction_SA__pc,Last_Transaction_Store__pc,Last_Update_Pushed_to_B2C_Commerce__pc,
                         LifetimePurchaseAmountAccessories__pc,LifetimePurchaseAmountLuggage__pc,LifetimePurchaseAmountProducts__pc,
                         LifetimePurchaseAmountRepairs__pc,LifetimePurchaseAmountServices__pc,LifeTimePurchaseAmount__pc,LightCurrentCluster__pc,
                         LightPreviousCluster__pc,LINE_Channel_ID__pc,LINE_UID__pc,LocalOrTourist__pc,Local_equals_Main_CA__c,
                         Local_equals_Main_Store__c,Local_Main_CA__c,Local_Main_Store_Code__c,Local_Main_Store__c,Local__pc,MainBoutiqueCode__c,
                         MainStoreId__pc,MainStore__pc,Market__c,MasterRecordId,Name,Nationality__pc,NbOfClientAddresses__c,nb_Client_Sources__c,
                         NewsletterSubscription__pc,NumberOfEmployees,NumberOfVisit__pc,OneTimer__pc,OptinCalling__pc,OptinEmailing__pc,
                         OptinInstantMessaging__pc,OptinMailing__pc,OptoutCalling__pc,OptoutEmailing__pc,OptoutInstantMessaging__pc,
                         OptoutMailing__pc,OriginStoreCode__c,OriginStoreId__pc,OriginStore__pc,OtherEmailValid__pc,OtherEmail__pc,
                         Other_sources_ID__c,OwnerId,Ownership,Owner__pc,ParentId,PassportNumber__pc,PDUE_InternalId__c,PersonAssistantName,
                         PersonAssistantPhone,PersonBirthdate,PersonContactId,PersonDepartment,PersonDoNotCall,PersonEmail,
                         PersonEmailBouncedDate,PersonEmailBouncedReason,PersonHasOptedOutOfEmail,PersonHasOptedOutOfFax,PersonHomePhone,
                         PersonIndividualId,PersonLastCURequestDate,PersonLastCUUpdateDate,PersonLeadSource,PersonMailingAddress,
                         PersonMailingCity,PersonMailingCountry,PersonMailingGeocodeAccuracy,PersonMailingLatitude,PersonMailingLongitude,
                         PersonMailingPostalCode,PersonMailingState,PersonMailingStreet,PersonMobilePhone,PersonOtherAddress,PersonOtherCity,
                         PersonOtherCountry,PersonOtherGeocodeAccuracy,PersonOtherLatitude,PersonOtherLongitude,PersonOtherPhone,
                         PersonOtherPostalCode,PersonOtherState,PersonOtherStreet,PersonTitle,Phone,Phone1Type__pc,Phone1Valid__pc,
                         Phone2Type__pc,Phone2Valid__pc,Phone2__pc,Phone3Type__pc,Phone3Valid__pc,Phone3__pc,PhoneticFullName__pc,PhotoUrl,
                         PreferredStoreId__pc,PreferredStore__pc,PreferredTransactionChannel__pc,PreviousCluster__pc,ProfilCompletionGraph__pc,
                         ProfileCompletion__pc,ProspectA__pc,PurchaserBehaviorMethod__pc,PurchaserStatusSubCategory__pc,PurchaserStatus__pc,
                         Rating,RecordTypeId,Record_ID__c,Repair__pc,Re_Crafted_Seller__pc,RomanizedFirstname__pc,RomanizedLastname__pc,
                         Salutation,SecondAlphabetFirstname__pc,SecondAlphabetLastname__pc,SecondName__pc,SFSC_Contact_Key__pc,ShippingAddress,
                         ShippingCity,ShippingCountry,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,
                         ShippingState,ShippingStreet,Sic,SicDesc,Site,Super_Main_CA_SFID__c,Synchronized_SFMC__pc,SystemModstamp,
                         Targeted_Customers_CAreattribution__c,Targeted_Customers_HP__c,Targeted_Customers__c,TickerSymbol,Title__pc,
                         ToDelete__pc,Total_Updates_From_B2C_Commerce__pc,Total_Updates_to_B2C_Commerce__pc,Tourist__pc,Type,UCRCreationDate__pc,
                         UCRInternalId__c,UCRLastUpdateDate__pc,UnionId__c,UnionId__pc,Updated_by_B2C_Platform_Event__pc,ValidityAddress__pc,
                         ValidityAllChannels__pc,ValidityEmail__pc,ValidityInstantMessaging__pc,ValidityPhone__pc,VIP__pc,Website,
                         WebsiteCountry__pc,WebsiteLanguage__pc,WebsiteLocale__pc,WeChat__pc,What_are_you_interested_in__c 
                         FROM Account 
                         Where id =: AccountId];
        return acc;
    }
}