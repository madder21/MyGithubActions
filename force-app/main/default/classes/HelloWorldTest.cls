@isTest
private class HelloWorldTest {
    @isTest static void testSayHello() {
        String result = HelloWorld.sayHello();
        System.assertEquals('Bonjour', result, 'La méthode sayHello doit retourner "Bonjour"');
    }
}