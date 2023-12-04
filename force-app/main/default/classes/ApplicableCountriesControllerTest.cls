/**
 * @description       : Test class for ApplicableCountriesController
 * @author            : Joe Desch @ ATG (Advanced Technology Group)
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-09-2019   Joe Desch @ ATG             Initial Version
 * 1.1   01-21-2021   Unknown                     Unknown Updates
 * 1.2   06-07-2022   Ethan Hirsch @ Zoetis Inc   Change Profile name of GER & CE Euro Business Administrator to 
 *                                                GER and CE Euro Business Administrator to avoid Copado deployment 
 *                                                errors with Profiles.
**/
@isTest
public class ApplicableCountriesControllerTest {
	
	static final String COUNTRY_SITE_URL = 'Test.test.com';
	static final String NGA_ETH_APPLICABLE_COUNTRIES = 'NGA;ETH';
	static final String TZA_ETH_APPLICABLE_COUNTRIES = 'TZA;ETH';

    @TestSetup
    static void dataSetup(){
        
        List<Applicable_Countries_URL__c> lstAppCountiries = new List<Applicable_Countries_URL__c>();
        List<Learn_And_Grow__c> lstLearnAndGrow = new List<Learn_And_Grow__c>();
        Applicable_Countries_URL__c appCountired = new Applicable_Countries_URL__c();
        appCountired.Name = 'Nigeria';
        appCountired.CountryCode__c = 'NGA';
        appCountired.CountrySiteUrl__c = COUNTRY_SITE_URL;
        lstAppCountiries.add(appCountired);
        
        Applicable_Countries_URL__c appCountired1 = new Applicable_Countries_URL__c();
        appCountired1.Name = 'Ethiopia';
        appCountired1.CountryCode__c = 'ETH';
        appCountired1.CountrySiteUrl__c = 'Test1.test1.com';
        lstAppCountiries.add(appCountired1);
        
        
        
        Learn_And_Grow__c LearnAndGrow = new Learn_And_Grow__c();
        LearnAndGrow.Name = 'Nigeria';
        LearnAndGrow.CountryCode__c = 'NGA';
        LearnAndGrow.CountrySiteUrl__c = COUNTRY_SITE_URL;
        lstLearnAndGrow.add(LearnAndGrow);
        
        Learn_And_Grow__c LearnAndGrow1 = new Learn_And_Grow__c();
        LearnAndGrow1.Name = 'Ethiopia';
        LearnAndGrow1.CountryCode__c = 'ETH';
        LearnAndGrow1.CountrySiteUrl__c = 'Test1.test1.com';
        lstLearnAndGrow.add(LearnAndGrow1);
        
        insert lstAppCountiries;
        insert lstLearnAndGrow;
             Profile profiles=[Select Id From Profile Where Name='GER and CE Euro Business Administrator'];
        List<User> usercoachList = new List<User>();
        User ngaEthUser=new User();
        ngaEthUser.profileid=profiles.Id;
        ngaEthUser.email='deneme@deneme.com';
        ngaEthUser.username='PLBusineAdmin@bisadmin.com';
        ngaEthUser.lastname='deneme';
        ngaEthUser.alias='deneme1';
        ngaEthUser.languagelocalekey='en_US';
        ngaEthUser.localesidkey='en_US';
        ngaEthUser.timezonesidkey='America/Los_Angeles';
        ngaEthUser.localesidkey='en_US';
        ngaEthUser.ZTS_EU_isCoacher__c=TRUE;    
        ngaEthUser.ZTS_EU_Market__c='United Kingdom';
        ngaEthUser.EmailEncodingKey='ISO-8859-1';
        ngaEthUser.Applicable_Countries__c = NGA_ETH_APPLICABLE_COUNTRIES;
        insert ngaEthUser;  

        User tzaEthUser=new User();
        tzaEthUser.profileid=profiles.Id;
        tzaEthUser.email='deneme@deneme1.com';
        tzaEthUser.username='PLBusineAdmin@bisadmin1.com';
        tzaEthUser.lastname='deneme3';
        tzaEthUser.alias='deneme2';
        tzaEthUser.languagelocalekey='en_US';
        tzaEthUser.localesidkey='en_US';
        tzaEthUser.timezonesidkey='America/Los_Angeles';
        tzaEthUser.localesidkey='en_US';
        tzaEthUser.ZTS_EU_isCoacher__c=TRUE;    
        tzaEthUser.ZTS_EU_Market__c='United Kingdom';
        tzaEthUser.EmailEncodingKey='ISO-8859-1';
        tzaEthUser.Applicable_Countries__c = TZA_ETH_APPLICABLE_COUNTRIES;
        insert tzaEthUser;

    }
    
    @isTest static void ApplicableCountriesControllerTest_Nigeria() {
        
        User ngaEthUser = [SELECT Id FROM User WHERE Applicable_Countries__c = :NGA_ETH_APPLICABLE_COUNTRIES];
        System.runAs(ngaEthUser){
            String actualCountrySiteUrl = ApplicableCountriesController.getCountrySiteUrl();
            String actualLearnAndGrowUrl = ApplicableCountriesController.getLeanandGrowUrl();
        
            System.assertEquals(COUNTRY_SITE_URL, actualCountrySiteUrl, 'The country site url should match');
            System.assertEquals(COUNTRY_SITE_URL, actualLearnAndGrowUrl, 'The learn and grow url should match');
        }

    }

    @isTest static void ApplicableCountriesControllerTest_Not_Nigeria() {
        
        User tzaEthUser = [SELECT Id FROM User WHERE Applicable_Countries__c = :TZA_ETH_APPLICABLE_COUNTRIES];
        System.runAs(tzaEthUser){
            String actualCountrySiteUrl = ApplicableCountriesController.getCountrySiteUrl();
            String actualLearnAndGrowUrl = ApplicableCountriesController.getLeanandGrowUrl();
            
            System.assertEquals(COUNTRY_SITE_URL, actualCountrySiteUrl, 'The country site url should match');
            System.assertEquals(COUNTRY_SITE_URL, actualLearnAndGrowUrl, 'The learn and grow url should match');
        }

    }
}