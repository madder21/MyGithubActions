@isTest
public with sharing class SOM_FlowUtils_UuidGenerator_Test {

    @isTest
    public static void UuidGenerator_Test() {
        List<String> listeInputs = new List<String>{'a','b'};
        List<SOM_FlowUtils_UuidGenerator.UuidGeneratorResponse> lUuid = SOM_FlowUtils_UuidGenerator.generateUuid(listeInputs);
        System.assertEquals(lUuid.size(),2);

    }
}