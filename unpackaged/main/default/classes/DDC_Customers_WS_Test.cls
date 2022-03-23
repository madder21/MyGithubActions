@isTest
private with sharing class DDC_Customers_WS_Test {

    /*private static testMethod void test_Customer_GET() {
        Contact contact = new Contact(LastName = 'test');
        insert contact;

        Map<String,String> pathParameters = new Map<String,String>();

        // no customer id - return all
        DDC_Customers_WS ws = new DDC_Customers_WS();
        List<Map<String,Object>> result = (List<Map<String,Object>>) ws.executeGET(pathParameters, null);
        System.debug('result: ' + result);
        System.assert(!result.isEmpty(), '');
        
        // with customer id, return customer
        pathParameters.put('customerId', contact.Id);
        Map<String,Object> resultObj = (Map<String,Object>) ws.executeGET(pathParameters, null);
        System.assert(!resultObj.isEmpty());

        delete contact;
        try {
            resultObj = (Map<String,Object>) ws.executeGET(pathParameters, null);
        } catch(Exception ex) {
        }
    }*/

    private static testMethod void test_createCustomer() {

        List<User> users = [SELECT Id, StaffCode__c from User WHERE StaffCode__c = '2' LIMIT 1];
        if (users.isEmpty()) {
            User advisor = prepareUser();
            advisor.StaffCode__c = '2';
            insert advisor;
        }

        Store__c store = new Store__c(SourceStoreId__c = 'JP27');
        insert store;

        String customerJson = '{"title":"Mr.","firstName":"John","lastName":"Smith","alternateFirstName1":"John","alternateFirstName2":"גון","alternateLastName1":"Smith","alternateLastName2":"סמית","alternateFullName1":"John Smith","alternateFullName2":"גון סמית","birthDate":"1980-01-28T00:00:00.000Z","birthDateYear":"1980","birthDateMonth":"01","birthDateDay":"28","nationality":"FR","email":"test@test.net","mobilePhoneNumber":"+972523456789","homePhoneNumber":"+972523456789","address":{"fullStreetAddress":"Jaffa 20,20 apt.","streetAddress1":"Jaffa 20","streetAddress2":"20 apt.","city":"Jerusalem","postalCode":"34534","country":"IL"},"appsConsent":true,"emailConsent":true,"postConsent":false,"phoneConsent":true,"advisorCode":"2","storeCode":"JP27","preferredLanguage":"en","notes":"note 1 2 3","CustomerId":"D123456789","eReceipt":true, "gender":"M","signatureData":"test"}';
        Map<String,Object> customerObj = (Map<String,Object>) Json.deserializeUntyped(customerJson);
        System.debug('customerObj: ' + customerObj);

        DDC_Customers_WS ws = new DDC_Customers_WS();
        Map<String,Object> resultObj = (Map<String,Object>) ws.executePOST(null, null, customerObj);
        System.debug('resultObj: ' + resultObj);
        
        String customerId = (String) resultObj.get('id');
        System.assert(String.isNotEmpty(customerId), 'No customer id in response.');

        List<Account> customers = [SELECT Id, FirstName, LastName, Salutation, Title__pc, 
            Birthday__pc, Birthmonth__pc, Birthyear__pc, Nationality__pc,
            EReceipt__pc, PersonEmail, Phone, Phone2__pc, 
            OptinCalling__pc, OptinEmailing__pc, OptinInstantMessaging__pc, OptinMailing__pc,
            SecondAlphabetFirstname__pc, SecondAlphabetLastname__pc, SecondName__pc, Gender__pc,
            ClientAdvisor__pr.StaffCode__c, OriginStore__pr.SourceStoreId__c, Language__pc,
            IsPersonAccount,
            (SELECT Id, Address1__c, Address2__c, City__c, Country__c, PostalCode__c FROM ClientAddresses__r),
            (SELECT Id, ContentDocumentId FROM ContentDocumentLinks)
            FROM Account
            WHERE Id = :customerId];
        System.assert(!customers.isEmpty(), 'Customer has not been created!');
        Account customer = customers[0];
        System.assertEquals('John', customer.FirstName);
        System.assertEquals('Smith', customer.LastName);
        System.assertEquals('Mr.', customer.Salutation);
        System.assertEquals('28', customer.Birthday__pc);
        System.assertEquals('01', customer.Birthmonth__pc);
        System.assertEquals('1980', customer.Birthyear__pc);
        System.assertEquals('FR', customer.Nationality__pc);
        System.assertEquals(true, customer.EReceipt__pc);
        System.assertEquals('test@test.net', customer.PersonEmail);
        System.assertEquals('+972523456789', customer.Phone);
        System.assertEquals('+972523456789', customer.Phone2__pc);
        System.assertEquals(true, customer.OptinCalling__pc);
        System.assertEquals(true, customer.OptinEmailing__pc);
        System.assertEquals(true, customer.OptinInstantMessaging__pc);
        System.assertEquals(false, customer.OptinMailing__pc);
        System.assertEquals('John', customer.SecondAlphabetFirstname__pc);
        System.assertEquals('Smith', customer.SecondAlphabetLastname__pc);
        //System.assertEquals('גון סמית', customer.SecondName__pc);
        System.assertEquals('M', customer.Gender__pc);
        System.assertEquals('2', customer.ClientAdvisor__pr.StaffCode__c);
        System.assertEquals('JP27', customer.OriginStore__pr.SourceStoreId__c);
        System.assertEquals('en', customer.Language__pc);
        System.assertEquals(true, customer.IsPersonAccount);

        List<ClientAddress__c> addresses = customer.ClientAddresses__r;
        System.assert(!addresses.isEmpty());
        ClientAddress__c address = addresses[0];
        System.assertEquals('Jaffa 20', address.Address1__c);
        System.assertEquals('20 apt.', address.Address2__c);
        System.assertEquals('Jerusalem', address.City__c);
        System.assertEquals('IL', address.Country__c);
        System.assertEquals('34534', address.PostalCode__c);

        System.assert(customer.ContentDocumentLinks != null);
        System.assert(!customer.ContentDocumentLinks.isEmpty(), 'No attachment');
        String contentDocumentId = customer.ContentDocumentLinks[0].contentDocumentId;
        List<ContentVersion> contentVersions = [SELECT VersionData FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId];
        String content = contentVersions[0].VersionData.toString();
        System.assertEquals('test', content);
    }

    private static User prepareUser() {
        List<Profile> profiles = [select Id from Profile];
        User user = new User(
            Username = 'test4564566@test.com',
            LastName = 'test',
            Email = 'test@test.com',
            Alias = 'test',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = profiles[0].Id,
            LanguageLocaleKey = 'en_US'
        );
        return user;
    }
}