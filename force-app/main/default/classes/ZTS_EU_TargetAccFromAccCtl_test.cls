/****************************************************************************************************************************************** 
 * Class Name       : ZTS_EU_TargetAccFromAccCtl_test
 * Description      : Test Class for "ZTS_EU_TargetedAccountfromAccountctl.cls" (SC-008159)                                 
 * Created By   : Cognizant
 * Created Date : March 12th, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        03/12/2021          Created 
*****************************************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_TargetAccFromAccCtl_test {
    
    static testmethod void testsave(){
        Account testAccount;
        testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            testAccount.ZTS_EU_Market__c = 'United States';
            insert testAccount;
        
        List<Contact> testcontactList;
        testcontactList = ZTS_DataUtilityTest.createContactRecord(3);
        
        for(Contact c: testcontactList)
            c.ZTS_EU_Market__c = 'United States';
            
        insert testcontactList;
        
        list<ZTS_EU_Affiliations__c> testaffList;
        testaffList = ZTS_DataUtilityTest.createAccConAffiliationRecord(3);
        for(Integer i=0;i<3;i++){
            testaffList[i].ZTS_EU_Contact__c=testcontactList[i].id;
            testaffList[i].ZTS_EU_Account__c=testAccount.id;
        }
        insert testaffList;
        
        Campaign testCampaign = ZTS_DataUtilityTest.createCampaignRecord(1)[0];
            testCampaign.Campaign_Name_English__c = 'English';
            testCampaign.ZTS_EU_Market__c = 'United States';
            testCampaign.ZTS_EU_Field_Targeting__c = 'Open';
            insert testCampaign;
        
        ZTS_EU_Campaign_Account__c ta = new ZTS_EU_Campaign_Account__c();
        ta.ZTS_EU_Account__c = testAccount.id;
        ta.ZTS_EU_Campaign__c = testCampaign.id;
        ta.ZTS_EU_Member_Status__c = 'Removed';
        
        
        
        Test.startTest();
        system.debug('Inserting TA&&&&&&&&&&&&&&&&&&');
        insert ta;            
        PageReference pageRef = Page.ZTS_EU_TargetedAccountfromAccount;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accId',testAccount.id); 
        Apexpages.StandardController stc = new ApexPages.StandardController(testAccount);
        ZTS_EU_TargetedAccountfromAccountctl ctl = new ZTS_EU_TargetedAccountfromAccountctl(stc);
        ctl.campAccnt.ZTS_EU_Account__c = testAccount.id;
        ctl.campAccnt.ZTS_EU_Campaign__c = testCampaign.id;
        System.assertNotEquals(null,ctl.createTA());
        Test.stopTest();
        
    }


}