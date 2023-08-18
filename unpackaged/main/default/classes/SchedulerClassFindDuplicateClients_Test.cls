/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts comprehensive testing for the class  SchedulerClassFindDuplicateClients
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|22062023			|.PLM		|.					|.
*/

@Istest
public with sharing class SchedulerClassFindDuplicateClients_Test {

    @TestSetup
    static void setup(){
		
        //Create CommSubscriptionChannelType
        List<CommSubscriptionChannelType> channelTypeTestDataList = ConsentManagement_TestDataFactory.createCommSubscriptionChannelType();
        
        String lname;
        String fname;
        String addressEmail;
        String mobilePhone;

        Contact con;
        Contact conUpdate;
        
        Account acc;
        Account accUpdate;

        List<Contact> conListWithEmail = new List<Contact>();
        List<Contact> conListWithEmailUpdate = new List<Contact>();
        
        List<Account> accListWithEmail = new List<Account>();
        List<Account> accListWithEmailUpdate = new List<Account>();

        List<Contact> conListWithPhone = new List<Contact>();
        List<Contact> conListWithPhoneUpdate = new List<Contact>();

        List<Contact> conListWithEmailAndPhone = new List<Contact>();
        List<Contact> conListWithEmailAndPhoneUpdate = new List<Contact>();

        List<DuplicateRecordItem> duplicateRecordListEmail = new List<DuplicateRecordItem>();
        List<DuplicateRecordItem> duplicateRecordListPhone = new List<DuplicateRecordItem>();
        List<DuplicateRecordItem> duplicateRecordListEmailandPhone = new List<DuplicateRecordItem>();
        DuplicateRecordItem duplicateRecord;

        List<DuplicateRecordSet> dupRSListEmail = new List<DuplicateRecordSet>();
        List<DuplicateRecordSet> dupRSListPhone = new List<DuplicateRecordSet>();
        List<DuplicateRecordSet> dupRSListEmailPhone = new List<DuplicateRecordSet>();
        DuplicateRecordSet dupRS;

        DuplicateRule dupRuleByEmail = [SELECT id FROM DuplicateRule WHERE DeveloperName = 'Duplicate_Contact_By_Email'][0];
        DuplicateRule dupRuleByPhone= [SELECT id FROM DuplicateRule WHERE DeveloperName = 'Duplicate_Contact_By_Phone'][0];

        //-----------------------------------------------Email-----------------------------------------------
        //Create 10 Contacts and 10 accounts for testing Duplicate Rule by Email
        for (Integer i=0; i<10; i++) {

            lname = 'LastName.by.email ' + i;  
            fname = 'FirstName.by.email ' + i;  
            addressEmail = 'test.by.email' + i +'@mail.com';  
            acc = new Account(LastName=lname, FirstName=fname, personEmail=addressEmail);
            accListWithEmail.add(acc);
        }
        insert accListWithEmail;

        //Create duplicate contacts by Email
        for (Integer i=5; i<10; i++) {

            lname = 'LastName.by.email ' + (i-5);  
            fname = 'FirstName.by.email ' + (i-5);  
            addressEmail = 'test.by.email' + (i-5) +'@mail.com'; 
            accUpdate = new Account(Id = accListWithEmail[i].Id, LastName=lname, FirstName=fname, personEmail=addressEmail);
            accListWithEmailUpdate.add(accUpdate);

        }
        update accListWithEmailUpdate;

        //Create 5 DuplicateRecordSet by using Duplicate rule by email, each one contain 2 duplicate contact
        for (Integer i=0; i<5; i++) {
            dupRS = new DuplicateRecordSet();
            dupRS.DuplicateRuleId = dupRuleByEmail.Id;
            dupRSListEmail.add(dupRS);
        }
        insert dupRSListEmail;
        

        //Create 10 DuplicateRecordItem for each contact
        for (Integer i=0; i<5; i++) {

            duplicateRecord = new DuplicateRecordItem();
            duplicateRecord.DuplicateRecordSetId = dupRSListEmail[i].Id;
            duplicateRecord.RecordId = accListWithEmail[i].Id;
            duplicateRecordListEmail.add(duplicateRecord);

            duplicateRecord = new DuplicateRecordItem();
            duplicateRecord.DuplicateRecordSetId = dupRSListEmail[i].Id;
            duplicateRecord.RecordId = accListWithEmail[i+5].Id;
            duplicateRecordListEmail.add(duplicateRecord);
        }
        insert duplicateRecordListEmail;
        //---------------------------------------------------------------------------------------------------



        //-----------------------------------------------Phone-----------------------------------------------
        //Create 10 Contacts for testing Duplicate Rule by Phone
        for (Integer i=0; i<10; i++) {

            lname = 'LastName.by.phone ' + i;  
            fname = 'FirstName.by.phone ' + i;  
            mobilePhone = '+33 12345678' + i;  
            con = new Contact(LastName=lname, FirstName=fname, Phone=mobilePhone);
            conListWithPhone.add(con);
        }
        insert conListWithPhone;

        //Create duplicate contacts by Phone
        for (Integer i=5; i<10; i++) {

            lname = 'LastName.by.phone ' + (i-5);  
            fname = 'FirstName.by.phone ' + (i-5);  
            mobilePhone = '+33 12345678' + (i-5);  
            conUpdate = new Contact(Id = conListWithPhone[i].Id, LastName=lname, FirstName=fname, Phone=mobilePhone);
            conListWithPhoneUpdate.add(conUpdate);

        }
        update conListWithPhoneUpdate;

        //Create 5 DuplicateRecordSet by using Duplicate rule by phone, each one contain 2 duplicate contact
        for (Integer i=0; i<5; i++) {
            dupRS = new DuplicateRecordSet();
            dupRS.DuplicateRuleId = dupRuleByPhone.Id;
            dupRSListPhone.add(dupRS);
        }
        insert dupRSListPhone;

        //Create 10 DuplicateRecordItem for each contact
        for (Integer i=0; i<5; i++) {

            duplicateRecord = new DuplicateRecordItem();
            duplicateRecord.DuplicateRecordSetId = dupRSListPhone[i].Id;
            duplicateRecord.RecordId = conListWithPhone[i].Id;
            duplicateRecordListPhone.add(duplicateRecord);

            duplicateRecord = new DuplicateRecordItem();
            duplicateRecord.DuplicateRecordSetId = dupRSListPhone[i].Id;
            duplicateRecord.RecordId = conListWithPhone[i+5].Id;
            duplicateRecordListPhone.add(duplicateRecord);
        }
        insert duplicateRecordListPhone;
        //---------------------------------------------------------------------------------------------------



        //-----------------------------------------------Email & Phone---------------------------------------
        //Contacts to run Duplicate Rule by Email & Phone
        for (Integer i=0; i<10; i++) {

            //Contacts to run Duplicate Rule by Email
            lname = 'LastName.by.email.phone ' + i;  
            fname = 'FirstName.by.email.phone ' + i;  
            addressEmail = 'test.by.email.phone' + i +'@mail.com';   
            mobilePhone = '+33 12345678' + i;  
            con = new Contact(LastName=lname, FirstName=fname, Email=addressEmail, Phone=mobilePhone);
            conListWithEmailAndPhone.add(con);
        }
        insert conListWithEmailAndPhone;

         //Create duplicate contacts by Phone
         for (Integer i=5; i<10; i++) {

            lname = 'LastName.by.email.phone ' + (i-5);  
            fname = 'FirstName.by.email.phone ' + (i-5);  
            addressEmail = 'test.by.email.phone' + (i-5) +'@mail.com';
            mobilePhone = '+33 12345678' + (i-5);  
            conUpdate = new Contact(Id = conListWithEmailAndPhone[i].Id, LastName=lname, FirstName=fname, Email=addressEmail, Phone=mobilePhone);
            conListWithEmailAndPhoneUpdate.add(conUpdate);

        }
        update conListWithEmailAndPhoneUpdate;

        //Create 5 DuplicateRecordSet by using Duplicate rule by email, each one contain 2 duplicate contact
        for (Integer i=0; i<5; i++) {
            dupRS = new DuplicateRecordSet();
            dupRS.DuplicateRuleId = dupRuleByEmail.Id;
            dupRSListEmailPhone.add(dupRS);
        }
        insert dupRSListEmailPhone;

        //Create 10 DuplicateRecordItem for each contact
        for (Integer i=0; i<5; i++) {

            duplicateRecord = new DuplicateRecordItem();
            duplicateRecord.DuplicateRecordSetId = dupRSListEmailPhone[i].Id;
            duplicateRecord.RecordId = conListWithEmailAndPhone[i].Id;
            duplicateRecordListEmailandPhone.add(duplicateRecord);

            duplicateRecord = new DuplicateRecordItem();
            duplicateRecord.DuplicateRecordSetId = dupRSListEmailPhone[i].Id;
            duplicateRecord.RecordId = conListWithEmailAndPhone[i+5].Id;
            duplicateRecordListEmailandPhone.add(duplicateRecord);
        }
        insert duplicateRecordListEmailandPhone;
        //---------------------------------------------------------------------------------------------------

        System.debug(logginglevel.debug, 'DuplicateRecordItem.size()='+[SELECT COUNT() FROM DuplicateRecordItem]);
    }
    
    @Istest
    static void test() {

        Test.startTest();

        SchedulableContext sc = null;
        SchedulerClassFindDuplicateClients scheduleBatch = new SchedulerClassFindDuplicateClients();
        scheduleBatch.execute(sc);
        Test.stopTest();
        System.assertEquals(5, [SELECT COUNT() FROM Account WHERE personEmail != null AND Phone = null AND B2C_Date_Last_Modified__pc =: Date.today()], 'Not expected result for accounts with Email');
        System.assertEquals(5, [SELECT COUNT() FROM Contact WHERE Email = null AND Phone != null AND B2C_Date_Last_Modified__c =: Date.today()], 'Not expected result for Contact with phone');
        System.assertEquals(5, [SELECT COUNT() FROM Contact WHERE Email != null AND Phone != null AND B2C_Date_Last_Modified__c =: Date.today()], 'Not expected result for Contact with email & phone');

    }
}