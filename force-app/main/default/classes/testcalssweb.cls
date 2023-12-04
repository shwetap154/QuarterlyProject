@isTest
global class testcalssweb implements HttpCalloutMock {
   
    global HTTPResponse respond(HTTPRequest req) {
        string body='{"access_token" : "ya29.GlvCBXPrXiGrsZmDqKEsWbebuDdkKi_X2JhBB8fei0taPcPUD0jVhuGIj4-Cj7RIMePBD2XZKhRyD32uxoqWQqodx32Z537BtuUxPg-yOfQHFDqjrOMnhC4vR0DO", "expires_in" : 3600,"token_type" : "Bearer"}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode(200);
        return response; 
    }
}