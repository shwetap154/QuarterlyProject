/**
 * @description       : Test class for  EventInviteeListController and InviteeRelListController
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-01-2020   Art Smorodin @ Slalom       Initial Version (Based on  class being tested)
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Fix test failures due to validation errors and move common data into test setup method.
**/
@isTest
public class EventInviteeListController_Test {
    @testSetup
    private static void setupTestData() {
        
        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        Account testAcct = testAccts[0];
        testAcct.Name = 'TestAcct';
        testAcct.ZTS_EU_Market__c = 'United States';
        testAcct.ZTS_US_NARC_ID__c = 'TestNID';
        testAcct.Type = 'Vet Practice';

        insert  testAcct;
        
        Contact testContact  = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
        testContact.FirstName = 'Test Contact';
        testContact.LastName = 'Si';
        testContact.ZTS_EU_Market__c = 'United States';
        testContact.ZTS_EU_Profession__c = 'Comercial';
        testContact.AccountId = testAcct.id;
        insert testContact;
            
        ZTS_Events__c testEvent =new ZTS_Events__c(ZTS_US_Name__c ='test Event',
                                                      ZTS_US_Event_Category__c ='CPAC',
                                                      ZTS_US_Location__c = 'some location',
                                                      ZTS_US_Number_of_Attendees__c = 111,
                                                      ZTS_US_Start_Date__c = datetime.newInstance(2020, 05, 01, 12, 30, 0),
                                                      ZTS_US_End_Date__c = datetime.newInstance(2020, 25, 01, 12, 30, 0),
                                                      Purpose_Agenda__c = 'some agenda',//Pooja - Added new rich text field insted old text field "ZTS_US_Purpose_Agenda__c"
                                                  	  ZTS_US_Type__c = 'DISC');
        insert testEvent;
            
            
        ZTS_US_Event_Invitee__c testEventInvitee = new ZTS_US_Event_Invitee__c(ZTS_US_Event__c = testEvent.id,
                                                                              ZTS_US_Contact__c = testContact.id);
        insert testEventInvitee;
    }

    @isTest
    private static void redirectToLC() {            
        ZTS_US_Event_Invitee__c testEventInvitee = retrieveTestEventInvitee();
            
        Test.startTest();
        List<ZTS_US_Event_Invitee__c> eventsList = new List<ZTS_US_Event_Invitee__c>();
        eventsList.add(testEventInvitee);
        Test.setCurrentPage(Page.EventInviteeListStatusAttended);
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(eventsList);
        standardController.setSelected(eventsList);
        EventInviteeListController ext = new EventInviteeListController(standardController);
        System.assertNotEquals(null,ext.redirectToLC());

        Test.stopTest();
    }
    
    @isTest
    private static void doEditPageRedirect() {
        ZTS_US_Event_Invitee__c testEventInvitee = retrieveTestEventInvitee();

        Test.startTest();
        List<ZTS_US_Event_Invitee__c> eventsList = new List<ZTS_US_Event_Invitee__c>();
        eventsList.add(testEventInvitee);
        Test.setCurrentPage(Page.EventInviteesEditContact);
        ApexPages.currentPage().getParameters().put('id',testEventInvitee.ZTS_US_Event__c);
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(eventsList);
        standardController.setSelected(eventsList);
        InviteeRelListController ext = new InviteeRelListController(standardController);
        ext.doEditPageRedirect();
        System.assertNotEquals(null,ext.doEditPageRedirect());

        Test.stopTest();
    }
    
    private static testMethod void doAddContactsRedirect() {
        ZTS_US_Event_Invitee__c testEventInvitee = retrieveTestEventInvitee();
        // Update the Event to have a Market of Australia to match the original Event creation.
        update new ZTS_Events__c(Id = testEventInvitee.ZTS_US_Event__c,
                                 ZTS_EU_Market__c = 'Australia');

        Test.startTest();
        List<ZTS_US_Event_Invitee__c> eventsList = new List<ZTS_US_Event_Invitee__c>();
        eventsList.add(testEventInvitee);
        Test.setCurrentPage(Page.EventInviteesEditContact);
        ApexPages.currentPage().getParameters().put('id',testEventInvitee.ZTS_US_Event__c);
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(eventsList);
        standardController.setSelected(eventsList);
        InviteeRelListController ext = new InviteeRelListController(standardController);
        ext.doAddContRedirectIntl();
        ext.doAddNewContactsRedirect();
        ext.doEditPageRedirect();
        System.assertNotEquals(null,ext.doAddContactsRedirect());

        Test.stopTest();
    }

    private static ZTS_US_Event_Invitee__c retrieveTestEventInvitee() {
        return [SELECT Id, ZTS_US_Event__c FROM ZTS_US_Event_Invitee__c LIMIT 1];
    }
}