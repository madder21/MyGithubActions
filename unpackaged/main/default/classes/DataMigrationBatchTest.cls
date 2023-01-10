/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-17-2021
 * @last modified by  : BADER EDDINE ELKHAL
**/
@isTest
private class DataMigrationBatchTest {
    public static boolean isTrue = false;
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Individual> individuals  = new List<Individual>();
        List<ContactPointEmail> contactPointEmails = new List<ContactPointEmail>();
        //insert 5 individualS
        for(Integer i=1;i<=10;i++){
            Individual individual = new Individual();
            individual.LastName='individual'+i;
            individuals.add(individual);
            
        }
        insert individuals;
        
        // insert 15 accounts
        for (Integer i=1;i<=20;i++) {
            Account account = new Account();
            account.LastName='Account'+i;
            account.PersonEmail='Account'+i+'@gmail.com';
            
            if(i<=5){
                account.PersonIndividualId=individuals.get(i-1).Id;
                account.LastUpdateOptinEmailing__pc=System.now().addDays(-i);
            	account.OptinEmailing__pc=true;
                
            }
            else if (i>5 && i<=10){
                account.PersonIndividualId=individuals.get(i-1).Id;
                account.LastUpdateOptinEmailing__pc=System.now();
            	account.OptinEmailing__pc=false;
            }
            else if(i>15){
                account.LastUpdateOptinEmailing__pc=System.now().addDays(-i);
            	account.OptinEmailing__pc=true;
                
            }
            else{
             	account.LastUpdateOptinEmailing__pc=System.now();
            	account.OptinEmailing__pc=false;
            }
            accounts.add(account);
            
            
            
        }
        insert accounts;
        //new contactPointEmails
        for(Integer i=1;i<=5;i++){
            ContactPointEmail con = new ContactPointEmail();
            con.ActiveFromDate =accounts.get(i-1).LastUpdateOptinEmailing__pc.Date();
            con.AccountId__c=accounts.get(i-1).Id;
            con.ParentId=accounts.get(i-1).PersonIndividualId;
            
            if(i>3){
                con.EmailAddress = 'conpointemail'+i+'@gmail.com';
                
            }
            else{
                con.EmailAddress = accounts.get(i-1).PersonEmail;
                con.ActiveToDate=System.Today().addDays(+10);
            }
            
            contactPointEmails.add(con);
        }
        insert contactPointEmails;
        
        ContactPointTypeConsent conpointtypecons1 = new ContactPointTypeConsent();
        conpointtypecons1.Name = 'EmailConsent1';
        conpointtypecons1.PartyId = accounts.get(2).PersonIndividualId;
        conpointtypecons1.ContactPointType = 'Email';
        conpointtypecons1.PrivacyConsentStatus = 'OptIn';
        conpointtypecons1.EffectiveFrom = System.now().addDays(-10);
        conpointtypecons1.EffectiveTo = null;
        conpointtypecons1.CaptureDate = System.now().addDays(-10);
        conpointtypecons1.CaptureContactPointType = 'Web';
        conpointtypecons1.CaptureSource = 'Test source';
        conpointtypecons1.DoubleConsentCaptureDate = null;
        conpointtypecons1.AccountId__c = accounts.get(2).Id;
        insert conpointtypecons1;
        
        ContactPointTypeConsent conpointtypecons2 = new ContactPointTypeConsent();
        conpointtypecons2.Name = 'EmailConsent2';
        conpointtypecons2.PartyId = accounts.get(3).PersonIndividualId;
        conpointtypecons2.ContactPointType = 'Email';
        conpointtypecons2.PrivacyConsentStatus = 'OptIn';
        conpointtypecons2.EffectiveFrom = System.now().addDays(-20);
        conpointtypecons2.EffectiveTo = null;
        conpointtypecons2.CaptureDate = System.now().addDays(-20);
        conpointtypecons2.CaptureContactPointType = 'Web';
        conpointtypecons2.CaptureSource = 'Test source';
        conpointtypecons2.DoubleConsentCaptureDate = null;
        conpointtypecons2.AccountId__c = accounts.get(3).Id;
        insert conpointtypecons2;
        
        ContactPointTypeConsent conpointtypecons3 = new ContactPointTypeConsent();
        conpointtypecons3.Name = 'EmailConsent3';
        conpointtypecons3.PartyId = accounts.get(8).PersonIndividualId;
        conpointtypecons3.ContactPointType = 'Email';
        conpointtypecons3.PrivacyConsentStatus = 'OptIn';
        conpointtypecons3.EffectiveFrom = accounts.get(8).LastUpdateOptinEmailing__pc.Date();
        conpointtypecons3.EffectiveTo = null;
        conpointtypecons3.CaptureDate = accounts.get(8).LastUpdateOptinEmailing__pc.Date();
        conpointtypecons3.CaptureContactPointType = 'Web';
        conpointtypecons3.CaptureSource = 'Test source';
        conpointtypecons3.DoubleConsentCaptureDate = null;
        conpointtypecons3.AccountId__c = accounts.get(8).Id;
        insert conpointtypecons3;
        
        
    }
    @isTest static void testFirstRun() {
        DataMigrationBatchTest.setup();
        DataMigrationBatchTest.isTrue= true;
        ContactPointTypeConsent cons1 = [SELECT Id, AccountId__c, EffectiveFrom, EffectiveTo, ContactPointType 
                                                                 	FROM ContactPointTypeConsent 
                                                                 	WHERE Name = :'EmailConsent1' LIMIT 1];
        System.debug('Id cons before'+cons1.Id);
        Id idacc= cons1.AccountId__c;
        Account account = [SELECT Id,LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, PersonEmail
                          FROM Account
                          WHERE Id = :idacc];
        
        System.debug('Id account before'+account.Id +' ' + cons1.AccountId__c);
        Test.startTest();
        DataMigrationBatch b = new DataMigrationBatch(true,null);
		Id add = Database.executeBatch(b);
        Test.stopTest();
        List<ContactPointTypeConsent> listConsPoints = [SELECT Id, AccountId__c, EffectiveFrom, EffectiveTo, ContactPointType 
                                                                 	FROM ContactPointTypeConsent 
                                                                 	WHERE AccountId__c = :idacc];

        System.debug('listConsPoints size '+listConsPoints.size());
        System.assertEquals(2, listConsPoints.size());
        for(ContactPointTypeConsent consp : listConsPoints){
            if(consp.Id == cons1.Id){
                System.debug(account.LastUpdateOptinEmailing__pc+' AND '+consp.EffectiveTo);
        		System.assertEquals(account.LastUpdateOptinEmailing__pc, consp.EffectiveTo);
            }
        }
        
        
        System.debug(account.LastUpdateOptinEmailing__pc+' AND '+listConsPoints.get(1).EffectiveFrom);
        System.assertEquals(account.LastUpdateOptinEmailing__pc, listConsPoints.get(1).EffectiveFrom);
    }  
    @isTest static void testScondRun() {
        //DataMigrationBatchTest.setup();
        if(DataMigrationBatchTest.isTrue==false){
            DataMigrationBatchTest.setup();
        }
       
        Test.startTest();
        DataMigrationBatch bat = new DataMigrationBatch(false,null);
		Id idbatch = Database.executeBatch(bat);
        Test.stopTest();
        List<ContactPointTypeConsent> listConsPoints2 = [SELECT Id, AccountId__c, PrivacyConsentStatus, EffectiveFrom, EffectiveTo, ContactPointType 
                                                                 	FROM ContactPointTypeConsent 
                                                                 	WHERE PrivacyConsentStatus = 'OptOut'];
        
		ContactPointTypeConsent consTst = [SELECT Id, AccountId__c, PrivacyConsentStatus, EffectiveFrom, EffectiveTo, ContactPointType 
                                                                 	FROM ContactPointTypeConsent 
                                                                 	WHERE Name = :'EmailConsent3' LIMIT 1];
        
        System.assertEquals(consTst.PrivacyConsentStatus, 'OptOut');
        System.debug('new list size '+listConsPoints2.size());
        System.assertEquals(false, listConsPoints2.isEmpty());
        
        
    }
    @isTest static void testRegularRun() {
        //DataMigrationBatchTest.setup();
        if(DataMigrationBatchTest.isTrue==false){
            DataMigrationBatchTest.setup();
        }
       
        DateTime dt = System.now().addDays(-7);
        Test.startTest();
        DataMigrationBatch batchReg = new DataMigrationBatch(false,dt);
		Id idB = Database.executeBatch(batchReg);
        Test.stopTest();
        
        List<ContactPointConsent> listpoinytCons = [SELECT Id, Name FROM ContactPointConsent 
                                                    WHERE Name = 'Newsletter-Subscription' AND PrivacyConsentStatus = 'OptIn'];
        
        System.assertEquals(false, listpoinytCons.isEmpty());
        
        
    }
 }