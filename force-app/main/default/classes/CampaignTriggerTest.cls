/**
 * @description       : 
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 04-01-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   Unknown      Unknown                      Initial Version
 * 1.1   04-01-2021   Morgan Marchese @ Zoetis Inc  Added United States Market Value to createTestData
**/
@isTest
private class CampaignTriggerTest {

    static List<Campaign> createTestData(Integer num) {
        List<Campaign> camps = ZTS_DataUtilityTest.createCampaignRecord(num);
        for(Campaign c : camps){
            c.ZTS_EU_Market__c = 'United States';
        }
        Insert Camps;
        List<ZTS_EU_Campaign_Account__c> campaignAcntList = ZTS_DataUtilityTest.createCampaignAccountRecord(1);
        List<Account> accts = ZTS_DataUtilityTest.createAccountRecord(1);
        Insert accts;
        campaignAcntList[0].ZTS_EU_Account__c = accts[0].id;
        campaignAcntList[0].ZTS_EU_Campaign__c = camps[0].id;
        Insert campaignAcntList;
        return camps;
    }

    @IsTest
    static void myUnitTest1() {
        test.startTest();
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Campaign> cmpgn=CampaignTriggerTest.createTestData(1);
        cmpgn[0].Key_Initiative__c = True;
        Update cmpgn;
        TargetedAccountFlagUpdate bc = new TargetedAccountFlagUpdate(cmpgn);

        Database.executeBatch(bc, 1);
        Test.stopTest();

        List<ZTS_EU_Campaign_Account__c> cmpAcctList = [SELECT Id, ZTS_US_Description__c, Key_Initiative__c FROM ZTS_EU_Campaign_Account__c];
        /*
        TODO

        Look into why the Key_Initiative__c from campaign is not copied from the Campaign.Key_Initiative__c
        */
        System.assert(cmpgn[0].Description == cmpAcctList[0].ZTS_US_Description__c, 'ZTS_EU_Campaign_Account__c description does not match Campaign description');
    }

    @IsTest
    static void myUnitTest2() {
        test.startTest();
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Campaign> cmpgn=CampaignTriggerTest.createTestData(1);
        cmpgn[0].Key_Initiative__c = false;
        Update cmpgn;
        TargetedAccountFlagUpdate bc = new TargetedAccountFlagUpdate(cmpgn);

        Database.executeBatch(bc, 1);
        Test.stopTest();

        List<ZTS_EU_Campaign_Account__c> cmpAcctList = [SELECT Id, ZTS_US_Description__c, Key_Initiative__c FROM ZTS_EU_Campaign_Account__c];
        System.assert(cmpgn[0].Key_Initiative__c == cmpAcctList[0].Key_Initiative__c, 'ZTS_EU_Campaign_Account__c Key Initiative does not match Campaign Key Initiative');
        System.assert(cmpgn[0].Description == cmpAcctList[0].ZTS_US_Description__c, 'ZTS_EU_Campaign_Account__c description does not match Campaign description');
    }

    @IsTest
    static void myUnitTest3() {
        test.startTest();
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Campaign> cmpgn=CampaignTriggerTest.createTestData(1);
        cmpgn[0].IsActive = False;
        cmpgn[0].Key_Initiative__c = True;
        Update cmpgn;
        TargetedAccountFlagUpdate bc = new TargetedAccountFlagUpdate(cmpgn);

        Database.executeBatch(bc, 1);
        Test.stopTest();

        List<ZTS_EU_Campaign_Account__c> cmpAcctList = [SELECT Id, ZTS_US_Description__c, Key_Initiative__c, ZTS_US_Active__c FROM ZTS_EU_Campaign_Account__c];
        /*
        TODO

        Look into why the Key_Initiative__c from campaign is not copied from the Campaign.Key_Initiative__c
        */
        System.assert(cmpgn[0].IsActive == cmpAcctList[0].ZTS_US_Active__c, 'ZTS_EU_Campaign_Account__c active state does not match Campaign active state');
        System.assert(cmpgn[0].Description == cmpAcctList[0].ZTS_US_Description__c, 'ZTS_EU_Campaign_Account__c description does not match Campaign description');
    }

    @IsTest
    static void myUnitTest4() {
        test.startTest();
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Campaign> cmpgn=CampaignTriggerTest.createTestData(1);
        cmpgn[0].IsActive = False;
        cmpgn[0].Key_Initiative__c = False;
        Update cmpgn;
        TargetedAccountFlagUpdate bc = new TargetedAccountFlagUpdate(cmpgn);

        Database.executeBatch(bc, 1);
        Test.stopTest();

        List<ZTS_EU_Campaign_Account__c> cmpAcctList = [SELECT Id, ZTS_US_Description__c, Key_Initiative__c, ZTS_US_Active__c FROM ZTS_EU_Campaign_Account__c];
        System.assert(cmpgn[0].Key_Initiative__c == cmpAcctList[0].Key_Initiative__c, 'ZTS_EU_Campaign_Account__c Key Initiative does not match Campaign Key Initiative');
        System.assert(cmpgn[0].IsActive == cmpAcctList[0].ZTS_US_Active__c, 'ZTS_EU_Campaign_Account__c active state does not match Campaign active state');
        System.assert(cmpgn[0].Description == cmpAcctList[0].ZTS_US_Description__c, 'ZTS_EU_Campaign_Account__c description does not match Campaign description');
    }
    
}