/*
@author : Abdelaaziz IDAOUMAHMOUD
Created date : 10/06/2022
Class: CountryNameManager

*/
@isTest
public class CountryNameManagerTest {

 @isTest
 public static void testcountryName(){
 	Test.startTest();
 	List<String> countries=new List<String>();
	countries.add('FR');
	List<String> countryName=CountryNameManager.getCountryName(countries);
 	Test.stopTest();
      System.assertEquals('France', countryName[0]);

    } 
}