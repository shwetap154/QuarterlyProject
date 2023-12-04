/**
* @description       : 
* @author            : Morgan Marchese @ Zoetis Inc
* @group             : 
* @last modified on  : 10-18-2021
* @last modified by  : Mahendra Kumar
**/
@isTest
public class alphaOrderPDFController_Test {
    public static testmethod void alphaDistReadOnly(){
        Profile p = [select id from profile where name='Distributor Community User'];
        UserRole roleObj = [Select id from userrole where name='International'];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User adminUsr = new User(alias = 'sysAdmin', email='sysAdmin@testorg.com',
                                 emailencodingkey='UTF-8', lastname='Testing Admin', languagelocalekey='fr',
                                 localesidkey='fr', profileid = adminProfile.Id,ZTS_EU_Market__c = 'ALPHA',
                                 timezonesidkey='America/Los_Angeles', 
                                 username='testAdmUser.alpha@testsales.com',UserRoleId = roleObj.Id);
        insert adminUsr;
        
        
        
        system.runAs(adminUsr){
          account acc=new account();
            acc.name='test acc';
            acc.ZTS_EU_Market__c = 'ALPHA';
            acc.ZTS_EU_Country__c='Albania';
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
            con.ZTS_EU_Market__c = 'ALPHA';
            insert con;
            User usr = new User(alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                                localesidkey='fr', profileid = p.Id,ZTS_EU_Market__c = 'ALPHA',
                                timezonesidkey='America/Los_Angeles',contactid=con.id, 
                                username='testUser@testsales.com');
            insert usr;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
                                         Family = 'Hardware');
            insert prod;
            
            
            State_Country__c stc = new State_Country__c();
            stc.name='test co';
            stc.ZTS_EU_Country__c='Albania';
            insert stc;
            
            Address__c addr = new Address__c();
            addr.ZTS_EU_Account__c = acc.Id;
            addr.ZTS_EU_Address_Type__c = 'Main';
            addr.ZTS_EU_State_County__c = stc.Id;
            addr.ZTS_EU_Country__c = 'Albania';
            addr.Zip_Postal_Code__c = '00000';
            insert addr;
            
            
            Forecast__c fa=new Forecast__c();
            fa.Year__c='2021';
            fa.Month__c='June';
            fa.Account__c=acc.id;
            insert fa;
            
            /*Forecast__History fh = new Forecast__History();
            fh.parentId = fa.Id;
            fh.Field = 'Year__c';
            
            insert fh;*/
            
            Forecast_Product__c fcp=new Forecast_Product__c();
            fcp.SAP_Product_Code__c='000000000010000312';
            fcp.Quantity__c=5;
            fcp.Forecast__c=fa.id;
            fcp.Price__c=4;
            insert fcp;
            /*Forecast_Product__History fph = new Forecast_Product__History();
            fph.ParentId =fcp.Id;
            fph.Field= 'Quantity__c';
            insert fph;*/ 
            Stock__c st=new Stock__c();
            st.Market_Account__c = '';
            st.Year__c='2021';
            st.Month__c='June';
            st.Account__c=acc.id;
            insert st;
            Stock_Product__c stockprod = new Stock_Product__c(Product__c = prod.id,Quantity__c=1,SAP_Product_Code__c = 'ABCOde',Stock__c=st.id);
            insert stockprod;
            
            Contract Conn = New Contract();
            Conn.AccountId = acc.id;
            Insert Conn;
            
            order orderobj = new order();
            orderobj.Accountid=acc.id;
            orderobj.Status='Submitted';
            orderobj.EffectiveDate=system.today();
            orderobj.ContractId=conn.id;
            insert orderobj;
            
            
            System.runAs(usr){
                
                
            }
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(orderobj);
            alphaOrderPDFController testAccPlan = new alphaOrderPDFController(sc);
            testAccPlan.getOrderProducts();
            testAccPlan.getShippingDocs();
            testAccPlan.getAccountAddress();
            testAccPlan.getSignature();
            testAccPlan.getSignatureImage();
            testAccPlan.getRenderFreePercent();
            testAccPlan.getRenderFreeQuantity();
            testAccPlan.getRenderDiscount();
            testAccPlan.getIsDownload();          
            
        }
    }
 
    public static testmethod void alphaOrderPdf(){
        Profile p = [select id from profile where name='Distributor Community User'];
        UserRole roleObj = [Select id from userrole where name='International'];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User adminUsr1 = new User(alias = 'sysAdmin', email='sysAdmin@testorg.com',
                                 emailencodingkey='UTF-8', lastname='Testing Admin', languagelocalekey='fr',
                                 localesidkey='fr', profileid = adminProfile.Id,ZTS_EU_Market__c = 'Panama',
                                 timezonesidkey='America/Los_Angeles', 
                                 username='testAdmUser1.alpha@testsales.com',UserRoleId = roleObj.Id);
        insert adminUsr1;              
        
        system.runAs(adminUsr1){
          account acc=new account();
            acc.name='test acc';
            acc.ZTS_EU_Market__c = 'Panama';
            acc.ZTS_EU_Country__c='Panama';
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
            con.ZTS_EU_Market__c = 'Panama';
            insert con;
            User usr = new User(alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                                localesidkey='fr', profileid = p.Id,ZTS_EU_Market__c = 'Panama',
                                timezonesidkey='America/Los_Angeles',contactid=con.id, 
                                username='testUser@testsales.com');
            insert usr;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
                                         Family = 'Hardware');
            insert prod;
            
            
            State_Country__c stc = new State_Country__c();
            stc.name='test co';
            stc.ZTS_EU_Country__c='Panama';
            insert stc;
            
            Address__c addr = new Address__c();
            addr.ZTS_EU_Account__c = acc.Id;
            addr.ZTS_EU_Address_Type__c = 'Main';
            addr.ZTS_EU_State_County__c = stc.Id;
            addr.ZTS_EU_Country__c = 'Panama';
            addr.Zip_Postal_Code__c = '00000';
            insert addr;
            
            
            Forecast__c fa=new Forecast__c();
            fa.Year__c='2021';
            fa.Month__c='June';
            fa.Account__c=acc.id;
            insert fa;
                                
            Forecast_Product__c fcp=new Forecast_Product__c();
            fcp.SAP_Product_Code__c='000000000010000312';
            fcp.Quantity__c=5;
            fcp.Forecast__c=fa.id;
            fcp.Price__c=4;
            insert fcp;
            
            Stock__c st=new Stock__c();
            st.Market_Account__c = '';
            st.Year__c='2021';
            st.Month__c='June';
            st.Account__c=acc.id;
            insert st;
            Stock_Product__c stockprod = new Stock_Product__c(Product__c = prod.id,Quantity__c=1,SAP_Product_Code__c = 'ABCOde',Stock__c=st.id);
            insert stockprod;
            
            Contract Conn = New Contract();
            Conn.AccountId = acc.id;
            Insert Conn;
            
            order orderobj = new order();
            orderobj.Accountid=acc.id;
            orderobj.Status='Submitted';
            orderobj.EffectiveDate=system.today();
            orderobj.ContractId=conn.id;
            insert orderobj;                                          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(orderobj);
            alphaOrderPDFController testAccPlan = new alphaOrderPDFController(sc);
            testAccPlan.getOrderProducts();
            testAccPlan.getShippingDocs();
            testAccPlan.getAccountAddress();
            testAccPlan.getSignature();
            testAccPlan.getSignatureImage();
            testAccPlan.getRenderFreePercent();
            testAccPlan.getRenderFreeQuantity();
            testAccPlan.getRenderDiscount();
            testAccPlan.getIsDownload();
            testAccPlan.getRenderDeliveryDate();
            testAccPlan.getRenderShippingDoc();
            
        }
    }            
}