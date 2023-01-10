@isTest
public class SOM_SerialNumbersValidation_Test {
    
    @isTest(seeAllData=true)
    public static void ValidateSerialNumbersTest() {
        SOM_SerialNumbersValidation.wr_SerialNumberQuantity SerNum = new SOM_SerialNumbersValidation.wr_SerialNumberQuantity();
        SOM_SerialNumbersValidation.wr_SerialNumberQuantity SerNum2 = new SOM_SerialNumbersValidation.wr_SerialNumberQuantity();
        List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity> ListSerNum = new List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity>();
        List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity> ListSerNum2 = new List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity>();
        SerNum.qty = 1;
        SerNum.serialNumbers = '111';
        SerNum2.qty = 2;
        SerNum2.serialNumbers = '111';
        //System.debug('SerNum.serialNumbers ' + SerNum.serialNumbers.size());
        ListSerNum.Add(SerNum);
        ListSerNum2.Add(SerNum2);
        Test.startTest();
        SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum);
        SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum2);
        Test.stopTest();
        System.assertNotEquals(Null,'');
    }
}