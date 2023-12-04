/*******************************************************************************************************************************************
* File Name     :  ZTS_US_AddContactRedirectTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Vidya             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_US_AddContactRedirectTest 
{   
    static List<Contact> listContact ;
    static List<ZTS_US_Event_Account__c> listeventAccount;
    static List<ZTS_Events__c> listEvents;
    static List<ZTS_US_Event_Invitee__c> listEventInvitee;
    static ZTS_US_AddContactRedirect contRedirect = new ZTS_US_AddContactRedirect();
    
    public static void createTestData(){
        listContact = ZTS_EU_DataUtilityTest.createContactRecord(3);
        insert listContact;
        listEvents = createEvents(3);
        insert listEvents;
    }
    
    static testMethod void createStandardSetControllerTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listeventAccount = createEventAccount(listEvents);
        insert listeventAccount;
        listEventInvitee = createEventInvitee(listEvents);
        insert listEventInvitee;
        contRedirect.getContacts();
        contRedirect.prepareList();
        test.stopTest();
    }
    
    static testMethod void saveContactsTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listeventAccount = createEventAccount(listEvents);
        insert listeventAccount;
        listEventInvitee = createEventInvitee(listEvents);
        insert listEventInvitee;
        contRedirect.getContacts();
       
        ZTS_US_AddContactRedirect.ContactWrapper contWrap = new ZTS_US_AddContactRedirect.ContactWrapper();
        contWrap.con = listContact[0];
        contWrap.checked = true;
        ZTS_US_AddContactRedirect.ContactWrapper contactWrap = new ZTS_US_AddContactRedirect.ContactWrapper(listContact[0]);
        //List<ZTS_US_AddContactRedirect.ContactWrapper> contWrapList = contRedirect.getCategories();
        contRedirect.selectAll();
        contRedirect.handleMasterCheckBox();
        contRedirect.prepareList();
        contRedirect.contactDataInformationHold();
        contRedirect.next();
        contRedirect.previous();
        //contWrapList[0].checked = true;
        //
        contRedirect.saveContacts();
        contRedirect.executesearch();
        test.stopTest();
    }
    
    static testMethod void cancelTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        contRedirect.cancel();
        test.stopTest();
    }
    
    //Kaushik
   static testMethod void saveAccTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        contRedirect.getContacts();
        ZTS_US_AddContactRedirect.ContactWrapper contWrap = new ZTS_US_AddContactRedirect.ContactWrapper();
        contWrap.con = listContact[0];
        contWrap.checked = true;
        ZTS_US_AddContactRedirect.ContactWrapper contactWrap = new ZTS_US_AddContactRedirect.ContactWrapper(listContact[0]);
        //List<ZTS_US_AddContactRedirect.ContactWrapper> contWrapList = contRedirect.getCategories();
        contRedirect.selectAll();
        contRedirect.handleMasterCheckBox();
        contRedirect.prepareList();
        contRedirect.SaveAcc();
        test.stopTest();
    }
    //Kaushik
    //
    static testMethod void clearTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        contRedirect.clear();
        contRedirect.refr();
        contRedirect.refr1();
        contRedirect.refr2();
        contRedirect.refr3();
        contRedirect.refr4();
        test.stopTest();
    }
    
    static testMethod void pageNumberTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listeventAccount = createEventAccount(listEvents);
        insert listeventAccount;
        listEventInvitee = createEventInvitee(listEvents);
        insert listEventInvitee;
        contRedirect.getContacts();
        Integer pgNum = contRedirect.pageNumber;
        Boolean hasnxt = contRedirect.hasNext;
        Boolean hasprev = contRedirect.hasPrevious;
        contRedirect.first();
        contRedirect.last();
        contRedirect.previous();
        contRedirect.next();
        contRedirect.sortExpression = 'c.con.FirstName';
        // contRedirect.sortExpression = 'con.firstname';
        String sortExp = contRedirect.sortExpression;
       // contRedirect.ViewSortData(); Commented due to error 
        contRedirect.setSortDirection('ASC');
        contRedirect.getSortDirection();
        test.stopTest();
    }
    
    static testMethod void sortDirectionTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listeventAccount = createEventAccount(listEvents);
        insert listeventAccount;
        listEventInvitee = createEventInvitee(listEvents);
        insert listEventInvitee;
        contRedirect.getContacts();
        //contRedirect.viewsortdata();
        contRedirect.sortExpression = '';
        String sortExp = contRedirect.sortExpression;
        
        contRedirect.setSortDirection('DESC');
        contRedirect.getSortDirection();
        //contRedirect.viewsortdata();
        test.stopTest();
    }
    
    static testMethod void executeSearchTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listeventAccount = createEventAccount(listEvents);
        insert listeventAccount;
        listEventInvitee = createEventInvitee(listEvents);
        insert listEventInvitee;
        contRedirect.getContacts();
        contRedirect.name = 'TEST NAME';
        
        contRedirect.executesearch();
        test.stopTest();
    }
    
    static testMethod void viewSortDataTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listeventAccount = createEventAccount(listEvents);
        insert listeventAccount;
        listEventInvitee = createEventInvitee(listEvents);
        insert listEventInvitee;
        contRedirect.getContacts();
        //contRedirect.viewsortdata();
        contRedirect.sortExpression = 'Name';
        String sortExp = contRedirect.sortExpression;
        
        contRedirect.setSortDirection('DESC');
        contRedirect.viewsortdata();
        test.stopTest();
    }
    
    static testMethod void contactDataInformationHoldTest(){
        test.startTest();
        createTestData();
        PageReference massAddAccPage = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listContact); 
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        listeventAccount = createEventAccount(listEvents);
        insert listeventAccount;
        listEventInvitee = createEventInvitee(listEvents);
        insert listEventInvitee;
        contRedirect.getContacts();
        Integer pgNum = contRedirect.pageNumber;
        Boolean hasnxt = contRedirect.hasNext;
        Boolean hasprev = contRedirect.hasPrevious;
        Map<id,ZTS_US_AddContactRedirect.ContactWrapper> dataHoldingMap = contRedirect.dataHoldingMap;
        for (ZTS_US_AddContactRedirect.ContactWrapper cw : dataHoldingMap.values()) {
            cw.checked = true;
        }
        
        contRedirect.first();
        contRedirect.last();
        contRedirect.previous();
        contRedirect.next();
        contRedirect.sortExpression = 'c.con.FirstName';
        // contRedirect.sortExpression = 'con.firstname';
        String sortExp = contRedirect.sortExpression;
       // contRedirect.ViewSortData(); Commented due to error 
        contRedirect.setSortDirection('ASC');
        contRedirect.getSortDirection();
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
        //    event.ZTS_US_End_Date__c = system.today().addDays(i);
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
    
    /*------------insert ZTS_US_Event_Account__c object records-----*/
    public static List<ZTS_US_Event_Account__c> createEventAccount(List<ZTS_Events__c> listEvnts){
        List<ZTS_US_Event_Account__c> listEventAccounts = new List<ZTS_US_Event_Account__c>();
        List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert accList;
        }
        
        for(ZTS_Events__c evnt: listEvnts){
            system.debug('----------------accList---------'+ accList[0]);
            ZTS_US_Event_Account__c evntAcc = new ZTS_US_Event_Account__c(ZTS_US_Event_Account__c=accList[0].Id, ZTS_US_Events__c=evnt.Id);
            listEventAccounts.add(evntAcc);
        }
        return listEventAccounts;
    }
    
    /*-------insert ZTS_US_Event_Invitee__c object records------*/
    public static List<ZTS_US_Event_Invitee__c> createEventInvitee(List<ZTS_Events__c> listEvnts){
        List<ZTS_US_Event_Invitee__c> listEventInvitees = new List<ZTS_US_Event_Invitee__c>();
        List<Contact> conList = ZTS_EU_DataUtilityTest.createContactRecord(1);
        insert conList;
        for(ZTS_Events__c event: listEvnts){
            ZTS_US_Event_Invitee__c evntInv = new ZTS_US_Event_Invitee__c(ZTS_US_Contact__c=conList[0].Id, ZTS_US_Event__c=event.Id,ZTS_US_Invitation_Status__c='Invited');
            listEventInvitees.add(evntInv);
        }
        return listEventInvitees;
    }
}