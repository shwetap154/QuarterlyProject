/**
 * @description       : Test class for ZTS_EU_SalesCallController
 * @author            : Deloitte consulting
 * @group             : 
 * @last modified on  : 07-26-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-15-2014   Vidya @ Deloitte            Created the Class.
 * 1.1   07-26-2022   Ethan Hirsch @ Zoetis Inc   Changed createTestData to only be called once per class execution to 
 *                                                save on execution time and avoid extra limit usage inside a Test block.
 *                                                Create addresses with the ZTS_DataUtilityTest method instead of 
 *                                                ZTS_EU_DataUtilityTest to avoid extra daa creation.
 *                                                Bypass Triggers in setup to avoid limits.
 *                                                Create Primary_Contact_Inactive_Profile_List__c to avoid null
 *                                                exceptions in ZTS_EU_RepStatusInactive.
 *                                                Remove generateData call from removeAttendeeTest to save on data creation.
 *                                                Remove createAttendeeWrapList in showAttendee test as the data wasn't used.
 *                                                Modify saveAndSubmit to call generateData outside Test.startTest to save on limits.
 *                                                Modify generateData to only insert Species Products once.
 * 1.2 09-11-2023     Rahul @ Cognizant           Modify createAttendeeWrapList because we cannot add same attendee to call again so we are checking same Attendees available on same call, if it is not exist create new call
 **/
@isTest
public class ZTS_EU_SalesCallControllerTest1 
{   
    static final String INTL_USER_FN = 'intlUser';

    static List<Account> listAccount;
    static List<Contact> listContact;
    static Task tak;
    static List<Call__c> listCalls;
    
    @TestSetup
    static void makeData(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('CallTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_DiscussionTriggerHandler');

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = INTL_USER_FN;
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        createTestData(usr);

        DispatchTriggerHandler.clearAllBypasses();
    }

    public static void createTestData(User usr){
        
        System.runAs(usr)
        {
        
            //Code change on 6th Oct-17
            User userRecord1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            userRecord1.Email = 'temp@temp.com';
            insert userRecord1;
            listAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            listAccount[0].ZTS_EU_Market__c = 'United Kingdom';
            insert listAccount;
            
            List<Address__c> listAddress = ZTS_DataUtilityTest.createAddressrec(listAccount);
            insert listAddress;
            
            listCalls = createCalls(listAccount);
            for(Call__c c : listCalls){
                c.ZTS_EU_SelectedAdress__c = 'Test'; 
                c.ZTS_EU_Address__c = listAddress[0].Id; 
                c.ZTS_EU_Call_Owner__c = userRecord1.Id;
            }
            System.runAs(userRecord1)
            {
                insert listCalls;
            }
            
            listContact = ZTS_EU_DataUtilityTest.createContactRecord(1);
            insert listContact;
            //below lines added by Mayukh Deb as part of SC-002827
            List <Call__c> lstcall = [select Id from Call__c WHERE ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States' Limit 1];
            Attendee__c lstatnd = new Attendee__c(Name='TestAtt1',ZTS_EU_call__c=lstcall[0].id);
            insert lstatnd;
            ZTS_EU_Discussion__c lstdis = new ZTS_EU_Discussion__c(Name='TestDis1',ZTS_EU_Call_Attendee__c=lstatnd.id);
            insert lstdis;
            
        }
    }

    // Setup static variables with existing data
    // Originally createTestData was called for every test
    public static void retrieveTestData() {
        listAccount = [SELECT Id FROM Account LIMIT 1];
        listContact = [SELECT Id FROM Contact LIMIT 1];
        listCalls = [
            SELECT Id, ZTS_EU_Account__c, ZTS_EU_Sub_Type__c, ZTS_EU_Start_Date_Time__c, ZTS_EU_End_Date_Time__c, Name,
                   ZTS_EU_Call_Owner__c, ZTS_EU_Status__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Additional_Notes__c,
                   ZTS_EU_Next_Step__c, ZTS_EU_Duration__c, ZTS_EU_Next_Call_Date__c, ZTS_EU_Local_Subtype__c,
                   ZTS_EU_Expense_Value__c, ZTS_EU_Expense_Type__c, ZTS_EU_Expense_Comments__c, ZTS_EU_SelectedAdress__c,
                   ZTS_EU_Agree_To_Purchase__c, ZTS_EU_Submitted_Date__c, ZTS_EU_City__c, ZTS_EU_Address__c,ZTS_EU_Next_Call_Type__c
            FROM Call__c
            LIMIT 1];
    }
    
    static testMethod void createStandardControllerT(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.accountChange();
            
            test.stoptest();
        }
    }
    
    static testMethod void createStandardControllerTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            //ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
            
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            State_Country__c stateC = new State_Country__c(ZTS_EU_Country__c='United Kingdom',ZTS_EU_uniqueCOUNTY__c='UK');
            insert stateC;
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='London',ZTS_EU_Street__c='test street',ZTS_EU_Country__c='United Kingdom',ZTS_EU_State_County__c=stateC.Id,Zip_Postal_Code__c ='440013');
            insert address;
            String profleName = salesCall.userProfileName;
            String cityName = salesCall.City;
            List<SelectOption> addList = salesCall.addressList;
            List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }
    
    static testMethod void createStandardControllerTest2(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            //ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
            
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            State_Country__c stateC = new State_Country__c(ZTS_EU_Country__c='United Kingdom',ZTS_EU_uniqueCOUNTY__c='UK');
            insert stateC;
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='London',ZTS_EU_Street__c='test street',ZTS_EU_Country__c='United Kingdom',ZTS_EU_State_County__c=stateC.Id,Zip_Postal_Code__c ='440013');
            insert address;
            String profleName = salesCall.userProfileName;
            String cityName = salesCall.City;
            List<SelectOption> addList = salesCall.addressList;
            List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }
    
    static testMethod void userProfileNameTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            //ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
            
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.accountChange();
            test.stopTest();
        }
    }
    
    static testMethod void productAdaptationTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            
            test.startTest();
            generateData();        
            salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            salesCall.productAdaptationChange();
            salesCall.addBrandIndication();
            test.stopTest();
        }
    }
    
    static testMethod void cancelBrandIndicationTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            
            test.startTest();
            generateData();
            salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            salesCall.cancelBrandIndication();
            test.stopTest();
        }
    }
    
    static testMethod void addNewPAPTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            
            test.startTest();
            generateData();
            salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            salesCall.addNewPAP();
            test.stopTest();
        }
    }
    
    static testMethod void displaySaveTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            
            test.startTest();
            generateData();
            salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            salesCall.displaySave();
            test.stopTest();
        }
    }
    
    static testMethod void saveCallTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.productRemoveId = 'Test';
            salesCall.keyMsgRemoveId = 'Test';
            salesCall.sDropRemoveId = 'Test';
            salesCall.aapRemoveId = 'Test';
            salesCall.accid = 'Test';
            
            test.startTest();
            generateData();
            salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            salesCall.saveCall();
            salesCall.getIsMarketFromCLAR();
            test.stopTest();
        }
    }
    
    static testMethod void saveCallTest2(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            
            Test.startTest();
            generateData();
            salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            salesCall.saveCall();
            Test.stopTest();
        }
    }
    
    static testMethod void cancelCallTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.cancelCall();
            test.stopTest();
        }
    }
    
    static testMethod void editCallTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.editCall();
            test.stopTest();
        }
    }
    
    static List<ZTS_EU_SalesCallController.attendeerWrapper> createAttendeeWrapList(Integer num){

         //We cannot add same attendee to call again so we are checking same Attendees available on same call, if it is not exist create new call
            Attendee__c attn = new Attendee__c();
            List<Attendee__c> attnList  = new List<Attendee__c>([SELECT Id,ZTS_EU_call__c,ZTS_EU_Contact__c,ZTS_EU_Employee__c,ZTS_EU_Represents_Account__c,ZTS_EU_External_ID__c,ZTS_EU_Uniqueness_Key__c,ZTS_EU_Related_Campaign__c FROM Attendee__c WHERE ZTS_EU_call__c=:listCalls[0].Id AND ZTS_EU_Contact__c =: listContact[0].Id]);
            if(attnList.size()>0){
                attn = attnList[0];
            }
            else{
                attn = new Attendee__c(ZTS_EU_call__c= listCalls[0].id,ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Employee__c=UserInfo.getUserId(),
                                           ZTS_EU_Represents_Account__c=listAccount[0].Id,ZTS_EU_External_ID__c='testExt'+num,ZTS_EU_Uniqueness_Key__c='testKey'+num);
        insert attn;
                
            }
       
        ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_Account_influence__c='High',ZTS_EU_Affiliation_Status__c='Active',
                                                                ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Commitment_Level__c='Supporter',ZTS_EU_Job_Function__c='Lead Technician',ZTS_EU_Profession__c='Consultant');
        insert aff;
        ZTS_EU_Colleague__c coll = new ZTS_EU_Colleague__c(ZTS_EU_Call__c=listCalls[0].Id,ZTS_EU_User__c=UserInfo.getUserId(),ZTS_EU_Automatic_ECC_creation__c='To be Created');
        insert coll;
        ZTS_EU_SalesCallController.attendeerWrapper attWrapList = new ZTS_EU_SalesCallController.attendeerWrapper();
        attWrapList.attendeeObj = attn;
        attWrapList.aConAff = aff;
        attWrapList.selectedAcctPos = listAccount[0].Id;
        attWrapList.colleagueobj = coll;
        List<ZTS_EU_SalesCallController.attendeerWrapper > wrapList = new List<ZTS_EU_SalesCallController.attendeerWrapper >{attWrapList};
            return wrapList;
    }
    
    static testMethod void saveAndSubmitTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            Attendee__c attn = new Attendee__c(ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Employee__c=UserInfo.getUserId(),ZTS_EU_External_ID__c='test123',
                                               ZTS_EU_Represents_Account__c=listAccount[0].Id);
            
                                               
            generateData();
            test.startTest();
            salesCall.saveAndSubmit();
            test.stopTest();
        }
    }
    
    static testMethod void showAttendee(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();

            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);

            test.startTest();
            generateData();
            Campaign camp = new Campaign(Name='TestCamp', Campaign_Name_English__c = 'TestCampaign', isActive=true,StartDate=system.today());
            insert camp;
            CampaignMember campMem = new CampaignMember(CampaignId=camp.Id,ContactId=listContact[0].Id);
            insert campMem;
            salesCall.showAttendee();
            test.stopTest();
        } 
    }
    
    static testMethod void removeAttendeeTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            
            test.startTest();
            List<ZTS_EU_SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(3);
            salesCall.attendeeRemoveId = wrapList[0].attendeeObj.Id;
            salesCall.removeAttendee();
            test.stopTest();
        }
    }
    
    static testMethod void removeColleagueTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            List<ZTS_EU_SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(5);
            salesCall.colleagueRemoveId = wrapList[0].colleagueobj.Id;
            salesCall.removeColleague();
            test.stopTest();
        } 
    }
    
    static testMethod void removeDiscussionItemTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            
            test.startTest();
            generateData();
            List<ZTS_EU_SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(4);
            //salesCall.discRemoveId = wrapList[0].colleagueobj.Id;
            salesCall.removeDiscussionItem();
            test.stopTest();
        } 
    }
    
    static testMethod void deleteCallTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.deleteCall();
            test.stopTest();
        }
    }
    
    static testMethod void showFollowUpActivitiesTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.showFollowUpActivities();
            test.stopTest();
        }
    }
    
    static testMethod void removeFollowUpActivitiesTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            
            retrieveTestData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            
            Test.startTest();
            generateData();
            salesCall.followUpActivityRemoveId = tak.Id;
            salesCall.removeFollowUpActivities();
            Test.stopTest();
        }
    }
    
    static testMethod void calculateEndDateTimeTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCAll.calculateEndDateTime();
            test.stopTest();
        }
    }
    
    static testMethod void saveTaskTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.saveTask();
            test.stopTest();
        }
    }
    
    static testMethod void addSectionToTaskTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.addSectionToTask();
            test.stopTest();
        }
    }
    
    static testMethod void showDiscussionAFTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.showDiscussionAF();
            test.stopTest();
        }
    }
    
    static testMethod void hideDiscussionAFTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            retrieveTestData();
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            salesCall.hideDiscussionAF();
            test.stopTest();
        }
    }
    
    
    static void generateData(){
		DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_DiscussionTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CampaignTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_ProductAdoptionProfileHandler');
        DispatchTriggerHandler.bypass('TaskTriggerHandler');
        User usr = [SELECT Id FROM User WHERE FirstName = :INTL_USER_FN];
        
        System.runAs(usr)
        {
            Attendee__c att = new Attendee__c(ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Represents_Account__c=listAccount[0].Id);
            insert att;
            ZTS_EU_Species_Product__c spProd = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Brand',Name='Test',ZTS_EU_Is_Detailable__c=true, ZTS_Hierarchy_Level__c='Brand' );
            ZTS_EU_Species_Product__c spProd1 = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Business Unit',Name='Test');
            insert new List<ZTS_EU_Species_Product__c> { spProd, spProd1 };
            Product2 prod = new Product2(ZTS_EU_Market__c='United Kingdom',Name='Test Product',ZTS_EU_Product_Type__c='Brand',isActive=true);
            insert prod;
            ZTS_EU_Species__c sp = new ZTS_EU_Species__c(ZTS_EU_Business_Unit__c=spProd1.Id,ZTS_External_ID__c='Test12',ZTS_EU_Market__c='United Kingdom',ZTS_EU_Species__c='TEst Species');
            insert sp;
            ZTS_EU_Brand_Indication__c brndInd = new ZTS_EU_Brand_Indication__c(ZTS_EU_Product__c=spProd.Id, Market__c='United Kingdom');
            insert brndInd;
            ZTS_EU_Product_Barrier__c prodBar = new ZTS_EU_Product_Barrier__c(ZTS_EU_Brand_Indication__c=brndInd.Id);
            insert prodBar;
            ZTS_EU_Product_Adoption_Profile__c prodAdop = new ZTS_EU_Product_Adoption_Profile__c(ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Contact_Primary_Account__c=listAccount[0].Id,
                                                                                                ZTS_EU_Brand_Indication__c=brndInd.Id,ZTS_EU_Uniqueness_Key__c='test12',ZTS_EU_Product_Barrier__c=prodBar.Id,ZTS_EU_Usage__c='Advocate');
            insert prodAdop;//ZTS_EU_Competitor_Product__c=compProd.Id,
            State_Country__c stateC = new State_Country__c(ZTS_EU_Country__c='United Kingdom',ZTS_EU_uniqueCOUNTY__c='UK');
            insert stateC;
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='London',ZTS_EU_Street__c='test street',ZTS_EU_Country__c='United Kingdom',ZTS_EU_State_County__c=stateC.Id,Zip_Postal_Code__c ='440013');
            insert address;
            Campaign camp = new Campaign(Name='TestCamp',Campaign_Name_English__c = 'TestCampaign', isActive=true,StartDate=system.today());
            insert camp;
            CampaignMember campMem = new CampaignMember(CampaignId=camp.Id,ContactId=listContact[0].Id);
            insert campMem;
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c(ZTS_EU_Market__c='Brand',ZTS_EU_Active__c=true,ZTS_EU_Discussion_Item_Title__c='Test Item', ZTS_EU_Start_Date__c = (system.today() - 1));
            insert discItem;
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(ZTS_EU_Call_Attendee__c=att.Id,ZTS_EU_Campaign__c=camp.Id,ZTS_EU_Discussion_Items__c=discItem.Id,ZTS_EU_Product__c=spProd.Id);
            insert disc;
            tak = new Task(OwnerId=UserInfo.getUserId(),CallDurationInSeconds=10,ActivityDate=system.today(),WhoId=listContact[0].Id,Status='Completed',Subject='Call',Type='Call');
            insert tak;
            DispatchTriggerHandler.clearbypass('AttendeeTriggerHandler');
            DispatchTriggerHandler.clearbypass('ContactTriggerHandler');
            DispatchTriggerHandler.clearbypass('ZTS_EU_DiscussionTriggerHandler');
            DispatchTriggerHandler.clearbypass('AccountTriggerHandler');
            DispatchTriggerHandler.clearbypass('CampaignTriggerHandler');
            DispatchTriggerHandler.clearbypass('UserTriggerHandler');
            DispatchTriggerHandler.clearbypass('ZTS_EU_ColleagueTriggerHandler');
            DispatchTriggerHandler.clearbypass('AddressTriggerHandler');
            DispatchTriggerHandler.clearbypass('ZTS_EU_ProductAdoptionProfileHandler');
            DispatchTriggerHandler.clearbypass('TaskTriggerHandler');
        }
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
            event.ZTS_US_End_Date__c = system.today().addDays(i);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
            //event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';//Pooja - Added new rich text field insted old text field "ZTS_US_Purpose_Agenda__c"
            listEvents1.add(event);
        }
        return listEvents1;
    }
    /*-------insert Call__c object records */
    public static List<Call__c> createCalls(List<Account> listAcct){
        
        
        List<Call__c> listCall = new List<Call__c>();
        for(Account acc: listAcct){
            Call__c call = new Call__c(ZTS_EU_Account__c=acc.Id,  ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2),
                                       ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today());
            listCall.add(call);
        }
        return listCall;
    }
}