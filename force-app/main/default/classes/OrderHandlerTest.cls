/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-27-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
@isTest
public class OrderHandlerTest {
    @isTest
    static void testOrderStatusChangeEmail() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@example.com',ZTS_US_Profession__c='Consultant',ZTS_US_Job_Function__c='Practice Mgt', AccountId = testAccount.Id,  Selected_For_Alert__c = true);
        insert testContact;
        Order testOrder = new Order(AccountId = testAccount.Id, RecordTypeId = OrderHandler.distributorOrderRTId,EffectiveDate=Date.newInstance(2022, 06, 09), Status = 'Draft');
        insert testOrder;
        // Call the OrderHandler method that should send the email
        testOrder.Status = 'Submitted';
        update testOrder;
        // Verify that the email was sent
        EmailTemplate sentEmails= [SELECT Id, Name FROM EmailTemplate WHERE Name in ('Distributor New Order Submitted Template - Spanish')];
        System.assertEquals(OrderHandler.emailTemplateDLSpanish.Id,sentEmails.Id);
          
    }
	private static void deleteOrder(Order orderToDelete) {
        delete orderToDelete;
    }
        
	@isTest
    static void testBulkAfter() {         
        AlphaMarketCountry__c alp=new AlphaMarketCountry__c();
        alp.name='testalp';
        alp.CL_Email__c='Test@email.com';
        alp.Country__c='United Kingdom';
        alp.Market__c='Panama';
        insert alp;
        
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'Zoetis';
        acc.ZTS_EU_Country__c='United Kingdom';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Parsippany';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = '07054';
        acc.BillingCountry = 'United States';
        insert acc;
      
        contact con=new contact();
        con.lastname='test last';
        con.accountid=acc.id;
        con.email='test@deloitte.com';
        con.Selected_For_Alert__c=true;
        con.ZTS_EU_Market__c = 'Panama';
        insert con;
        
        contact con2=new contact();
        con2.lastname='test last2';
        con2.accountid=acc.id;
        con2.email='test123@gmail.com';
        con2.Selected_For_Alert__c=true;
        con2.ZTS_EU_Market__c = 'Costa Rica';
        insert con2;
        
        contact con3=new contact();
        con3.lastname='test last3';
        con3.accountid=acc.id;
        con3.email='test345@deloitte.com';
        con3.Selected_For_Alert__c=true;
        con3.ZTS_EU_Market__c = 'United States';
        insert con3;

        Order testOrder = new Order(AccountId = acc.Id,EffectiveDate=Date.newInstance(2022, 06, 09), Status = 'Submitted');
        insert testOrder;
        Contact eachCon=[
          SELECT
            id,
            accountId,
            Email,
            ZTS_EU_Market__c,
            Account.ZTS_EU_Market__c,
            Account.ZTS_EU_Country__c
          FROM Contact 
          WHERE Id = :con2.Id
        ];
        system.debug(eachCon.Email);
        System.assertEquals('test123@gmail.com', eachcon.Email);
        deleteOrder(testOrder);
        List<Order> deletedOrders = [SELECT Id FROM Order WHERE Id = :testOrder.Id];
        System.assertEquals(0, deletedOrders.size());
    }

    @isTest
  	public static void Test1() {
      AlphaMarketCountry__c alp=new AlphaMarketCountry__c();
        alp.name='testalp';
        alp.CL_Email__c='Test@email.com';
        alp.Country__c='United Kingdom';
        alp.Market__c='Zoetis';
        insert alp;
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'Zoetis';
        acc.ZTS_EU_Country__c='United Kingdom';
      acc.ZTS_EU_Zip_Postal_Code__c = '00000';
      acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Parsippany';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = '07054';
        acc.BillingCountry = 'United States';
        insert acc;
      
      contact con=new contact();
        con.lastname='test last';
        con.accountid=acc.id;
        con.email='test@email.com';
      con.Selected_For_Alert__c=true;
      con.ZTS_EU_Market__c = 'ALPHA';
        insert con;
      
      State_Country__c stc = new State_Country__c();
            stc.name='test co';
            stc.ZTS_EU_Country__c='Albania';
            insert stc;
            
            Address__c adds=new Address__c();
            adds.name='test line';
            adds.ZTS_EU_Account__c=acc.id;
            adds.ZTS_EU_District__c='Teast';
            adds.ZTS_EU_Country__c='Albania';
            adds.ZTS_EU_State_County__c=stc.id;
            adds.Zip_Postal_Code__c='738747';
      adds.ZTS_EU_Address_Type__c = 'Main';
            adds.ZTS_US_Source_Account_Number__c='908090';
            insert adds;
      List<Address__c> lstAddr = new List<Address__c>();
      lstAddr.add(adds);
      Address__c addss=new Address__c();
            addss = adds;
            
            //insert addss;
      
      Product2 prod = new Product2(Name = 'Laptop X200',
                                         Family = 'Hardware');
            insert prod;
            Stock__c st=new Stock__c();
        st.Year__c='2021';
        st.Month__c='December';
        st.Account__c=acc.id;
        //insert st;
            Stock_Product__c stockprod = new Stock_Product__c(Product__c = prod.id,Quantity__c=1,SAP_Product_Code__c = 'ABCOde',Stock__c=st.id);
            //insert stockprod;
            Forecast_Product__c forecastProd = new Forecast_Product__c();
            //insert forecastProd;
            List<SAPCustomerMaterialPrice__c> sapList = new List<SAPCustomerMaterialPrice__c>();
            SAPCustomerMaterialPrice__c sapc = new SAPCustomerMaterialPrice__c();
            sapc.Customer_Number__c='908090';
            sapc.Product__c=prod.id;
            sapc.Sales_Organization__c='2941'; 
            sapc.Material_Number__c='test'; 
            sapc.Valid_From__c=system.today(); 
            sapc.Valid_To__c=system.today().adddays(10); 
            sapc.Price__c=20;
      sapc.External_ID__c='123456';
            insert sapc;
            sapList.add(sapc);
      AccountProductPortfolio__c acp = new AccountProductPortfolio__c();
      acp.Account__c = acc.id;
      acp.Product__c = prod.Id;
      insert acp;
       
      //Instantiate the Pricebook2 record with StandardPricebookId
Pricebook2 standardPricebook = new Pricebook2(
    Id = Test.getStandardPricebookId(),
    IsActive = true
);
 
//Execute an update DML on the Pricebook2 record, to make IsStandard to true
Update standardPricebook;
 
//Query for the Pricebook2 record, to check IsStandard field
standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
//It should return true
System.assertEquals(true, standardPricebook.IsStandard);
 
 
//Create the PricebookEntry
PricebookEntry pbe = new PricebookEntry(
    Pricebook2Id = standardPricebook.Id,
    Product2Id = prod.Id,
    UnitPrice = 1020,
    IsActive = true
);
Insert pbe;
 
//Query the PricebookEntry record
pbe = [SELECT Id, Pricebook2.IsStandard FROM PricebookEntry];
         Contract Conn = New Contract();
        Conn.AccountId = acc.id;
        Insert Conn;

order orderobj = new order();
        orderobj.Accountid=acc.id;
        orderobj.Status='Draft';
        orderobj.EffectiveDate=system.today();
        orderobj.ContractId=conn.id;
      orderobj.BillToContactId = con.Id;
        insert orderobj;
      
      Product2 producto =new Product2();
        producto.Name='test';
        producto.productCode='1234';
        producto.isActive = true;
        //producto.Proveedor__c = cuenta2.Id;
        producto.CurrencyIsoCode='MXN';
        
        insert producto;
        
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='MXN';
        
        insert pb2;
      PricebookEntry pbe1 = createPricebookEntry(standard,pb2,producto);
      
      OrderItem oi = new OrderItem();
      
          oi.OrderId=orderobj.id;
              oi.Quantity=decimal.valueof('1');
      oi.PricebookEntryId=pbe1.id;
      
      orderobj.Status = 'Rejected';
      update orderobj;
    }
    
    @isTest
	public static void Test2() {
    AlphaMarketCountry__c alp = new AlphaMarketCountry__c();
    alp.name = 'Test Market Country';
    alp.CL_Email__c = 'Test@email.com';
    alp.Country__c = 'United Kingdom';
    alp.Market__c = 'Zoetis';
    insert alp;

    Account acc = new Account();
    acc.name = 'test acc';
    acc.ZTS_EU_Market__c = 'Zoetis';
    acc.ZTS_EU_Country__c = 'United Kingdom';
    acc.ZTS_EU_Zip_Postal_Code__c = '00000';
    acc.BillingStreet = '123 Street';
    acc.BillingCity = 'Parsippany';
    acc.BillingState = 'New Jersey';
    acc.BillingPostalCode = '07054';
    acc.BillingCountry = 'United States';
    insert acc;

    Contact con = new Contact();
    con.lastname = 'test last';
    con.accountid = acc.id;
    con.email = 'test@email.com';
    con.Selected_For_Alert__c = true;
    con.ZTS_EU_Market__c = 'ALPHA';
    insert con;

    State_Country__c stc = new State_Country__c();
    stc.name = 'test co';
    stc.ZTS_EU_Country__c = 'Albania';
    insert stc;

    Address__c adds = new Address__c();
    adds.name = 'test line';
    adds.ZTS_EU_Account__c = acc.id;
    adds.ZTS_EU_District__c = 'Teast';
    adds.ZTS_EU_Country__c = 'Albania';
    adds.ZTS_EU_State_County__c = stc.id;
    adds.Zip_Postal_Code__c = '738747';
    adds.ZTS_EU_Address_Type__c = 'Main';
    adds.ZTS_US_Source_Account_Number__c = '908090';
    insert adds;
    
    List<Address__c> lstAddr = new List<Address__c>();
      lstAddr.add(adds);
      Address__c addss=new Address__c();
            addss = adds;

    Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
    insert prod;

    Stock__c st = new Stock__c();
    st.Year__c = '2021';
    st.Month__c = 'December';
    st.Account__c = acc.id;
    insert st;

    Stock_Product__c stockprod = new Stock_Product__c(
    Product__c = prod.id,
    Quantity__c = 1,
    SAP_Product_Code__c = 'ABCOde',
    Stock__c =st.id
	);
    
    insert stockprod;
    Forecast__c forecast= new Forecast__c(Account__c=acc.id, Year__c='2023',Month__c='March');
    insert forecast;
    Forecast_Product__c forecastProd = new Forecast_Product__c(
    Product__c= prod.id,
    Quantity__c = 1,
    Price__c= 100,
   	Forecast__c=forecast.id,
    SAP_Product_Code__c = 'ABCOde');
    
    
   // insert forecastProd;

    List<SAPCustomerMaterialPrice__c> sapList = new List<SAPCustomerMaterialPrice__c>();
    SAPCustomerMaterialPrice__c sapc = new SAPCustomerMaterialPrice__c();
    sapc.Customer_Number__c = '908090';
    sapc.Product__c = prod.id;
    sapc.Sales_Organization__c = '2941';
    sapc.Material_Number__c = 'test';
    sapc.Valid_From__c = system.today();
    sapc.Valid_To__c = system.today().adddays(10);
    sapc.Price__c = 20;
    sapc.External_ID__c = '123456';
    insert sapc;
    sapList.add(sapc);

    AccountProductPortfolio__c acp = new AccountProductPortfolio__c();
    acp.Account__c = acc.id;
    acp.Product__c = prod.Id;
    insert acp;

    Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true
    );

    Update standardPricebook;

    standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
    System.assertEquals(true, standardPricebook.IsStandard);

    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = standardPricebook.Id,
        Product2Id = prod.Id,
        UnitPrice = 1020,
        IsActive = true
    );
    Insert pbe;

     System.runAs(new User(Id = UserInfo.getUserId())) {

    Contract Conn = New Contract();
    Conn.AccountId = acc.id;
    Insert Conn;
         
    Order orderobj1 = new Order();
    orderobj1.Accountid = acc.id;
    orderobj1.Status = 'Draft';
    orderobj1.EffectiveDate = system.today();
    orderobj1.ContractId = Conn.id;  
    orderobj1.BillToContactId = con.Id;
    insert orderobj1;
         
    echosign_dev1__SIGN_Agreement__c testAgreement = new echosign_dev1__SIGN_Agreement__c();
    testAgreement.Order__c = orderobj1.Id;
          
    insert testAgreement;
         
         Attachment testAttachment = new Attachment(
    		ParentId = testAgreement.Id,  
    		Name = 'TestAttachment - Signed.pdf',
    		Body = Blob.valueOf('Test Attachment Content')
		);
        
		insert testAttachment;
        List<Id> attachmentIds = new List<Id>();
		attachmentIds.add(testAttachment.Id);
		System.assert(!attachmentIds.isEmpty(), 'attachmentIds should not be empty');
         
    Product2 producto =new Product2();
        producto.Name='test';
        producto.productCode='1234';
        producto.isActive = true;
        //producto.Proveedor__c = cuenta2.Id;
        producto.CurrencyIsoCode='MXN';
        
        insert producto;
        
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='MXN';
        
        insert pb2;
      	PricebookEntry pbe1 = createPricebookEntry(standard,pb2,producto);
      
      OrderItem oi = new OrderItem();
      
          oi.OrderId=orderobj1.id;
          oi.Quantity=decimal.valueof('1');
      oi.PricebookEntryId=pbe1.id;
      
      orderobj1.Status = 'Submitted';
      update orderobj1;
         
      AlphaMarketCountry__c alp1 = new AlphaMarketCountry__c();
        alp1.name = 'Panama Panama';
        alp1.CL_Email__c = 'sample@email.com';
        alp1.Country__c = 'Panama';
        alp1.Market__c = 'Panama';
        alp1.Language__c= 'es';
        insert alp1;
        
        Account acc1=new Account();
        acc1.name = 'test acc1';
        acc1.ZTS_EU_Market__c = 'Panama';
        acc1.ZTS_EU_Country__c = 'Panama';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.lastname = 'test last1';
        con1.accountid = acc1.id;
        con1.email = 'sample@email.com';
        con1.Selected_For_Alert__c = true;
        con1.ZTS_EU_Market__c = 'Panama';
        insert con1;
        
        Order ord = new Order();
        ord.Accountid = acc1.id;
        ord.Status = 'Draft';
        ord.EffectiveDate = system.today();
        ord.BillToContactId = con1.Id;
        insert ord;
               
        echosign_dev1__SIGN_Agreement__c testAgreement1 = new echosign_dev1__SIGN_Agreement__c();
    	testAgreement1.Order__c = ord.Id;
        insert testAgreement1;
         
         Attachment testAttachment1 = new Attachment(
    		ParentId = testAgreement1.Id,  
    		Name = 'TestAttachment - Signed.pdf',
    		Body = Blob.valueOf('Test Attachment Content')
		);
		insert testAttachment1;
        
        ord.Status='Submitted';
        update ord;
         
        System.assertEquals(3, Limits.getEmailInvocations());
     }   
}
    
    public static PricebookEntry createPricebookEntry (Pricebook2 standard, Pricebook2 newPricebook, Product2 prod) {
        System.debug('***** starting one');
        PricebookEntry one = new PricebookEntry();
        one.pricebook2Id = standard.id;
        one.product2id = prod.id;
        one.unitprice = 1249.0;
        one.isactive = true;
        insert one;
        System.debug('***** one complete, ret next');
        PricebookEntry ret = new PricebookEntry();
        ret.pricebook2Id = newPricebook.id;
        ret.product2id = prod.id;
        ret.unitprice = 1250.0;
        ret.isactive = true;
        insert ret;
        return ret;
    }
    
    
    
   
}