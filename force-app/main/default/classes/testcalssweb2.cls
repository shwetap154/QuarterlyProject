@isTest
global class testcalssweb2 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        string body='{"kind": "drive#file", "id": "1pX5PChTL37AlslDxN-a8LqXB9WH9kaJs", "name": "Untitled","mimeType": "image/jpeg"}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode(200);
        return response; 
    }
}