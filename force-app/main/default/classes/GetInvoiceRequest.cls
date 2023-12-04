/**
* File Name     :  GetInvoiceRequest
* @description  :  Data definition for the Invoice Payer Document request callout from CPQ
* @author       :  Sourav Mitra @ CTS - Cognizant Technology Solutions
				   Indranil Deria @ CTS - Cognizant Technology Solutions
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     4/28/2023     Sourav Mitra     	    Created the Class and added methods.
*/

public class GetInvoiceRequest {
    
    public String DocumentNo;
    public String DocumentType = 'I';
    //public Integer Payer = 1000016529;
    public Integer SalesOrg = 1436;
    public String FiscalYear;
    public String BinaryFormat = 'X';
    public String HashCode = 'SHA256';
    public String HashFormat = 'X';
    public String Base64Format = 'X';
    
}