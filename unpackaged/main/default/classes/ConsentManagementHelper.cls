/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : BADER EDDINE ELKHAL
 * @last modified on  : 24-01-2023
 * @last modified by  : Paul Louis MONY
 * @last modified on  : 30-01-2023
 * @last modified by  : Ulrich NDONG NGOMO
 * @last modification : indentation, cleansing and commenting; add a method for migrationJob newsletter handling
**/

public class ConsentManagementHelper {
        
    //Logic for Custom input
    @InvocableMethod (label = 'B2C: Manage Contact Consent' Description = 'this method manage contact consent from flow')
    public static void ContactConsentMangement(List <ConsentManagementFlowInputs> flowInputs){
       Contact contact = flowInputs[0].contactRecord;
       B2CContactProcessCustomInput customInput = flowInputs[0].customInputRecord;
       if(contact != null && customInput != null){
            Map<Id,B2CContactProcessCustomInput> customInputsList = new Map<Id,B2CContactProcessCustomInput>();
            List<Account> accountsList = [SELECT id,LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, 
                               PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                               (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                               FROM Account WHERE PersonContactId = : contact.Id limit 1
                              ];
            if(accountsList.size() == 1){
               customInputsList.put(accountsList[0].Id,customInput);
               ConsentManagementHelper.migrateConsentGlobalMethod(accountsList,customInputsList,false);
            }          
        }        
    }

    public static String HashMD5(Datetime createDate, Id contactId, String email){
        String fieldsConcatenate = String.valueOf(createDate);
        if(email != null){
            fieldsConcatenate += Email;
        }
        if(ContactId != null){
            fieldsConcatenate += String.valueOf(ContactId);
        }
        Blob targetBlob = Blob.valueOf(fieldsConcatenate);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        String ecodingToUrl = EncodingUtil.Base64Encode(hash);
        return EncodingUtil.urlEncode(ecodingToUrl, 'UTF-8');
    }
    
    //Method called from DataMigrationBatch & Custom Input
    public static void migrateConsentGlobalMethod(List<Account> accounts,Map<Id,B2CContactProcessCustomInput> customInputsByAccountId, Boolean isFromMigrationJob){
        Map<Id,Account> mapAccounts= New Map<Id,Account>(accounts);
        List<ContactPointTypeConsent> contactPointTypeConsentToUpdate = New List<ContactPointTypeConsent>();
        List<ContactPointTypeConsent> contactPointTypeConsentToInsert = New List<ContactPointTypeConsent>();
        List<ContactPointConsent> contactPointConsentToInsert = New List<ContactPointConsent>();
        List<ContactPointConsent> contactPointConsentToUpdate = New List<ContactPointConsent>();
        Map<Id, Individual> individualsToInsertByAccountId = new Map<Id, Individual>();
        Map<Id, Account> accountsByIndividualId = new Map<Id, Account>();
        Map<Id, ContactPointEmail> contactPointsToInsertByIndividualId = new Map<Id, ContactPointEmail>();
        Map<Id, ContactPointEmail> allContactPointsByIndividualId = new Map<Id, ContactPointEmail>();
        Map<ID, ContactPointTypeConsent> contactPointTypeConsentsByAccountId = new Map<ID, ContactPointTypeConsent>();
        Map<ID, ContactPointConsent> contactPointConsentsByAccountId = new Map<ID, ContactPointConsent>();
        List<CommSubscriptionConsent> commSubscriptionConsentToInsert = New List<CommSubscriptionConsent>();
        Map<String, CommSubscriptionChannelType> commSubChannelTypesByName= new Map<String, CommSubscriptionChannelType>();
        Map<Id, CommSubscriptionConsent> commSubscriptionConsentByAccountId = new Map<Id, CommSubscriptionConsent>();
        Map<Id, Boolean> mapConsentStatusWithAccountId = new Map<Id, Boolean>();
        DateTime lastUpdateOptinDate = System.now();
        Boolean isConsentActive = true;
        Boolean toUpdateAccounts = false;
        
        /*!START SECTION 1 ***************************************************************************************
        Management of Individual and ContactPointEmail
        */
        for(Account aAccount: accounts){
           lastUpdateOptinDate = isFromMigrationJob ? aAccount.LastUpdateOptinEmailing__pc : System.now();
           //IF there is no Individual attached to the Account
           if(aAccount.PersonIndividualId == null){
               individualsToInsertByAccountId.put(
                    aAccount.Id,
                    new Individual(
                        LastName = aAccount.LastName,
                        Salutation = aAccount.Salutation,
                        BirthDate = aAccount.PersonBirthdate
                    ));
            }
            //If there is an Individual already attached to the account
            else{
                //IF the account have a ContactPointEmail
                if(!aAccount.ContactPointEmails__r.isEmpty()){
                    for(ContactPointEmail aContactPointEmail : aAccount.ContactPointEmails__r){
                        // Add to map <individualID,ContactPointEmail> the related ContactPointEmail 
                        //with the Indidual linked in the Account if the contactPointEmail Is Active
                        if(aContactPointEmail.ActiveToDate == null && aContactPointEmail.EmailAddress == aAccount.PersonEmail){
                                allContactPointsByIndividualId.put(aAccount.PersonIndividualId,aContactPointEmail);
                                break;
                        }
                    }
                    //IF the map <individualID,ContactPointEmail> doestn't contain an individual who match the ContactPointEmail 
                    //- create a new ContactPointEmail
                    if(!allContactPointsByIndividualId.containskey(aAccount.PersonIndividualId)){
                        contactPointsToInsertByIndividualId.put(aAccount.PersonIndividualId,
                                                                new ContactPointEmail(ActiveFromDate = lastUpdateOptinDate.Date(),
                                                                                      AccountId__c   = aAccount.Id,
                                                                                      ParentId       = aAccount.PersonIndividualId,
                                                                                      EmailAddress   = aAccount.PersonEmail));
                    }
                }
                //IF the account haven't a ContactPointEmail
                else{
                    contactPointsToInsertByIndividualId.put(aAccount.PersonIndividualId,
                                                            new ContactPointEmail(ActiveFromDate = lastUpdateOptinDate.Date(),
                                                                                  AccountId__c=aAccount.Id,
                                                                                  ParentId=aAccount.PersonIndividualId,
                                                                                  EmailAddress = aAccount.PersonEmail));
                }
            }
        }
        if(!individualsToInsertByAccountId.isEmpty()){
            insert individualsToInsertByAccountId.values();
            for(Id aId : individualsToInsertByAccountId.keySet()){
                accountsByIndividualId.put(individualsToInsertByAccountId.get(aId).Id, mapAccounts.get(aId));
                //affect individual Id to Account to update it later!
                mapAccounts.get(aId).PersonIndividualId = individualsToInsertByAccountId.get(aId).Id;
                toUpdateAccounts = true;
            }
            for(Individual aIndividual : individualsToInsertByAccountId.values()){
                contactPointsToInsertByIndividualId.put(
                            aIndividual.Id,
                            new ContactPointEmail(
                            	ActiveFromDate = isFromMigrationJob ? accountsByIndividualId.get(aIndividual.Id).LastUpdateOptinEmailing__pc.Date() : System.today(),
                                AccountId__c=accountsByIndividualId.get(aIndividual.Id).Id,
                                ParentId=aIndividual.Id,
                                EmailAddress = accountsByIndividualId.get(aIndividual.Id).PersonEmail
                            ));
            }
        }
        //Insert the list of contactPointEmails from contactPointsToInsertByIndividualId MAP
        if(!contactPointsToInsertByIndividualId.isEmpty()){
            System.debug('SECTION 1 : Insert ContactPointEmail : ' + contactPointsToInsertByIndividualId);
            Database.Insert(contactPointsToInsertByIndividualId.values());
        }
        //Add inserted contactPointEmails to allContactPointsByIndividualId
        for(ContactPointEmail aContactPointEmail : contactPointsToInsertByIndividualId.values()){
            allContactPointsByIndividualId.put(aContactPointEmail.ParentId,aContactPointEmail);
        }
        /*!END SECTION 1    ***************************************************************************************
        */

        /*!START SECTION 2  ***************************************************************************************
        Management of ContactPointTypeConsent and ContactPointConsent
        */
       //Query on ContactPointTypeConsent by AccountIds
        for(ContactPointTypeConsent aContactPointTypeConsent: [SELECT Id, AccountId__r.Name ,AccountId__c, EffectiveFrom, EffectiveTo, ContactPointType 
                                                              FROM ContactPointTypeConsent 
                                                              WHERE AccountId__c IN :mapAccounts.keySet()
                                                              AND PrivacyConsentStatus = 'OptIn'
                                                              AND ContactPointType ='Email'
                                                              ORDER BY EffectiveFrom DESC]){
            if(!contactPointTypeConsentsByAccountId.containsKey(aContactPointTypeConsent.AccountId__c)){
                contactPointTypeConsentsByAccountId.put(aContactPointTypeConsent.AccountId__c, aContactPointTypeConsent);
            }
        }
       //Query on ContactPointConsent by AccountIds 
        for(ContactPointConsent aContactPointConsent : [SELECT Id, PrivacyConsentStatus ,AccountId__c, EffectiveFrom, EffectiveTo 
                                                    FROM ContactPointConsent 
                                                    WHERE AccountId__c IN :mapAccounts.keySet()
                                                    AND PrivacyConsentStatus = 'OptIn'
                                                    ORDER BY EffectiveFrom DESC]){
            if(!contactPointConsentsByAccountId.containsKey(aContactPointConsent.AccountId__c)){
                contactPointConsentsByAccountId.put(aContactPointConsent.AccountId__c, aContactPointConsent);
            }
        }
        //For each Account in keySet, create or update ContactPointTypeConsent and ContactPointConsent Lists
        for(Id aAccountId : mapAccounts.keySet()){
           Boolean consentFlag = !isFromMigrationJob && customInputsByAccountId.get(aAccountId).EmailConsent!=null ? customInputsByAccountId.get(aAccountId).EmailConsent : false;
           if(!isFromMigrationJob && !consentFlag){
               System.debug('******** Inside ContactPointConsent logic part skip : ');
               continue;
           }
           Account aAccount = mapAccounts.get(aAccountId);
           lastUpdateOptinDate = isFromMigrationJob ? aAccount.LastUpdateOptinEmailing__pc : System.now();
           DateTime lastUpdateOptinEmailing = DataMigrationHelper.formatDateTime(lastUpdateOptinDate);
           Datetime effectiveFrom = null;
           if(isFromMigrationJob){
                if(contactPointTypeConsentsByAccountId.containsKey(aAccountId)){
                    effectiveFrom = DataMigrationHelper.formatDateTime(contactPointTypeConsentsByAccountId.get(aAccountId).EffectiveFrom);
                }
                else{
                    effectiveFrom = null;
                }
           }
           //String generatedHashOptIn = null;
           Boolean isGerman = false;
           if(aAccount.Country__pc == 'DEU' || aAccount.Country__pc =='DE' || aAccount.WebsiteCountry__pc == 'DEU' || aAccount.WebsiteCountry__pc == 'DE'){
            isGerman = true;
            mapConsentStatusWithAccountId.put(aAccountId,true);
           }
           else{
            mapConsentStatusWithAccountId.put(aAccountId,false);
           }
           
           //if there is no ContactPointTypeConsent for this account
           //=> create ContactPointTypeConsent and ContactPointConsent and attached it to the individual already attached to the account
           if(!contactPointTypeConsentsByAccountId.containsKey(aAccountId)){
               //isConsentActive = isGerman ? false : true;
               contactPointTypeConsentToInsert.add(
                    	new ContactPointTypeConsent (
                        	Name = 'Email Consent',
                            PartyId = aAccount.PersonIndividualId == null ? individualsToInsertByAccountId.get(aAccountId).Id : aAccount.PersonIndividualId,
                            ContactPointType = 'Email',
                            PrivacyConsentStatus = 'OptIn',
                            EffectiveFrom = lastUpdateOptinDate,
                            EffectiveTo = null,
                            CaptureDate = lastUpdateOptinDate,
                            CaptureContactPointType = 'Web',
                            CaptureSource = !isFromMigrationJob ? 'SFDC Contact Process' : 'SFDC Migration Job',
                            DoubleConsentCaptureDate = null,
                            OptOutContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CustomContactPointType : 'SFDC',
                            CustomContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CustomContactPointType : 'SFDC',
                            AccountId__c = aAccountId
                        ));
               //create new ContactPointConsent
               contactPointConsentToInsert.add(
                      	new ContactPointConsent(
                            Name = 'Newsletter-Subscription',
                            ContactPointId = aAccount.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(aAccountId).Id).Id : allContactPointsByIndividualId.get(aAccount.PersonIndividualId).Id,
                            PrivacyConsentStatus = isGerman ? 'OptOut' : 'OptIn',
                            EffectiveFrom = isGerman ? null : lastUpdateOptinDate,
                            EffectiveTo = null,
                            CaptureDate = lastUpdateOptinDate,
                            CaptureContactPointType = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CaptureContactPointType : 'Web',
                            CaptureSource = !isFromMigrationJob ? 'SFDC Contact Process' : 'SFDC Migration Job',
                            DoubleConsentCaptureDate = null,
                            OptOutContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CustomContactPointType : 'SFDC',
                            CustomContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CustomContactPointType : 'SFDC',
                            DoubleOptInHash__c = isGerman ? ConsentManagementHelper.HashMD5(aAccount.CreatedDate, aAccount.PersonContactId, aAccount.PersonEmail) : null,
                            AccountId__c = aAccountId
                           	));
           }
            //if ContactPointTypeConsent exist for this account and effectiveFrom before lastUpdateOptinEmailing and we are in MigrationJob
            else if((effectiveFrom < lastUpdateOptinEmailing || effectiveFrom == null) && isFromMigrationJob){
                //optin True case
                if(aAccount.OptinEmailing__pc==true){
                    //update old one
                    //update old contactPointTypeConsent and stop it lastUpdateOptinDate
                    ContactPointTypeConsent aContactPointTypeConsent = contactPointTypeConsentsByAccountId.get(aAccountId);
                    aContactPointTypeConsent.EffectiveTo = lastUpdateOptinDate;
                    contactPointTypeConsentToUpdate.add(aContactPointTypeConsent);
                    //Update old ContactPointConsent and stop it lastUpdateOptinDate
                    if(contactPointConsentsByAccountId.containsKey(aAccountId)){
                        ContactPointConsent aContactPointConsent = contactPointConsentsByAccountId.get(aAccountId);
                        aContactPointConsent.EffectiveTo = lastUpdateOptinDate;
                        contactPointConsentToUpdate.add(aContactPointConsent);
                    }
                    //create new ContactPointTypeConsent and start it to lastUpdateOptinDate
                    contactPointTypeConsentToInsert.add(
                        new ContactPointTypeConsent (
                            Name = 'Email Consent',
                            PartyId = aAccount.PersonIndividualId == null ? individualsToInsertByAccountId.get(aAccountId).Id : aAccount.PersonIndividualId,
                            ContactPointType = 'Email',
                            PrivacyConsentStatus = 'OptIn',
                            EffectiveFrom = lastUpdateOptinDate,
                            EffectiveTo = null,
                            CaptureDate = lastUpdateOptinDate,
                            CaptureContactPointType = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CaptureContactPointType : 'Web',
                            CaptureSource = !isFromMigrationJob ? 'SFDC Contact Process' : 'SFDC Migration Job',
                            DoubleConsentCaptureDate = null,
                            OptOutContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CustomContactPointType : 'SFDC',
                            CustomContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CustomContactPointType : 'SFDC',
                            AccountId__c = aAccountId
                        ));
                    //create new ContactPointConsent
                    contactPointConsentToInsert.add(
                        new ContactPointConsent(
                            Name = 'Newsletter-Subscription',
                            ContactPointId = aAccount.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(aAccountId).Id).Id : allContactPointsByIndividualId.get(aAccount.PersonIndividualId).Id,
                            PrivacyConsentStatus = isGerman ? 'OptOut' : 'OptIn',
                            EffectiveFrom = isGerman ? null : lastUpdateOptinDate,
                            EffectiveTo = null,
                            CaptureDate = lastUpdateOptinDate,
                            CaptureContactPointType = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CaptureContactPointType : 'Web',
                            CaptureSource = !isFromMigrationJob ? 'SFDC Contact Process' : 'SFDC Migration Job',
                            DoubleConsentCaptureDate = null,
                            OptOutContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CustomContactPointType : 'SFDC',
                            CustomContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(aAccountId).CustomContactPointType : 'SFDC',
                            DoubleOptInHash__c = isGerman ? ConsentManagementHelper.HashMD5(aAccount.CreatedDate, aAccount.PersonContactId, aAccount.PersonEmail) : null,
                            AccountId__c = aAccountId
                        ));
                }
                ////optin False case
                else{
                    ContactPointTypeConsent aContactPointTypeConsent = contactPointTypeConsentsByAccountId.get(aAccountId);
                    aContactPointTypeConsent.EffectiveTo = lastUpdateOptinDate;
                    aContactPointTypeConsent.PrivacyConsentStatus = 'OptOut';
                    contactPointTypeConsentToUpdate.add(aContactPointTypeConsent);
                    //update contactPointConsent
                    if(contactPointConsentsByAccountId.containsKey(aAccountId)){
                        ContactPointConsent aContactPointConsent = contactPointConsentsByAccountId.get(aAccountId);
                        aContactPointConsent.EffectiveTo = lastUpdateOptinDate;
                        aContactPointConsent.PrivacyConsentStatus = 'OptOut';
                        contactPointConsentToUpdate.add(aContactPointConsent);
                    }
                }
            }
        }
        //Update ContactPointTypeConsent
        if(!contactPointTypeConsentToUpdate.isEmpty()) {
            update contactPointTypeConsentToUpdate;
        }
        //Update ContactPointConsent
        if(!contactPointConsentToUpdate.isEmpty()){
            update contactPointConsentToUpdate;
        }
        //Create ContactPointTypeConsent
        if(!contactPointTypeConsentToInsert.isEmpty()){
            System.debug('SECTION 2 : Insert contactPointTypeConsent : ' + contactPointTypeConsentToInsert);
            insert contactPointTypeConsentToInsert;
        } 
        //Create ContactPointConsent
        if(!contactPointConsentToInsert.isEmpty()){
            System.debug('SECTION 2 : Insert contactPointConsent : ' + contactPointConsentToInsert);
            insert contactPointConsentToInsert;
        }
         /*!END  SECTION 2  ***************************************************************************************
         */
        /*!START SECTION 3  ***************************************************************************************
        Management of Communication Subscription Consent 
        */
        for(CommSubscriptionConsent commSubscriptionConsent : [SELECT Id, ContactPointId ,AccountId__c, EffectiveFromDate, EffectiveToDate,
                                                                ConsentCapturedDateTime, ConsentCapturedSource, CommSubscriptionChannelTypeId
                                                               FROM CommSubscriptionConsent 
                                                               WHERE AccountId__c IN :mapAccounts.keySet()
                                                               AND EffectiveToDate = null
                                                               AND CommSubscriptionChannelType.Name = 'Newsletter'
                                                               ORDER BY EffectiveFromDate DESC]){
            	if(!commSubscriptionConsentByAccountId.containsKey(commSubscriptionConsent.AccountId__c)){
                	commSubscriptionConsentByAccountId.put(commSubscriptionConsent.AccountId__c, commSubscriptionConsent);
            	}
        }
        //Fill commSubChannelTypes By Names in map
        for(CommSubscriptionChannelType commsubChannelType: [Select Id, Name From CommSubscriptionChannelType]){
            commSubChannelTypesByName.put(commsubChannelType.Name.toLowerCase(), commsubChannelType);
        }
        //if from flow
        if(!isFromMigrationJob){
            toUpdateAccounts = true;
            for(Account accountLine : mapAccounts.values()){
                Boolean emailConsentFlag = customInputsByAccountId.get(accountLine.Id).EmailConsent !=null ?customInputsByAccountId.get(accountLine.Id).EmailConsent : false;
                Id currentContactPointEmailId = accountLine.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountLine.Id).Id).Id : allContactPointsByIndividualId.get(accountLine.PersonIndividualId).Id;
                lastUpdateOptinDate = System.now();
                if(customInputsByAccountId.get(accountLine.Id).SubscriptionName != null){
                    String subNames = customInputsByAccountId.get(accountLine.Id).SubscriptionName;
                    List<String> listSubscriptionName = subNames.split(';');
                    //Add New commSubscriptionConsent to list to insert
                    for(String subcriptionName : listSubscriptionName){
                        System.debug('******** subcriptionName Loop Lv1');
                        if(!emailConsentFlag && commSubChannelTypesByName.containsKey(subcriptionName.toLowerCase()) && subcriptionName.equalsIgnoreCase('BackInStock')){
                            commSubscriptionConsentToInsert.add(new CommSubscriptionConsent(
                                Name = subcriptionName,
                                AccountId__c = accountLine.Id,
                                ContactPointId = accountLine.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountLine.Id).Id).Id : allContactPointsByIndividualId.get(accountLine.PersonIndividualId).Id,
                                EffectiveFromDate = lastUpdateOptinDate.Date(),
                                ConsentCapturedDateTime = lastUpdateOptinDate,
                                ConsentCapturedSource = customInputsByAccountId.get(accountLine.Id).CaptureContactPointType,
                                sku__c = customInputsByAccountId.get(accountLine.Id).BackInStockSubscriptionSKU,
                                StoreCode__c = customInputsByAccountId.get(accountLine.Id).Store,
                                SaleChannel__c = customInputsByAccountId.get(accountLine.Id).SaleChannel,
                                Locale__c = accountLine.WebsiteLocale__pc,
                                Warehouse__c = customInputsByAccountId.get(accountLine.Id).Warehouse,
                                Country__c = accountLine.WebsiteCountry__pc == 'DEU'? 'DE' : accountLine.WebsiteCountry__pc,
                                CommSubscriptionChannelTypeId = commSubChannelTypesByName.get(subcriptionName.toLowerCase()).Id
                            ));
                            break;
                        }
                        System.debug('******** subcriptionName Loop Lv2');
                        //Updated on 2021-11-08
                        //check if consent type is newsletter and is not yet active to not create commSubscriptionConsent
                        if(emailConsentFlag && (!subcriptionName.equalsIgnoreCase('Newsletter') || !mapConsentStatusWithAccountId.get(accountLine.Id))){
                            System.debug('******** subcriptionName Loop Lv3 Inside bloc');
                            if(commSubChannelTypesByName.containsKey(subcriptionName.toLowerCase())){
                                if(subcriptionName.equalsIgnoreCase('BackInStock')){
                                    commSubscriptionConsentToInsert.add(new CommSubscriptionConsent(
                                        Name = subcriptionName,
                                        AccountId__c = accountLine.Id,
                                        ContactPointId = accountLine.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountLine.Id).Id).Id : allContactPointsByIndividualId.get(accountLine.PersonIndividualId).Id,
                                        EffectiveFromDate = lastUpdateOptinDate.Date(),
                                        ConsentCapturedDateTime = lastUpdateOptinDate,
                                        ConsentCapturedSource = customInputsByAccountId.get(accountLine.Id).CaptureContactPointType,
                                        sku__c = customInputsByAccountId.get(accountLine.Id).BackInStockSubscriptionSKU,
                                        StoreCode__c = customInputsByAccountId.get(accountLine.Id).Store,
                                        SaleChannel__c = customInputsByAccountId.get(accountLine.Id).SaleChannel,
                                        Locale__c = accountLine.WebsiteLocale__pc,
                                        Warehouse__c = customInputsByAccountId.get(accountLine.Id).Warehouse,
                                        Country__c = accountLine.WebsiteCountry__pc == 'DEU'? 'DE' : accountLine.WebsiteCountry__pc,
                                        CommSubscriptionChannelTypeId = commSubChannelTypesByName.get(subcriptionName.toLowerCase()).Id
                                    ));
                                }else if(!commSubscriptionConsentByAccountId.containsKey(accountLine.Id)){
                                    commSubscriptionConsentToInsert.add(new CommSubscriptionConsent(
                                        Name = subcriptionName,
                                        AccountId__c = accountLine.Id,
                                        ContactPointId = accountLine.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountLine.Id).Id).Id : allContactPointsByIndividualId.get(accountLine.PersonIndividualId).Id,
                                        // EffectiveFromDate = isConsentActive ? lastUpdateOptinDate.Date() : null, //updated 2021-11-04
                                        EffectiveFromDate = lastUpdateOptinDate.Date(), //updated 2021-11-04
                                        //isDesactive__c = isConsentActive ? false : true, //Added 2021-11-04
                                        //isDesactive__c = mapConsentStatusWithAccountId.containsKey(accountLine.Id) ? mapConsentStatusWithAccountId.get(accountLine.Id) : false, //Added 2021-11-08
                                        ConsentCapturedDateTime = lastUpdateOptinDate,
                                        ConsentCapturedSource = customInputsByAccountId.get(accountLine.Id).CaptureContactPointType,
                                        CommSubscriptionChannelTypeId = commSubChannelTypesByName.get(subcriptionName.toLowerCase()).Id
                                    ));
                                }
                                else if(commSubscriptionConsentByAccountId.containsKey(accountLine.Id)
                                        && commSubscriptionConsentByAccountId.get(accountLine.Id).ContactPointId != currentContactPointEmailId){
                                    commSubscriptionConsentToInsert.add(new CommSubscriptionConsent(
                                        Name = subcriptionName,
                                        AccountId__c = accountLine.Id,
                                        ContactPointId = accountLine.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountLine.Id).Id).Id : allContactPointsByIndividualId.get(accountLine.PersonIndividualId).Id,
                                        //EffectiveFromDate = isConsentActive ? lastUpdateOptinDate.Date() : null, //updated 2021-11-04
                                        EffectiveFromDate = lastUpdateOptinDate.Date(), //updated 2021-11-04
                                        //isDesactive__c = isConsentActive ? false : true, //Added 2021-11-04 
                                        //isDesactive__c = mapConsentStatusWithAccountId.containsKey(accountLine.Id) ? mapConsentStatusWithAccountId.get(accountLine.Id) : false, //Added 2021-11-08 
                                        ConsentCapturedDateTime = lastUpdateOptinDate,
                                        ConsentCapturedSource = customInputsByAccountId.get(accountLine.Id).CaptureContactPointType,
                                        CommSubscriptionChannelTypeId = commSubChannelTypesByName.get(subcriptionName.toLowerCase()).Id
                                    ));
                                }
                            }else{
                                commSubscriptionConsentToInsert.add(new CommSubscriptionConsent(
                                    Name = 'SpecialEvent',
                                    AccountId__c = accountLine.Id,
                                    ContactPointId = accountLine.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountLine.Id).Id).Id : allContactPointsByIndividualId.get(accountLine.PersonIndividualId).Id,
                                    EffectiveFromDate = lastUpdateOptinDate.Date(),
                                    ConsentCapturedDateTime = lastUpdateOptinDate,
                                    ConsentCapturedSource = customInputsByAccountId.get(accountLine.Id).CaptureContactPointType,
                                    CommSubscriptionChannelTypeId = commSubChannelTypesByName.get('specialevent').Id
                                ));
                            }
                        }
                    }
               	}
                //update Account Record
               //only if emailconsent is true !!!!
                if(emailConsentFlag && !accountLine.OptinEmailing__pc && !mapConsentStatusWithAccountId.get(accountLine.Id)){
                    accountLine.OptinEmailing__pc = true;
                    accountLine.LastUpdateOptinEmailing__pc = System.now();
                }
            }
        }
        //If from Batch MigrationJob, Only Newsletter are concerned
        else{
            //toUpdateAccounts = false; -- Commented by Ulrich NDONG NGOMO 30/01/2023
            for(Account aAccount : mapAccounts.values()){
                if(!commSubscriptionConsentByAccountId.containsKey(aAccount.Id) && aAccount.OptinEmailing__pc){
                    commSubscriptionConsentToInsert.add(new CommSubscriptionConsent(
                        Name = 'Newsletter',
                        AccountId__c = aAccount.id,
                        ContactPointId = aAccount.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(aAccount.Id).Id).Id : allContactPointsByIndividualId.get(aAccount.PersonIndividualId).Id,
                        EffectiveFromDate = lastUpdateOptinDate.Date(),
                        ConsentCapturedDateTime = lastUpdateOptinDate,
                        ConsentCapturedSource = 'SFDC Migration Job',
                        Locale__c = aAccount.WebsiteLocale__pc,
                        Country__c = aAccount.WebsiteCountry__pc == 'DEU'? 'DE' : aAccount.WebsiteCountry__pc,
                        CommSubscriptionChannelTypeId = commSubChannelTypesByName.get('newsletter').Id));                    
                }
            }
        }
        /*!END  SECTION 3  ***************************************************************************************
        */
        //Insert CommSubscriptionConsent list
        if(!commSubscriptionConsentToInsert.isEmpty()) {
            System.debug('END : Insert commSubscriptionConsent : ' + commSubscriptionConsentToInsert);
            insert commSubscriptionConsentToInsert;
        }
        //update account list
        if(!mapAccounts.isEmpty() && toUpdateAccounts) {
            System.debug('END : Update Account : ' + mapAccounts);
            update mapAccounts.values();
        }
	}   
}