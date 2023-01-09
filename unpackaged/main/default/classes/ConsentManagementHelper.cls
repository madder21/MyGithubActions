/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : BADER EDDINE ELKHAL
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

       for(Account account: accounts){
           lastUpdateOptinDate = isFromMigrationJob ? account.LastUpdateOptinEmailing__pc : System.now();
           if(account.PersonIndividualId == null){
               individualsToInsertByAccountId.put(
                    account.Id,
                    new Individual(
                        LastName = account.LastName,
                        Salutation = account.Salutation,
                        BirthDate = account.PersonBirthdate
                    ));
            }else{
                if(!account.ContactPointEmails__r.isEmpty()){
                    for(ContactPointEmail contactPointEmail: account.ContactPointEmails__r){
                        //we need to take on considiration 
                        if(contactPointEmail.ActiveToDate == null
                          && contactPointEmail.EmailAddress == account.PersonEmail
                          ){
                              allContactPointsByIndividualId.put(
                              	account.PersonIndividualId,
                                contactPointEmail
                              );
                              break;
                        }
                    }
                    if(!allContactPointsByIndividualId.containskey(account.PersonIndividualId)){
                        contactPointsToInsertByIndividualId.put(
                            account.PersonIndividualId,
                            new ContactPointEmail(
                            	ActiveFromDate = lastUpdateOptinDate.Date(),
                                AccountId__c=account.Id,
                                ParentId=account.PersonIndividualId,
                                EmailAddress = account.PersonEmail
                            ));
                    }
                }else{
                    contactPointsToInsertByIndividualId.put(
                            account.PersonIndividualId,
                            new ContactPointEmail(
                            	ActiveFromDate = lastUpdateOptinDate.Date(),
                                AccountId__c=account.Id,
                                ParentId=account.PersonIndividualId,
                                EmailAddress = account.PersonEmail
                            ));
                }
            }
       }
        if(!individualsToInsertByAccountId.isEmpty()){
            insert individualsToInsertByAccountId.values();
            for(Id id : individualsToInsertByAccountId.keySet()){
                accountsByIndividualId.put(individualsToInsertByAccountId.get(id).Id, mapAccounts.get(id));
                //affect individual Id to Account to update it later!
                mapAccounts.get(id).PersonIndividualId = individualsToInsertByAccountId.get(id).Id;
                toUpdateAccounts = true;
            }
            for(Individual individual : individualsToInsertByAccountId.values()){
                contactPointsToInsertByIndividualId.put(
                            individual.Id,
                            new ContactPointEmail(
                            	ActiveFromDate = isFromMigrationJob ? accountsByIndividualId.get(individual.Id).LastUpdateOptinEmailing__pc.Date() : System.today(),
                                AccountId__c=accountsByIndividualId.get(individual.Id).Id,
                                ParentId=individual.Id,
                                EmailAddress = accountsByIndividualId.get(individual.Id).PersonEmail
                            ));
            }
        }
       //Insert the list of contactPointEmails allContactPointsByIndividualId MAP
       if(!contactPointsToInsertByIndividualId.isEmpty()) insert contactPointsToInsertByIndividualId.values();
       //Add inserted contactPointEmails to 
       for(ContactPointEmail contactPointEmail : contactPointsToInsertByIndividualId.values()){
            allContactPointsByIndividualId.put(contactPointEmail.ParentId,contactPointEmail);
        }
       //Query on ContactPointTypeConsent by AccountIds
       for(ContactPointTypeConsent contactPointTypeConsent: [SELECT Id, AccountId__r.Name ,AccountId__c, EffectiveFrom, EffectiveTo, ContactPointType 
                                                                 	FROM ContactPointTypeConsent 
                                                                 	WHERE AccountId__c IN :mapAccounts.keySet()
                                                                 	AND PrivacyConsentStatus = 'OptIn'
                                                                	AND ContactPointType ='Email'
                                                            		ORDER BY EffectiveFrom DESC]){
            if(!contactPointTypeConsentsByAccountId.containsKey(contactPointTypeConsent.AccountId__c)){
                contactPointTypeConsentsByAccountId.put(contactPointTypeConsent.AccountId__c, contactPointTypeConsent);
            }
       }
       //Query on ContactPointConsent by AccountIds 
       for(ContactPointConsent contactPointConsent: [SELECT Id, PrivacyConsentStatus ,AccountId__c, EffectiveFrom, EffectiveTo 
                                                                 	FROM ContactPointConsent 
                                                                 	WHERE AccountId__c IN :mapAccounts.keySet()
                                                                 	AND PrivacyConsentStatus = 'OptIn'
                                                            		ORDER BY EffectiveFrom DESC]){
            if(!contactPointConsentsByAccountId.containsKey(contactPointConsent.AccountId__c)){
                contactPointConsentsByAccountId.put(contactPointConsent.AccountId__c, contactPointConsent);
            }
       }

       for(Id accountId : mapAccounts.keySet()){
           Boolean consentFlag = !isFromMigrationJob && customInputsByAccountId.get(accountId).EmailConsent!=null ? customInputsByAccountId.get(accountId).EmailConsent : false;
           if(!isFromMigrationJob && !consentFlag){
               System.debug('******** Inside ContactPointConsent logic part skip : ');
               continue;
           }
           Account account = mapAccounts.get(accountId);
           lastUpdateOptinDate = isFromMigrationJob ? account.LastUpdateOptinEmailing__pc : System.now();
           DateTime lastUpdateOptinEmailing = DataMigrationHelper.formatDateTime(lastUpdateOptinDate);
           Datetime effectiveFrom = null;
           if(isFromMigrationJob) effectiveFrom = !contactPointTypeConsentsByAccountId.containsKey(accountId) ? null : DataMigrationHelper.formatDateTime(contactPointTypeConsentsByAccountId.get(accountId).EffectiveFrom);
           //String generatedHashOptIn = null;
           Boolean isGerman = false;
           if(account.Country__pc == 'DEU' || account.Country__pc =='DE' || account.WebsiteCountry__pc == 'DEU' || account.WebsiteCountry__pc == 'DE'){
            isGerman = true;
            mapConsentStatusWithAccountId.put(accountId,true);
           }
           else{
            mapConsentStatusWithAccountId.put(accountId,false);
           }
           
           //if not exist any ContactPointTypeConsent
           if(!contactPointTypeConsentsByAccountId.containsKey(accountId)){
               //isConsentActive = isGerman ? false : true;
               
               contactPointTypeConsentToInsert.add(
                    	new ContactPointTypeConsent (
                        	Name = 'Email Consent',
                            PartyId = account.PersonIndividualId == null ? individualsToInsertByAccountId.get(accountId).Id : account.PersonIndividualId,
                            ContactPointType = 'Email',
                            PrivacyConsentStatus = 'OptIn',
                            EffectiveFrom = lastUpdateOptinDate,
                            EffectiveTo = null,
                            CaptureDate = lastUpdateOptinDate,
                            CaptureContactPointType = 'Web',
                            CaptureSource = !isFromMigrationJob ? 'SFDC Contact Process' : 'SFDC Migration Job',
                            DoubleConsentCaptureDate = null,
                            OptOutContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CustomContactPointType : 'SFDC',
                            CustomContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CustomContactPointType : 'SFDC',
                            AccountId__c = accountId
                        ));
               //create new ContactPointConsent
               contactPointConsentToInsert.add(
                      	new ContactPointConsent(
                            Name = 'Newsletter-Subscription',
                            ContactPointId = account.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountId).Id).Id : allContactPointsByIndividualId.get(account.PersonIndividualId).Id,
                            PrivacyConsentStatus = isGerman ? 'OptOut' : 'OptIn',
                            EffectiveFrom = isGerman ? null : lastUpdateOptinDate,
                            EffectiveTo = null,
                            CaptureDate = lastUpdateOptinDate,
                            CaptureContactPointType = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CaptureContactPointType : 'Web',
                            CaptureSource = !isFromMigrationJob ? 'SFDC Contact Process' : 'SFDC Migration Job',
                            DoubleConsentCaptureDate = null,
                            OptOutContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CustomContactPointType : 'SFDC',
                            CustomContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CustomContactPointType : 'SFDC',
                            DoubleOptInHash__c = isGerman ? ConsentManagementHelper.HashMD5(account.CreatedDate, account.PersonContactId, account.PersonEmail) : null,
                            AccountId__c = accountId
                            
                           	));
           }
           //if ContactPointTypeConsent exist
           else if(effectiveFrom < lastUpdateOptinEmailing && isFromMigrationJob){
                        //optin True case
                        if(account.OptinEmailing__pc==true){
                            //update old one
                            //update contactPointTypeConsent
                            ContactPointTypeConsent contactPointTypeConsent = contactPointTypeConsentsByAccountId.get(accountId);
                            contactPointTypeConsent.EffectiveTo = lastUpdateOptinDate;
                            contactPointTypeConsentToUpdate.add(contactPointTypeConsent);
                            //Update ContactPointConsent
                            if(contactPointConsentsByAccountId.containsKey(accountId)){
                           	ContactPointConsent contactPointConsent = contactPointConsentsByAccountId.get(accountId);
                           	contactPointConsent.EffectiveTo = lastUpdateOptinDate;
                           	contactPointConsentToUpdate.add(contactPointConsent);
                            }
                            //create new ContactPointTypeConsent
                            contactPointTypeConsentToInsert.add(
                                new ContactPointTypeConsent (
                                    Name = 'Email Consent',
                                    PartyId = account.PersonIndividualId == null ? individualsToInsertByAccountId.get(accountId).Id : account.PersonIndividualId,
                                    ContactPointType = 'Email',
                                    PrivacyConsentStatus = 'OptIn',
                                    EffectiveFrom = lastUpdateOptinDate,
                                    EffectiveTo = null,
                                    CaptureDate = lastUpdateOptinDate,
                                    CaptureContactPointType = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CaptureContactPointType : 'Web',
                                    CaptureSource = !isFromMigrationJob ? 'SFDC Contact Process' : 'SFDC Migration Job',
                                    DoubleConsentCaptureDate = null,
                                    OptOutContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CustomContactPointType : 'SFDC',
                            		CustomContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CustomContactPointType : 'SFDC',
                                    AccountId__c = accountId
                                ));
                            //create new ContactPointConsent
                            contactPointConsentToInsert.add(
                                new ContactPointConsent(
                                    Name = 'Newsletter-Subscription',
                                    ContactPointId = account.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountId).Id).Id : allContactPointsByIndividualId.get(account.PersonIndividualId).Id,
                                    PrivacyConsentStatus = isGerman ? 'OptOut' : 'OptIn',
                                    EffectiveFrom = isGerman ? null : lastUpdateOptinDate,
                                    EffectiveTo = null,
                                    CaptureDate = lastUpdateOptinDate,
                                    CaptureContactPointType = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CaptureContactPointType : 'Web',
                                    CaptureSource = !isFromMigrationJob ? 'SFDC Contact Process' : 'SFDC Migration Job',
                                    DoubleConsentCaptureDate = null,
                                    OptOutContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CustomContactPointType : 'SFDC',
                            		CustomContactPointType__c = !isFromMigrationJob ? customInputsByAccountId.get(accountId).CustomContactPointType : 'SFDC',
                                    DoubleOptInHash__c = isGerman ? ConsentManagementHelper.HashMD5(account.CreatedDate, account.PersonContactId, account.PersonEmail) : null,
                                    AccountId__c = accountId
                                ));
                        }
                       ////optin False case
                       else{
                            ContactPointTypeConsent contactPointTypeConsent = contactPointTypeConsentsByAccountId.get(accountId);
                            contactPointTypeConsent.EffectiveTo = lastUpdateOptinDate;
                            contactPointTypeConsent.PrivacyConsentStatus = 'OptOut';
                            contactPointTypeConsentToUpdate.add(contactPointTypeConsent);
                           	//update contactPointConsent
                           	if(contactPointConsentsByAccountId.containsKey(accountId)){
                           	ContactPointConsent contactPointConsent = contactPointConsentsByAccountId.get(accountId);
                            contactPointConsent.EffectiveTo = lastUpdateOptinDate;
                            contactPointConsent.PrivacyConsentStatus = 'OptOut';
                            contactPointConsentToUpdate.add(contactPointConsent);
                            }
                        }
                }
        }

        if(!contactPointTypeConsentToUpdate.isEmpty()) update contactPointTypeConsentToUpdate;
        if(!contactPointConsentToUpdate.isEmpty()) update contactPointConsentToUpdate;
        if(!contactPointTypeConsentToInsert.isEmpty()) insert contactPointTypeConsentToInsert;
        if(!contactPointConsentToInsert.isEmpty()) insert contactPointConsentToInsert;
        //Create Communication Subscription
        if(!isFromMigrationJob){
            toUpdateAccounts = true;
            for(CommSubscriptionConsent commSubscriptionConsent: [SELECT Id, ContactPointId ,AccountId__c, EffectiveFromDate, EffectiveToDate,
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
        //Insert CommSubscriptionConsent list
        if(!commSubscriptionConsentToInsert.isEmpty()) insert commSubscriptionConsentToInsert;
        //update account list
        if(!mapAccounts.isEmpty() && toUpdateAccounts) update mapAccounts.values();
	}  
 
}