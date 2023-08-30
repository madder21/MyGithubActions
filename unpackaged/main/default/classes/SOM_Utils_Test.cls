@isTest
public with sharing class SOM_Utils_Test {
    
    @isTest
    public static void getCountryKeyValueMap() {
        Map<String,String> getCountryKeyValueMap = SOM_Utils.getCountryKeyValueMap('OrderSummary','OrderNumber');
        System.assertEquals(new List<String>(),getCountryKeyValueMap.values());
    }
    
    @isTest
    public static void getTotalFormattedTest() {
        String AmountsFormat1 = '###.##0,00';
        String AmountsFormat2 = '###,##0.00';
        String Resultat1 = SOM_Utils.getTotalFormatted(100000.10,AmountsFormat1);
        String Resultat2 = SOM_Utils.getTotalFormatted(100000.10,AmountsFormat2);
        System.assertEquals(Resultat1,'100.000,10');
        System.assertEquals(Resultat2,'100,000.10');
    }
    
    @isTest
    public static void formatDecimalNumberTest() {
        String AmountsFormat1 = '###.##0,00';
        String AmountsFormat2 = '###,##0.00';
        String Resultat1 = SOM_Utils.formatDecimalNumber(100000.10,AmountsFormat1);
        String Resultat2 = SOM_Utils.formatDecimalNumber(100000.10,AmountsFormat2);
        String Resultat3 = SOM_Utils.formatDecimalNumber(null,AmountsFormat1);
        String Resultat4 = SOM_Utils.formatDecimalNumber(null,AmountsFormat2);
        String Resultat5 = SOM_Utils.formatDecimalNumber(100000.10,'');
        System.assertEquals(Resultat1,'100.000,10');
        System.assertEquals(Resultat2,'100,000.10');
        System.assertEquals(Resultat3,'0,00');
        System.assertEquals(Resultat4,'0.00');
        System.assertEquals(Resultat5,'100000.10');
    }
}