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
/*******************************************************************************************************************************************
* File Name     :  ZTS_US_targetAccountControllerTest
* Description   :           
* @author       :  Mayank
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mayank             Created the Class.

********************************************************************************************************************************************/
@isTest
public class ZTS_US_targetAccountControllerTest{

Public static List<Account> accListIns = new List<Account>();
Public static List<Contact> conListIns = new List<Contact>();
Public static List<ZTS_EU_Campaign_Account__c> listCampAccsIns = new List<ZTS_EU_Campaign_Account__c>();
Public static List<Campaign> listCampsIns = new List<Campaign>();
Public static List<CampaignMember> campaignMemberListIns = new List<CampaignMember>();
Public static List<ZTS_EU_Affiliations__c> listAccConAffIns = new List<ZTS_EU_Affiliations__c>();

/****************************Insert Campaign**************************************************************************/
    public static List<Campaign> createCampaignRecord(Integer counter) { // 6/14
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=0;i<counter;i++) {
            Campaign campaign = new Campaign();         
            campaign.Name = 'TestCampaign';
            campaign.ZTS_EU_Field_Targeting__c = 'Open';
            campaign.Campaign_Name_English__c = 'Testing Campaign';
            campaignList.add(campaign);
        }        
        return campaignList;  
           
    }


/*-------------insert ZTS_EU_Campaign_Account__c objects---------------*/
    public static List<ZTS_EU_Campaign_Account__c> createCampAcc(Integer counter){ // 6/14
    
       
        
        List<ZTS_EU_Campaign_Account__c> listCampAccs = new List<ZTS_EU_Campaign_Account__c>();
        
            ZTS_EU_Campaign_Account__c campAcc = new ZTS_EU_Campaign_Account__c();
            campAcc.ZTS_EU_Account__c = accListIns[0].id;
            campAcc.ZTS_EU_Campaign__c = listCampsIns[0].id;
            campAcc.ZTS_EU_Member_Status__c = 'Added';
            
            listCampAccs.add(campAcc);
        
        return listCampAccs;
        
    }

 /****************************Insert Campaign Member**************************************************************************/
    public static List<CampaignMember> createCampaignMemberRecord(Integer counter) {
      
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        for(Integer i=0;i<counter;i++) {
            CampaignMember campaignMember = new CampaignMember();         
            campaignMember.CampaignId = listCampsIns[0].Id;
            campaignMember.ContactId = conListIns[0].Id;        
            campaignMemberList.add(campaignMember);
        }        
        return campaignMemberList;  
           
    }
     /****************************Insert AccountContactAffiliation(s)**************************************************************************/
    public static List<ZTS_EU_Affiliations__c> createAccConAffiliationRecord(Integer numConAffli) {
       
        List<ZTS_EU_Affiliations__c> accConAffList = new List<ZTS_EU_Affiliations__c>();
        for(Integer i=0;i<numConAffli;i++) {
            ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c();
            accConAff.ZTS_EU_Account__c = accListIns[0].id;
            accConAff.ZTS_EU_Contact__c = conListIns[0].Id;
            accConAffList.add(accConAff);
        }        
        return accConAffList;             
    }


    public static void createTestData(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        accListIns = ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert accListIns;
        }
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        conListIns = ZTS_DataUtilityTest.createContactRecord(1);
        conListIns[0].ZTS_EU_Contact_Status__c = 'Active';
        conListIns[0].AccountId = accListIns[0].id;
        System.runAs(usr)
        {
            insert conListIns;
        }
        
        //update conListIns;
        listCampsIns = createCampaignRecord(1);
        
        insert listCampsIns;
        listCampAccsIns = createCampAcc(1);
        insert listCampAccsIns;
        listAccConAffIns = createAccConAffiliationRecord(1);
        try{
            insert listAccConAffIns;
        }
        catch(Exception e){
            System.debug('Exception : '+e);
        }
      
    }


    static testmethod void testZTS_US_targetAccountCont(){
        Test.startTest();
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);
        
        PageReference myPage = Page.ZTS_US_targetAccount;
        myPage.getParameters().put('campId',listCampsIns[0].id);
        test.setCurrentPage(myPage);
        
        ZTS_US_targetAccountController tarAccCont = new ZTS_US_targetAccountController(cont);
        
        system.debug('------------accListIns : ' + accListIns[0].Id);
        //tarAccCont.campId = listCampsIns[0].Id;
        tarAccCont.campAccnt = listCampAccsIns[0];
        //tarAccCont.selectedAccId = accListIns[0].id;
        tarAccCont.addTargetAccount();
        Test.stopTest();
        
    }
    
    static testmethod void testZTS_US_targetAccountCont2(){
        Test.startTest();
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);
        
        PageReference myPage = Page.ZTS_US_targetAccount;
        myPage.getParameters().put('campId',listCampsIns[0].id);
        test.setCurrentPage(myPage);
        
        ZTS_US_targetAccountController tarAccCont = new ZTS_US_targetAccountController(cont);
        
        system.debug('------------accListIns : ' + accListIns[0].Id);
        //tarAccCont.campId = listCampsIns[0].Id;
        //tarAccCont.campAccnt = listCampAccsIns[0];
        //tarAccCont.selectedAccId = accListIns[0].id;
        tarAccCont.addTargetAccount();
        Test.stopTest();
        
    }
}