/*******************************************************************************************************************************************
* File Name     :  ZTS_US_AddContactAndRedirectTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Vidya             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_US_AddContactAndRedirectTest 
{   
    
    static List<ZTS_Events__c> listEvents;
  static List<Contact> listContact;
    static List<ZTS_US_Event_Invitee__c> listEventInvitee;
    
    public static void createTestData(){
        listEvents = createEvents(3);
        insert listEvents;
    }
    
    static testMethod void createStandardSetControllerTest(){
        test.startTest();
        createTestData();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listEvents[0]);
        PageReference massAddAccPage = Page.ZTS_EU_Add_Contact_Redirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        ApexPages.currentPage().getParameters().put('isError', 'true');
        
        ZTS_US_AddContactAndRedirect massContact = new ZTS_US_AddContactAndRedirect(sc);
        test.stopTest();
    }
    
    static testMethod void createStandardSetControllerTest2(){
        test.startTest();
        createTestData();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listEvents[0]);
        PageReference massAddAccPage = Page.ZTS_EU_Add_Contact_Redirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        
        ZTS_US_AddContactAndRedirect massContact = new ZTS_US_AddContactAndRedirect(sc);
        test.stopTest();
    }
    
    static testMethod void saveEventAccountTest(){
        test.startTest();
        createTestData();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listEvents[0]);
        PageReference massAddAccPage = Page.ZTS_EU_Add_Contact_Redirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listContact = ZTS_EU_DataUtilityTest.createContactRecord(3);
        insert listContact;
        String recordIds = '';
        for(Contact contact : listContact){
            recordIds += contact.Id+',';
        }
        ApexPages.currentPage().getParameters().put('records',recordIds );
        ZTS_US_AddContactAndRedirect contRedirect = new ZTS_US_AddContactAndRedirect(sc);
        
        contRedirect.saveEventAccount();
        test.stopTest();
    }
  
  static testMethod void saveEventAccountTest2(){
        test.startTest();
        createTestData();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listEvents[0]);
        PageReference massAddAccPage = Page.ZTS_EU_Add_Contact_Redirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('eventId', null);
        listContact = ZTS_EU_DataUtilityTest.createContactRecord(3);
        insert listContact;
        String recordIds = '';
        for(Contact contact : listContact){
            recordIds += contact.Id+',';
        }
        ApexPages.currentPage().getParameters().put('records',recordIds );
        ZTS_US_AddContactAndRedirect contRedirect = new ZTS_US_AddContactAndRedirect(sc);
        contRedirect.saveEventAccount();
        test.stopTest();
    }
  
  static testMethod void saveEventAccountTest3(){
        test.startTest();
        createTestData();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listEvents[0]);
        PageReference massAddAccPage = Page.ZTS_EU_Add_Contact_Redirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listContact = ZTS_EU_DataUtilityTest.createContactRecord(3);
        insert listContact;
        String recordIds = '';
        for(Contact contact : listContact){
            recordIds += contact.Id+',';
        }
        ApexPages.currentPage().getParameters().put('records',recordIds );
        ZTS_US_AddContactAndRedirect contRedirect = new ZTS_US_AddContactAndRedirect(sc);
        List<ZTS_US_Event_Invitee__c> evntInvList = createEventInvitee(listEvents);
    insert evntInvList;
        contRedirect.saveEventAccount();
        test.stopTest();
    }
    
    
     /*-------------insert ZTS_Events__c objects---------------*/
    public static List<ZTS_Events__c> createEvents(Integer counter){ // 6/14
        List<ZTS_Events__c> listEvents1 = new List<ZTS_Events__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_Events__c event = new ZTS_Events__c();
            event.ZTS_US_Will_Firearms_be_Present__c = true;
            event.ZTS_US_Type__c = 'Cattle General';
            event.Total_Number_of_Invitees__c = i;
            event.ZTS_US_Status__c = 'New';
            event.ZTS_US_Start_Date__c = system.now();
            event.ZTS_US_Is_Event_Private__c = false;
            event.ZTS_US_Name__c = 'Test Event'+i;
           // event.ZTS_US_End_Date__c = system.today().addDays(i);
            event.ZTS_US_End_Date__c = system.now().addDays(i);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
           // event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';
            listEvents1.add(event);
        }
        return listEvents1;
    }
    
  /*-------insert ZTS_US_Event_Invitee__c object records------*/
    public static List<ZTS_US_Event_Invitee__c> createEventInvitee(List<ZTS_Events__c> listEvnts){
        List<ZTS_US_Event_Invitee__c> listEventInvitees = new List<ZTS_US_Event_Invitee__c>();
        for(ZTS_Events__c event: listEvnts){
            ZTS_US_Event_Invitee__c evntInv = new ZTS_US_Event_Invitee__c(ZTS_US_Contact__c=listContact[0].Id, ZTS_US_Event__c=event.Id,ZTS_US_Invitation_Status__c='Invited');
            listEventInvitees.add(evntInv);
        }
        return listEventInvitees;
    }
}