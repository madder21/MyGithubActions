public class CLT_TestDateFactory {
    public static User createTestUser(String profileName, String langCode, Boolean toInsert) {
        String profileId = [SELECT Id FROM Profile WHERE name =: profileName].Id;
        String username = Datetime.now().getTime()+'testUser@chaumet.com';
        User u = new User(
            Username = username,
            LastName = 'test',
            FirstName = 'test',
            Email = username,
            Alias = 'TST',
            CommunityNickname = username.substring(0, username.indexOf('@')),
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US',
            EmailEncodingKey='ISO-8859-1',
            ProfileId = profileId,
            LanguageLocaleKey = langCode,
            isActive=true
        );

        if(toInsert) {
            insert u;
        }

        return u;
    }

    public static User createTestUser(String profileName, Boolean toInsert) {
        return CLT_TestDateFactory.createTestUser(profileName, 'en_US', toInsert);  
    }

    public static User createTestUser() {
        return CLT_TestDateFactory.createTestUser('System Administrator', true);    
    }

    public static Task createTask(String ownerId, Boolean toInsert) {
        Task t = new Task(
            Subject = 'test Subject',
            OwnerId = ownerId,
            Priority = 'Normal',
            Status = 'Open'
        );

        if(toInsert) {
            insert t;
        }

        return t;
    }
}