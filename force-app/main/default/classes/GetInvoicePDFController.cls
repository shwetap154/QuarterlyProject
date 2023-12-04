/**
* File Name     :  GetInvoicePDFController
* @description  :  Render PDF from Contract Payment layout
* @author       :  Sourav Mitra @ CTS - Cognizant Technology Solutions
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/23/2023     Sourav Mitra     	    Created the Class and added methods.
*/
public with sharing class GetInvoicePDFController {
	
    private ApexPages.StandardController ctrl;
    public String currentRecordId;
    public String response {get;set;}
    public String error {get;set;}
    public Boolean noError {get;set;}
    public GetInvoicePDFController() {}
    public GetInvoicePDFController(ApexPages.StandardController stdController){
        ctrl = stdController;
        this.noError = true;
       currentRecordId = ApexPages.currentPage().getParameters().get('recid');
      Map<String,Object> res = (Map<String,Object>) getInvoiceDoc();
        if(res!=null){
            if(res.get('ErrorDesc') == '' || res.get('ErrorDesc') == null){
      this.response = res.get('PDFBase64String').toString();
       System.debug(res.get('PDFBase64String').toString());
        }else{
          this.noError = false;
          		 this.error = res.get('ErrorDesc').toString();
            }
        }else{
          this.noError = false;
          this.error = 'An unknown error has occured while trying to get a rebate invoice. Please do contact your System Administrator';
        }
    }
    
    
    public Object getInvoiceDoc(){
       
        GetInvoiceRequest req = new GetInvoiceRequest();
        ZTS_US_Contract_Payments__c contractPay = [Select Id,Name,ZTS_US_Date_Sent__c from ZTS_US_Contract_Payments__c Where Id =: currentRecordId];
        String fiscalYear = String.valueOf(contractPay.ZTS_US_Date_Sent__c.year());
        
        req.DocumentNo = contractPay.Name;
        req.FiscalYear = fiscalYear;
        
        String response = GetInvoicePayerDocument.doRequest(req);
        if(response != ''){
        Object res = JSON.deserializeUntyped(response);
        System.debug(res);
        return res;
        }else{
            return null;
        }
        
        
    }
    
    //NOT BE USED FOR NOW
    /*
    public static List<Address__c> getAddressData(){
        ZTS_US_Contract_Payments__c contractPay = new ZTS_US_Contract_Payments__c();
		List<Address__c> addrLst = [Select Id,Name FROM Address__c WHERE ZTS_EU_Account__c =: contractPay.Accounts.Id AND (ZTS_EU_Address_Type__c LIKE 'Bill%' OR ZTS_EU_Address_Type__c LIKE 'Sold%')];
        return addrLst;
    }*/
}