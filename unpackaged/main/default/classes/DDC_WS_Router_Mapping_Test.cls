@isTest
private with sharing class DDC_WS_Router_Mapping_Test {
    @isTest
    private static void DDC_WS_Router_Mapping_Test() {
        DDC_WS_Router_Mapping ddcMapping = new DDC_WS_Router_Mapping();
        Map<String,String> routerMap = ddcMapping.getRoutes();
    }
}