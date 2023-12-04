/*******************************************************************************************************************************************
* File Name     :  CampaignMemberTriggerTest
* Description   : Test class for CampaignMemberTrigger        
* @author       :  Mayank Agarwal
* Modification Log
===================================================================================================
* Ver.    Date          Author                     Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/16         Keshika                     Created the Class.
* 1.1     8/9/2023     Padma Nerella @ Zoetis Inc  Add bypass UserTriggerHandler to avoid groupId null value and added recordtype for account object to avoid 
                                                   "INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, bad value for restricted picklist field: 
                                                   VETSCAN HM+: [Products_Interested_In__c]"

********************************************************************************************************************************************/
@isTest
private class CampaignMemberTriggerTest{

    static List<Account> accListIns = new List<Account>();
    static List<Contact> conListIns = new List<Contact>();
    static List<ZTS_EU_Campaign_Account__c> listCampAccsIns = new List<ZTS_EU_Campaign_Account__c>();
    static List<Campaign> listCampsIns = new List<Campaign>();
    static List<CampaignMember> campaignMemberListIns = new List<CampaignMember>();
    static List<ZTS_EU_Affiliations__c> listAccConAffIns = new List<ZTS_EU_Affiliations__c>();

 /****************************Insert Campaign Member**************************************************************************/
    private static List<CampaignMember> createCampaignMemberRecord(Integer counter) {
        conListIns = [SELECT Id FROM Contact];
        listCampsIns = [SELECT Id FROM Campaign];

        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        for(Integer i=0;i<counter;i++) {
            CampaignMember campaignMember = new CampaignMember();         
            campaignMember.CampaignId = listCampsIns[1].Id;
            campaignMember.ContactId = conListIns[0].Id;        
            campaignMemberList.add(campaignMember);
        }        
        return campaignMemberList;  
           
    }
     /****************************Insert AccountContactAffiliation(s)**************************************************************************/
    private static List<ZTS_EU_Affiliations__c> createAccConAffiliationRecord(Integer numConAffli) {
       
        List<ZTS_EU_Affiliations__c> accConAffList = new List<ZTS_EU_Affiliations__c>();
        for(Integer i=0;i<numConAffli;i++) {
            ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c();
            accConAff.ZTS_EU_Account__c = accListIns[0].id;
            accConAff.ZTS_EU_Contact__c = conListIns[0].Id;
            accConAffList.add(accConAff);
        }        
        return accConAffList;             
    }

    @TestSetup
    static void createTestData(){
        controlTriggers cttest = new controlTriggers();
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Active_Pending').getRecordTypeId();
        accListIns =  ZTS_DataUtilityTest.createAccountRecord(2);
        accListIns[0].RecordTypeId =recordtypeId;
        accListIns[1].RecordTypeId =recordtypeId;
        List<User> usersToInsert = new List<User>();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u2 = new User(Alias = 'standtus', Email='standarduser12123@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, ZTS_EU_Market__c = 'United States',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1212@testorg.com.uat');
        usersToInsert.add(u2);
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        insert usersToInsert;
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
        conListIns = ZTS_DataUtilityTest.createContactRecord(1);
        conListIns[0].ZTS_EU_Market__c = 'United States';
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        listCampsIns = ZTS_DataUtilityTest.createCampaignRecord(2);
        listCampsIns[0].Campaign_Name_English__c = 'English';
        listCampsIns[1].Campaign_Name_English__c = 'English';
        listCampsIns[0].ZTS_EU_Market__c = 'United States';
        listCampsIns[1].ZTS_EU_Market__c = 'United States';

       

        System.runAs(u2) {
            insert accListIns;
            insert conListIns;
            insert listCampsIns;
            insert listAccConAffIns;
        }

        for(Integer i=0; i<2; i++){
            ZTS_EU_Campaign_Account__c campaignAccountRec = new ZTS_EU_Campaign_Account__c();
            campaignAccountRec.ZTS_EU_Account__c = accListIns[i].Id;
            campaignAccountRec.ZTS_EU_Campaign__c = listCampsIns[i].Id;
            listCampAccsIns.add(campaignAccountRec);
        }

        System.runAs(u2) {
           insert listCampAccsIns;
        }

        
        listAccConAffIns = createAccConAffiliationRecord(1);
        insert listAccConAffIns;
    }
    
    @IsTest
    static void validate_CampaignMemberTriggerTest(){
        campaignMemberListIns = createCampaignMemberRecord(1);

        Test.startTest();
            ZTS_DataUtilityTest.activateTriggerSettings();
            insert campaignMemberListIns;
        Test.stopTest();

        List<Contact> updatedCons = [SELECT Id, Campaign_Member_Created_by_Email__c FROM Contact];
        List<ZTS_EU_Campaign_Account__c> campAcct = [SELECT id FROM ZTS_EU_Campaign_Account__c];
        System.assert( String.isBlank(updatedCons[0].Campaign_Member_Created_by_Email__c), 'Email field should be blank' );
    }

    @IsTest
    static void testCampaignMemberTrigger(){
        // Code added by Amitabh
        //ZTS_DataUtilityTest.activateTriggerSettings();
        campaignMemberListIns = createCampaignMemberRecord(1);
        User u = [SELECT Id FROM User WHERE Email='standarduser12123@testorg.com' LIMIT 1];

        Test.startTest();
            System.runAs(u) {
                insert campaignMemberListIns;
            }
        Test.stopTest();

        List<Contact> updatedCons = [SELECT Id, Campaign_Member_Created_by_Email__c FROM Contact];
        List<ZTS_EU_Campaign_Account__c> campAcct = [SELECT id FROM ZTS_EU_Campaign_Account__c];
        System.assert( !String.isBlank(updatedCons[0].Campaign_Member_Created_by_Email__c), 'Email field should not be blank' );

        delete campaignMemberListIns;
    }

}