/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-27-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
@isTest
public class alphaCaseHandlerTest {
    
    
    public static testmethod void alphaTest(){  
        Profile p = [select id from profile where name='Distributor Community User'];
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = '123456';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Parsippany';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = '07054';
        acc.BillingCountry = 'United States';
        insert acc;
        contact con=new contact();
        con.lastname='test last';
        con.ZTS_EU_Market__c = 'ALPHA';
        con.accountid=acc.id;
        insert con;
        User usr = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                            localesidkey='fr', profileid = p.Id,ZTS_EU_Market__c = '123456',
                            timezonesidkey='America/Los_Angeles',contactid=con.id, 
                            username='testUser@testsales.com');
        insert usr;
        
        System.runAs(usr){
        alphaCaseHandler.getCaseType();
        alphaCaseHandler.getCaseList(acc.id);
       } 
       
    }
    
    public static testmethod void alphaTest1()
    {
        Profile p = [select id from profile where name='Distributor Community User'];
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = '123456';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Parsippany';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = '07054';
        acc.BillingCountry = 'United States';
        insert acc;
        contact con=new contact();
        con.lastname='test last';
        con.ZTS_EU_Market__c = 'ALPHA';
        con.accountid=acc.id;
        insert con;
        User usr = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                            localesidkey='fr', profileid = p.Id,ZTS_EU_Market__c = '123456',
                            timezonesidkey='America/Los_Angeles',contactid=con.id, 
                            username='testUser@testsales.com');
        insert usr;
        
        System.runAs(usr){
            alphaCaseHandler.createCase('{"Subject":"alpha","Description":"asdfg","Case_Type__c":"Forecast"}');
        }
    }

}