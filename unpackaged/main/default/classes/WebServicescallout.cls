public class WebServicescallout
{
 @future(Callout=true)
 public static void sendSurvey(String email, String survey_id, String template_id, String segments) {
   // STEP 0: Constants definitions
   String api_key = '1f0b0900-9f88-4a1a-8f94-6dd3373c16bd'; // TODO: Replace it by the associated value
   // STEP 1: Build HTTP Request
   HttpRequest req = new HttpRequest();
   req.setEndpoint('https://api.diduenjoy.com/api/v1/easy_dispatches');
   req.setMethod('POST');
   req.setHeader('Content-Type', 'application/json;charset=UTF-8');
   String authHeader = EncodingUtil.base64Encode(Blob.valueof(api_key + ':'));
   req.setHeader('Authorization', 'Basic ' + authHeader);
   req.setBody('{' +
     '"email":"' + email + '",' +
     '"survey_id": "' + survey_id + '",' +
     '"template_id": "' + template_id + '",' +
     '"segments": {' + segments + '}' +
   '}');
   // Step 3: Execute HTTP Request
   Http http = new Http();
   http.send(req);
 }
}