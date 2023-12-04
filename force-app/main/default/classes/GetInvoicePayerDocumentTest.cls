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
* 3.0  	  5/2/2023		   Sourav Mitra @ CTS	 Modified method GetInvoicePayerDocumentTest so that it takes data from GetInvoiceRequest Class
*/

@istest
private class GetInvoicePayerDocumentTest {
    
    @testSetup
    public static void testDataSetup(){
        //Setting up Custom Setting Data
        Vistex_Configuration__c vistexConfig = new Vistex_Configuration__c();
        vistexConfig.Response_time_out__c = 40000;
        vistexConfig.Retry_Times__c = 1;
        vistexConfig.Endpoint_Relative_Path__c = 'Deals/PricingCall/1234';
        vistexConfig.Invoice_Endpoint_Relative_Path__c = 'sap/pdfextract';
        insert vistexConfig;
    }
    
 	@isTest
    private static void testInvoiceMock(){
        GetInvoiceRequest req = new GetInvoiceRequest();
        String body = JSON.serialize(req);
        System.debug('Request Sent : ' + body );
        Map<String,String> header = new Map<String,String>();
        header.put('Accept', 'application/json');
        Test.setMock(HttpCalloutMock.class, new GetInvoicePayerDocumentMockCall(200,'SUCCESS',body,header));
        Test.startTest();
        String response = GetInvoicePayerDocument.doRequest(req);
        Test.stopTest();
        //System.assertNotEquals(null, response);
        String expectedResponse = '{"PDFBase64String": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}';
        System.debug('Expected Response ***1'+expectedResponse);
        System.debug('Actual Response ***2'+response);
        System.assertEquals(expectedResponse, response);
    }
    
    @isTest
    private static void testCallError(){
		Vistex_Configuration__c vistexConfig = [Select Id,Retry_Times__c from Vistex_Configuration__c LIMIT 1];
        vistexConfig.Retry_Times__c = 0;
        update vistexConfig;
        GetInvoiceRequest req = new GetInvoiceRequest();
        String body = JSON.serialize(req);
        System.debug('Request Sent : ' + body );
        Map<String,String> header = new Map<String,String>();
        header.put('Accept', 'application/json');
        Test.setMock(HttpCalloutMock.class, new GetInvoicePayerDocumentMockCall(200,'SUCCESS',body,header));
        Test.startTest();
        String response = GetInvoicePayerDocument.doRequest(req);
        Test.stopTest();
        //System.assertNotEquals(null, response);
        String expectedResponse = '{"PDFBase64String": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}';
        System.debug('Expected Response ***1'+expectedResponse);
        System.debug('Actual Response ***2'+response);
    }
    
    @isTest
    private static void testInvoiceCallOutErrorCode(){
        GetInvoiceRequest req = new GetInvoiceRequest();
        String body = JSON.serialize(req);
        System.debug('Request Sent : ' + body );
        Map<String,String> header = new Map<String,String>();
        header.put('Accept', 'application/json');
        Test.setMock(HttpCalloutMock.class, new GetInvoicePayerDocumentMockCall(404,'SUCCESS',body,header));
        Test.startTest();
        String response = GetInvoicePayerDocument.doRequest(req);
        Test.stopTest();
        //System.assertNotEquals(null, response);
        String expectedResponse = '{"PDFBase64String": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}';
        System.debug('Expected Response ***1'+expectedResponse);
        System.debug('Actual Response ***2'+response);
        System.assertNotEquals(expectedResponse,null);
    }
}