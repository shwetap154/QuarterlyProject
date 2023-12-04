/**
 * @description       : Controller for alphaCreateOrderForm LWC
 * @author            : Cognizant
 * @group             :
 * @last modified on  : 03-30-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-29-2021   Cognizant                   Initial Version
 * 1.1   03-18-2022   Ethan Hirsch @ Zoetis Inc   Update deleteOrder to skip deletion if an Order is related to an Agreement.
 * 1.2   03-29-2022   Ethan Hirsch @ Zoetis Inc   Update SAPCustomerMaterialPrice__c queries in getModeofTransport and 
 *                                                prepareData to use SAPCustomerMaterialPricesSelector to retrieve data
 *                                                that is currently valid.
 *                                                Remove SOQL query in getOrderRecord that wasn't used.
 *  1.3   09-11-2023   Sweta Kumari               Add more Products in addProductOrder when the order is edited.                                               
 *  1.4   09-26-2023   Sweta Kumari               Display(getOrderRecord)and Download(downloadFile)all attachments for an Order on Order Details.                                      
 **/
public without sharing class alphaCreateOrder {
  @testVisible
  private static string orderDeletionErrorMessage = 'An Agreement exists for this Order. This Order cannot be deleted.';
  
  @AuraEnabled(cacheable=true)
  public static List<SObject> getColumns() {
    try {
      List<SObject> colList = [
        SELECT label, label__c, fieldName__c
        FROM StockForecastColumns__mdt
        WHERE ObjectName__c = 'Order'
        ORDER BY label
      ];
      return colList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Order> getOrderList() {
    try {
      //Getting the account  info..
      List<Account> accList = UtilityController.returnObjList();
      // string accountId = '0011g00000u7SSdAAM';// for testing...
      return [
        SELECT
          Id,
          Status,
          PoDate,
          PoNumber,
          OrderReferenceNumber,
          lastmodifieddate
        FROM order
        WHERE AccountId IN :accList
        ORDER BY lastmodifieddate DESC
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static MasterData getModeofTransport() {
    try {
      MasterData md = new MasterData();
      List<string> options = new List<string>();

      List<Account> accList = UtilityController.returnObjList();

      Schema.DescribeFieldResult fieldResult = Order.Mode_of_Transport__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry f : ple) {
        options.add(f.getValue());
      }
      md.modeOfTransport = options;
      system.debug('accList>>>>' + accList);
      string accountId = accList[0].Id;
      String sapCustomerNumber = '';
      List<Address__c> accountAddressList = AddressesSelector.newInstance()
        .selectByAccountId(new Set<Id>{ accountId });
      System.debug('Address Data==>' + accountAddressList);
      for (Address__c objAddress : accountAddressList) {
        if (objAddress.ZTS_US_Source_Account_Number__c != null) {
          if (objAddress.ZTS_EU_Address_Type__c == 'Main') {
            sapCustomerNumber = objAddress.ZTS_US_Source_Account_Number__c;
          }
        }
      }

      ISAPCustomerMaterialPricesSelector sapSelector = SAPCustomerMaterialPricesSelector.newInstance();
      md.lstMatPrice = sapSelector.selectValidByCustomerNumbersWithProduct(new Set<String> {sapCustomerNumber});

      System.debug('Master Data==>' + md);
      return md;
    } catch (Exception e) {
      system.debug(e.getMessage());
      system.debug(e.getLineNumber());
      throw new AuraHandledException(e.getMessage());
    }
  }

  //This function prepares the dataset for order form...
  @AuraEnabled(cacheable=true)
  public static OrderWrapper prepareData(string selectedCurrencyCode) {
    try {
      OrderWrapper orderWrap = new OrderWrapper();
      //Getting the account  info..
      List<Account> accList = UtilityController.returnObjList();
      // string accountId = '0011g00000u7SSdAAM';// for testing...
      string accountId = accList[0].Id;
      //Getting user info..
      String uId = UserInfo.getUserId();
      User currUser = [
        SELECT ZTS_EU_Market__c, Profile.name, ContactId, Contact.AccountId
        FROM User
        WHERE Id = :uId
        LIMIT 1
      ];

      orderWrap.lstContact = [
        SELECT Id, Name
        FROM Contact
        WHERE AccountId = :accountId
      ];
      System.debug('Current User==>' + currUser);

      //Loading addressess...
      List<Address__c> lstAddr = new List<Address__c>();
      lstAddr = [
        SELECT
          ZTS_EU_Account__c,
          Account_Ultimate_Parent_Name__c,
          CurrencyIsoCode,
          Id,
          Name,
          OwnerId,
          ZTS_EU_Address_Type__c,
          ZTS_EU_Account__r.Name,
          ZTS_EU_Primary_Address__c,
          ZTS_US_Source_Account_Number__c,
          Full_Address__c,
          ZTS_EU_Account__r.Distributor_Payment_Terms__c,
          ZTS_EU_Account__r.Incoterms__c,
          ZTS_EU_Account__r.Incoterms_Description__c,
          ZTS_EU_Account__r.ZTS_EU_Country__c
        FROM Address__c
        WHERE ZTS_EU_Account__c = :accountId 
        AND ZTS_US_Source_Account_Number__c != NULL
      ];
       
      system.debug(lstAddr);
      Address__c mainAddr;
      List<Address__c> lstShipToAddr = new List<Address__c>();
      for (Address__c address : lstAddr) {
        system.debug(address.ZTS_EU_Address_Type__c);
        if (address.ZTS_EU_Address_Type__c == 'Main') {
          system.debug(address);
          mainAddr = address;
        } else if (address.ZTS_EU_Address_Type__c == 'Ship To') {
          system.debug(address);
          lstShipToAddr.add(address);
        }
      }

      //if no ship to is present...put the main address..
      if (lstShipToAddr.size() == 0) {
        lstShipToAddr.add(mainAddr);
      }

      system.debug(mainAddr.ZTS_US_Source_Account_Number__c + '---');
      orderWrap.companyName = new Account(
        Id = mainAddr.ZTS_EU_Account__c,
        Name = mainAddr.ZTS_EU_Account__r.Name
      );
      orderWrap.tel = '';
      orderWrap.fax = '';
      orderWrap.contactName = UserInfo.getName();
      orderWrap.purchaseOrderNo = '';
      orderWrap.purchaseOrderDate = System.today();
      orderWrap.shipToAddr = mainAddr;
      orderWrap.soldToAddr = mainAddr;
      orderWrap.grandTotal = '';
      orderWrap.remarks = '';
      orderWrap.userId = currUser.ContactId;
      orderWrap.market = currUser.ZTS_EU_Market__c;
      orderWrap.status = 'Draft';
      orderWrap.Id = '';
      orderWrap.SalesOrg = '';
      //load address options for ship to address....
      orderWrap.country = mainAddr.ZTS_EU_Account__r.ZTS_EU_Country__c;
      orderWrap.shipToAddrOptions = lstShipToAddr; // [SELECT Id,Name FROM Address__c LIMIT 5];

      orderWrap.currencyValue = selectedCurrencyCode;//lstSAP[0].CurrencyIsoCode;mainAddr.CurrencyIsoCode;
      orderWrap.incoterms =
        mainAddr.ZTS_EU_Account__r.Incoterms__c +
        '-' +
        mainAddr.ZTS_EU_Account__r.Incoterms_Description__c;
      orderWrap.modeOfTransport = '';
      orderWrap.termsOfPayment = mainAddr.ZTS_EU_Account__r.Distributor_Payment_Terms__c;
      orderWrap.eSignature = '';

      //getting forecast quantity for the month.....
      string currDate = Datetime.now().format('yyyy-MMMM-dd');
      string month = currDate.substring(5, 9);
      string year = currDate.substring(0, 4);

      // system.debug('Month==> ' + month + '  Year==> '+ year);

      //get forecast data..

      //This code is commented because quantity will be zero now always until month & year for
      //order is implemented..then this can be used..

      // List<Forecast_Product__c> fplst = [SELECT Id,Name,Product__c,Product__r.Name,
      //                                     Forecast__r.Month__c,
      //                                     Forecast__r.Year__c,Forecast__r.Account__r.Name,Quantity__c,
      //                                     createddate from Forecast_Product__c
      //                                     where Forecast__r.Month__c = :month
      //                                     and Forecast__r.Year__c = : year
      //                                     and Forecast__r.Account__c = :accountId];

      //get free of charge related data..
      List<AccountProductPortfolio__c> lstAccProdFolio = [
        SELECT
          Id,
          Name,
          FreeOfChargePercent__c,
          FreeOfChargeQuantity__c,
          Discount__c,
          Product__c
        FROM AccountProductPortfolio__c
        WHERE Account__c = :accountId
      ];

      List<OrderItemWrapper> lstOitem = new List<OrderItemWrapper>();

      List<string> lstpriceBookProdCode = new List<string>();
      Integer count = 0;

      //Loading SAP Mat price..
      ISAPCustomerMaterialPricesSelector sapSelector = SAPCustomerMaterialPricesSelector.newInstance();
      for (SAPCustomerMaterialPrice__c prodItem : SAPCustomerMaterialPricesService.removeDuplicateRecords(
                                                      sapSelector.selectValidByCustomerNumbersWithProduct(
                                                          new Set<String> {mainAddr.ZTS_US_Source_Account_Number__c}))) {
        OrderItemWrapper oItem = new OrderItemWrapper();
        lstpriceBookProdCode.add(prodItem.Product__c);
        oItem.sapMaterialNo = prodItem.Material_Number__c;
        oItem.prodName = new Product2(
          Id = prodItem.Product__c,
          Name = prodItem.Product__r.Name
        );                                                     
        oItem.supplyPoint = prodItem.Market__c;
        oItem.SalesOrg = prodItem.Sales_Organization__c;
        //load quantity from forecast...

        //This code is commented because quantity will be zero now always until month & year for
        //order is implemented..then this can be used..

        // for(Forecast_Product__c fp : fplst)
        //     {
        //         if(fp.Product__c == prodItem.Product__c)
        //         {
        //             oItem.quantity = String.valueOf(fp.Quantity__c);
        //         }

        //     }
        oItem.quantity = '0';
        oItem.uom = String.valueof(
          String.isBlank(prodItem.Unit_of_Measure__c)
         ? prodItem.Product__r.SAP_Material__r.SAP_Sales_Unit_of_Measure__c 
           : prodItem.Unit_of_Measure__c
        );
        if(oItem.supplyPoint == 'Panama' && oItem.supplyPoint == 'Costa Rica' ){
          oItem.reqDeliveryDate = null;
        }
        else{
          oItem.reqDeliveryDate = System.today().addDays(15);
        }
        oItem.unitPrice = String.valueof(prodItem.Price__c);
        for (AccountProductPortfolio__c accProd : lstAccProdFolio) {
          if (prodItem.Product__c == accProd.Product__c) {
            oItem.percentageOfFreeCharge = String.ValueOf(
              accProd.FreeOfChargePercent__c
            );
            oItem.freeOfChargeQuantity = String.ValueOf(
              accProd.FreeOfChargeQuantity__c
            );
            oItem.discount = String.ValueOf(accProd.Discount__c);
          }
        }
        if (oItem.percentageOfFreeCharge == null)
          oItem.percentageOfFreeCharge = '0';
        if (oItem.freeOfChargeQuantity == null)
          oItem.freeOfChargeQuantity = '0';
        if (oItem.discount == null)
          oItem.discount = '0';

        oItem.totalprice = '';
        oItem.Id = String.valueof(++count);
        lstOitem.add(oItem);
      }
      //Get the Price book entry information...
      List<Pricebook2> pricebook = [
        SELECT Id, CurrencyIsoCode
        FROM PriceBook2
        WHERE IsStandard = TRUE
      ];
      orderWrap.pricebookId = pricebook[0].Id;
      List<PriceBookEntry> pbentries = [
        SELECT Id, Product2Id
        FROM PriceBookEntry
        WHERE
          Product2Id IN :lstpriceBookProdCode
          AND PriceBook2Id = :pricebook[0].Id
          AND CurrencyIsoCode = :selectedCurrencyCode
      ];

      for (OrderItemWrapper oItem : lstOitem) {
        for (PriceBookEntry pbe : pbentries) {
          if (oItem.prodName.Id == pbe.Product2Id) {
            oItem.pricebookentryId = pbe.Id;
          }
        }
      }

      //putting order items in order
      orderWrap.lstOrdItm = lstOitem;

      //Getting Shipping doc collection..
      List<ShippingDoc> lstShippingDocs = new List<ShippingDoc>();
        system.debug('lstShippingDocs'+lstShippingDocs);
      count = 0;
      List<string> options = new List<string>();
      Schema.DescribeFieldResult fieldResult = Shipping_Document__c.Document_Type__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry f : ple) {
        ShippingDoc sd = new ShippingDoc();
        sd.docType = f.getValue();
        sd.elecByEmail = false;
        sd.originalByCourier = String.valueOf(0);
        sd.docRemarks = '';
        sd.Id = String.valueof(++count);
        lstShippingDocs.add(sd);
          system.debug('lstShippingDocs341'+lstShippingDocs);
      }
      orderWrap.lstShippingDocs = lstShippingDocs;
        
      return orderWrap;
    } catch (Exception ex) {
      System.debug('ERROR : ' + ex.getMessage());
      throw new AuraHandledException(ex.getMessage());
    }
  }

  @AuraEnabled
  public static string saveOrder(string payload) {
    system.debug('payload>>' + payload);
    try {
      //getting the payload..
      OrderWrapper orderWrap = (OrderWrapper) JSON.deserialize(
        payload,
        OrderWrapper.class
      );
      //parsing for order
      Order order = new Order();
      order.RecordTypeId = OrderHandler.distributorOrderRTId;
      order.AccountId = orderWrap.companyName.Id;
      order.BillToContactId = orderWrap.userId;
      order.ShipToContactId = orderWrap.userId;
      order.PoDate = orderWrap.purchaseOrderDate;
      order.PoNumber = orderWrap.purchaseOrderNo;
      order.Mode_of_Transport__c = orderWrap.modeOfTransport;
      order.Customer_Comments__c = orderWrap.remarks;
      order.EffectiveDate = System.today();
      order.Status = orderWrap.status;
      order.Pricebook2Id = orderWrap.pricebookId;
      order.Phone__c = orderWrap.tel;
      order.Fax__c = orderWrap.fax;
      order.Portal_Total_price__c = Decimal.valueOf(orderWrap.grandTotal);
      order.Ship_To_Address__c = orderWrap.shipToAddr.Id;
      order.Address__c = orderWrap.soldToAddr.Id;
      order.Market_Account__c = orderWrap.market;
      order.Sales_Org__c = orderWrap.SalesOrg;
      order.CurrencyIsoCode = orderWrap.currencyValue;
      order.PaymentTerms__c = orderWrap.termsOfPayment;
      insert order;
      system.debug('Order ==>' + order);
      List<OrderItem> lstOrderItems = new List<OrderItem>();
      //Looping through for order item..

      for (OrderItemWrapper orderItemWrap : orderWrap.lstOrdItm) {
        if (Decimal.valueOf(orderItemWrap.quantity) < 1) {
          continue;
        } else {
          OrderItem oItem = new OrderItem();

          oItem.PricebookEntryId = orderItemWrap.pricebookentryId;
          oItem.OrderId = order.Id;
          oitem.Product2Id = orderItemWrap.prodName.Id;
          oItem.SAP_Unit_Of_Measure__c = orderItemWrap.uom;
          oItem.Requested_Delivery_Date__c = orderItemWrap.reqDeliveryDate;
          oItem.UnitPrice = Decimal.valueOf(orderItemWrap.unitPrice);
          oItem.FreeOfChargePercent__c = Decimal.valueOf(
            orderItemWrap.percentageOfFreeCharge
          );
          oItem.FreeOfChargeQuantity__c = Decimal.valueOf(
            orderItemWrap.freeOfChargeQuantity
          );
          oItem.Discount__c = Decimal.valueOf(orderItemWrap.discount);
          oItem.Quantity = Decimal.valueOf(orderItemWrap.quantity);
          oItem.IsPortalCreated__c = true;
          lstOrderItems.add(oItem);
        }
      }
      insert lstOrderItems;

            
      //Looping for shipping docs..
      List<Shipping_Document__c> shippingDocs = new List<Shipping_Document__c>();
      for (ShippingDoc sDoc : orderWrap.lstShippingDocs) {
        if (sDoc.elecByEmail || Decimal.valueOf(sDoc.originalByCourier) > 0) {
          Shipping_Document__c shipDoc = new Shipping_Document__c();
          shipDoc.Document_Type__c = sDoc.docType;
          shipDoc.Electronic_by_Email__c = sDoc.elecByEmail;
          shipDoc.Original_By_Courier__c = Decimal.valueOf(
            sDoc.originalByCourier
          );
          shipDoc.Other_Document__c = sDoc.docRemarks;
          shipDoc.Order__c = order.Id;

          shippingDocs.add(shipDoc);
        }
      }

      system.debug('Shipping Doc List ==>' + shippingDocs);
      insert shippingDocs;

      system.debug('incoming Order list==>' + orderWrap);
      return order.Id;
    } catch (Exception e) {
      system.debug('ERROR==>' + e.getMessage());
      system.debug('STACK==>' + e.getStackTraceString());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
  * @description Deletes an Order. If an Order has an Agreement, it cannot be deleted.
  * @author Ethan Hirsch @ Zoetis Inc | 03-18-2022 
  * @param orderId 
  * @return SubmissionResponse 
  **/
  @AuraEnabled
  public static SubmissionResponse deleteOrder(string orderId) {
    try {

      // If an Order has a related Agreement, it cannot be deleted due to limiitations of EchoSign
      IEchoSignSignAgreementSelector selector = EchoSignSignAgreementSelector.newInstance();
      selector.setEnforceSecurity(false);
      boolean hasAgreements = selector.selectByOrderIdQuery(new List<Id> {orderId}).isEmpty() == false;

      if (hasAgreements) {
          return new SubmissionResponse(false, orderDeletionErrorMessage);
      }

      System.debug('DEL triggered' + orderId);
      delete [SELECT Id, Name FROM Order WHERE Id = :orderId LIMIT 1];
      return new SubmissionResponse(true);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string updateOrderStatus(string orderId) {
    try {
      Order o = [
        SELECT
          Id,
          Status,
          PoDate,
          Phone__c,
          Fax__c,
          PoNumber,
          Mode_of_Transport__c,
          Customer_Comments__c,
          EffectiveDate
        FROM Order
        WHERE Id = :orderId
      ];
      o.Status = 'Draft';
      update o;
      return o.Id;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string updateOrder(string payload) {
    system.debug('payload' + payload);
    try {
      OrderWrapper orderWrap = (OrderWrapper) JSON.deserialize(
        payload,
        OrderWrapper.class
      );
      Order o = [
        SELECT
          Id,
          Status,
          PoDate,
          Phone__c,
          Fax__c,
          PoNumber,
          Mode_of_Transport__c,
          Customer_Comments__c,
          EffectiveDate,
          BillToContactId,
          ShipToContactId
        FROM Order
        WHERE Id = :orderWrap.Id
      ];

      o.PoDate = System.today();
      o.PoNumber = orderWrap.purchaseOrderNo;
      o.Status = 'Draft';
      o.Phone__c = orderWrap.tel;
      o.Fax__c = orderWrap.fax;
      o.Customer_Comments__c = orderWrap.remarks;
      o.EffectiveDate = System.today();
      o.Mode_of_Transport__c = orderWrap.modeOfTransport;
      o.BillToContactId = orderWrap.userId;
      o.ShipToContactId = orderWrap.userId;
      o.Ship_To_Address__c = orderWrap.shipToAddr.Id;
      o.Sales_Org__c = orderWrap.SalesOrg;  
      update o;
  
            List<Product2> accList = UtilityController.returnProdList();
            List<OrderItem> lstOrderItemInsert = new List<OrderItem>();
            map<Id, OrderItem> mapOrderItem = new map<Id,OrderItem>([SELECT Id, Quantity, Requested_Delivery_Date__c FROM OrderItem WHERE OrderId = :orderWrap.Id ]);
            List<OrderItem> lstOrderItemUpdate = new List<OrderItem>();
            for (OrderItemWrapper orderItemWrap : orderWrap.lstOrdItm)
            {
                Boolean isDuplicate = false ;
               if(mapOrderItem.containsKey(orderItemWrap.Id))
               {
                   OrderItem oItem = new OrderItem();
                   oItem = mapOrderItem.get(orderItemWrap.Id);
                   oItem.Quantity = Decimal.valueOf(orderItemWrap.quantity);
                   oItem.Requested_Delivery_Date__c = orderItemWrap.reqDeliveryDate;
                   lstOrderItemUpdate.add(oItem);
                   isDuplicate=true;
               }
                
                if(!isDuplicate)
                {
                    OrderItem oItem = new OrderItem();        
                    oItem.OrderId = o.Id;
                    oItem.Discount__c = Decimal.valueOf(orderItemWrap.discount);
                    oItem.FreeOfChargeQuantity__c = Decimal.valueOf(orderItemWrap.freeOfChargeQuantity);
                    oItem.FreeOfChargePercent__c = Decimal.valueOf(orderItemWrap.percentageOfFreeCharge);
                    oItem.PricebookEntryId = orderItemWrap.pricebookentryId;
                    oItem.Product2Id = orderItemWrap.prodName.Id;
                    oItem.Quantity = Decimal.valueOf(orderItemWrap.quantity);
                    oItem.UnitPrice = Decimal.valueOf(orderItemWrap.unitPrice);
                    oItem.SAP_Unit_Of_Measure__c = orderItemWrap.uom;
                    oItem.Requested_Delivery_Date__c =orderItemWrap.reqDeliveryDate;
                    oItem.IsPortalCreated__c = true;
                    lstOrderItemInsert.add(oItem);
                 }
            }
            // Perform updates and inserts separately
            if (!lstOrderItemInsert.isEmpty()) {
                insert lstOrderItemInsert;
            }
            if (!lstOrderItemUpdate.isEmpty()) {
                update lstOrderItemUpdate;
      }
      List<Shipping_Document__c> lstShipDocs = [
        SELECT
          Id,
          Document_Type__c,
          Electronic_by_Email__c,
          Original_By_Courier__c,
          Other_Document__c
        FROM Shipping_Document__c
      ];

      for (Shipping_Document__c shipDoc : lstShipDocs) {
        for (ShippingDoc sDoc : orderWrap.lstShippingDocs) {
          if (shipDoc.Id == sDoc.Id) {
            shipDoc.Electronic_by_Email__c = sDoc.elecByEmail;
            shipDoc.Original_By_Courier__c = Decimal.valueOf(
              sDoc.originalByCourier
            );
            shipDoc.Other_Document__c = sDoc.docRemarks;
          }
        }
      }

      system.debug('Updated Shipping docs ==>' + lstShipDocs);
      update lstShipDocs;

      return o.Id;
    } catch (Exception e) {
      system.debug(e.getMessage());
      system.debug(e.getLineNumber());
      throw new AuraHandledException(e.getMessage());
    }
  }
    
    
  //Added by Saranya [] -- To get files from Agreements where Name is - Signed.pdf if the Order is Submitted 
  @AuraEnabled
  public static String getFileFromAgreement(Id orderId){
    blob attachBody;
    List<Attachment> agreeAttachments = AttachmentsSelector.getAgreementAttachment(orderId);
      if (!agreeAttachments.isEmpty()) {
            return EncodingUtil.base64Encode(agreeAttachments[0].Body);
        } else {
            return null;
        }
  }

  //Added by NamrataP [7/14/21] -- Adobe Implementation
  @AuraEnabled
  public static string adobeSendForSignature(string orderID) {
    try {
      String agreementId;
      String response;        
                    
      List<echosign_dev1__SIGN_Data_Mapping__c> dataMappings = [
        SELECT Id
        FROM echosign_dev1__SIGN_Data_Mapping__c
        WHERE Name = 'Distributor Order DM'
      ];
      Order objOrder = [
        SELECT Id, BillToContactId, PoNumber, AccountId
        FROM Order
        WHERE Id = :orderId
      ];
        
      System.debug('Apex Data-->>' + objOrder);

      //Create Agreement
      echosign_dev1__SIGN_Agreement__c objAgreement = new echosign_dev1__SIGN_Agreement__c();
      objAgreement.name = 'Zoetis New Order Agreement -' + objOrder.PoNumber;
      objAgreement.Order__c = objOrder.Id;
      objAgreement.echosign_dev1__Signature_Flow__c = 'Any Order';
      // Set Data Mapping if found, used to update the Order post-signature based on Adobe Data Mapping configuration.
      if (!dataMappings.isEmpty()) {
        objAgreement.echosign_dev1__Process_Template__c = dataMappings[0].Id;
      }
      //Fetch Email Id of from Contact Linked to Orders Account
      Contact objBillToCon = [
        SELECT id, Email
        FROM Contact
        WHERE Id = :objOrder.BillToContactId
      ];
      objAgreement.echosign_dev1__Recipient_Addresses__c = objBillToCon.Email;
      insert objAgreement;

      if (!String.isBlank(objAgreement.Id)) {
        agreementId = objAgreement.Id;
        //Convert Agreement into PDF
        Attachment objAttachment = new Attachment();
        objAttachment.Name = objOrder.PoNumber + '.pdf';
        objAttachment.parentId = objAgreement.Id;
        objAttachment.description = 'Order Agreement';
        PageReference pdfPage = Page.alphaOrderPDF;
        pdfPage.getParameters().put('id', objOrder.Id);

        Blob b;
        if (Test.isRunningTest()) {
          b = blob.valueof('TEST');
        } else {
          b = pdfPage.getContentAsPDF();
        }
        objAttachment.body = b;
        system.debug('Attachment--->' + objAttachment);
        insert objAttachment;
      }
      response = agreementId + '|' + objBillToCon.Email;
      return response;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
    
  @AuraEnabled
  public static string sendForSignatureRemote(string agreementId) {
    try {
      Http h = new Http();
      HttpRequest req = new HttpRequest();
      String responseString;
      req.setEndpoint('callout:Touchpoint_ApexRest_API' + '/Adobe/v1/eSign/');
      req.setMethod('PUT');
      req.setHeader('Content-Type', 'application/json');
      req.setHeader('Accept', 'application/json');

      String reqBody = '{"documents":[{"Id":"' + agreementId + '"}]}';
      req.setBody(reqBody);

      HttpResponse res = h.send(req);
      System.debug('res: ' + res);
      System.debug('Response Headers: ' + res.getHeaderKeys());
      System.debug(res.getHeader('Location'));
      while (res.getStatusCode() == 302) {
        req.setEndpoint(res.getHeader('Location'));
        res = h.send(req);
      }
      responseString = res.getBody();
      return responseString;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled(cacheable=true)
  public static OrderWrapper getOrderRecord(string orderId) {
    try {
      System.debug('ORDER ID==>' + orderId);
      // string accountId = '0011g00000u7SSdAAM';// for testing...
      //Getting order data from DB.....
      // String orderId = '8011g000001Kl0zAAC'; //for testing..

      Order o = [
        SELECT
          Id,
          Status,
          AccountId,
          BillToContactId,
          PoDate,
          Phone__c,
          Fax__c,
          Sales_Org__c,
          PoNumber,
          Mode_of_Transport__c,
          Customer_Comments__c,
          BillToContact.Name,
          EffectiveDate,
          Pricebook2Id,
          ZTS_EU_Market__c,
          Ship_To_Address__c,
          CurrencyIsoCode,
          (
            SELECT
              Id,
              PricebookEntryId,
              Product2Id,
              SAP_Unit_Of_Measure__c,
              Requested_Delivery_Date__c,
              UnitPrice,
              FreeOfChargePercent__c,
              FreeOfChargeQuantity__c,
              Discount__c,
              Quantity,
              Product2.SAP_Material__r.SAP_Product_Number__c,
              Product2.Name
            FROM OrderItems ORDER BY Product2.Name ASC
          ),
          (
            SELECT
              Id,
              Document_Type__c,
              Electronic_by_Email__c,
              Original_By_Courier__c,
              Other_Document__c
            FROM Shipping_Documents__r
          )
        FROM Order
        WHERE Id = :orderId
      ];
       system.debug('oooooo'+o);
      //Loading addressess...
      List<Address__c> lstAddr = new List<Address__c>();
      lstAddr = [
        SELECT
          ZTS_EU_Account__c,
          Account_Ultimate_Parent_Name__c,
          CurrencyIsoCode,
          Id,
          Name,
          OwnerId,
          ZTS_EU_Address_Type__c,
          Full_Address__c,
          ZTS_EU_Account__r.Name,
          ZTS_EU_Primary_Address__c,
          ZTS_EU_Account__r.Incoterms_Description__c,
          ZTS_US_Source_Account_Number__c,
          ZTS_EU_Account__r.Distributor_Payment_Terms__c,
          ZTS_EU_Account__r.Incoterms__c,
          ZTS_EU_Account__r.ZTS_EU_Country__c
        FROM Address__c
        WHERE ZTS_EU_Account__c = :o.AccountId
        AND ZTS_US_Source_Account_Number__c != NULL
      ];

      Address__c mainAddr;
      Address__c shipToAddr;
      List<Address__c> lstShipToAddr = new List<Address__c>();
      for (Address__c address : lstAddr) {
        if (address.ZTS_EU_Address_Type__c == 'Main') {
          mainAddr = address;
          //  lstShipToAddr.add(address);
        } else if (address.ZTS_EU_Address_Type__c == 'Ship To') {
          system.debug(address);
          lstShipToAddr.add(address);
        }
        if (address.Id == o.Ship_To_Address__c) {
          shipToAddr = address;
        }
      }

      //if no ship to is present...put the main address..
      if (lstShipToAddr.size() == 0) {
        lstShipToAddr.add(mainAddr);
      }

      OrderWrapper orderWrap = new OrderWrapper();
      //load address options for ship to address....
      orderWrap.shipToAddrOptions = lstShipToAddr; // [SELECT Id,Name FROM Address__c LIMIT 5];
      // system.debug('$$$$$$$$ '+mainAddr.ZTS_EU_Account__c+ '   ' +mainAddr.ZTS_EU_Account__r.Name);
      orderWrap.companyName = new Account(
        Id = mainAddr.ZTS_EU_Account__c,
        Name = mainAddr.ZTS_EU_Account__r.Name
      );
      orderWrap.tel = o.Phone__c;
      orderWrap.fax = o.Fax__c;
      orderWrap.contactName = o.BillToContact.Name;
      orderWrap.purchaseOrderNo = o.PoNumber;
      orderWrap.purchaseOrderDate = System.today();
      orderWrap.shipToAddr = shipToAddr;
      orderWrap.soldToAddr = mainAddr;
      orderWrap.grandTotal = '';
      orderWrap.remarks = o.Customer_Comments__c;
      orderWrap.userId = o.BillToContactId;
      orderWrap.market = o.ZTS_EU_Market__c;
      orderWrap.status = o.Status;
      orderWrap.Id = o.Id;
      orderWrap.modeOfTransport = o.Mode_of_Transport__c;
       orderWrap.currencyValue = o.CurrencyIsoCode;
      orderWrap.incoterms =
        mainAddr.ZTS_EU_Account__r.Incoterms__c +
        '-' +
        mainAddr.ZTS_EU_Account__r.Incoterms_Description__c;
      orderWrap.termsOfPayment = mainAddr.ZTS_EU_Account__r.Distributor_Payment_Terms__c;
      orderWrap.eSignature = '';
      orderWrap.SalesOrg = o.Sales_Org__c;
      orderWrap.country = mainAddr.ZTS_EU_Account__r.ZTS_EU_Country__c;
      //load address options for ship to address....
      // orderWrap.shipToAddrOptions  = lstAddr;//[SELECT Id,Name FROM Address__c LIMIT 5];

      orderWrap.lstContact = [
        SELECT Id, Name
        FROM Contact
        WHERE AccountId = :o.AccountId
      ];

      //get free of charge related data..
      List<AccountProductPortfolio__c> lstAccProdFolio = [
        SELECT
          Id,
          Name,
          FreeOfChargePercent__c,
          FreeOfChargeQuantity__c,
          Discount__c,
          Product__c
        FROM AccountProductPortfolio__c
        WHERE Account__c = :o.AccountId
      ];

      List<OrderItemWrapper> lstOrderItems = new List<OrderItemWrapper>();
      List<String> lstOfProdIds = new List<String>();
      for (OrderItem oItem : o.OrderItems) {
        OrderItemWrapper orderItemWrap = new OrderItemWrapper();
        orderItemWrap.Id = oItem.Id;
        orderItemWrap.pricebookentryId = oItem.PricebookEntryId;
        lstOfProdIds.add(oItem.Product2Id);
        orderItemWrap.prodId = oItem.Product2Id;
        // orderItemWrap.prodName = new Product2(Id=oItem.Product2Id,Name='Temp');
        orderItemWrap.uom = oItem.SAP_Unit_Of_Measure__c;
        orderItemWrap.sapMaterialNo = oItem.Product2.SAP_Material__r.SAP_Product_Number__c;
        orderItemWrap.prodName = new Product2(
          Id = oItem.Product2Id,
          Name = oItem.Product2.Name
        );
        orderItemWrap.reqDeliveryDate = oItem.Requested_Delivery_Date__c;
        orderItemWrap.unitPrice = string.valueOf(oItem.UnitPrice);
        for (AccountProductPortfolio__c accProd : lstAccProdFolio) {
          if (oItem.Product2Id == accProd.Product__c) {
            orderItemWrap.percentageOfFreeCharge = String.ValueOf(
              accProd.FreeOfChargePercent__c
            );
            orderItemWrap.freeOfChargeQuantity = String.ValueOf(
              accProd.FreeOfChargeQuantity__c
            );
            orderItemWrap.discount = String.ValueOf(accProd.Discount__c);
          }
        }

        if (orderItemWrap.percentageOfFreeCharge == null)
          orderItemWrap.percentageOfFreeCharge = '0';
        if (orderItemWrap.freeOfChargeQuantity == null)
          orderItemWrap.freeOfChargeQuantity = '0';
        if (orderItemWrap.discount == null)
          orderItemWrap.discount = '0';

        // orderItemWrap.percentageOfFreeCharge= '0' ;
        // orderItemWrap.freeOfChargeQuantity= '0' ;
        orderItemWrap.quantity = string.valueOf(oItem.Quantity);
        lstOrderItems.add(orderItemWrap);
      }
      
       List<ContentDocumentLink> cd = ContentDocumentLinksSelector.selectContentDocumentById(new List<Id>{o.Id});

          map<Id,AttachmentWrapper> attachmentDetailsWrapper = new map<Id,AttachmentWrapper>();
              
            for(ContentDocumentLink attacDoc :cd)
            {
                //converting contentSize from byte to KB 
                 Decimal kb = Decimal.valueOf(attacDoc.ContentDocument.ContentSize);
                  kb = kb.divide(1024,2);
                //adding attachment details into wrapper vaiable
               AttachmentWrapper attachmentWrapper = new AttachmentWrapper();
                 attachmentWrapper.name = attacDoc.ContentDocument.Title;
                 attachmentWrapper.contentType = attacDoc.ContentDocument.FileType;
                 attachmentWrapper.contentSize = string.valueOf(kb) + ' KB';
                 attachmentWrapper.Id = attacDoc.ContentDocumentId;
                 if(!attachmentDetailsWrapper.containsKey(attacDoc.Id))
                 {
                 attachmentDetailsWrapper.put(attacDoc.Id,attachmentWrapper);
                 }
           }
      List<ShippingDoc> lstShipDocs = new List<ShippingDoc>();
      for (Shipping_Document__c shipDoc : o.Shipping_Documents__r) {
        ShippingDoc sd = new ShippingDoc();
        sd.docRemarks = shipDoc.Other_Document__c;
        sd.docType = shipDoc.Document_Type__c;
        sd.elecByEmail = shipDoc.Electronic_by_Email__c;
        sd.originalByCourier = string.valueOf(shipDoc.Original_By_Courier__c);
        sd.Id = shipDoc.Id;

        lstShipDocs.add(sd);
      }
             orderWrap.attachmentDetails = attachmentDetailsWrapper.values();
                  orderWrap.lstOrdItm = lstOrderItems;
                  orderWrap.lstShippingDocs = lstShipDocs;
                System.debug('ORDER WRAP==>' + orderWrap);
        return orderWrap;
    } 
    catch (Exception e) {
      throw new AuraHandledException(e.getStackTraceString());
    }   
  }

 @AuraEnabled
    public static List<ContentVersion> downloadFile(String fileId)
    {
        List<ContentVersion> cv = ContentVersionsSelector.selectByContentDocumentId(fileId);
        return cv;
    }

     @AuraEnabled
    public static OrderItemWrapper addProductOrder(string productId, string selectedCurrencyCode){

      List<String> lstOfProdIds = new List<String>();
      OrderItemWrapper orderItemWrap = new OrderItemWrapper();
      Date currentDate = System.today();
      Date futureDate = currentDate.addDays(15);

      //Getting the account  info..
      List<Account> accList = UtilityController.returnObjList();
      string accountId = accList[0].Id;

      //Loading addressess...
     List<Address__c> lstAddr = new List<Address__c>();
      lstAddr = [
        SELECT
          ZTS_EU_Address_Type__c,
          ZTS_US_Source_Account_Number__c 
        FROM Address__c
        WHERE ZTS_EU_Account__c = :accountId 
        AND ZTS_US_Source_Account_Number__c != NULL
      ]; 
        
       
      Address__c mainAddr;
      List<Address__c> lstShipToAddr = new List<Address__c>();
      for (Address__c address : lstAddr) {
        if (address.ZTS_EU_Address_Type__c == 'Main') {
          mainAddr = address;
        }
      }
        
      //Loading SAP Mat price..
      ISAPCustomerMaterialPricesSelector sapSelector = SAPCustomerMaterialPricesSelector.newInstance();
      List<SAPCustomerMaterialPrice__c> prodItem = SAPCustomerMaterialPricesService.removeDuplicateRecords(
                                                      sapSelector.selectValidByCustomerNumbersAndProductIds(
                                                          new Set<String> {mainAddr.ZTS_US_Source_Account_Number__c}, new Set<Id> {productId}));
        
          //Get the Price book entry information...
      List<Pricebook2> pricebook = [
        SELECT Id, CurrencyIsoCode
        FROM PriceBook2
        WHERE IsStandard = TRUE
      ];
      List<PriceBookEntry> pbentries = [
        SELECT Id, Product2Id
        FROM PriceBookEntry
        WHERE
          Product2Id =: productId
          AND PriceBook2Id = :pricebook[0].Id
          AND CurrencyIsoCode = :selectedCurrencyCode
      ]; 

      orderItemWrap.Id =prodItem[0].Product__c;
      if(prodItem != null){
        if (orderItemWrap.discount == null)
            orderItemWrap.discount = '0.00';    
        if (orderItemWrap.percentageOfFreeCharge == null)
            orderItemWrap.percentageOfFreeCharge = '0.00';
        if (orderItemWrap.freeOfChargeQuantity == null)
            orderItemWrap.freeOfChargeQuantity = '0'; 
        orderItemWrap.prodId = prodItem[0].Product__c;
        orderItemWrap.prodName = new Product2(Id=prodItem[0].Product__c,Name = prodItem[0].Product__r.Name);
	     	orderItemWrap.unitPrice = string.valueOf(prodItem[0].Price__c);  
         orderItemWrap.uom = String.valueof(
          String.isBlank(prodItem[0].Unit_of_Measure__c)
         ? prodItem[0].Product__r.SAP_Material__r.SAP_Sales_Unit_of_Measure__c 
           : prodItem[0].Unit_of_Measure__c
        );
        orderItemWrap.sapMaterialNo = prodItem[0].Product__r.SAP_Material__r.SAP_Product_Number__c;
      }

        List<AccountProductPortfolio__c> lstAccProdFolio = [
            SELECT
            Id,
            Name,
            FreeOfChargePercent__c,
            FreeOfChargeQuantity__c,
            Discount__c,
            Product__c
            FROM AccountProductPortfolio__c where Product__c =:productId ];
        
        orderItemWrap.pricebookentryId = pbentries[0].Id;
        orderItemWrap.reqDeliveryDate = futureDate; 
        orderItemWrap.quantity = '0.00';
        orderItemWrap.totalprice = '0.00';
        for (AccountProductPortfolio__c accProd : lstAccProdFolio) {
            if (prodItem[0].Product__c == accProd.Product__c) {
                if(accProd.FreeOfChargePercent__c!=null)
                {
                    orderItemWrap.percentageOfFreeCharge = String.ValueOf(
                        accProd.FreeOfChargePercent__c
                    );
                }
                if(accProd.FreeOfChargeQuantity__c!=null)
                {
                    orderItemWrap.freeOfChargeQuantity = String.ValueOf(
                        accProd.FreeOfChargeQuantity__c
                    );
                }
                if(accProd.Discount__c!=null)
                {
                    orderItemWrap.discount = String.ValueOf(accProd.Discount__c);
                }
                
            }
        }
        return orderItemWrap ;
       
    }
    
  
    @AuraEnabled
    public static Boolean changeOrderStatus(Id orderId) {
        try {
            List<Order> orders = [SELECT ID, Status 
                             FROM Order
                             WHERE ID =: orderId];
            List<Order> updatedOrders = new List<Order>();
            for(Order order: orders) {
                order.Status = 'Submitted';
                updatedOrders.add(order);
            }
            Boolean insertSuccess = false;
            Database.SaveResult[] SRS = Database.update(updatedOrders, false);
            System.debug('srs' + srs);
            for(Database.SaveResult sr: srs) {
                if(sr.isSuccess()){
                    insertSuccess = true;
                } else {
                    insertSuccess = false;
                    break;
                }
            }
        	return insertSuccess;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }


    
  public class OrderWrapper {
    @AuraEnabled
    public string Id;
    //company info vars..
    @AuraEnabled
    public Account companyName;
    @AuraEnabled
    public string tel;
    @AuraEnabled
    public string fax;
    @AuraEnabled
    public string contactName;
    @AuraEnabled
    public string userId;

    @AuraEnabled
    public List<Contact> lstContact;

     @AuraEnabled
    public string country;

    //order details vars..
    @AuraEnabled
    public string purchaseOrderNo;
    @AuraEnabled
    public Date purchaseOrderDate;
    @AuraEnabled
    public Address__c shipToAddr;
    @AuraEnabled
    public Address__c soldToAddr;
    @AuraEnabled
    public string grandTotal;
    @AuraEnabled
    public string remarks;
    @AuraEnabled
    public string status;
    @AuraEnabled
    public string SalesOrg;
    @AuraEnabled
    public List<Address__c> shipToAddrOptions;

    //More Info vars..
    @AuraEnabled
    public string currencyValue;
    @AuraEnabled
    public string modeOfTransport;
    @AuraEnabled
    public string incoterms;
    @AuraEnabled
    public string termsOfPayment;

    @AuraEnabled
    public List<ShippingDoc> lstShippingDocs;

    @AuraEnabled
    public List<OrderItemWrapper> lstOrdItm;

    @AuraEnabled
    public string eSignature;

    @AuraEnabled
    public string market;

    @AuraEnabled
    public string pricebookId;
    
    @AuraEnabled
   public List<AttachmentWrapper> attachmentDetails;  
  }

  public class OrderItemWrapper {
    @AuraEnabled
    public string Id;
    @AuraEnabled
    public string sapMaterialNo;
    @AuraEnabled
    public Product2 prodName;
    @AuraEnabled
    public string quantity;
    @AuraEnabled
    public string uom;
    @AuraEnabled
    public Date reqDeliveryDate;
    @AuraEnabled
    public string unitPrice;
    @AuraEnabled
    public string percentageOfFreeCharge;
    @AuraEnabled
    public string freeOfChargeQuantity;
    @AuraEnabled
    public string discount;
    @AuraEnabled
    public string totalprice;
    @AuraEnabled
    public string pricebookentryId;
    @AuraEnabled
    public string SalesOrg;
    @AuraEnabled
    public string supplyPoint;

    public string prodId;
  }
  public class ShippingDoc {
    //Shipping doc vars..
    @AuraEnabled
    public string docType;
    @AuraEnabled
    public string originalByCourier;
    @AuraEnabled
    public Boolean elecByEmail;
    @AuraEnabled
    public string docRemarks;
    @AuraEnabled
    public string Id;
  }
  public class MasterData {
    @AuraEnabled
    public List<SAPCustomerMaterialPrice__c> lstMatPrice;
    @AuraEnabled
    public List<String> modeOfTransport;
  }
  public class SubmissionResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String errorMessage;
  public SubmissionResponse(boolean success, string errorMessage) {
        this.success = success;
        this.errorMessage = errorMessage;
    }
public SubmissionResponse(boolean success) {
        this.success = success;
    }
  }   
  public class AttachmentWrapper{
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string contentType;
        @AuraEnabled
        public string contentSize;
    }
    
}