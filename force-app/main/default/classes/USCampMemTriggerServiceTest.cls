/****************************************************************************************************************************************** 
* Class Name       : USCampMemTriggerServiceTest
* Description      : Test Class for "USCampaignMemberTriggerService.cls" (SC-008159)                                 
* Created By   	: Cognizant
* Created Date 	: April 8th, 2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra(Cognizant)        04/08/2021          Created 
*****************************************************************************************************************************************/
@isTest
public with sharing class USCampMemTriggerServiceTest {
    
    static testMethod void testCampMemInsert(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('US Business Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        System.runAs(usr)
        {
            List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(1);
            lstacnt[0].zts_eu_market__c='United States';
            insert lstacnt;
            
            List<Contact> testcontactList;
            testcontactList = ZTS_DataUtilityTest.createContactRecord(3);
            
            for(Contact c: testcontactList)
            {
                c.ZTS_EU_Market__c = 'United States';   
                c.AccountID= lstacnt[0].Id;
            }
            insert testcontactList;
            
            /*list<ZTS_EU_Affiliations__c> testaffList;
testaffList = ZTS_DataUtilityTest.createAccConAffiliationRecord(3);
for(Integer i=0;i<3;i++){
testaffList[i].ZTS_EU_Contact__c=testcontactList[i].id;
testaffList[i].ZTS_EU_Account__c=lstacnt[0].id;
}
insert testaffList;*/
            
            
            List<Campaign> lstcamp = ZTS_DataUtilityTest.createCampaignRecord(1);
            lstcamp[0].zts_eu_market__c='United States';
            lstcamp[0].startDate = system.today();
            lstcamp[0].EndDate = system.today()	+15;
            lstcamp[0].Type = 'Email';
            lstcamp[0].Campaign_Name_English__c = 'US Test';
            lstcamp[0].Name = 'US Test';
            lstcamp[0].ZTS_EU_Field_Targeting__c= 'Open';
            lstcamp[0].IsActive = true;
            insert lstcamp;
            
            CampaignMemberStatus cms = new CampaignMemberStatus();
            cms.CampaignId = lstcamp[0].id;
            cms.Label = 'test';
            cms.IsDefault = True;
            insert cms;
            
            CampaignMember newCm = new CampaignMember();
            newCm.CampaignId	=lstcamp[0].Id;
            newCm.ContactId   =  testcontactList[0].id;
            
            CampaignMember newCm1 = new CampaignMember();
            newCm1.CampaignId	=lstcamp[0].Id;
            newCm1.ContactId   =  testcontactList[1].id;
            
            insert new List<CampaignMember>{newCm,newCm1};
            
            
        }
        
        
    }
    
    static testMethod void testCampMemDelete(){
        
        Boolean exceptionThrown = false;
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('US Business Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        System.runAs(usr)
        {
            List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(1);
            lstacnt[0].zts_eu_market__c='United States';
            insert lstacnt;
            
            List<Contact> testcontactList;
            testcontactList = ZTS_DataUtilityTest.createContactRecord(3);
            
            for(Contact c: testcontactList)
                c.ZTS_EU_Market__c = 'United States';   
            insert testcontactList;
            
            list<ZTS_EU_Affiliations__c> testaffList;
            testaffList = ZTS_DataUtilityTest.createAccConAffiliationRecord(3);
            for(Integer i=0;i<3;i++){
                testaffList[i].ZTS_EU_Contact__c=testcontactList[i].id;
                testaffList[i].ZTS_EU_Account__c=lstacnt[0].id;
            }
            insert testaffList;
            
            
            List<Campaign> lstcamp = ZTS_DataUtilityTest.createCampaignRecord(1);
            lstcamp[0].zts_eu_market__c='United States';
            lstcamp[0].startDate = system.today();
            lstcamp[0].EndDate = system.today()	+18;
            lstcamp[0].Type = 'Email';
            lstcamp[0].Campaign_Name_English__c = 'US Test Camp 1';
            lstcamp[0].Name = 'US Test Camp 1';
            lstcamp[0].ZTS_EU_Field_Targeting__c= 'Open';
            lstcamp[0].IsActive = true;
            insert lstcamp;
            
            CampaignMemberStatus cms = new CampaignMemberStatus();
            cms.CampaignId = lstcamp[0].id;
            cms.Label = 'test';
            cms.IsDefault = True;
            insert cms;

            
            CampaignMember newCm = new CampaignMember();
            newCm.CampaignId	=lstcamp[0].Id;
            newCm.ContactId   =  testcontactList[0].id;
            insert newCm;
            CampaignMember newCm1 = new CampaignMember();
            newCm1.CampaignId	=lstcamp[0].Id;
            newCm1.ContactId   =  testcontactList[1].id;
            insert newCm1;
            List<CampaignMember> cmList = new List<CampaignMember>{newCm,newCm1};
                try{
                    delete cmList;
                }
            catch(Exception e)
            {
                exceptionThrown = true;
                Boolean expectedExceptionThrown =  (e.getMessage().contains('You cannot add or delete campaign members for Inactive Campaigns.')) ? true : false; 
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
            }
            
            
        }
        
        
    }
    
}