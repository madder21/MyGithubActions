/*
----------------------------------------------------------------------
-- - Name              :  Batch_BackInStock_Test
-- - Author            :  Mohamed Amine El Mandour
-- - Description       :  Test Class for Batch_BackInStock
-- Maintenance History :    
--
-- Date                 Name                        Version          Remarks
-- -----------          -----------                 --------         ----------------------
-- 17-03-2022           Mohamed Amine El Mandour    1.0              Initial version
-- 14-05-2022           Bader Eddine Elkhal         2.0              updated version
-- 24-04-2023			Paul-Louis MONY				3.0				 Add IsRunningTest on SFMC get Access token to use just one MOCK in the test class
---------------------------------------------------------------------------------------
*/

public class BackInStockBatchHelper{

    public static String getSFMCAccessToken(){
        SFMCAPISetting__c sfmcAPIAuthSetting = SFMCAPISetting__c.getOrgDefaults();
        Map<String, Object> requestMap = new Map<String, Object>{
            'grant_type' => sfmcAPIAuthSetting.GrantType__c,
            'client_id' => sfmcAPIAuthSetting.clientId__c,
            'client_secret' => sfmcAPIAuthSetting.clientSecret__c,
            'account_id' => sfmcAPIAuthSetting.AccountId__c
        };
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:SFMC_API_Auth_Endpoint/v2/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serialize(requestMap));
        Http http = new Http();
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        if(Test.isRunningTest()){
            responseBody = '{"example":"test","access_token":"tokkenTestBelike","status":200}';
        }
        if(response.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            return (String) responseMap.get('access_token');
        }else{
            return 'Error';
        } 
    }

    public static Long postBackInStockEvent(Map<String, BackInStock_Wrapper> productInventories, Set<String> skuWarehouseToSendToSFMC, String oAUTHAccessToken){
        List<Object> jsonList= new List<Object>();
        SFMCAPISetting__c sfmcAPISetting = SFMCAPISetting__c.getOrgDefaults();
        Long i = (Long) sfmcAPISetting.LastSentEventId__c;
        if(i == null) i = 0;
        for(String skuWarehouse :skuWarehouseToSendToSFMC){

            if(productInventories.containsKey(skuWarehouse)){
                i += 1;
                jsonList.add(
                    new Map<String, Object>{
                        'keys' => new Map<String, Object>{
                            'EventId' => 'transation-'+ i
                        },
                        'values' => new Map<String, Object>{
                            'sku' => productInventories.get(skuWarehouse).sku, 
                            'ATS' =>  productInventories.get(skuWarehouse).ats,
                            'treatedByMc' => false,
                            'Warehouse' =>  productInventories.get(skuWarehouse).warehouse 
                        }
                    }
                );
            }
            
           
        }
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:SFMC_API_Rest_Endpoint/hub/v1/dataevents/key:'+SFMCAPISetting__c.getOrgDefaults().BackInStockDEExternalKey__c+'/rowset');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer '+oAUTHAccessToken);
        request.setBody(JSON.serialize(jsonList));
        Http http = new Http();
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 202 || response.getStatusCode() == 200){
            return i;
        }else{
            return null;
        } 
    }

    public static String triggerSFMCBackInStockAutomation(String oAUTHAccessToken){
        SFMCAPISetting__c sfmcAPIAuthSetting = SFMCAPISetting__c.getOrgDefaults();
        String body = '<s:Envelope xmlns:s="'+sfmcAPIAuthSetting.SoapAPIxmlnssAttribute__c+'" xmlns:a="'+sfmcAPIAuthSetting.SoapAPIxmlnsaAttribute__c+'" xmlns:u="'+sfmcAPIAuthSetting.SoapAPIxmlnsuAttribute__c+'">';
        body += '<s:Header>';
        body += '<a:Action s:mustUnderstand="1">Perform</a:Action>';        
        body += '<a:To s:mustUnderstand="1">'+sfmcAPIAuthSetting.SoapAPIToMustUnderstandAttribute__c+'</a:To>';
        body += '<fueloauth>'+oAUTHAccessToken+'</fueloauth>';
        body += '</s:Header>';
        body += '<s:Body xmlns:xsi="'+sfmcAPIAuthSetting.SoapAPIxmlnsxsiAttribute__c+'" xmlns:xsd="'+sfmcAPIAuthSetting.SoapAPIxmlnsxsdAttribute__c+'">';
        body += '<PerformRequestMsg xmlns="'+sfmcAPIAuthSetting.SoapAPIPerformRequestMsgNsAttribute__c+'" xmlns:ns2="'+sfmcAPIAuthSetting.SoapAPIPerformRequestMsgNs2Attribute__c+'">';
        body += '<Action>start</Action>';
        body += '<Definitions>';
        body += '<Definition xmlns:xsi="'+sfmcAPIAuthSetting.SoapAPIxmlnsxsiAttribute__c+'" xsi:type="Automation">';
        body += '<CustomerKey>'+sfmcAPIAuthSetting.BackInStockAutomationExternalKey__c+'</CustomerKey>';
        body += '</Definition>';
        body += '</Definitions>';
        body += '</PerformRequestMsg>';
        body += '</s:Body>';
        body += '</s:Envelope>';
        HttpRequest request = new HttpRequest();
        request.setEndpoint('Callout:SFMC_API_Soap_Endpoint/Service.asmx');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/soap+xml;charset=UTF-8');
        request.setHeader('Content-Length', String.valueOf(body.length()));
        request.setBody(body);
        request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = http.send(request);
        Dom.Document responseBody = response.getBodyDocument();
        return responseBody.getRootElement()
            ?.getChildElement('Body',sfmcAPIAuthSetting.SoapAPIxmlnssAttribute__c)
            ?.getChildElements()[0]
            ?.getChildElement('Results', '')
            ?.getChildElement('Result', '')
            ?.getChildElement('Object', '')
            ?.getChildElement('ObjectID', '')
            ?.getText();
    }

    public static String getSFMCBackInStockAutomationStatus(String oAUTHAccessToken, SFMCAPISetting__c sfmcAPISetting){
        String body = '<s:Envelope xmlns:s="'+sfmcAPISetting.SoapAPIxmlnssAttribute__c+'" xmlns:a="'+sfmcAPISetting.SoapAPIxmlnsaAttribute__c+'" xmlns:u="'+sfmcAPISetting.SoapAPIxmlnsuAttribute__c+'">';
        body += '<s:Header>';
        body += '<a:Action s:mustUnderstand="1">Retrieve</a:Action>';
        body += '<a:To s:mustUnderstand="1">'+sfmcAPISetting.SoapAPIToMustUnderstandAttribute__c+'</a:To>';
        body += '<fueloauth>'+oAUTHAccessToken+'</fueloauth>';
        body += '</s:Header>';
        body += '<s:Body xmlns:xsi="'+sfmcAPISetting.SoapAPIxmlnsxsiAttribute__c+'" xmlns:xsd="'+sfmcAPISetting.SoapAPIxmlnsxsdAttribute__c+'">';
        body += '<RetrieveRequestMsg xmlns="'+sfmcAPISetting.SoapAPIPerformRequestMsgNsAttribute__c+'" xmlns:ns2="'+sfmcAPISetting.SoapAPIPerformRequestMsgNs2Attribute__c+'">';
        body += '<RetrieveRequest>';
        body += '<ObjectType>AutomationInstance</ObjectType>';
        body += '<Properties>Name</Properties>';
        body += '<Properties>Status</Properties>';
        body += '<Filter xsi:type="SimpleFilterPart">';
        body += '<Property>ProgramInstanceID</Property>';
        body += '<SimpleOperator>equals</SimpleOperator>';
        body += '<Value>'+sfmcAPISetting.BackInStockAutomationObjectId__c+'</Value>';
        body += '</Filter>';
        body += '</RetrieveRequest>';
        body += '</RetrieveRequestMsg>';
        body += '</s:Body>';
        body += '</s:Envelope>';
        HttpRequest request = new HttpRequest();
        request.setEndpoint('Callout:SFMC_API_Soap_Endpoint/Service.asmx');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/soap+xml;charset=UTF-8');
        request.setHeader('Content-Length', String.valueOf(body.length()));
        request.setBody(body);
        request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = http.send(request);
        Dom.Document responseBody = response.getBodyDocument();
        return responseBody.getRootElement()
            ?.getChildElement('Body', 'soap')
            ?.getChildElement('RetrieveResponseMsg', '')
            ?.getChildElement('Results', '')
            ?.getChildElement('StatusMessage', '')
            ?.getText();
    }
    
}