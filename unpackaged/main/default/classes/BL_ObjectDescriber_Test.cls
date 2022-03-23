@IsTest
public with sharing class BL_ObjectDescriber_Test {
    private static testMethod void test_getFieldType() {
        String fieldType = BL_ObjectDescriber.getFieldType('Account', 'Name');
        System.assertEquals('STRING', fieldType);
    }
}