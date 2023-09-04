/**
 * @author AbdelKhalek Saidi
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts comprehensive testing for the class ConvertStringToStringCollection
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
*/
@isTest
public with sharing class ConvertStringToStringCollection_TEST{


    @isTest
    public static void canConvertStringWithDelimiter(){
        //String testString = 'foo,bar,baz';
        ConvertStringToStringCollection.Request testReq = new ConvertStringToStringCollection.Request();
        testReq.csvString = 'foo;bar;baz';
        testReq.delimiter = ';';

        List<ConvertStringToStringCollection.Request> testReqList = new List<ConvertStringToStringCollection.Request>();
        testReqList.add(testReq);

        List<ConvertStringToStringCollection.Response> testResponseList = ConvertStringToStringCollection.execute(testReqList);
     
        System.assertEquals(testResponseList[0].stringCollection[0], 'foo');
    }
}