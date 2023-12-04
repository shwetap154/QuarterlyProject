/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-28-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
@isTest
public class accordianFAQ_CntrlTest {
   @isTest
    static void Testme(){
        String uId = userinfo.getUserId();
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Zip_Postal_Code__c = '11111';
        insert acc;
         contact con=new contact();
        con.lastname='test last';
        con.accountid=acc.id;
        con.ZTS_EU_Market__c = 'ALPHA';
        insert con;
        User uMarket = [Select ZTS_EU_Market__c,Profile.name,ContactId,Contact.AccountId from User where Id=: uId limit 1];
         User usr = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                            localesidkey='fr',ZTS_EU_Market__c = '123456',
                            timezonesidkey='America/Los_Angeles',contactid=con.id, 
                            username='testUser@testsales.com');
        
        accordianFAQ_Cntrl.getMarketBasedOnUser();
        
    }
}