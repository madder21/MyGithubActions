@isTest
private with sharing class DDC_Titles_WS_Test {

    private static testMethod void test_DDC_Titles_WS() {
        DDC_Titles_WS ws = new DDC_Titles_WS();
        List<BL_ObjectDescriber.Option> titles = (List<BL_ObjectDescriber.Option>) ws.executeGET(null, null);
    }
}