/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-28-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
@istest
public class AdobeWS_SendForSignatureMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public AdobeWS_SendForSignatureMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
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
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}