/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EventRedirectionControllerTest {

    static Event evnold;
    static User u;

    private static void createTestData(String recTypeStr){
        RecordType recTId = [Select Id from RecordType where SObjectType='Event' and DeveloperName = :recTypeStr limit 1];        
        system.debug('--------------user values----'+ UserInfo.getUserId());
        evnold = new Event(
            Subject='Call1', 
            CurrencyIsoCode = 'USD', 
            StartDateTime = System.Now(), 
            EndDateTime = System.Now().addDays(4), 
            RecordTypeId = recTId.Id
        );
        insert evnold;
        
        system.debug('----------evnold---' + evnold);
        PageReference myPage1 = Page.EventNewRedirection;
        myPage1.getParameters().put('RecordType', recTId.id);       
        test.setCurrentPage(myPage1);
        
        PageReference myPage2 = Page.EventViewRedirection;
        myPage2.getParameters().put('RecordType', recTId.id);
        test.setCurrentPage(myPage2);
    }

    @IsTest
    static void testEventRedirectionController() {
        String recStr = 'Sales_Call';
        List<Profile> p = [select Id from Profile where Name='System Administrator' limit 1];   

        u = new User(username='testUser@testabcasdfasdf232323.com',alias='abctest',ProfileId=p[0].Id,email='test@abc.com',CommunityNickname='abc',ZTS_EU_Market__c='United Kingdom',EmailEncodingKey='ISO-8859-1', TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',LocaleSidKey='en_US',CurrencyIsoCode='EUR',LastNAme='testLsatNAme');
        insert u;
        system.runAs(u){
            createTestData(recStr);
            Event evnt = [select Id,Subject, CurrencyIsoCode, StartDateTime,EndDateTime,RecordTypeId, createdById from Event where Id=: evnold.Id AND ZTS_EU_Market__c != 'United States' limit 1];
            system.debug('----------------test values---:'+ evnt.CreatedById+'--'+ UserInfo.getUserId());

            // controller sets recordtypeid based on event record
            ApexPages.standardController cont =  new ApexPages.StandardController(evnt);
            EventRedirectionController eventRedCont = new EventRedirectionController(cont);
            ApexPages.standardController cont2 =  new ApexPages.StandardController(evnt);
            EventRedirectionController eventRedCont2 = new EventRedirectionController(cont2);

            PageReference redirect1;
            PageReference redirect2;
            Test.startTest();
                redirect1 = eventRedCont.newRedirect();
                redirect2 = eventRedCont2.viewRedirect();
            Test.stopTest();

            System.assert( redirect1.getUrl().contains('salescalldetails'), 'Page not redirected to SalesCallDetails page' );
            System.assert( redirect2.getUrl().contains('zts_eu_viewsalescalldetails'), 'Page not redirected to ZTS_EU_ViewSalesCallDetails page' );
        }
    }
    
    @IsTest
    static void testEventRedirectionController2() {
        String recStr = 'Regular_Event';
        List<Profile> p = [select Id from Profile where Name='System Administrator' limit 1];
                
        u = new User(username='testUser@testabcasdfasdf232323.com',alias='abctest',ProfileId=p[0].Id,email='test@abc.com',CommunityNickname='abc',ZTS_EU_Market__c='United Kingdom',EmailEncodingKey='ISO-8859-1', TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',LocaleSidKey='en_US',CurrencyIsoCode='EUR',LastNAme='testLsatNAme');
        insert u;
        system.runAs(u){
            createTestData(recStr);
        }

        ApexPages.standardController cont =  new ApexPages.StandardController(evnold);
        EventRedirectionController eventRedCont = new EventRedirectionController(cont);
        ApexPages.standardController cont2 =  new ApexPages.StandardController(evnold);
        EventRedirectionController eventRedCont2 = new EventRedirectionController(cont2);
        
        PageReference redirect1;
        PageReference redirect2;
        Test.startTest();
            redirect1 = eventRedCont.newRedirect();
            redirect2 = eventRedCont2.viewRedirect();
        Test.stopTest();
 
        String shortId = String.valueOf(evnold.Id).substring(0, 14);
        System.assert( redirect1.getUrl().contains(evnold.RecordTypeId), 'Page url does not contain record type id' );
        System.assert( redirect2.getUrl().contains(shortId), 'Page url does not contain record id' );
    }
     @IsTest
    static void testEventRedirectionController3() {
        String recStr = 'Sales_Call';
        List<Profile> p = [select Id from Profile where Name='System Administrator' limit 1];   

        u = new User(username='testUser@testabcasdfasdf232323.com',alias='abctest',ProfileId=p[0].Id,email='test@abc.com',CommunityNickname='abc',ZTS_EU_Market__c='United States',EmailEncodingKey='ISO-8859-1', TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',LocaleSidKey='en_US',CurrencyIsoCode='EUR',LastNAme='testLsatNAme');
        insert u;
        system.runAs(u){
            createTestData(recStr);
            Event evnt = [select Id,Subject, CurrencyIsoCode, StartDateTime,EndDateTime,RecordTypeId, createdById from Event where Id=: evnold.Id AND ZTS_EU_Market__c = 'United States' limit 1];
            system.debug('----------------test values---:'+ evnt.CreatedById+'--'+ UserInfo.getUserId());

            // controller sets recordtypeid based on event record
            ApexPages.standardController cont =  new ApexPages.StandardController(evnt);
            EventRedirectionController eventRedCont = new EventRedirectionController(cont);
            ApexPages.standardController cont2 =  new ApexPages.StandardController(evnt);
            EventRedirectionController eventRedCont2 = new EventRedirectionController(cont2);

            PageReference redirect1;
            PageReference redirect2;
            Test.startTest();
                redirect1 = eventRedCont.newRedirect();
            Test.stopTest();
            System.debug('redirect1--->'+redirect1);
            String shortId = String.valueOf(evnt.Id).substring(0, 14);
            System.assert( redirect1.getUrl().contains('Call__c'), 'Page url moved to call page' );

        }
    }
}