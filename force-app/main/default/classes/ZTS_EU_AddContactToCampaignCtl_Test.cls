/****************************************************************************************************************************************** 
 * Class Name       : ZTS_EU_AddContactToCampaignCtl_Test
 * Description      : Test Class for ZTS_EU_AddContactToCampaignCtl.cls (SC-008159)                                 
 * Created By       : Cognizant
 * Created Date     : March 11th, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        03/11/2021          Created 
*****************************************************************************************************************************************/
@isTest
public class ZTS_EU_AddContactToCampaignCtl_Test {
 
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
        
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = testCampaign.id;
        cms.Label = 'test';
        cms.IsDefault = True;
        insert cms;
        
        Test.startTest();
                    
        PageReference pageRef = Page.ZTS_EU_AddContactToCampaign;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('campId',testCampaign.id); 
        ApexPages.currentPage().getParameters().put('accIds',testAccount.id); 
        ApexPages.currentPage().getParameters().put('fromAccount','true'); 
        ZTS_EU_AddContactToCampaignCtl ctl = new ZTS_EU_AddContactToCampaignCtl();
        System.assertNotEquals(null,ctl.saveContacts());
        System.assertNotEquals(null,ctl.cancel());
        System.assertEquals(null,ctl.CheckAll());
        Test.stopTest();
        
    }

}