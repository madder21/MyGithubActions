@isTest
public with sharing class SFMCTest {
    @isTest
    static void testPerformUpdateSubStatus(){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a = new Account (FirstName = 'test1',LastName= 'test2', RecordTypeID=recordTypeId ); 
        insert a; 

        //Account a1 = [Select id, OptinEmailing__pc FROM Account Where Name = 'test1' Limit 1];
        a.FirstName = 'Test'; 
        a.OptinEmailing__pc = true;
        update a;
        List <String> listStirng = new List<String>(); 
        listStirng.add('a');
        Test.setMock(WebServiceMock.class, new SFMCCalloutMock());
        SFMCCallOut.calloutAllsubscriber(listStirng);


    }
    
}