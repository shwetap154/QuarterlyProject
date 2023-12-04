/****************************************************************************************************************************************** 
 * Class Name       : INTLCampaignMemTrigger_test
 * Description      : Test Class for "INTLCampaignMemberTriggerService.cls" (SC-008159)                                 
 * Created By   	: Cognizant
 * Created Date 	: April 1st, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        04/01/2021          Created 
 * Ethan Hirsch (Zoetis)    06/07/2022          Change reference to UK & Nordics Business Administrator Profile to not include
 *                                              special characters to avoid Copado deployment issues with Profiles.
*****************************************************************************************************************************************/
@isTest
public with sharing class INTLCampaignMemTrigger_test {
    
    static testMethod void testCampMemInsert(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('UK and Nordics Business Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        System.runAs(usr)
        {
            List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(1);
            lstacnt[0].zts_eu_market__c='United Kingdom';
            insert lstacnt;
            
            List<Contact> testcontactList;
            testcontactList = ZTS_DataUtilityTest.createContactRecord(3);
            
            for(Contact c: testcontactList)
            {
                c.ZTS_EU_Market__c = 'United Kingdom';   
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
            lstcamp[0].zts_eu_market__c='United Kingdom';
            lstcamp[0].startDate = system.today();
            lstcamp[0].EndDate = system.today()	+30;
            lstcamp[0].Type = 'Email';
            lstcamp[0].Campaign_Name_English__c = 'is Test';
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
              
            
        }
        
        
    }
    
     static testMethod void testCampMemDelete(){
         
        Boolean exceptionThrown = false;
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('UK and Nordics Business Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        System.runAs(usr)
        {
            List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(1);
            lstacnt[0].zts_eu_market__c='United Kingdom';
            insert lstacnt;
            
            List<Contact> testcontactList;
            testcontactList = ZTS_DataUtilityTest.createContactRecord(3);
            
            for(Contact c: testcontactList)
                c.ZTS_EU_Market__c = 'United Kingdom';   
            insert testcontactList;
            
            list<ZTS_EU_Affiliations__c> testaffList;
            testaffList = ZTS_DataUtilityTest.createAccConAffiliationRecord(3);
            for(Integer i=0;i<3;i++){
                testaffList[i].ZTS_EU_Contact__c=testcontactList[i].id;
                testaffList[i].ZTS_EU_Account__c=lstacnt[0].id;
            }
            insert testaffList;
            
            
            List<Campaign> lstcamp = ZTS_DataUtilityTest.createCampaignRecord(1);
            lstcamp[0].zts_eu_market__c='United Kingdom';
            lstcamp[0].startDate = system.today();
            lstcamp[0].EndDate = system.today()	+30;
            lstcamp[0].Type = 'Email';
            lstcamp[0].Campaign_Name_English__c = 'is Test';
            lstcamp[0].ZTS_EU_Field_Targeting__c= 'Closed';
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
            try{
            delete newCm;
            }
            catch(Exception e)
            {
                exceptionThrown = true;
                Boolean expectedExceptionThrown =  (e.getMessage().contains('You cannot add or delete campaign members if Field Targeting is Closed on associated Campaign.')) ? true : false; 
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
            }
             
            
        }
        
        
    }
    
}