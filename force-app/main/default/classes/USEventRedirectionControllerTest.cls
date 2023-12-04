/*******************************************************************************************************************************************
* File Name     :  USEventRedirectionControllerTest
* Description   :  Test class for USEventRedirectionController
  
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Keshika         Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class USEventRedirectionControllerTest {
 
    static Event evnold;
    static USer u;
    public static void createTestData(String recTypeStr){
        RecordType recTId=[Select Id from RecordType where SObjectType='Event' and DeveloperName=:recTypeStr limit 1];        
        system.debug('--------------user values----'+ UserInfo.getUserId());
        evnold=new Event(Subject='Call1',StartDateTime=System.Now(),EndDateTime=System.Now().addDays(4),RecordTypeId=recTId.Id);
        insert evnold;
        
        system.debug('----------evnold---' + evnold);
        PageReference myPage1 = Page.EventNewRedirection;
        myPage1.getParameters().put('RecordType',recTId.id);       
        test.setCurrentPage(myPage1);
        
        PageReference myPage2 = Page.EventViewRedirection;
        myPage2.getParameters().put('RecordType',recTId.id);
        test.setCurrentPage(myPage2);
        
    }
    static testMethod void testEventRedirectionController() {
        String recStr = 'Sales_Call';
        List<Profile> p = [select Id from Profile where Name='System Administrator' limit 1];       
        u = new User(username='testUser1@testabc.com1213122541',alias='abctest',ProfileId=p[0].Id,email='test1@abc.com',CommunityNickname='abc',EmailEncodingKey='ISO-8859-1', TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',LocaleSidKey='en_US',LastNAme='testLsatNAme');
        u.ZTS_EU_Market__c = 'United States';
        insert u;
        system.runAs(u){
            createTestData(recStr);
            Event evnt = [select Id,Subject, StartDateTime,EndDateTime,RecordTypeId, createdById from Event where Id=: evnold.Id AND ZTS_EU_Market__c = 'United States' limit 1];
            system.debug('----------------test values---:'+ evnt.CreatedById+'--'+ UserInfo.getUserId());
            ApexPages.standardController cont =  new ApexPages.StandardController(evnt);
            USEventRedirectionController eventRedCont = new USEventRedirectionController(cont);
            ApexPages.standardController cont2 =  new ApexPages.StandardController(evnt);
            USEventRedirectionController eventRedCont2 = new USEventRedirectionController(cont2);
            Test.startTest();
                eventRedCont.newRedirect();
                eventRedCont2.viewRedirect();
            Test.stopTest();
        }
        
    }
    
    static testMethod void testEventRedirectionController2() {
        
       String recStr = 'General_Event';
        createTestData(recStr);
        ApexPages.standardController cont =  new ApexPages.StandardController(evnold);
        USEventRedirectionController eventRedCont = new USEventRedirectionController(cont);
        
 
        ApexPages.standardController cont2 =  new ApexPages.StandardController(evnold);
        USEventRedirectionController eventRedCont2 = new USEventRedirectionController(cont2);
        
        Test.startTest();
            
            eventRedCont.newRedirect();
            eventRedCont2.viewRedirect();
            
        Test.stopTest();
        
    }
}