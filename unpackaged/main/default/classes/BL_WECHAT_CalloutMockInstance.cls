@isTest
global class BL_WECHAT_CalloutMockInstance implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"priority": "Normal","activityDate": "2019-12-20","subject": "Test CALL","statusLabel": "Ouvert","status": "Ouvert","isReminderSet": true,"reminderDateTime": "2019-12-23T09:00:00.000Z"}');
        return response;
    }
}