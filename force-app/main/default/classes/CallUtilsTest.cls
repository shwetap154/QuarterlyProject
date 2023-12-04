/**
* @description       : Test class for CallUtils class (used in multiple trigger handlers)
* @author            : Ketan Prakash Singh @ Deloitte
* @group             : 
* @last modified on  : 03-22-2022
* @last modified by  : Ethan Hirsch @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                           Modification
* 1.0   01-15-2014   Ketan Prakash Singh @ Deloitte   Initial Version (Assumption based on Class Creation)
**/
@IsTest
public class CallUtilsTest {
    
    public static Id accId; 
    
    @testSetup
    public static void setup() { 
        
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('CallTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_DiscussionTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CampaignTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        //Profile Intprofile = [SELECT Id FROM Profile WHERE Name = 'Integration Profile' LIMIT 1];
        //Create User.  Needed to get around process builder on Attendee
        User usr = CPQ_TestDataFactory.createUser(
            'LeadFromCall',
            'Create',
            'Cory.bartholomew@atginfo.com',
            'cory.bartholomew@atginfo.com.testing',
            'testUser1',
            'clfctest',
            profile.Id,
            null,
            false
        );
        usr.ZTS_EU_Market__c = 'United Kingdom';
        
        User insideDiagnosticSalesRep = CPQ_TestDataFactory.createUser(
            'Inside',
            'DiagnosticRep',
            'Cory.bartholomew@atginfo.com',
            'insideDiagRep@zoetistest.com',
            'testUser2',
            'diagRep',
            profile.Id,
            null,
            false
        );
        insideDiagnosticSalesRep.ZTS_EU_Market__c = 'United Kingdom';
        //United states user 
        User statesUsr = CPQ_TestDataFactory.createUser(
            'testCall',
            'Create',
            'demouser@gmail.com',
            'demouser@gmail.com.testing',
            'testStateUser1',
            'testclas',
            profile.Id,
            null,
            false
        );
        statesUsr.ZTS_EU_Market__c = 'United States';
        
        User statesUsr2 = CPQ_TestDataFactory.createUser(
            'testCall1',
            'Create1',
            'demouser1@gmail.com',
            'demouser@gmail.com.testing1',
            'testStateUser12',
            'testcls1',
            profile.Id,
            null,
            false
        );
        statesUsr2.ZTS_EU_Market__c = 'United States';
        statesUsr2.Territory__c = 'Test Territory1';
        
        User statesUsr3 = CPQ_TestDataFactory.createUser(
            'testCall2',
            'Create2',
            'demouser1@gmail.com',
            'demouser@gmail.com.testing2',
            'testStateUser1212',
            'testcls9',
            profile.Id,
            null,
            false
        );
        statesUsr3.ZTS_EU_Market__c = 'United States';
        statesUsr3.Territory__c = null;  
        
        User statesUsr4 = CPQ_TestDataFactory.createUser(
            'testCall3',
            'Create3',
            'demouser3@gmail.com',
            'demouser@gmail.com.testing3',
            'testStateUser1313',
            'testcls8',
            profile.Id,
            null,
            false
        );
        statesUsr4.ZTS_EU_Market__c = 'United States';
        
        
        
        List<User> users = new List<User>{usr,insideDiagnosticSalesRep,statesUsr,statesUsr2,statesUsr3,statesUsr4 };
            insert users;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting(); 
        Test.startTest();
        
        //Create Account
        Account acct = CPQ_TestDataFactory.createAccount(false);
        acct.Name = 'Lead You Down That Road';
        acct.BillingStreet = 'Hornsey Rd';
        acct.BillingCity = 'London';
        acct.BillingPostalCode = 'N7 7AJ';
        acct.BillingCountry = 'United Kingdom';
        acct.ZTS_EU_Market__c = 'United Kingdom';
        acct.ZTS_EU_Zip_Postal_Code__c = '00001';
        insert acct;
        
        //Account with states market 
        Account statesAcct = CPQ_TestDataFactory.createAccount(false);
        statesAcct.Name = 'States Acc';
        statesAcct.BillingStreet = 'Hornsey Rd';
        statesAcct.BillingCity = 'London';
        statesAcct.BillingPostalCode = 'N7 7AJ';
        statesAcct.BillingCountry = 'United Kingdom';
        statesAcct.ZTS_EU_Market__c = 'United States';
        statesAcct.ZTS_EU_Zip_Postal_Code__c = '00001';
        insert statesAcct;
        
        accId = statesAcct.id;
        ZTS_EU_Territory__c territory = CPQ_TestDataFactory.createTerritory('United States',null, 'Inside Sales Diagnostics','Territory', true); 
        ZTS_EU_Position__c position = CPQ_TestDataFactory.createZoetisPosition(insideDiagnosticSalesRep, territory, true);
        position.ZTS_PrimaryUser__c = true;
        position.ZTS_EU_Employee__c = statesUsr.Id;
        
        update position;
        ZTS_AccountTerritory__c acctTerritory = CPQ_TestDataFactory.createAccountTerritory(statesAcct, territory, true, true);
        ZTS_EU_Account_Position__c accountPosition = CPQ_TestDataFactory.createAccountPosition(statesAcct, position, acctTerritory, false);
        
        ZTS_EU_Territory__c territory2 = CPQ_TestDataFactory.createTerritory('United States',null, 'Inside Sales Diagnostics2','Territory', true); 
        ZTS_EU_Position__c position2 = CPQ_TestDataFactory.createZoetisPosition(insideDiagnosticSalesRep, territory2, true);
        position2.ZTS_PrimaryUser__c = true;
        position2.ZTS_EU_Employee__c = statesUsr4.id;
        update position2;
        
        Test.stopTest();
        
        //Create Contact
        Contact contact = CPQ_TestDataFactory.createContact(true);
        system.runAs(statesUsr){
            
            //Create Call in draft status
            Call__c call = new Call__c();        
            call.Name = 'Account Call';
            call.ZTS_EU_Account__c = statesAcct.Id;
            call.ZTS_EU_Start_Date_Time__c = Date.today();
            call.ZTS_EU_Additional_Notes__c = 'Testing';
            call.Discussion_Item__c = 'Diagnostics Equipment Lead';
            call.ZTS_EU_Duration__c = '0.5 Hour';
            call.ZTS_EU_End_Date_Time__c = Date.today();
            call.ZTS_EU_Status__c = 'Planned';
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.ZTS_EU_Call_Owner__c = statesUsr.Id;
            call.ZTS_EU_Call_Objectives__c = 'This is a test';
            insert call;
            
            
            // position.ZTS_EU_Employee__c = statesUsr.Id;
            
            // update position;
            
            
            //create Attendees
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_call__c = call.Id;
            attendee.ZTS_EU_Contact__c = contact.Id;
            attendee.ZTS_EU_Uniqueness_Key__c = null;
            insert attendee;
            
            //Insert Discussion item
            ZTS_EU_Discussion_Item__c discussionItem = new ZTS_EU_Discussion_Item__c();
            discussionItem.ZTS_EU_Active__c = true;
            discussionItem.ZTS_EU_Discussion_Item_Title__c = 'Diagnostics Equipment Lead';
            insert discussionItem;
            
            //Create discussions
            ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c();
            discussion.Name = 'Diagnostics Equipment Lead';
            discussion.ZTS_EU_Call_Attendee__c = attendee.Id;
            discussion.ZTS_EU_Discussion_Items__c = discussionItem.Id;
            discussion.ZTS_EU_Discussion_Topic__c = 'Diagnostics Equipment Lead';
            insert discussion;
            
            List<ZTS_EU_Colleague__c> colleagues = new List<ZTS_EU_Colleague__c>();
            colleagues.add(TestDataFactory.createColleague(call.Id, statesUsr.Id));
            insert colleagues;
        }
        
        
        system.runAs(statesUsr2){
            Call__c call1 = new Call__c();        
            call1.Name = 'Account Call2';
            call1.ZTS_EU_Account__c = statesAcct.id;
            call1.ZTS_EU_Start_Date_Time__c = Date.today();
            call1.ZTS_EU_Additional_Notes__c = 'Testing';
            call1.Discussion_Item__c = 'Diagnostics Equipment Lead2';
            call1.ZTS_EU_Duration__c = '0.5 Hour';
            call1.ZTS_EU_End_Date_Time__c = Date.today();
            call1.ZTS_EU_Status__c = 'Planned';
            call1.ZTS_EU_Sub_Type__c = 'Account Call';
            call1.ZTS_EU_Call_Owner__c = StatesUsr2.Id;
            call1.ZTS_EU_Call_Objectives__c = 'This is a test';
            INSERT call1;
        }
        
        system.runAs(statesUsr3){
            Call__c call2 = new Call__c();
            call2.Name = 'Account Call For Null Check';
            call2.ZTS_EU_Account__c = statesAcct.id;
            call2.ZTS_EU_Start_Date_Time__c = Date.today();
            call2.ZTS_EU_Additional_Notes__c = 'Testing';
            call2.Discussion_Item__c = 'Diagnostics Equipment Lead3';
            call2.ZTS_EU_Duration__c = '0.5 Hour';
            call2.ZTS_EU_End_Date_Time__c = Date.today();
            call2.ZTS_EU_Status__c = 'Planned';
            call2.ZTS_EU_Sub_Type__c = 'Account Call';
            call2.ZTS_EU_Call_Owner__c = StatesUsr3.Id;
            call2.ZTS_EU_Call_Objectives__c = 'This is a test';
            INSERT call2;
        } 
        system.runAs(statesUsr4){
            Call__c call3 = new Call__c();
            call3.Name = 'Account Call For Null Check';
            call3.ZTS_EU_Account__c = statesAcct.id;
            call3.ZTS_EU_Start_Date_Time__c = Date.today();
            call3.ZTS_EU_Additional_Notes__c = 'Testing';
            call3.Discussion_Item__c = 'Diagnostics Equipment Lead3';
            call3.ZTS_EU_Duration__c = '0.5 Hour';
            call3.ZTS_EU_End_Date_Time__c = Date.today();
            call3.ZTS_EU_Status__c = 'Planned';
            call3.ZTS_EU_Sub_Type__c = 'Account Call';
            call3.ZTS_EU_Call_Owner__c = statesUsr4.Id;
            call3.ZTS_EU_Call_Objectives__c = 'This is a test';
            INSERT call3;
        }
        
        DispatchTriggerHandler.clearBypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.clearBypass('CallTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_DiscussionTriggerHandler');
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('CampaignTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
    }
    
    @isTest
    public static void syncOnInsert_Test() { 
        
        List<Call__c> callList = new List<Call__c>([SELECT Id, ZTS_EU_Call_Owner__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__c FROM Call__c]);
        System.assert(callList.size() > 0);
        
        CallUtils.syncOnInsert(callList);
        
        List<Event> events = [SELECT Id FROM Event];
        System.assert(events.size() > 0);
    }
    
    @isTest
    public static void syncOnUpdate_Test() { 
        
        List<Call__c> callList = new List<Call__c>([SELECT Id, ZTS_EU_Call_Owner__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__c FROM Call__c]);
        System.assert(callList.size() > 0);
        
        CallUtils.syncOnInsert(callList);
        
        List<Event> events = [SELECT Id FROM Event];
        System.assert(events.size() > 0);
        
        CallUtils.syncOnUpdate(callList);
    }
    
    @isTest
    public static void createCallCredits_Test_CallNotCompleted() { 
        
        List<Call__c> callList = new List<Call__c>([SELECT Id, ZTS_EU_Call_Owner__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__c, ZTS_EU_Status__c,
                                                    ZTS_EU_Submitted_Date__c, ZTS_EU_Start_Date_Time__c
                                                    FROM Call__c]);
        System.assert(callList.size() > 0);
        
        CallUtils.createCallCredits(callList);
    }
    
    @isTest
    public static void createCallCredits_Test() { 
        
        List<Call__c> callList = new List<Call__c>([SELECT Id, ZTS_EU_Call_Owner__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__c, ZTS_EU_Status__c,
                                                    ZTS_EU_Submitted_Date__c, ZTS_EU_Start_Date_Time__c
                                                    FROM Call__c]);
        System.assert(callList.size() > 0);
        
        callList[0].ZTS_EU_Status__c = ZTS_EU_GlobalConstants.CALL_STATUS_COMPLETED;
        update callList;
        
        CallUtils.createCallCredits(callList);
    }
    
    @isTest
    public static void setCallTerritory_Test() { 
        User u = [SELECT Id,Territory__c FROM User WHERE Username='demouser@gmail.com.testing' LIMIT 1];
        List<Call__c> callList = [SELECT Id, ZTS_EU_Call_Owner__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__c, ZTS_EU_Status__c,
                                  ZTS_EU_Submitted_Date__c, ZTS_EU_Start_Date_Time__c, ZTS_US_Call_Territory__c, CreatedById
                                  FROM Call__c WHERE ZTS_EU_Call_Owner__c=:u.Id];
        System.assert(callList.size() > 0);
        
        CallUtils.setCallTerritory(callList);
    }
    @isTest
    public static void setCallTerritory_Test2() { 
        
        User u1 = [SELECT Id,Territory__c FROM User WHERE Username='demouser@gmail.com.testing1' LIMIT 1];
        List<Call__C> callList = [SELECT Id,CreatedById,Name,ZTS_EU_Account__c,ZTS_EU_Start_Date_Time__c,ZTS_EU_Additional_Notes__c,
                                  Discussion_Item__c,ZTS_EU_Duration__c,ZTS_EU_End_Date_Time__c,ZTS_EU_Status__c,ZTS_EU_Submitted_Date__c,
                                  ZTS_EU_Sub_Type__c,ZTS_EU_Call_Owner__c,ZTS_EU_Call_Objectives__c,
                                  ZTS_US_Call_Territory__c FROM Call__c WHERE ZTS_EU_Call_Owner__c=:u1.id];
        
        System.assert(callList.size() > 0);
        
        CallUtils.setCallTerritory(callList);
        
        system.assertEquals([SELECT ZTS_US_Call_Territory__c FROM Call__c WHERE ZTS_EU_Call_Owner__c=:u1.id][0].ZTS_US_Call_Territory__c, u1.Territory__c);
        
        User u2= [SELECT Id,Territory__c FROM User WHERE Username='demouser@gmail.com.testing2' LIMIT 1];
        callList = [SELECT Id,CreatedById,Name,ZTS_EU_Account__c,ZTS_EU_Start_Date_Time__c,ZTS_EU_Additional_Notes__c,
                    Discussion_Item__c,ZTS_EU_Duration__c,ZTS_EU_End_Date_Time__c,ZTS_EU_Status__c,ZTS_EU_Submitted_Date__c,
                    ZTS_EU_Sub_Type__c,ZTS_EU_Call_Owner__c,ZTS_EU_Call_Objectives__c,
                    ZTS_US_Call_Territory__c FROM Call__c WHERE ZTS_EU_Call_Owner__c=:u2.Id];
        CallUtils.setCallTerritory(callList);
        system.assertEquals([SELECT ZTS_US_Call_Territory__c FROM Call__c WHERE ZTS_EU_Call_Owner__c=:u2.id][0].ZTS_US_Call_Territory__c, null);
        
    } 
    @isTest
    public static void setCallTerritory_Test3() { 
        
        User u1 = [SELECT Id,Territory__c FROM User WHERE Username='demouser@gmail.com.testing3' LIMIT 1];
        List<Call__C> callList = [SELECT Id,CreatedById,Name,ZTS_EU_Account__c,ZTS_EU_Start_Date_Time__c,ZTS_EU_Additional_Notes__c,
                                  Discussion_Item__c,ZTS_EU_Duration__c,ZTS_EU_End_Date_Time__c,ZTS_EU_Status__c,ZTS_EU_Submitted_Date__c,
                                  ZTS_EU_Sub_Type__c,ZTS_EU_Call_Owner__c,ZTS_EU_Call_Objectives__c,
                                  ZTS_US_Call_Territory__c FROM Call__c WHERE ZTS_EU_Call_Owner__c=:u1.id];
        
        System.assert(callList.size() > 0);
        
        CallUtils.setCallTerritory(callList);
        
        Id territoryId =  [select id,ZTS_EU_Territory__r.Name,ZTS_EU_Territory__c,ZTS_PrimaryUser__c, ZTS_EU_Employee__c from ZTS_EU_Position__c where ZTS_EU_Employee__c =: u1.id and ZTS_PrimaryUser__c=true][0].ZTS_EU_Territory__c;
        system.assertEquals([SELECT ZTS_US_Call_Territory__c FROM Call__c WHERE ZTS_EU_Call_Owner__c=:u1.id][0].ZTS_US_Call_Territory__c, territoryId);

    }
    
    @isTest
    public static void createOpportunity_Test() { 
        
        Map<Id, Call__c> callList = new Map<Id, Call__c>([SELECT Id, ZTS_EU_Call_Owner__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__c, ZTS_EU_Status__c,
                                                          ZTS_EU_Submitted_Date__c, ZTS_EU_Start_Date_Time__c
                                                          FROM Call__c]);
        System.assert(callList.size() > 0);
        
        CallUtils.createOpportunity(new List<Id>(callList.keySet()));
    }
}