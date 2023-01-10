/*
@author : Abdelaaziz IDAOUMAHMOUD
Created date : 10/06/2022
Description : this class is used in B2CProcess Flow to fill the value of Maillingcountry field by the country__c 

*/
public class CountryNameManager {
        
@InvocableMethod(label='Get Country Name' description='Get the country Name from the Code iso 2')
public static List<String> getCountryName(List<String> isoCode)
{
    Map<String,String> options = new Map<String,String>();
    Schema.DescribeFieldResult fieldResult = Contact.CountryIso2__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : ple)
    {
        options.put(f.getValue(),f.getLabel());
        
            
    }
    List<String> returnvalues=new List<String>();
    returnvalues.add(options.get(isoCode[0]));
    return returnvalues;
}
}