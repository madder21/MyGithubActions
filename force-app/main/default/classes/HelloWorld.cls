public class HelloWorld {
    public static String sayHello() {
        for(Integer i=0;i<2; i++) {
            List<Contact> contactList = [SELECT Id FROM Contact LIMIT 100];
        }
        return 'Bonjour Ulrich';
    }
}