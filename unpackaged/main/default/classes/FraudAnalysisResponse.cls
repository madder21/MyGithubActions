global with sharing class FraudAnalysisResponse {
    @AuraEnabled
    public String orderSummaryNumber;
    @AuraEnabled
    public String orderStatus;
    @AuraEnabled
    public String errorMessage;
    @AuraEnabled
    public Boolean isSuccess;
}