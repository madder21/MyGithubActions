public class DataMigrationHelper {
    
    public static String buildDataMigrationBatchQuery(Boolean isFirstRun, DateTime lastBatchExecutionDateTime, DateTime maxDate){
       	String query = 'SELECT id,LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, PersonBirthdate, PersonEmail';
        query += ', (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)';
        query += ' FROM Account WHERE PersonEmail != null AND IsPersonAccount = true';
        if(isFirstRun){
            query += ' AND OptinEmailing__pc =true AND LastUpdateOptinEmailing__pc != null AND LastUpdateOptinEmailing__pc < :maxDate AND LastUpdateOptinEmailing__pc >= :lastBatchExecutionDateTime';
        }else if(lastBatchExecutionDateTime != null){
            query += ' AND LastUpdateOptinEmailing__pc >=:lastBatchExecutionDateTime ';
        }else{
            query += ' AND LastUpdateOptinEmailing__pc >= YESTERDAY';
        }
		return query;
    }
    
    public static DateTime formatDateTime(DateTime dateTimeValue){
        if(dateTimeValue != null){
            String dateVal = dateTimeValue.format('yyyy-MM-dd\'T\'hh:mm:ss');
           Datetime valToreturn = Datetime.valueOf(dateVal.replace('T',' '));
            return valToreturn;
        }
        else{
            return null;
        }
     
    }
    public static void migrateConsents(List<Account> accounts){
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
        
       for(Account account: accounts){
            if(account.PersonIndividualId == null){
                individualsToInsertByAccountId.put(
                    account.Id,
                    new Individual(
                        LastName = account.LastName,
                        Salutation = account.Salutation,
                        BirthDate = account.PersonBirthdate
                    ) 
                );
            }else{
                if(!account.ContactPointEmails__r.isEmpty()){
                    
                    for(ContactPointEmail contactPointEmail: account.ContactPointEmails__r){
                        if(contactPointEmail.ActiveToDate != null
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
                            	ActiveFromDate =account.LastUpdateOptinEmailing__pc.Date(),
                                AccountId__c=account.Id,
                                ParentId=account.PersonIndividualId,
                                EmailAddress = account.PersonEmail
                            )
                        );
                        
                    }
                }else{
                    contactPointsToInsertByIndividualId.put(
                            account.PersonIndividualId,
                            new ContactPointEmail(
                            	ActiveFromDate = account.LastUpdateOptinEmailing__pc.Date(),
                                AccountId__c=account.Id,
                                ParentId=account.PersonIndividualId,
                                EmailAddress = account.PersonEmail
                            )
                        );
                }
            }
       }
        if(!individualsToInsertByAccountId.isEmpty()){
            insert individualsToInsertByAccountId.values();
            for(Id id : individualsToInsertByAccountId.keySet()){
                accountsByIndividualId.put(individualsToInsertByAccountId.get(id).Id, mapAccounts.get(id));
            }
            
            for(Individual individual : individualsToInsertByAccountId.values()){
                contactPointsToInsertByIndividualId.put(
                            individual.Id,
                            new ContactPointEmail(
                            	ActiveFromDate = accountsByIndividualId.get(individual.Id).LastUpdateOptinEmailing__pc.Date(),
                                AccountId__c=accountsByIndividualId.get(individual.Id).Id,
                                ParentId=individual.Id,
                                EmailAddress = accountsByIndividualId.get(individual.Id).PersonEmail
                            )
                        );
                
            }
        } 
       
       if(!contactPointsToInsertByIndividualId.isEmpty()) insert contactPointsToInsertByIndividualId.values();
        for(ContactPointEmail contactPointEmail : contactPointsToInsertByIndividualId.values()){
            allContactPointsByIndividualId.put(contactPointEmail.ParentId,contactPointEmail);
        }
     
       for(ContactPointTypeConsent contactPointTypeConsent: [SELECT Id, AccountId__r.Name ,AccountId__c, EffectiveFrom, EffectiveTo, ContactPointType 
                                                                 	FROM ContactPointTypeConsent 
                                                                 	WHERE AccountId__c IN :mapAccounts.keySet()
                                                                 	AND PrivacyConsentStatus = 'OptIn'
                                                                	AND ContactPointType ='Email'
                                                            		ORDER BY EffectiveFrom DESC]){
            if(!contactPointTypeConsentsByAccountId.containsKey(contactPointTypeConsent.AccountId__c)){
                contactPointTypeConsentsByAccountId.put(contactPointTypeConsent.AccountId__c, contactPointTypeConsent);
                System.debug('account name '+contactPointTypeConsent.AccountId__r.Name);
                
            }
           
       }
        
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
           Account account = mapAccounts.get(accountId);
           DateTime date1 = account.LastUpdateOptinEmailing__pc;
           DateTime lastUpdateOptinEmailing = DataMigrationHelper.formatDateTime(account.LastUpdateOptinEmailing__pc);
           Datetime effectiveFrom = contactPointTypeConsentsByAccountId.containsKey(accountId)==false ? null : DataMigrationHelper.formatDateTime(contactPointTypeConsentsByAccountId.get(accountId).effectiveFrom);
           
           
           //if not exist
           if(!contactPointTypeConsentsByAccountId.containsKey(accountId)){
               contactPointTypeConsentToInsert.add(
                    	new ContactPointTypeConsent (
                        	Name = 'Email Consent',
                            PartyId = account.PersonIndividualId == null ? individualsToInsertByAccountId.get(accountId).Id : account.PersonIndividualId,
                            ContactPointType = 'Email',
                            PrivacyConsentStatus = 'OptIn',
                            EffectiveFrom = account.LastUpdateOptinEmailing__pc,
                            EffectiveTo = null,
                            CaptureDate = account.LastUpdateOptinEmailing__pc,
                            CaptureContactPointType = 'Web',
                            CaptureSource = 'SFDC Migration Job',
                            DoubleConsentCaptureDate = null,
                            OptOutContactPointType__c = 'SFDC',
                            CustomContactPointType__c = 'SFDC',
                            AccountId__c = accountId
                        )
                    );
               //create new ContactPointConsent
               contactPointConsentToInsert.add(
                      	new ContactPointConsent(
                            Name = 'Newsletter-Subscription',
                            ContactPointId = account.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountId).Id).Id : allContactPointsByIndividualId.get(account.PersonIndividualId).Id,
                            PrivacyConsentStatus = 'OptIn',
                            EffectiveFrom = account.LastUpdateOptinEmailing__pc,
                            EffectiveTo = null,
                            CaptureDate = account.LastUpdateOptinEmailing__pc,
                            CaptureContactPointType = 'Web', //the value should be SFDC as mentioned in the doc but is not a pickval of CaptureContactPointType
                            CaptureSource = 'SFDC Migration Job',
                            DoubleConsentCaptureDate = null,
                            OptOutContactPointType__c = 'SFDC',
                            CustomContactPointType__c = 'SFDC',
                            AccountId__c = accountId
                           	)
                        );
               
           }
           //if ContactPointTypeConsent exist
           
           else if(effectiveFrom < lastUpdateOptinEmailing){
                        //optin True case
                        if(account.OptinEmailing__pc==true){
                            //update old one
                            //update contactPointTypeConsent
                            ContactPointTypeConsent contactPointTypeConsent = contactPointTypeConsentsByAccountId.get(accountId);
                            contactPointTypeConsent.EffectiveTo = account.LastUpdateOptinEmailing__pc;
                            contactPointTypeConsentToUpdate.add(contactPointTypeConsent);
                            //Update ContactPointConsent
                            if(contactPointConsentsByAccountId.containsKey(accountId)){
                           	ContactPointConsent contactPointConsent = contactPointConsentsByAccountId.get(accountId);
                           	contactPointConsent.EffectiveTo = account.LastUpdateOptinEmailing__pc;
                           	contactPointConsentToUpdate.add(contactPointConsent);
                            }
                           
                            //create new ContactPointTypeConsent
                            contactPointTypeConsentToInsert.add(
                                new ContactPointTypeConsent (
                                    Name = 'Email Consent',
                                    PartyId = account.PersonIndividualId == null ? individualsToInsertByAccountId.get(accountId).Id : account.PersonIndividualId,
                                    ContactPointType = 'Email',
                                    PrivacyConsentStatus = 'OptIn',
                                    EffectiveFrom = account.LastUpdateOptinEmailing__pc,
                                    EffectiveTo = null,
                                    CaptureDate = account.LastUpdateOptinEmailing__pc,
                                    CaptureContactPointType = 'Web',
                                    CaptureSource = 'SFDC Migration Job',
                                    DoubleConsentCaptureDate = null,
                                    OptOutContactPointType__c = 'SFDC',
                            		CustomContactPointType__c = 'SFDC',
                                    AccountId__c = accountId
                                )
                            );
                            //create new ContactPointConsent
                            contactPointConsentToInsert.add(
                                new ContactPointConsent(
                                    Name = 'Newsletter-Subscription',
                                    ContactPointId = account.PersonIndividualId == null ? allContactPointsByIndividualId.get(individualsToInsertByAccountId.get(accountId).Id).Id : allContactPointsByIndividualId.get(account.PersonIndividualId).Id,
                                    PrivacyConsentStatus = 'OptIn',
                                    EffectiveFrom = account.LastUpdateOptinEmailing__pc,
                                    EffectiveTo = null,
                                    CaptureDate = account.LastUpdateOptinEmailing__pc,
                                    CaptureContactPointType = 'Web', //the value should be SFDC as mentioned in the doc but is not a pickval of CaptureContactPointType
                                    CaptureSource = 'SFDC Migration Job',
                                    DoubleConsentCaptureDate = null,
                                    OptOutContactPointType__c = 'SFDC',
                            		CustomContactPointType__c = 'SFDC',
                                    AccountId__c = accountId
                                )
                            );
                        }
            
                       ////optin False case
                       else{
                                ContactPointTypeConsent contactPointTypeConsent = contactPointTypeConsentsByAccountId.get(accountId);
                                contactPointTypeConsent.EffectiveTo = account.LastUpdateOptinEmailing__pc;
                                contactPointTypeConsent.PrivacyConsentStatus = 'OptOut';
                                contactPointTypeConsentToUpdate.add(contactPointTypeConsent);
                           		//update contactPointConsent
                           		if(contactPointConsentsByAccountId.containsKey(accountId)){
                           		ContactPointConsent contactPointConsent = contactPointConsentsByAccountId.get(accountId);
                                contactPointConsent.EffectiveTo = account.LastUpdateOptinEmailing__pc;
                                contactPointConsent.PrivacyConsentStatus = 'OptOut';
                                contactPointConsentToUpdate.add(contactPointConsent);
                                }
                             }
       	
                    }
               
           
       }
       
        if(!contactPointTypeConsentToUpdate.isEmpty()) {
            update contactPointTypeConsentToUpdate;
        }
        if(!contactPointConsentToUpdate.isEmpty()){
            update contactPointConsentToUpdate;
        }
        if(!contactPointTypeConsentToInsert.isEmpty()){
            insert contactPointTypeConsentToInsert;
        } 
        if(!contactPointConsentToInsert.isEmpty()){
            insert contactPointConsentToInsert;
        }
        
	}
}