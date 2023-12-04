/**
* File Name     :  GetInvoicePayerDocumentMockCall
* Description   :  Test class for checking the functionalities for the GetInvoicePDFController class    
* @author       :  Sourav Mitra @ CTS - Cognizant Technology Solutions
				   Indranil Deria @ CTS - Cognizant Technology Solutions
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/26/2023        Indranil Deria @ CTS    Created the Class.
* 2.0	  5/26/2023		   Sourav Mitra @ CTS  Added the methods.
*/

@isTest
private class GetInvoicePDFControllerTest{
    
    @testSetup
    public static void testDataSetup(){
        //Creating Account record
        Account account = CPQ_TestDataFactory.createAccount(true);
        Address__c soldToAddress = CPQ_TestDataFactory.createAddress(account, true);
        account.ZTS_EU_Primary_Address__c = soldToAddress.Id;
        update account;
        
        //Setting up Vistex Custom Setting
         Vistex_Configuration__c vistexConfig = new Vistex_Configuration__c();
        vistexConfig.Response_time_out__c = 40000;
        vistexConfig.Retry_Times__c = 1;
        vistexConfig.Endpoint_Relative_Path__c = 'Deals/PricingCall/1234';
        insert vistexConfig;
 		
    }
    
    @isTest
    private static void testControllerCall(){
        
        Account accnt = [Select Id from Account LIMIT 1];
        //Setting up data that will be sent as parameters for the API Call as Payload
        ZTS_US_Contract_Payments__c contractPay = new ZTS_US_Contract_Payments__c();
        contractPay.Name = '9500807255';
        contractPay.ZTS_US_Date_Sent__c = System.now();
        contractPay.ZTS_US_Accounts__c = accnt.Id;
        insert contractPay;
        System.debug('Contract Pay after insert' + contractPay);
        
        //Calling the mock class for running the test
        GetInvoiceRequest req = new GetInvoiceRequest();
        String body = JSON.serialize(req);
        System.debug('Request Sent : ' + body );
        Map<String,String> header = new Map<String,String>();
        header.put('Accept', 'application/json');
        Test.setMock(HttpCalloutMock.class, new GetInvoicePayerDocumentMockCall(200,'SUCCESS',body,header));
        
        Test.startTest();
        PageReference pageRef = Page.GetInvoicePDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recid',contractPay.Id);
  
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(contractPay);
        GetInvoicePDFController reqAfter = new GetInvoicePDFController(ctrl);
        
        Test.stopTest();
        System.debug('Response Value from Test Class *** ' + reqAfter.getInvoiceDoc());
        System.assertNotEquals(null, reqAfter.getInvoiceDoc());
    }
    
    @isTest
    private static void testControllerError(){
        Account accnt = [Select Id from Account LIMIT 1];
        //Setting up data that will be sent as parameters for the API Call as Payload
        ZTS_US_Contract_Payments__c contractPay = new ZTS_US_Contract_Payments__c();
        contractPay.Name = '9500807255';
        contractPay.ZTS_US_Date_Sent__c = System.now();
        contractPay.ZTS_US_Accounts__c = accnt.Id;
        insert contractPay;
        System.debug('Contract Pay after insert' + contractPay);
        
        //Calling the mock class for running the test
        GetInvoiceRequest req = new GetInvoiceRequest();
        String body = JSON.serialize(req);
        System.debug('Request Sent : ' + body );
        Map<String,String> header = new Map<String,String>();
        header.put('Accept', 'application/json');
        Test.setMock(HttpCalloutMock.class, new GetInvoicePayerDocumentMockCall(404,'SUCCESS',body,header));
        
        Test.startTest();
        PageReference pageRef = Page.GetInvoicePDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recid',contractPay.Id);
  
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(contractPay);
        GetInvoicePDFController reqAfter = new GetInvoicePDFController(ctrl);
        
        Test.stopTest();
        System.debug('Response Value from Test Class *** ' + reqAfter.getInvoiceDoc());
        System.assertEquals(null, reqAfter.getInvoiceDoc());
    }
    
}