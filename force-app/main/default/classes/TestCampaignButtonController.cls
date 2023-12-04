/****************************************************************************************************************************************** 
* CLass Name : TestCampaignButtonController
* Description  : Controller test for new buttons (that used to be JS) on Campaign object
* Created By   : Slalom(David Stern) 
* Created Date : 8th June, 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern            06/08/2020          Created 
*****************************************************************************************************************************************/
@isTest
public class TestCampaignButtonController 
{
    @testSetup
    public static void testSetup()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        Primary_Contact_Inactive_Profile_List__c contSetting = new Primary_Contact_Inactive_Profile_List__c();
        Primary_Contact_Inactive_Profile_List__c contSetting1 = new Primary_Contact_Inactive_Profile_List__c();
        Primary_Contact_Inactive_Profile_List__c contSetting2 = new Primary_Contact_Inactive_Profile_List__c();
        
        contSetting.Name = 'Profile Names';
        contSetting1.Name = 'Profile Names 1';
        contSetting2.Name = 'Profile Names 2';
        contSetting.Profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
        contSetting1.Profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
        contSetting2.Profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
        
        insert new List<Primary_Contact_Inactive_Profile_List__c>{contSetting, contSetting1, contSetting2};
            
        Account acct = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
        acct.ZTS_EU_Market__c = 'United Kingdom';
        System.runAs(usr)
        {
        	insert acct;   
        }
        
        Contact cont = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
        cont.ZTS_EU_Market__c = 'United Kingdom';
        System.runAs(usr)
        {
        	insert cont;   
        }
    }
    
    @isTest
    public static void testDoAddAccountAffiliation()
    {
        Contact cont = [
            SELECT Id
            FROM Contact
            LIMIT 1
        ];
                
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Campaign>());
        PageReference CampaignAddToCampaign = Page.CampaignAddToCampaign;
        Test.setCurrentPage(CampaignAddToCampaign);
        ApexPages.currentPage().getParameters().put('id', cont.Id);
        
        CampaignButtonController controller = new CampaignButtonController(sc);
        System.assertEquals(controller.recordId, cont.Id);
                
        PageReference pg = controller.doRedirectToAddCampaignFromContact();
        System.assertEquals(pg.getUrl(), '/apex/ZTS_EU_AddtoCampaignFromCon?conCampId=' + cont.Id);
    }
}