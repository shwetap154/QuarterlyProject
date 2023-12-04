/**
 * @description       :
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 03-18-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Ver   Date         Author                       Modification
 * 1.0   08-29-2021   Morgan Marchese @ Zoetis Inc Initial Version
 * 1.1   03-18-2022   Ethan Hirsch @ Zoetis Inc    Update deleteOrderTest to verify resposne is returned correctly.
                                                   Added new test to verify an Order can't be deleted if it's related to an Agrement
 * 
 **/
@isTest
public class alphaCreateOrder_Test {
  private static Profile p = [
    SELECT id
    FROM profile
    WHERE name = 'Distributor Community User'
  ];
  private static Pricebook2 standardPricebook = new Pricebook2(
    Id = Test.getStandardPricebookId(),
    IsActive = true
  );

  @TestSetup
  private static void makeData() {
    //Execute an update DML on the Pricebook2 record, to make IsStandard = true
    update standardPricebook;
    Profile p = [
      SELECT id
      FROM profile
      WHERE name = 'Distributor Community User'
    ];
      
      Profile p2 = [
      SELECT id
      FROM profile
      WHERE name = 'Distributor Market Admin'
    ];
      
     List<UserRole> usrrole = [
      SELECT Id,Name
      FROM UserRole
      WHERE name = 'Sales Operations'
    ];
      
      User usr2 = new User(
      alias = 'test',
      email = 'zoetisDistributorTest2@test.zts.com',
      emailencodingkey = 'UTF-8',
      lastname = 'Testing2',
      languagelocalekey = 'en_us',
      localesidkey = 'en_us',
      profileid = p2.Id,
      UserRoleId = usrrole[0].Id,
      ZTS_EU_Market__c = 'ALPHA',
      timezonesidkey = 'America/Los_Angeles',
      username = 'zoetisDistributorTest2@test.zts.com'
    );
      Id tempId2 = UserInfo.getUserId();
      User currUser2 = [
      SELECT Id
      FROM User WHERE Id = :tempId2
      LIMIT 1
    ];
    System.runAs(currUser2) {
      insert usr2;
    }
      
    account acc = new account();
    acc.name = 'test acc';
    acc.ZTS_EU_Market__c = 'ALPHA';
    acc.ZTS_EU_Country__c = 'United Kingdom';
    acc.ZTS_EU_Zip_Postal_Code__c = '00000';
    acc.BillingStreet = '123 Street';
    acc.BillingCity = 'Parsippany';
    acc.BillingState = 'New Jersey';
    acc.BillingPostalCode = '07054';
    acc.BillingCountry = 'United States';
    acc.OwnerId = usr2.Id;
    DispatchTriggerHandler.bypass('AccountTriggerHandler');
    insert acc;
    DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

    contact con = new contact();
    con.lastname = 'test last';
    con.accountid = acc.id;
    con.email = 'test@email.com';
    con.ZTS_EU_Market__c = 'ALPHA';
    DispatchTriggerHandler.bypass('ContactTriggerHandler');
    insert con;
    DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
      
    User usr = new User(
      alias = 'standt',
      email = 'zoetisDistributorTest@test.zts.com',
      emailencodingkey = 'UTF-8',
      lastname = 'Testing',
      languagelocalekey = 'en_us',
      localesidkey = 'en_us',
      profileid = p.Id,
      ZTS_EU_Market__c = 'ALPHA',
      timezonesidkey = 'America/Los_Angeles',
      contactid = con.id,
      username = 'zoetisDistributorTest@test.zts.com'
    );
      Id tempId = UserInfo.getUserId();
      system.debug('tempId::'+tempId);
      User currUser = [
      SELECT Id
      FROM User WHERE Id = :tempId
      LIMIT 1
    ];
    System.runAs(currUser) {
      insert usr;
    }
    

    State_Country__c stc = new State_Country__c();
    stc.name = 'test co';
    stc.ZTS_EU_Country__c = 'Albania';
    insert stc;

    List<Address__c> addresses = new List<Address__c>();
    Address__c address = new Address__c();
    address.name = 'test line';
    address.ZTS_EU_Account__c = acc.id;
    address.ZTS_EU_District__c = 'Teast';
    address.ZTS_EU_Country__c = 'Albania';
    address.ZTS_EU_State_County__c = stc.id;
    address.Zip_Postal_Code__c = '738747';
    address.ZTS_EU_Address_Type__c = 'Main';
    address.ZTS_US_Source_Account_Number__c = '1000908090';
    addresses.add(address);

    Address__c address2 = new Address__c();
    address2.name = 'test line';
    address2.ZTS_EU_Account__c = acc.id;
    address2.ZTS_EU_District__c = 'Teast';
    address2.ZTS_EU_Country__c = 'Albania';
    address2.ZTS_EU_State_County__c = stc.id;
    address2.Zip_Postal_Code__c = '738747';
    address2.ZTS_EU_Address_Type__c = 'Ship To';
    address2.ZTS_US_Source_Account_Number__c = '1000908090';
    addresses.add(address2);

    insert addresses;

    Product2 prod = new Product2(Name = 'Laptop X200Test', Family = 'Hardware');
    insert prod;

    SAPCustomerMaterialPrice__c sapc = new SAPCustomerMaterialPrice__c();
    sapc.Customer_Number__c = '1000908090';
    sapc.Product__c = prod.id;
    sapc.Sales_Organization__c = '2941';
    sapc.Material_Number__c = 'test';
    sapc.Valid_From__c = system.today();
    sapc.Valid_To__c = system.today().adddays(10);
    sapc.Price__c = 20;
    sapc.External_ID__c = '123456';
    sapc.Market__c = 'Panama';
    insert sapc;

    AccountProductPortfolio__c acp = new AccountProductPortfolio__c();
    acp.Account__c = acc.id;
    acp.Product__c = prod.Id;
    insert acp;

    order orderobj = new order();
    orderobj.Accountid = acc.id;
    orderobj.Status = 'Submitted';
    orderobj.EffectiveDate = system.today();
    orderobj.CurrencyIsoCode= 'EUR';
    orderobj.BillToContactId = con.Id;
    orderobj.Pricebook2Id = standardPricebook.Id;
    orderobj.RecordTypeId = OrderHandler.distributorOrderRTId;
    insert orderobj;

    //Create the PricebookEntry
    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = standardPricebook.Id,
      Product2Id = prod.Id,
      UnitPrice = 1020,
      IsActive = true,
      CurrencyIsoCode = 'EUR'
    );
    insert pbe;

    OrderItem oi = new OrderItem();

    oi.OrderId = orderobj.id;
    oi.IsPortalCreated__c = true;
    oi.Quantity = decimal.valueof('1');
    oi.PricebookEntryId = pbe.id;
    oi.UnitPrice = pbe.UnitPrice;
     oi.Discount__c = 0;
      oi.Product2Id = prod.Id;
      oi.SAP_Unit_Of_Measure__c = sapc.Material_Number__c;
    insert oi;

    Shipping_Document__c sd = new Shipping_Document__c();
    sd.Order__c = orderobj.Id;
    sd.Original_By_Courier__c = 3;
    sd.Electronic_by_Email__c = true;
    sd.Document_Type__c = 'Invoice';
    insert sd;

    Document document;

    document = new Document();
    document.Body = Blob.valueOf('Some Text');
    document.ContentType = 'application/pdf';
    document.DeveloperName = 'my_document';
    document.IsPublic = true;
    document.Name = 'My Document';
    document.FolderId = [SELECT id FROM folder WHERE name = 'Quotes'].id;
    insert document;
      
          
       
      
     
      
  }
   
 
    @isTest
    static void testGetFileFromAgreement(){
        
        account acc = new account();
        acc.name = 'test acc';
        insert acc;
        
        Order testOrder = new Order();
        testOrder.Accountid = acc.id;
        //testOrder.Account_Name__c='test Acc';
        testOrder.EffectiveDate = Date.today();
        testOrder.Status='Submitted';

        
        insert testOrder;
         echosign_dev1__SIGN_Agreement__c testAgreement = new echosign_dev1__SIGN_Agreement__c();
        testAgreement.Order__c = testOrder.Id;
          
        insert testAgreement;
         Attachment testAttachment = new Attachment(
        ParentId = testAgreement.Id,
        Name = 'TestAttachment - Signed.pdf',
        Body = Blob.valueOf('Test Attachment Content')
    );
        insert testAttachment;
        String result = alphaCreateOrder.getFileFromAgreement(testOrder.Id);
        System.assertNotEquals(null, result);
        
    }
    

  public static testMethod void saveOrderTest() {
    List<Account> accounts = [SELECT Id, Name FROM Account];
    List<Contact> contacts = [SELECT Id, Name FROM Contact];
    List<Address__c> addresses = [SELECT Id, Name FROM Address__c];
    List<PriceBookEntry> pbe = [
      SELECT Id
      FROM PriceBookEntry
      WHERE
        Product2.Name = 'Laptop X200Test'
        AND PriceBook2Id = :standardPricebook.Id
    ];
    List<Product2> products = [
      SELECT Id, Name
      FROM Product2
      WHERE Name = 'Laptop X200Test'
    ];
    List<Order> ordersBefore = [SELECT Id FROM Order];
    delete ordersBefore;
      
   Test.startTest();
         
    try{     
    alphaCreateOrder.saveOrder(
      '{"companyName":{"Id":"' +
      accounts[0].id +
      '","Name":"' +
      accounts[0].name +
      '"},"contactName":"' +
      contacts[0].Name +
      '","currencyValue":"EUR","lstContact":[{"Id":"' +
      contacts[0].Id +
      '","Name":"' +
      contacts[0].Name +
      '"}],"lstOrdItm":[{"Id":"","discount":"5.00","freeOfChargeQuantity":0,"percentageOfFreeCharge":"10.00","prodName":{"Id":"' +
      products[0].Id +
      '","Name":"' +
      products[0].Name +
      '"},"quantity":"1","reqDeliveryDate":"2021-08-27","sapMaterialNo":"000000000010000312","totalprice":0,"unitPrice":"317.5397032","pricebookentryId":"' +
      pbe[0].Id +
      '","SalesOrg":"1498","supplyPoint":"South Africa"}],"lstShippingDocs":[{"docType":"Invoice","originalByCourier":"1","elecByEmail":false,"docRemarks":"","Id":"1","isOtherVisible":false}],"shipToAddr":{"ZTS_EU_Account__c":"' +
      accounts[0].id +
      '","Account_Ultimate_Parent_Name__c":"' +
      accounts[0].name +
      '","CurrencyIsoCode":"EUR","Id":"' +
      addresses[0].Id +
      '","Name":"' +
      addresses[0].Name +
      '","ZTS_EU_Address_Type__c":"Main","ZTS_EU_Primary_Address__c":true,"ZTS_US_Source_Account_Number__c":"1000060365","Full_Address__c":"Kakiri town, Wakiso,256,Kakiri,Uganda","ZTS_EU_Account__r":{"Name":"' +
      accounts[0].Id +
      '","Payment_Term__c":"Net 30","Id":"' +
      accounts[0].Id +
      '"}},"shipToAddrOptions":[{"ZTS_EU_Account__c":"' +
      accounts[0].id +
      '","Account_Ultimate_Parent_Name__c":"' +
      accounts[0].name +
      '","CurrencyIsoCode":"EUR","Id":"' +
      addresses[0].Id +
      '","Name":"' +
      addresses[0].Name +
      '","ZTS_EU_Address_Type__c":"Main","ZTS_EU_Primary_Address__c":true,"ZTS_US_Source_Account_Number__c":"1000060365","Full_Address__c":"Kakiri town, Wakiso,256,Kakiri,Uganda","ZTS_EU_Account__r":{"Name":"' +
      accounts[0].Id +
      '","Payment_Term__c":"Net 30","Id":"' +
      accounts[0].Id +
      '"}}],"soldToAddr":{"ZTS_EU_Account__c":"' +
      accounts[0].Id +
      '","Account_Ultimate_Parent_Name__c":"' +
      accounts[0].Name +
      '","CurrencyIsoCode":"EUR","Id":"' +
      addresses[0].Id +
      '","Name":"' +
      addresses[0].Name +
      '","ZTS_EU_Address_Type__c":"Main","ZTS_EU_Primary_Address__c":true,"ZTS_US_Source_Account_Number__c":"1000060365","Full_Address__c":"Kakiri town, Wakiso,256,Kakiri,Uganda","ZTS_EU_Account__r":{"Name":"' +
      accounts[0].Id +
      '","Payment_Term__c":"Net 30","Id":"' +
      accounts[0].Id +
      '"}},"grandTotal":"2.22","status":"Submitted","tel":"12345","termsOfPayment":"Net 30","pricebookId":"' +
      standardPricebook.Id +
      '"}'
    );
      }
      catch (AuraHandledException e) {
          System.debug('MESSAGE -' + e.getMessage());
      }
    Test.stopTest(); 

  }

   
  public static testMethod void getColumnsTest() {
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    List<SObject> columns = new List<Order>();
    System.runAs(distributorUser) {
      columns = alphaCreateOrder.getColumns();
    }
    System.assert(!columns.isEmpty());
  } 

 public static testMethod void getOrderListTest() {
   User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    List<Order> orders = new List<Order>();
     
    System.runAs(distributorUser) {
      orders = alphaCreateOrder.getOrderList();
    }
    System.assert(!orders.isEmpty());
  }
      public static testMethod void getModeofTransportTest() {
    List<Account> accounts = [SELECT Id FROM Account];
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    alphaCreateOrder.MasterData data = new alphaCreateOrder.MasterData();
    System.runAs(distributorUser) {
      data = alphaCreateOrder.getModeofTransport();
    }
    System.assertNotEquals(null, data.lstMatPrice);
  }


  public static testMethod void prepareDataTest() {
    List<Account> accounts = [SELECT Id FROM Account];
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    SAPCustomerMaterialPrice__c temp = [SELECT Id FROM SAPCustomerMaterialPrice__c LIMIT 1];
    alphaCreateOrder.OrderWrapper data = new alphaCreateOrder.OrderWrapper();
    System.runAs(distributorUser) {
      data = alphaCreateOrder.prepareData('USD');
    }
    System.assertEquals(accounts[0].Id, data.companyName.Id);
    System.assertNotEquals(null, data.soldToAddr);
    temp.Market__c = '';
      upsert temp;
    System.runAs(distributorUser) {
      data = alphaCreateOrder.prepareData('USD');
    }
    System.assertEquals(accounts[0].Id, data.companyName.Id);
    System.assertNotEquals(null, data.soldToAddr);
  }
    
     public static testMethod void deleteOrderTest() {
    List<Order> orders = [SELECT Id FROM Order];
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    alphaCreateOrder.SubmissionResponse submissionResponse;
    Test.StartTest();
    System.runAs(distributorUser) {
      submissionResponse = alphaCreateOrder.deleteOrder(orders[0].id);
        
    }
    Test.StopTest();
         
   
    orders = [SELECT Id FROM Order];
    System.assert(orders.isEmpty());
  }
    
      public static testMethod void updateOrderStatus() {
    List<Account> accounts = [SELECT Id FROM Account];
    List<Order> orders = [SELECT Id FROM Order];
    orders[0].Status = 'Submitted';
    update new List<Order>{ orders[0] };
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    Test.startTest();
    alphaCreateOrder.OrderWrapper data = new alphaCreateOrder.OrderWrapper();
    System.runAs(distributorUser) {
      alphaCreateOrder.updateOrderStatus(orders[0].Id);
    }
    Test.StopTest();
    orders = [SELECT Status FROM Order];
    System.assertEquals('Draft', orders[0].Status);
  }
    
     public static testMethod void updateOrderTest() {
    List<Account> accounts = [SELECT Id, Name FROM Account];
    List<Contact> contacts = [SELECT Id, Name FROM Contact];
    List<Address__c> addresses = [SELECT Id, Name FROM Address__c];
    List<OrderItem> orderItems = [SELECT Id FROM OrderItem];
    List<Shipping_Document__c> shippingDocs = [
      SELECT Id
      FROM Shipping_Document__c
    ];
    List<PriceBookEntry> pbe = [
      SELECT Id
      FROM PriceBookEntry
      WHERE
        Product2.Name = 'Laptop X200Test'
        AND PriceBook2Id = :standardPricebook.Id
    ];
    List<Product2> products = [
      SELECT Id, Name
      FROM Product2
      WHERE Name = 'Laptop X200Test'
    ];
    List<Order> orders = [SELECT Id FROM Order];
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    String responseString;
         
    Test.StartTest();
    System.runAs(distributorUser) {
      alphaCreateOrder.updateOrder(
        '{"companyName":{"Id":"' +
        accounts[0].id +
        '","Name":"' +
        accounts[0].name +
        '"},"contactName":"' +
        contacts[0].Name +
        '","currencyValue":"EUR","lstContact":[{"Id":"' +
        contacts[0].Id +
        '","Name":"' +
        contacts[0].Name +
        '"}],"lstOrdItm":[{"Id":"' +
        orderItems[0].Id +
        '","discount":"5.00","freeOfChargeQuantity":0,"percentageOfFreeCharge":"10.00","prodName":{"Id":"' +
        products[0].Id +
        '","Name":"' +
        products[0].Name +
        '"},"quantity":"1","reqDeliveryDate":"2021-08-27","sapMaterialNo":"000000000010000312","totalprice":0,"unitPrice":"377.5397032","pricebookentryId":" ' +
        pbe[0].Id +
        ' ","SalesOrg":"1498","supplyPoint":"South Africa"}],"lstShippingDocs":[{"docType":"Invoice","originalByCourier":"1","elecByEmail":false,"docRemarks":"","Id":"' +
        shippingDocs[0].Id +
        '","isOtherVisible":false}],"shipToAddr":{"ZTS_EU_Account__c":"' +
        accounts[0].id +
        '","Account_Ultimate_Parent_Name__c":"' +
        accounts[0].name +
        '","CurrencyIsoCode":"EUR","Id":" ' +
        addresses[0].Id +
        ' ","Name":" ' +
        addresses[0].Name +
        ' ","ZTS_EU_Address_Type__c":"Main","ZTS_EU_Primary_Address__c":true,"ZTS_US_Source_Account_Number__c":"1000060365","Full_Address__c":"Kakiri town, Wakiso,256,Kakiri,Uganda","ZTS_EU_Account__r":{"Name":" ' +
        accounts[0].Id +
        ' ","Payment_Term__c":"Net 30","Id":" ' +
        accounts[0].Id +
        ' "}},"shipToAddrOptions":[{"ZTS_EU_Account__c":"' +
        accounts[0].id +
        '","Account_Ultimate_Parent_Name__c":"' +
        accounts[0].name +
        '","CurrencyIsoCode":"EUR","Id":" ' +
        addresses[0].Id +
        ' ","Name":" ' +
        addresses[0].Name +
        ' ","ZTS_EU_Address_Type__c":"Main","ZTS_EU_Primary_Address__c":true,"ZTS_US_Source_Account_Number__c":"1000060365","Full_Address__c":"Kakiri town, Wakiso,256,Kakiri,Uganda","ZTS_EU_Account__r":{"Name":" ' +
        accounts[0].Id +
        ' ","Payment_Term__c":"Net 30","Id":" ' +
        accounts[0].Id +
        ' "}}],"soldToAddr":{"ZTS_EU_Account__c":" ' +
        accounts[0].Id +
        ' ","Account_Ultimate_Parent_Name__c":" ' +
        accounts[0].Name +
        ' ","CurrencyIsoCode":"EUR","Id":" ' +
        addresses[0].Id +
        ' ","Name":" ' +
        addresses[0].Name +
        ' ","ZTS_EU_Address_Type__c":"Main","ZTS_EU_Primary_Address__c":true,"ZTS_US_Source_Account_Number__c":"1000060365","Full_Address__c":"Kakiri town, Wakiso,256,Kakiri,Uganda","ZTS_EU_Account__r":{"Name":" ' +
        accounts[0].Id +
        ' ","Payment_Term__c":"Net 30","Id":" ' +
        accounts[0].Id +
        ' "}},"grandTotal":"2.22","status":"Submitted","tel":"12345","termsOfPayment":"Net 30","pricebookId":"' +
        standardPricebook.Id +
        '","Id":"' +
        orders[0].Id +
        '"}'
      );
    }
    Test.StopTest();
         
         
         
  }
    
    public static testMethod void adobeSendForSignatureTest() {
    List<Order> orders = [SELECT Id FROM Order];
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    String responseString;
    Test.StartTest();
    System.runAs(distributorUser) {
      responseString = alphaCreateOrder.adobeSendForSignature(orders[0].id);
    }
    Test.StopTest();
    System.assert(responseString != null);
  } 
    
   public static testMethod void sendForSignatureRemoteTest() {
    List<Document> documents = [SELECT Id FROM Document LIMIT 1];
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
    Test.StartTest();
    String responseString;
    Test.setMock(
      HttpCalloutMock.class,
      new AdobeWS_SendForSignatureMock(
        200,
        'Success',
        '{"success":true}',
        new Map<String, String>()
      )
    );
    System.runAs(distributorUser) {
      responseString = alphaCreateOrder.sendForSignatureRemote(documents[0].id);
    }
    Test.StopTest();
    System.assert(responseString != null);
  }  
    
    
    
    public static testMethod void getOrderRecordTest() {
    List<Account> accounts = [SELECT Id FROM Account];
    List<Order> orders = [SELECT Id FROM Order];
    User distributorUser = [
      SELECT Id
      FROM User
      WHERE Username = 'zoetisDistributorTest@test.zts.com'
      LIMIT 1
    ];
         List<Id> orderIds = new List<Id>();
    for (Order order : orders) {
        orderIds.add(order.Id);
    }
  List<ContentDocumentLink> cdLinks = [
        SELECT Id, ContentDocumentId, LinkedEntityId,ContentDocument.Title,ContentDocument.ContentSize, 
          ContentDocument.FileType
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :orderIds
    ];

    if (!cdLinks.isEmpty()) {
        ContentDocumentLink testLink = new ContentDocumentLink();
        testLink.ContentDocument.Title = 'Test';
        testLink.ContentDocumentId = cdLinks[0].ContentDocumentId;
        testLink.LinkedEntityId = cdLinks[0].LinkedEntityId;
        testLink.ShareType = 'V';
        insert testLink;
    }
    alphaCreateOrder.OrderWrapper data = new alphaCreateOrder.OrderWrapper();
    System.runAs(distributorUser) {
      data = alphaCreateOrder.getOrderRecord(orders[0].Id);
    }
    System.assertEquals(accounts[0].Id, data.companyName.Id);
    System.assertNotEquals(null, data.soldToAddr);
  }
    
    public static testMethod void addProductOrderTest() {
        
        alphaCreateOrder.OrderItemWrapper actualResult;
        List<Account> accounts = [SELECT Id FROM Account];
        List<Order> orders = [SELECT Id FROM Order];
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem];
        List<Product2> products = [ SELECT Id FROM Product2 ];
        List<PriceBookEntry> pbe = [SELECT Id, CurrencyIsoCode FROM PriceBookEntry WHERE Product2ID =: products[0].Id AND PriceBook2Id = :standardPricebook.Id];
        User distributorUser = [
            SELECT Id
            FROM User
            WHERE Username = 'zoetisDistributorTest@test.zts.com'
            LIMIT 1
        ];
        
        Test.StartTest();
        System.runAs(distributorUser) {
        actualResult = alphaCreateOrder.addProductOrder(products[0].Id, pbe[0].CurrencyIsoCode);
        }
        Test.StopTest();
        System.assertEquals(System.today().addDays(15), actualResult.reqDeliveryDate);  
		System.assertEquals('20.0000', actualResult.unitPrice);   
           
    }   
    
    public static testMethod void testChangeOrderStatus(){
        List<Order> lstOrders = [SELECT Id,Status FROM Order Limit 1];
        lstOrders[0].Status = 'Draft';
        update new List<Order>{lstOrders[0]};
        Test.startTest();
          alphaCreateOrder.changeOrderStatus(lstOrders[0].Id);
        Test.StopTest();
        List<Order> lstUpdatedOrders = [SELECT Status FROM Order LIMIT 1];
        System.assertEquals('Submitted', lstUpdatedOrders[0].Status);            
    } 
    
    @isTest
    public static void testdownloadFile(){
        List<ContentVersion> orderContentVersion;
        List<ContentVersion> lstContentVersion = TestDataFactory.createContentVersion(1,'Test Document','TestDocument.pdf','Test content',true);
        insert lstContentVersion;
        System.debug('lstContentVersion === '+lstContentVersion[0]);
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:lstContentVersion[0].Id].ContentDocumentId;
        System.debug('lstContentVersion == '+conDocId);
        Test.startTest();
        orderContentVersion = alphaCreateOrder.downloadFile(conDocId);      
        Test.StopTest();
        system.debug('orderContentVersion==='+orderContentVersion);
        System.assertEquals(1, orderContentVersion.Size());            
    }    
}