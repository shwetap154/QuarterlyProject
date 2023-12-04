/****************************************************************************************************************************************** 
* CLass Name : TestCattleEquineSurveyButtonController
* Description  : Controller test for new buttons (that used to be JS) on Cattle_Equine_Survey__c object
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
public class TestCattleEquineSurveyButtonController 
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
        
        Cattle_Equine_Survey__c CES = new Cattle_Equine_Survey__c();
        CES.Account__c = acct.Id;
        CES.Status__c = 'New';
        insert CES;
    }
    
    @isTest
    public static void testDoAddAccountAffiliation()
    {           
        Cattle_Equine_Survey__c CES = [
            SELECT Id, Status__c
            FROM Cattle_Equine_Survey__c
            LIMIT 1
        ];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(CES);
        PageReference CattleEquineSurveySubmit = Page.CattleEquineSurveySubmit;
        Test.setCurrentPage(CattleEquineSurveySubmit);
        
        CattleEquineSurveyButtonController controller = new CattleEquineSurveyButtonController(sc);        
        controller.doUpdateCES();
        
        CES = [
            SELECT Id, Status__c
            FROM Cattle_Equine_Survey__c
            LIMIT 1
        ];
        System.assertEquals(CES.Status__c, 'Completed');
        
        controller = new CattleEquineSurveyButtonController(sc); 
        controller.failTest = true;
        controller.doUpdateCES();
        System.assertEquals(CES.Status__c, 'Completed');

        PageReference pg = controller.goBackToRecord();
        System.assertEquals(pg.getUrl(), '/' + CES.Id);
    }
}