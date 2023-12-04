/**
* File Name     :  GetInvoicePayerDocumentMockCall
* Description   :  Mock service for testing GetInvoicePayerDocument       
* @author       :  Sourav Mitra @ CTS - Cognizant Technology Solutions
				   Indranil Deria @ CTS - Cognizant Technology Solutions
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     4/27/2023        Sourav Mitra @ CTS    Created the Class.
* 2.0	  4/27/2023		   Indranil Deria @ CTS  Added the methods.
*/

@isTest
public class GetInvoicePayerDocumentMockCall implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    

    public GetInvoicePayerDocumentMockCall(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody('{"PDFBase64String": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        System.debug('testresponse1'+res);
        return res;
    }
}