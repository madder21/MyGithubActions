@isTest
private class HelloWorldTest {
    @isTest static void testSayHello() {
        String result = HelloWorld.sayHello();
        System.assertEquals('Bonjour Ulrich! Comment vas-tu Ulrich?', result, 'La méthode sayHello doit retourner "Bonjour Ulrich! Comment vas-tu Ulrich?"');
    }
}