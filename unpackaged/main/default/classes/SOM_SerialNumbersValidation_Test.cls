@isTest
public class SOM_SerialNumbersValidation_Test {
    
    @isTest(seeAllData=true)
    public static void ValidateSerialNumbersTest() {
        SOM_SerialNumbersValidation.wr_SerialNumberQuantity SerNum = new SOM_SerialNumbersValidation.wr_SerialNumberQuantity();
        SOM_SerialNumbersValidation.wr_SerialNumberQuantity SerNum2 = new SOM_SerialNumbersValidation.wr_SerialNumberQuantity();
        SOM_SerialNumbersValidation.wr_SerialNumberQuantity SerNum3 = new SOM_SerialNumbersValidation.wr_SerialNumberQuantity();
        SOM_SerialNumbersValidation.wr_SerialNumberQuantity SerNum4 = new SOM_SerialNumbersValidation.wr_SerialNumberQuantity();
        List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity> ListSerNum = new List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity>();
        List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity> ListSerNum2 = new List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity>();
        List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity> ListSerNum3 = new List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity>();
        List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity> ListSerNum4 = new List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity>();
        SerNum.qty = 2;
        SerNum.serialNumbers = '111';
        SerNum2.qty = 1;
        SerNum2.serialNumbers = '11111111111111111';
        SerNum3.qty = 2;
        SerNum3.serialNumbers = '111;111';
        SerNum4.qty = 2;
        SerNum4.serialNumbers = '111;1111';
        ListSerNum.Add(SerNum);
        ListSerNum2.Add(SerNum2);
        ListSerNum3.Add(SerNum3);
        ListSerNum4.Add(SerNum4);
        Test.startTest();
        SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum);
        SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum2);
        SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum3);
        SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum4);
        Test.stopTest();
        List<String> errorMessage = new List<String>();
        List<String> errorMessage1 = new List<String>();
        List<String> errorMessage2 = new List<String>();
        errorMessage.add('You must enter numbers of serial numbers equals to quantity and separated by ";".');
        errorMessage1.add('You must not enter duplicated serial numbers.');
        errorMessage2.add('Accepted Format is 17 digits (ex: xxxxxxxxxxxxxxxxx;xxxxxxxxxxxxxxxxx).');  
        
        System.assertEquals(SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum),errorMessage, 'errorMessage Generated');
        System.assertNotEquals(SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum2),errorMessage , 'errorMessage NOT Generated' );
        System.assertEquals(SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum3),errorMessage1 , 'errorMessage Generated');
        System.assertEquals(SOM_SerialNumbersValidation.ValidateSerialNumbers(ListSerNum4),errorMessage2 , 'errorMessage Generated');
    }
    
    @isTest(seeAllData=true)
    public static void wr_SerialNumberQuantityTest() {
        Test.startTest();
        SOM_SerialNumbersValidation.wr_SerialNumberQuantity SerNum = new SOM_SerialNumbersValidation.wr_SerialNumberQuantity();
        List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity> ListSerNum = new List<SOM_SerialNumbersValidation.wr_SerialNumberQuantity>();
        SerNum.qty = 2;
        SerNum.serialNumbers = '111';

        ListSerNum.Add(SerNum);
        Test.stopTest();
        
        System.assertEquals(ListSerNum.size(),1, 'SerialNumber Generated');
    }
        
}