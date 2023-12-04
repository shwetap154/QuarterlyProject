/****************************************************************************************************************************************** 
 * Class Name       : AddTAfromAccountRedirectCtl_test
 * Description      : Test Class for AddTAfromAccountRedirectCtl.cls (SC-008159)                                 
 * Created By   : Cognizant
 * Created Date : March 11th, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        03/11/2021          Created 
*****************************************************************************************************************************************/
@isTest
public with sharing class AddTAfromAccountRedirectCtl_test {

    
    static testMethod void redirectTest() {
        User usr = new User();
        Account testAccount;
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'USUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Campaign testCampaign = ZTS_DataUtilityTest.createCampaignRecord(1)[0];
            testCampaign.Campaign_Name_English__c = 'English';
            testCampaign.ZTS_EU_Market__c = 'United States';
            testCampaign.ZTS_EU_Field_Targeting__c = 'Open';
            insert testCampaign;
    
            testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            testAccount.ZTS_EU_Market__c = 'United States';
            insert testAccount;
            
            
        }
        

        Account acc = [Select id from Account where Id = : testAccount.id limit 1];
        Test.startTest();
                    
        PageReference pageRef = Page.ZTS_EU_TargetedAccountfromAccount;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accId',acc.id); 
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        AddTAfromAccountRedirectCtl ext = new AddTAfromAccountRedirectCtl(stdController);
        System.assertNotEquals(null,ext.doRedirect());
        
        Test.stopTest();
    }
    
    static testMethod void redirectTestfromStdSetCtl() {
        User usr = new User();
        Account testAccount;
        ZTS_EU_Campaign_Account__c tar_acc;
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'USUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Campaign testCampaign = ZTS_DataUtilityTest.createCampaignRecord(1)[0];
            testCampaign.Campaign_Name_English__c = 'English';
            testCampaign.ZTS_EU_Market__c = 'United States';
            testCampaign.ZTS_EU_Field_Targeting__c = 'Open';
            insert testCampaign;
    
            testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            testAccount.ZTS_EU_Market__c = 'United States';
            insert testAccount;
            
            tar_acc = new ZTS_EU_Campaign_Account__c(ZTS_EU_Account__c = testAccount.Id,ZTS_EU_Campaign__c = testCampaign.Id);
            insert tar_acc;
            
        }
        
        ZTS_EU_Campaign_Account__c ta = [
            SELECT Id
            FROM ZTS_EU_Campaign_Account__c
            LIMIT 1
        ];

        Account acc = [Select id from Account where Id = : testAccount.id limit 1];
        Test.startTest();
                    
        PageReference pageRef = Page.ZTS_EU_TargetedAccountfromAccount;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accId',acc.id); 
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(new List<ZTS_EU_Campaign_Account__c>{ta});
        AddTAfromAccountRedirectCtl ext = new AddTAfromAccountRedirectCtl(stdController);
        System.assertNotEquals(null,ext.doRedirect());
        
        Test.stopTest();
    }

}