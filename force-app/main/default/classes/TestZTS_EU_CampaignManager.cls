/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestZTS_EU_CampaignManager {

    static testMethod void ZTS_EU_CampaignManager() {
        test.starttest();
        List<Id> campaignIds = new List<Id>();
        List<Id> accIds = new List<Id>();
        
        Campaign c = new Campaign();
        c.IsActive = true;
        c.ZTS_EU_External_ID__c = '12345';
        c.Name = 'testCampaign';
        c.ZTS_EU_Field_Targeting__c = 'Open';
        c.Type = 'Awareness'; 
        c.Campaign_Name_English__c = 'testCampaign';
        insert c;       
        campaignIds.add(c.id);
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr; 
        Account a = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
        System.runAs(usr)
        {
            insert a;
        }
        
        accIds.add(a.id);
       
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        Contact con = new Contact();
        con.firstname = 'test';
        con.lastname = 'Con';
        con.zts_eu_market__c = 'United Kingdom';
        con.accountID = a.Id;  
        System.runAs(usr)
        {
            insert con;
        }
        
        Set<Id> conSet = new Set<Id>();
        conSet.add(con.Id);
        
        
        ZTS_EU_Campaign_Account__c ca = new ZTS_EU_Campaign_Account__c();
        ca.ZTS_EU_Account__c = a.id;
        ca.ZTS_EU_Campaign__c = c.id;
        ca.ZTS_EU_Member_Status__c = 'Added';
        insert ca;
        List<ZTS_EU_Campaign_Account__c> caList = new List<ZTS_EU_Campaign_Account__c>();
        caList.add(ca);
        
        Map<Id,Set<Id>> accContactIdMap = new Map<Id,Set<Id>>();
        accContactIdMap.put(a.Id, conSet);
        
        ZTS_EU_CampaignManager classObj = new ZTS_EU_CampaignManager();
        ZTS_EU_CampaignManager.getAccountWithContacts(accIds);
        ZTS_EU_CampaignManager.getCampaignsWithMembersForTargetAccounts(caList,accContactIdMap);
        test.stoptest();
    }
}