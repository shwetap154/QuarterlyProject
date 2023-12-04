/*******************************************************************************************************************************************
* File Name     :  DiscussionsServiceTest
* Description   :  Test class for DiscussionsService
* @author       :  Deepshikha Tyagi
*********************************************************************************************************************************************/
@isTest(SeeAllData = false)
public with sharing class DiscussionsServiceTest {
    
    @isTest
    public static void validate_createCampaignMembers(){
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
            User intlUsr = new User();
            intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            intlUsr.FirstName = 'IntUser';
            intlUsr.ZTS_EU_Market__c = 'United Kingdom';
            insert intlUsr;
            
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            List<Contact> ContactList = ZTS_EU_DataUtilityTest.createContactRecord(2);
            insert ContactList;
            
            List<Campaign> campaignList = new List<Campaign>();
            Set<Id> campaignSet = new Set<Id>();
            Campaign testCampaign = ZTS_DataUtilityTest.createCampaignRecord(2)[0];
            testCampaign.Campaign_Name_English__c = 'English';
            testCampaign.ZTS_EU_Market__c = 'United Kingdom';
            testCampaign.ZTS_EU_Field_Targeting__c = 'Open';
            testCampaign.IsActive = true;
            campaignList.add(testCampaign);
            
            Campaign testCamp = ZTS_DataUtilityTest.createCampaignRecord(2)[1];
            testCamp.Campaign_Name_English__c = 'English';
            testCamp.ZTS_EU_Market__c = 'United Kingdom';
            testCamp.ZTS_EU_Field_Targeting__c = 'Open';
            testCamp.IsActive = true;
            campaignList.add(testCamp);
            insert campaignList;
            
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
            attendee.ZTS_EU_Contact__c = ContactList[0].Id;
            attendee.ZTS_EU_call__c = call.Id;
            attendeeList.add(attendee);
            Attendee__c attend = new Attendee__c();
            attend.ZTS_EU_Contact__c = ContactList[1].Id;
            attend.ZTS_EU_call__c = call.Id;
            attendeeList.add(attend);
            insert attendeeList;

            List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
            ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c(Name = 'Test DI 1',
                                                                       ZTS_EU_Campaign__c=testCamp.Id,
                                                                       ZTS_EU_Call_Attendee__c = attendeeList[0].id
                                                                      );
            campaignSet.add(discussion.ZTS_EU_Campaign__c);
            discussionList.add(discussion);
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(Name = 'Test DI 2',
                                                                 ZTS_EU_Campaign__c=testCampaign.Id,
                                                                 ZTS_EU_Call_Attendee__c = attendeeList[0].id
                                                                );
            campaignSet.add(disc.ZTS_EU_Campaign__c);
            discussionList.add(disc);
            ZTS_EU_Discussion__c disc1 = new ZTS_EU_Discussion__c(Name = 'Test DI 3',
                                                                 ZTS_EU_Campaign__c=testCampaign.Id,
                                                                 ZTS_EU_Call_Attendee__c = attendeeList[1].id
                                                                );
            campaignSet.add(disc1.ZTS_EU_Campaign__c);
            discussionList.add(disc1);
            insert discussionList;
            Test.stopTest();
            //Two Campaign Member will get inserted for one Attendee after inserting discussions
            List<CampaignMember> campMembersList = [SELECT Id,CampaignId,ContactId,Call__c 
                                                    FROM CampaignMember 
                                                    WHERE CampaignId IN :campaignSet
                                                    AND Call__c =:call.Id
                                                    AND ContactId =:attendeeList[0].ZTS_EU_Contact__c];
            System.assertEquals(2,campMembersList.size(),'There will be two Campaign members will get created.');
            
            //One Campaign Member will get created for another Attendee
            List<CampaignMember> campMembersListWithDiffContact = [SELECT Id,CampaignId,ContactId,Call__c 
                                                    FROM CampaignMember 
                                                    WHERE CampaignId IN :campaignSet
                                                    AND Call__c =:call.Id
                                                    AND ContactId =:attendeeList[1].ZTS_EU_Contact__c];
            System.assertEquals(1,campMembersListWithDiffContact.size(),'One Campaign members is created for a contact.');
        }
    }
    @isTest
    public static void validate_deleteCampaignMembers(){
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
            User intlUsr = new User();
            intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            intlUsr.FirstName = 'IntUser';
            intlUsr.ZTS_EU_Market__c = 'United Kingdom';
            insert intlUsr;
            
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            List<Contact> ContactList = ZTS_EU_DataUtilityTest.createContactRecord(2);
            insert ContactList;
            
            List<Campaign> campaignList = new List<Campaign>();
            List<Id> campaignIdList = new List<Id>();
            Campaign testCampaign = ZTS_DataUtilityTest.createCampaignRecord(2)[0];
            testCampaign.Campaign_Name_English__c = 'English';
            testCampaign.ZTS_EU_Market__c = 'United Kingdom';
            testCampaign.ZTS_EU_Field_Targeting__c = 'Open';
            testCampaign.IsActive = true;
            campaignList.add(testCampaign);
            
            Campaign testCamp = ZTS_DataUtilityTest.createCampaignRecord(2)[1];
            testCamp.Campaign_Name_English__c = 'English';
            testCamp.ZTS_EU_Market__c = 'United Kingdom';
            testCamp.ZTS_EU_Field_Targeting__c = 'Open';
            testCamp.IsActive = true;
            campaignList.add(testCamp);
            insert campaignList;
            
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
            attendee.ZTS_EU_Contact__c = ContactList[0].Id;
            attendee.ZTS_EU_call__c = call.Id;
            attendeeList.add(attendee);
            Attendee__c attend = new Attendee__c();
            attend.ZTS_EU_Contact__c = ContactList[1].Id;
            attend.ZTS_EU_call__c = call.Id;
            attendeeList.add(attend);
            insert attendeeList;
            
            List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
            ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c(Name = 'Test DI 1',
                                                                       ZTS_EU_Campaign__c=testCamp.Id,
                                                                       ZTS_EU_Call_Attendee__c = attendeeList[0].id
                                                                      );
            campaignIdList.add(discussion.ZTS_EU_Campaign__c);
            discussionList.add(discussion);
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(Name = 'Test DI 2',
                                                                 ZTS_EU_Campaign__c=testCampaign.Id,
                                                                 ZTS_EU_Call_Attendee__c = attendeeList[0].id
                                                                );
            campaignIdList.add(disc.ZTS_EU_Campaign__c);
            ZTS_EU_Discussion__c disc1 = new ZTS_EU_Discussion__c(Name = 'Test DI 2',
                                                                 ZTS_EU_Campaign__c=testCampaign.Id,
                                                                 ZTS_EU_Call_Attendee__c = attendeeList[1].id
                                                                );
            campaignIdList.add(disc1.ZTS_EU_Campaign__c);
            discussionList.add(disc);
            insert discussionList;
   
            List<ZTS_EU_Discussion__c> discList = [SELECT Id,Name,ZTS_EU_Campaign__c,ZTS_EU_Call_Attendee__c
                                                   FROM ZTS_EU_Discussion__c
                                                   WHERE ZTS_EU_Call_Attendee__c =:attendeeList[0].Id
                                                   AND ZTS_EU_Campaign__c = :campaignIdList[0]];
            List<ZTS_EU_Discussion__c> discListWithDiffCon = [SELECT Id,Name,ZTS_EU_Campaign__c,ZTS_EU_Call_Attendee__c
                                                              FROM ZTS_EU_Discussion__c
                                                              WHERE ZTS_EU_Call_Attendee__c =:attendeeList[1].Id
                                                              AND ZTS_EU_Campaign__c = :campaignIdList[0]];
            
            //Deleting only one discussion that will delete related Campaign Member
            If(!discList.isEmpty()){
                delete discList[0];
            }
            
            //Deleting a discussion belongs to another attendee, will delete associated Campaign Member 
            If(!discList.isEmpty()){
                delete discListWithDiffCon;
            }
            Test.stopTest();
            List<CampaignMember> campMembersList = [SELECT Id,CampaignId,ContactId,Call__c 
                                                    FROM CampaignMember 
                                                    WHERE CampaignId IN :campaignIdList
                                                    AND Call__c =:call.Id
                                                    AND ContactId =:attendeeList[0].ZTS_EU_Contact__c];
            System.assertEquals(1,campMembersList.size(),'One Campaign member is get deleted associated with the deleted discussion.');
            
            List<CampaignMember> campMembersListWithDiffCon = [SELECT Id,CampaignId,ContactId,Call__c 
                                                                FROM CampaignMember 
                                                                WHERE CampaignId IN :campaignIdList
                                                                AND Call__c =:call.Id
                                                                AND ContactId =:attendeeList[1].ZTS_EU_Contact__c]; 
            System.assertEquals(0,campMembersListWithDiffCon.size(),'Campaign member is get deleted associated with the deleted discussion.');
            
        }  
    }
    @isTest
    private static void DiscussionsService_createCampaignMember_Exception_Test() {
        DiscussionsService.forceExceptionInsertCampaignMemberRecord = true;
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
            List<Campaign> campaignList = new List<Campaign>();
            Set<Id> campaignSet = new Set<Id>();
            Campaign testCampaign = ZTS_DataUtilityTest.createCampaignRecord(2)[0];
            testCampaign.Campaign_Name_English__c = 'English';
            testCampaign.ZTS_EU_Market__c = 'United Kingdom';
            testCampaign.ZTS_EU_Field_Targeting__c = 'Open';
            testCampaign.IsActive = true;
            campaignList.add(testCampaign);
            
            Campaign testCamp = ZTS_DataUtilityTest.createCampaignRecord(2)[1];
            testCamp.Campaign_Name_English__c = 'English';
            testCamp.ZTS_EU_Market__c = 'United Kingdom';
            testCamp.ZTS_EU_Field_Targeting__c = 'Open';
            testCamp.IsActive = true;
            campaignList.add(testCamp);
            insert campaignList;
            
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
            List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
            ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c(Name = 'Test DI 1',
                                                                       ZTS_EU_Campaign__c=testCamp.Id,
                                                                       ZTS_EU_Call_Attendee__c = attendeeList[0].id
                                                                      );
            campaignSet.add(discussion.ZTS_EU_Campaign__c);
            discussionList.add(discussion);
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(Name = 'Test DI 2',
                                                                 ZTS_EU_Campaign__c=testCampaign.Id,
                                                                 ZTS_EU_Call_Attendee__c = attendeeList[0].id
                                                                );
            campaignSet.add(disc.ZTS_EU_Campaign__c);
            discussionList.add(disc);
            insert discussionList;
            Test.stopTest();
            System.assert(DiscussionsService.forceExceptionInsertCampaignMemberRecord,
                'An error did not occur when Inserting Campaign Member Record as expected.');
            List<CampaignMember> campMembersList = [SELECT Id,CampaignId,ContactId,Call__c 
                                                    FROM CampaignMember 
                                                    WHERE CampaignId IN :campaignSet
                                                    AND Call__c =:call.Id
                                                    AND ContactId =:attendeeList[0].ZTS_EU_Contact__c];
            
            System.assertEquals(0, campMembersList.size(), 'Campaign Member Records were created unexpectedly.');
        }
    }
    }