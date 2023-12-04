/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-07-2023
 * @last modified by  : Dephney Dsouza
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   07-16-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1	 10-18-2021   Mahendra Kumar				 Added SAP Material code field in the query to display the column (SC-009048)
 * 1.2   08-07-2023   Dephney Dsouza				 Added Shippingdoc code & requested delivery date to not display in the document.
**/
public without sharing class alphaOrderPDFController {
    /*
    public Boolean showPDF {get; set;}
    public static String orderId {get; set;}
    public static Order order {get; set;}
    
    public void generatePDF() {
        showPDF = true;
    }

    public static void getOrderId() {
        orderId = System.currentPageReference().getParameters().get('orderId');
    }
    */

    private Order order;
    private List<OrderItem> orderProducts;
    private List<Shipping_Document__c> shippingDocs;
    private Address__c accountAddress;
    private Attachment signature;

    private String signatureImage;
    private String currentMarket;
    private String downloadParam;
    private String currentCountry;

    private Boolean renderFreePercent;
    private Boolean renderFreeQuantity;
    private Boolean renderDiscount;
    private Boolean isDownload;
    
    private Boolean renderDeliveryDate = true;
    private Boolean renderShippingDoc = true;

    // private Integer backgroundColor = 0;

    public alphaOrderPDFController() {}

    public alphaOrderPDFController(ApexPages.StandardController stdController) {
        this.order = (Order) stdController.getRecord();	
        system.debug('Order--->>'+this.order);
        this.orderProducts = [SELECT Id, OrderItemNumber, Product2.SAP_Material_Code__c, Product2.Name, Quantity, Product2.SAP_Sales_Unit_of_Measure__c, SAP_Unit_Of_Measure__c, Requested_Delivery_Date__c, UnitPrice, TotalPrice, FreeOfChargePercent__c, FreeOfChargeQuantity__c, Discount__c FROM OrderItem WHERE OrderId = :this.order.Id ORDER BY Product2.Name ASC];
        this.shippingDocs = [SELECT Id, Document_Type__c, Original_By_Courier__c, Electronic_by_Email__c, Other_Document__c FROM Shipping_Document__c WHERE Order__c = :this.order.Id];
        system.debug('this.order.AccountId'+this.order.AccountId);
        this.accountAddress = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Incoterms__c,ZTS_EU_Account__r.Incoterms_Description__c, ZTS_EU_Account__r.Distributor_Payment_Terms__c, CurrencyIsoCode, ZTS_EU_Address_Type__c FROM Address__c WHERE ZTS_EU_Account__c =: this.order.AccountId AND ZTS_EU_Address_Type__c = 'Main' LIMIT 1];
        downloadParam = ApexPages.currentPage().getParameters().get('download');
        if(downloadParam == null){
            isDownload = false;
        }else{
            isDownload = Boolean.valueOf(downloadParam);
        }
        //this.signature = [SELECT Id, Name, ContentType, ParentId, Body FROM Attachment WHERE ParentId = :this.order.Id AND ContentType = 'image/png' AND Name LIKE 'E-Signature%'][0];
        // this.signatureImage = EncodingUtil.base64Encode(this.signature.Body);
        //this.signatureImage = (URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + this.signature.Id).replace('visualforce', 'documentforce'); // We have to directly link to the signature image in order for the PDF to be able to display it correctly.

        List<Account> listAccounts = [SELECT Id, ZTS_EU_Market__c,ZTS_EU_Country__c FROM Account WHERE Id = :order.AccountId];
        this.currentMarket = listAccounts[0].ZTS_EU_Market__c;
        this.currentCountry = listAccounts[0].ZTS_EU_Country__c;
        if (this.currentMarket == 'Maghreb' || this.currentMarket == 'Middle East') {
            this.renderFreePercent = true;
            this.renderFreeQuantity = true;
        }
        if (this.currentCountry == 'Israel') {
            this.renderDiscount = true;
        }
        //TPDEV-1023 - code to not display fields for panama and Costa Rica.
        if (this.currentMarket == 'Panama' || this.currentMarket == 'Costa Rica') {
            this.renderDeliveryDate = false;
	    	this.renderShippingDoc = false;
        }
    }

    public List<OrderItem> getOrderProducts() {
        return orderProducts;
    }

    public List<Shipping_Document__c> getShippingDocs() {
        return shippingDocs;
    }

    public Address__c getAccountAddress() {
        return accountAddress;
    }

    public Attachment getSignature() {
        return signature;
    }

    public String getSignatureImage() {
        return signatureImage;
    }
    
    public Boolean getRenderFreePercent() {
        return renderFreePercent;
    }
    
    public Boolean getRenderFreeQuantity() {
        return renderFreeQuantity;
    }
    
    public Boolean getRenderDiscount() {
        return renderDiscount;
    }
    
     public Boolean getRenderDeliveryDate() {
        return renderDeliveryDate;
    }

    public Boolean getIsDownload() {
        return isDownload;
    }
    
    public Boolean getRenderShippingDoc() {
        return renderShippingDoc;
    }

    /*
    public String getBackgroundColor() {
        this.backgroundColor += 1;
        if (math.mod(this.backgroundColor, 2) == 0) {
            return '#DFDFDF';
        }
        else {
            return '#FFFFFF';
        }
    }
    */
}