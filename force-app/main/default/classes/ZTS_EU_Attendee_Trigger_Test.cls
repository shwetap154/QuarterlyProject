/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Attendee_Trigger_Test
* Description   :  Test class for AttendeeTrigger trigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_Attendee_Trigger_Test { 
    
    static testMethod void validate_ZTS_EU_Attendee_Trigger_AfterInsert () { 
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
        Test.startTest();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        // List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
        // TriggerActivation__c tr = new TriggerActivation__c(Name = 'AttendeeTrigger',ZTS_EU_Bypass__c = true);
        // triggerActiveList.add(tr);
        // insert triggerActiveList;   

        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;

        Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
        insert objAccount;

        Contact objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
        ZTS_EU_Species_Specialty__c='Cattle', ZTS_EU_District__c='UK', ZTS_EU_Market__c = 'United Kingdom');
        insert objContact;
        
        Call__c call = new Call__c();         
        call.ZTS_EU_Account__c = objAccount.Id;
        call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
        call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
        call.ZTS_EU_Sub_Type__c = 'Account Call';
        call.ZTS_EU_Call_Owner__c = intlUsr.Id;
        insert call;

        Test.stopTest();

        List<Attendee__c> attendeeList = new List<Attendee__c>();
        Attendee__c attendee = new Attendee__c();
        attendee.ZTS_EU_Contact__c = objContact.Id;
        attendee.ZTS_EU_call__c = call.Id;
        attendee.ZTS_EU_Employee__c=intlUsr.Id;
        attendeeList.add(attendee);

        
        
        
        // System.assert(false, Limits.getQueries());
        ZTS_EU_AttendeeService attenserv= new ZTS_EU_AttendeeService();
        Event evn= new Event(Subject='test Event',StartDateTime=System.now(),EndDateTime=System.now().addHours(1),CallRecordId__c=attendeeList[0].ZTS_EU_call__c);
        insert attendeeList;
        insert evn;
        ZTS_EU_AttendeeService.getCallIdToContactIdOrUserId_Map(attendeeList);
        ZTS_EU_AttendeeService.createEventRelations(attendeeList);
        delete attendeeList;
            
        system.assertNotEquals(AttendeeList.size(),0);
        }

    }
    static testMethod void validate_ZTS_EU_Attendee_Trigger_AfterInsert_catch () { 
        Test.StartTest();
        try {

            ZTS_EU_AttendeeService.createEventRelations(null);
        }
        catch(exception e){
            system.assertEquals(e.getMessage()!= null, true);
        }
        Test.StopTest();
    }
    static testMethod void deleteEventRelationscatch () { 
        Test.StartTest();
        try {

            ZTS_EU_AttendeeService.deleteEventRelations(null);
        }
        catch(exception e){
            system.assertEquals(e.getMessage()!= null, true);
        }
        Test.StopTest();
    }
    static testMethod void deleteCampaignMembers() {
        DispatchTriggerHandler.bypass('AccountSpeciesPotentialTriggerHandler');
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('callTriggerHandler');
        DispatchTriggerHandler.bypass('EUSpeciesProductTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CampaignTriggerHandler');
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            Test.startTest();
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();  
            
            User intlUsr = new User();
            intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            intlUsr.FirstName = 'IntUser';
            intlUsr.ZTS_EU_Market__c = 'United Kingdom';
            insert intlUsr;
            
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            Contact objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
                                             ZTS_EU_Species_Specialty__c='Cattle', ZTS_EU_District__c='UK', ZTS_EU_Market__c = 'United Kingdom');
            insert objContact;
            Campaign testCampaign = ZTS_DataUtilityTest.createCampaignRecord(1)[0];
            testCampaign.Campaign_Name_English__c = 'English';
            testCampaign.ZTS_EU_Market__c = 'United Kingdom';
            testCampaign.ZTS_EU_Field_Targeting__c = 'Open';
            insert testCampaign;
            
            ZTS_EU_Campaign_Account__c testCampaignAccount = new ZTS_EU_Campaign_Account__c();
            testCampaignAccount.ZTS_EU_Account__c = objAccount.Id;
            testCampaignAccount.ZTS_EU_Campaign__c = testCampaign.Id;
            insert testCampaignAccount;
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = objAccount.Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.ZTS_EU_Call_Owner__c = intlUsr.Id;
            insert call;
            
            
            List<Attendee__c> attendeeList = new List<Attendee__c>();
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_Contact__c = objContact.Id;
            attendee.ZTS_EU_call__c = call.Id;
            attendeeList.add(attendee);
            insert attendeeList;
            List<Attendee__c> deletedAttendees = new List<Attendee__c>();
            deletedAttendees.add(attendeeList[0]);
            Map<Id, Attendee__c> deletedAttendeesMap = new Map<Id, Attendee__c>();
            for (Attendee__c deletedAttendee : deletedAttendees) {
                deletedAttendeesMap.put(deletedAttendee.Id, deletedAttendee);
            }
            Set<Id> campaignIdSet = new Set<Id>();
            List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
            for (Attendee__c deletedAttendee : deletedAttendees) {
                ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c(
                    Name = 'Test DI 1',
                    ZTS_EU_Campaign__c=testCampaign.Id,
                    ZTS_EU_Call_Attendee__c = deletedAttendees[0].id
                    
                );
                campaignIdSet.add(discussion.ZTS_EU_Campaign__c);
                discussionList.add(discussion);
            }
            insert discussionList;
            ZTS_EU_AttendeeService.getRelatedRecordsAndDeleteCampaignMembers(deletedAttendeesMap);
            Test.stopTest();
            List<CampaignMember> campMembersList = [SELECT Id,CampaignId,ContactId,Call__c 
                                                    FROM CampaignMember 
                                                    WHERE CampaignId IN :campaignIdSet
                                                    AND Call__c =:call.Id
                                                    AND ContactId =:attendeeList[0].ZTS_EU_Contact__c];
            System.assertEquals(0,campMembersList.size(),'Campaign member is get deleted associated with the deleted discussion.');
        }
    }
    //Ilirjana 12/16/14 Added test method
    static testMethod void testColleague(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
        Profile p = [select id from profile where name='System Administrator' limit 1];
        User userRecord =  new User(LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
        Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
        TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
        insert userRecord;
        
        
        Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
        insert acc;
        
        Call__c call = new Call__c (Name='Test Call', ZTS_EU_Account__c=acc.Id, ZTS_EU_Call_Owner__c = userRecord.Id);
        insert call;
        
        List<ZTS_EU_Colleague__c> collList = new List<ZTS_EU_Colleague__c>();
        ZTS_EU_Colleague__c coll = new ZTS_EU_Colleague__c(Name='Test Colleague', ZTS_EU_call__c = call.Id);
        collList.Add(coll);
        insert coll;
        
        Event evn= new Event(Subject='test Event',StartDateTime=System.now(),EndDateTime=System.now().addHours(1),CallRecordId__c=coll.ZTS_EU_call__c);
        insert evn;
        
        Test.startTest();
        ZTS_EU_AttendeeService.createEventRelationsForColleagues(collList);
        map<id,ZTS_EU_Colleague__c> deletedAttendeesMap = new map<id,ZTS_EU_Colleague__c>();
        deletedAttendeesMap.put(coll.ZTS_EU_call__c,coll);
        ZTS_EU_AttendeeService.deleteEventRelationsForColleague(deletedAttendeesMap);
        Test.stopTest();
        }
		
    }
    
}