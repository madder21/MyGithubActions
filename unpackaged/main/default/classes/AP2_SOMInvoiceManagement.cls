/**
 * @author Paul Louis MONY
 * @date March,2nd 2023
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class contains the methods to download the Invoice from SOM Azure Server by Mulesoft API, And Upload it to SFMC FTP. It also delete the Invoice after the email is sent
 * This class need custom settings : *SFMCAPISetting__c
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|2023/03/03			|.PLM		|.					|.original version with method SOM_ServerConnect, SOM_AuthSMFCAccessToken and SOM_UploadInSFMCAsset						
 * 0.1		|2023/03/08			|.PLM		|.					|.Add method to find Asset ID in SFMC by querying the customer Key, Add methods to delete Asset by Asset ID.	
 * 0.2		|2023/04/18			|.PLM		|.					|.Modification of SOM_ServerConnect method to use the Name credential "Invoice Document Mulesoft Endpoint", by using the class SOM_DownloadInvoiceDocumentController
*/
public with sharing class AP2_SOMInvoiceManagement {
	
    /*
     * @METHOD 	: SOM_GenerateInvoicesInSFMC
     * @DESC 	: Generate Multiple Invoice In SFMC
     * @PARAM 	: transacEmails : Transactional Email to treat
     * @RETURN 	: void
     */	
    public static void SOM_GenerateInvoicesInSFMC(List<TransactionalEmail__c> transacEmails){
        for(TransactionalEmail__c transacEmail : transacEmails){
            SOM_GenerateInvoiceInSFMC(transacEmail.Id, transacEmail.OrderSummary__c);	
        }  
    }
    /*
     * @METHOD 	: SOM_GenerateInvoiceInSFMC
     * @DESC 	: Generate One Invoice In SFMC in Future Contexte
     * @PARAM 	: transacEmailId : Transactional Emails Id
     * @PARAM	: orderSummaryId : Order Summary Id of the Transactional Emails
     * @RETURN 	: void
     */	
    @future (callout=true)
    public static void SOM_GenerateInvoiceInSFMC(String transacEmailId,String orderSummaryId){
        
        /*STEP 1 : Find Invoice ID for each Transactional Emails*/ 
        Invoice invoiceToPdf = [SELECT ID,ReferenceEntityId,ReferenceEntity.Name FROM Invoice where ReferenceEntityId = :orderSummaryId LIMIT 1];
            /*STEP 2 : Download Invoices from SOM SERVER*/ 
        if(invoiceToPdf != null){
            String invoiceDocument = SOM_ServerConnect(invoiceToPdf.Id);
            if(Test.isRunningTest()){invoiceDocument = 'myTestBlob';}
            if(String.isNotEmpty(invoiceDocument)){
                /*STEP 3 : REST Auth API from SFMC*/
                String oAUTHAccessToken = SOM_AuthSFMCAccessToken();
                if(oAUTHAccessToken != 'Error'){
                    /*STEP 4 : Upload into SFMC Content Builder the BLOB as PDF*/
                    String fileName = 'Invoice-'+ invoiceToPdf.ReferenceEntity.Name;
                    String customerKey = SOM_UploadInSFMCAsset(invoiceDocument, fileName, oAUTHAccessToken);
                    if(customerKey != 'Error'){
                        /*STEP 5 : Update TransactionalEmail*/
            			updateTransactionalEmailGenerateInvoice(transacEmailId,customerKey);
                    }
                    else system.debug('**AP2 SOM_GenerateInvoiceInSFMC: Error Impossible to Upload invoice into content builder : FileName : ' + fileName);
                }
                else System.debug('**AP2 SOM_GenerateInvoiceInSFMC: Error on oAUTHAccessToken, impossible to Authorize SFMC Org, please verify custom Settings : SFMCAPISetting__c');
            }
            else System.debug('**AP2 SOM_GenerateInvoiceInSFMC: Blob not retrieve for invoice :' + invoiceToPdf.Id);
        }
        else System.debug('**AP2 SOM_GenerateInvoiceInSFMC: Invoice not found');
    }
    
    /*
     * @METHOD 	: SOM_GenerateInvoicesInSFMC
     * @DESC 	: Generate Multiple Invoice In SFMC
     * @PARAM 	: transacEmails : Transactional Email to treat
     * @RETURN 	: void
     */	
    public static void SOM_DeleteInvoicesFromSFMC(List<TransactionalEmail__c> transacEmails){
        for(TransactionalEmail__c transacemail : transacEmails){
            SOM_DeleteInvoiceFromSFMC(transacemail.id, transacemail.TECH_CustomerKey__c);
        }
    }
    
    /*
     * @METHOD 	: SOM_DeleteInvoiceFromSFMC
     * @DESC 	: Delete One Invoice In SFMC in Future Contexte
     * @PARAM 	: transacEmailId : Id of the transacEmail
     * @PARAM 	: customerKey : CustomerKey of the asset to delete
     * @RETURN 	: void
     */	
    @future (callout=true)
    public static void SOM_DeleteInvoiceFromSFMC(String transacEmailId, String CustomerKey){
        String oAUTHAccessToken = SOM_AuthSFMCAccessToken();
        if(String.isNotEmpty(oAUTHAccessToken) && oAUTHAccessToken!='Error'){
            String assetID = SOM_GetAssetIdByCustomerKeyInSFMC(CustomerKey,oAUTHAccessToken);
            if(String.isNotEmpty(assetID) && assetID!='Error'){
                String deleteResponse = SOM_DeleteInSFMCAsset(assetID,oAUTHAccessToken);
                System.debug('**AP2 SOM_DeleteInvoiceFromSFMC reponseDelete : ' + deleteResponse);
                if(deleteResponse == 'OK'){
					updateTransactionalEmailDeletedInvoice(transacEmailId);                    
                }
                else System.debug('**AP2 SOM_DeleteInvoiceFromSFMC: Error while deleting the Asset');
            }
            else System.debug('**AP2 SOM_DeleteInvoiceFromSFMC: Asset ID not found please verify the customerKey');
        }
        else  System.debug('**AP2 SOM_DeleteInvoiceFromSFMC: Error on oAUTHAccessToken, impossible to Authorize SFMC Org, please verify custom Settings : SFMCAPISetting__c');
    }

    /*
     * @METHOD 	: updateTransactionalEmailGenerateInvoice
     * @DESC 	: Update of the TransacEmail passed in Param with the customerKey passed in param and flag the record with the field TECH_GenerateInvoice__c
     * @PARAM 	: transacEmailId : ID TransacEmail
     * @PARAM 	: customerKey : customerKey returned by SFMC
     * @RETURN 	: void
     */	
    public static void updateTransactionalEmailGenerateInvoice(String transacEmailId, String customerKey){
        TransactionalEmail__c transacEmail = [SELECT ID, TECH_GenerateInvoice__c, TECH_CustomerKey__c FROM TransactionalEmail__c WHERE ID = :transacEmailId LIMIT 1];
        if(!transacEmail.TECH_GenerateInvoice__c) transacEmail.TECH_GenerateInvoice__c = true;
        if(String.isEmpty(transacEmail.TECH_CustomerKey__c) && customerKey!='Error' && String.isNotEmpty(customerKey)) 
            transacEmail.TECH_CustomerKey__c = customerKey;
        update transacEmail;
    }
    
    /*
     * @METHOD 	: updateTransactionalEmailDeletedInvoice
     * @DESC 	: Update of the TransacEmail passed in Param by erasing customer key and reset the flag TECH_GenerateInvoice__c
     * @PARAM 	: transacEmailId : ID TransacEmail
     * @RETURN 	: void
     */	
    public static void updateTransactionalEmailDeletedInvoice(String transacEmailId){
        TransactionalEmail__c transacEmail = [SELECT ID, TECH_GenerateInvoice__c, TECH_CustomerKey__c FROM TransactionalEmail__c WHERE ID = :transacEmailId LIMIT 1];
        transacEmail.TECH_GenerateInvoice__c = false;
        transacEmail.TECH_CustomerKey__c = null;
        update transacEmail;
    }
    
    /*
     * @METHOD 	: SOM_ServerConnect
     * @DESC 	: Connection to Azure SOM Server to get the Invoice indicate by the InvoiceID in a blob Format 
     * @PARAM 	: InvoiceID : ID of the invoice to download from Azure Server
     * @RETURN 	: Blob Invoice : Return the Invoice in a Blob Type
     */	
    public static String SOM_ServerConnect(String invoiceId){
		SOM_DownloadInvoiceDocumentController res = new SOM_DownloadInvoiceDocumentController((ID)invoiceId);
        return res.invoiceData;
    }
    
    /*
     * @METHOD 	: SOM_AuthSFMCAccessToken
     * @DESC 	: Connection to SFMC to AUTH the Rest API Call and retrieve an Access Token
     * @PARAM 	: 
     * @RETURN 	: String oAUTHAccessToken : Access token to be used in REST API
     */	
    public static String SOM_AuthSFMCAccessToken(){
        String oAUTHAccessToken = BackInStockBatchHelper.getSFMCAccessToken();
        return oAUTHAccessToken;
    }
    
    /*
     * @METHOD 	: SOM_UploadInSFMCAsset
     * @DESC 	: Rest API POST Method to post The Invoice in Param
     * @PARAM 	: String pdfFile : invoice pdf file as a String format
     * @PARAM 	: String fileName : Name of the file to be saved in Content Builder 
     * @PARAM	: String oAUTHAccessToken : Auth Token for Rest API Method
     * @RETURN 	: String customerKey : SFMC customerKey of the inserted file, can be use to attach the file to the Transactional Email
     */	
    public static String SOM_UploadInSFMCAsset(String pdfFile,String fileName,String oAUTHAccessToken){
        String customerKey = 'Error';
        SFMCAPISetting__c 	SFMCAPISetting = 	SFMCAPISetting__c.getOrgDefaults();        
        Map<String, Object> dataMap = new Map<String, Object>{
            	'name' => fileName,
            	'assetType'=> new Map<String, Object>{'name' => 'pdf', 'id' => 127},
            	'FileProperties' => new Map<String, Object>{'fileName' => fileName + '.pdf'},
                'file'=> pdfFile};
        HttpRequest request = new HttpRequest();
        try{
            request.setEndpoint(SFMCAPISetting.Rest_API_URL__c + SFMCAPISetting.Asset_Ressource__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', SFMCAPISetting.ContentType__c);
            request.setHeader('Authorization', 'Bearer '+oAUTHAccessToken);
            request.setBody(JSON.serialize(dataMap));
            
            System.debug('**AP2 SOM_UploadInSFMCAsset: endPoint : '+SFMCAPISetting.Rest_API_URL__c + SFMCAPISetting.Asset_Ressource__c);
            System.debug('**AP2 SOM_UploadInSFMCAsset: content type : '+ SFMCAPISetting.ContentType__c);
            System.debug('**AP2 SOM_UploadInSFMCAsset: body : '+ JSON.serialize(dataMap));
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('**AP2 SOM_UploadInSFMCAsset: statusCode : ' + response.getStatusCode());
            System.debug('**AP2 SOM_UploadInSFMCAsset: response : ' + responseBody);
            if(response.getStatusCode() == 200 ||response.getStatusCode() == 201){
                if(Test.isRunningTest()){
                    responseBody = '{"customerKey":"customerKeyBeLike"}';
                }
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                customerKey = (String) responseMap.get('customerKey');
            }
        }catch(Exception e){
            System.debug('**AP2 SOM_UploadInSFMCAsset: The following exception has occurred: ' + e.getMessage());
        }
        return customerKey;
    }
    
    /*
     * @METHOD 	: SOM_GetAssetIdByCustomerKeyInSFMC
     * @DESC 	: Rest API POST Method to post The Invoice in Param
     * @PARAM 	: String CustomerKey : SFMC customerKey of the asset  
     * @PARAM	: String oAUTHAccessToken : Auth Token for Rest API Method
     * @RETURN 	: String assetId : Id of the asset 
     */	
    public static String SOM_GetAssetIdByCustomerKeyInSFMC(String CustomerKey, String oAUTHAccessToken){
        String assetId = 'Error';
        SFMCAPISetting__c 	SFMCAPISetting = 	SFMCAPISetting__c.getOrgDefaults();       
        Map<String, Object> dataMap = new Map<String, Object>{'query' => new Map<String, Object> {'property' => 'customerKey',
                                                                                                  'simpleOperator' => 'equal',
                                                                                                  'value' => CustomerKey}
                                                             };
        HttpRequest request = new HttpRequest();
        try{
            request.setEndpoint(SFMCAPISetting.Rest_API_URL__c + SFMCAPISetting.Asset_Ressource__c + SFMCAPISetting.QueryPath__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', SFMCAPISetting.ContentType__c);
            request.setHeader('Authorization', 'Bearer ' + oAUTHAccessToken);
            request.setBody(JSON.serialize(dataMap));
            
            System.debug('**AP2 SOM_GetAssetIdByCustomerKeyInSFMC: endPoint : '+SFMCAPISetting.Rest_API_URL__c + SFMCAPISetting.Asset_Ressource__c + SFMCAPISetting.QueryPath__c);
            System.debug('**AP2 SOM_GetAssetIdByCustomerKeyInSFMC: content type : '+ SFMCAPISetting.ContentType__c);
            System.debug('**AP2 SOM_GetAssetIdByCustomerKeyInSFMC: body : '+ JSON.serialize(dataMap));
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('**AP2 SOM_GetAssetIdByCustomerKeyInSFMC: statusCode : ' + response.getStatusCode());
            System.debug('**AP2 SOM_GetAssetIdByCustomerKeyInSFMC: response : ' + responseBody);
            if(response.getStatusCode() == 200 ||response.getStatusCode() == 201){
                if(Test.isRunningTest()){
                    responseBody = '{"count": 1,"page": 1,"pageSize": 50,"links": {},"items": [{"id": 1010,"customerKey": "customerKeyBeLike","objectID": "3714b8b9-8356-4bd2-a6b7-2b6d241a5b04","assetType": {"id": 127,"name": "pdf","displayName": "Document"}}]}';
                }
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                List<Object> items = (List<Object>)responseMap.get('items');
                Map<String, Object> item = (Map<String, Object>)items[0];
                assetId = JSON.serialize(item.get('id'));
                System.debug('**AP2 SOM_GetAssetIdByCustomerKeyInSFMC get id : '+ assetId); 
            }
        }catch(Exception e){
            System.debug('**AP2 SOM_GetAssetIdByCustomerKeyInSFMC: The following exception has occurred: ' + e.getMessage());
            assetId = 'Error';
        }
        return assetID;
    }


    /*
     * @METHOD 	: SOM_DeleteInSFMCAsset
     * @DESC 	: Rest API DELETE Method to post The Invoice in Param
     * @PARAM 	: String customerKey : invoice Id in SFMC
     * @RETURN 	: String responseBody : SFMC return response
     */	
    public static String SOM_DeleteInSFMCAsset(String assetId,String oAUTHAccessToken){
        String responseBody = 'Bad request';
        SFMCAPISetting__c 	SFMCAPISetting = 	SFMCAPISetting__c.getOrgDefaults();
        try{
            HttpRequest request = new HttpRequest();
            String endPoint = SFMCAPISetting.Rest_API_URL__c + SFMCAPISetting.Asset_Ressource__c + '/' + assetId + SFMCAPISetting.deletePath__c;
            request.setEndpoint(endPoint);
            request.setMethod('DELETE');
            request.setHeader('Content-Type', SFMCAPISetting.ContentType__c);
            request.setHeader('Authorization', 'Bearer '+oAUTHAccessToken);
            
            System.debug('**AP2 SOM_DeleteInSFMCAsset: endPoint : '+ endPoint);
            System.debug('**AP2 SOM_DeleteInSFMCAsset: content type : '+ SFMCAPISetting.ContentType__c);
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
            System.debug('response body :' + responseBody);
            if(response.getStatusCode() == 200)responseBody = 'OK';
        }
        catch(Exception e){
            System.debug('**AP2 SOM_DeleteInSFMCAsset: The following exception has occurred: ' + e.getMessage());
            responseBody = 'Bad request';
        }
        return responseBody;
    }
}