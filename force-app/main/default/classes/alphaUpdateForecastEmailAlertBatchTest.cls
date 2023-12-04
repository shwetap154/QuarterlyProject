/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-27-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
@isTest
public class alphaUpdateForecastEmailAlertBatchTest {
	@isTest
    static void testMe(){
       
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Country__c='Albania';
        acc.Applicable_Product_Lines__c='Advocin';
        acc.Applicable_Countries__c = 'TZA';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Parsippany';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = '07054';
        acc.BillingCountry = 'United States';
        insert acc;
        AlphaMarketCountry__c alp=new AlphaMarketCountry__c();
        alp.name='testalp';
        alp.CL_Email__c='Test@email.com';
        alp.Country__c='Test Country';
        alp.Market__c='123456';
        insert alp;
         Contact con = new Contact();         
            con.lastname = 'Test Contact';  
            con.firstname = 'first name'; 
            con.AccountId = acc.Id;    
            con.ZTS_EU_Market__c ='United Kingdom';
            con.Send_Alert_For_Forecast__c = true;
            con.Email = 'usa123@test.com';
        insert con;
        list<contact> conlist=new list<contact>();
        for(integer i=0; i<=10;i++){
            contact conn=new contact();
            conn.lastname='test last'+i;
            conn.accountid=acc.id;
            conn.Send_Alert_For_Forecast__c=true;
            conn.ZTS_EU_Market__c ='United Kingdom';
            conn.Email='xelliott'+i+'@example.net';
            conlist.add(conn);
        }
        insert conlist;
        list<Forecast__c> falist=new list<Forecast__c>();
        for(integer i=0; i<=10;i++){
            Forecast__c fa=new Forecast__c();
            fa.Year__c='2021';
            fa.Month__c='December';
            fa.Account__c=acc.id;
            falist.add(fa);
        }
        insert falist;
        list<Forecast__History> foshistory = [SELECT Id FROM Forecast__History where createddate = LAST_N_DAYS:7];
        Test.startTest();
        alpha_UpdateForecastEmailAlert_Batch an = new alpha_UpdateForecastEmailAlert_Batch();
        Id JobId = database.executeBatch(an);
        Test.stopTest();
        
        
    }
}