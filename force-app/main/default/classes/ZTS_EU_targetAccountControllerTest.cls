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
* File Name     :  ZTS_EU_targetAccountControllerTest
* Description   :           
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/15         Ketan             Created the Class.

********************************************************************************************************************************************/
@isTest
public class ZTS_EU_targetAccountControllerTest{

Public static List<Account> accListIns = new List<Account>();
Public static List<Contact> conListIns = new List<Contact>();
Public static List<ZTS_EU_Campaign_Account__c> listCampAccsIns = new List<ZTS_EU_Campaign_Account__c>();
Public static List<Campaign> listCampsIns = new List<Campaign>();
Public static List<CampaignMember> campaignMemberListIns = new List<CampaignMember>();
Public static List<ZTS_EU_Affiliations__c> listAccConAffIns = new List<ZTS_EU_Affiliations__c>();

// public static ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);

/****************************Insert Campaign**************************************************************************/
    public static List<Campaign> createCampaignRecord(Integer counter) { // 6/14
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=0;i<counter;i++) {
            Campaign campaign = new Campaign();         
            campaign.Name = 'TestCampaign';
            campaign.ZTS_EU_Field_Targeting__c = 'Open';
             campaign.Campaign_Name_English__c = 'TestCampaign '+i;
            campaignList.add(campaign);
        }        
        return campaignList;  
           
    }


/*-------------insert ZTS_EU_Campaign_Account__c objects---------------*/
    public static List<ZTS_EU_Campaign_Account__c> createCampAcc(Integer counter){ // 6/14
    
        //accListIns =  ZTS_EU_DataUtilityTest.createAccountRecord(1);
        //insert accListIns;
        //listCampsIns = createCampaignRecord(1);
        //insert listCampsIns;
        //ZTS_EU_Campaign_Account__c campAcc1 = new ZTS_EU_Campaign_Account__c();
        //campAcc1.ZTS_EU_Account__c = accListIns[0].id;
        //campAcc1.ZTS_EU_Campaign__c = listCampsIns[0].id;
        //insert campAcc1;
        
        
        List<ZTS_EU_Campaign_Account__c> listCampAccs = new List<ZTS_EU_Campaign_Account__c>();
        
            ZTS_EU_Campaign_Account__c campAcc = new ZTS_EU_Campaign_Account__c();
            campAcc.ZTS_EU_Account__c = accListIns[0].id;
            campAcc.ZTS_EU_Campaign__c = listCampsIns[0].id;
            //campAcc.ZTS_EU_Campaign_Hidden__c = listCampsIns[i].id;
            //campAcc.ZTS_EU_Targeted_Account_Unique__c = 'TestUniqueAcc'+i;
            campAcc.ZTS_EU_Member_Status__c = 'Added';
            
            listCampAccs.add(campAcc);
        
        return listCampAccs;
        
    }

 /****************************Insert Campaign Member**************************************************************************/
    public static List<CampaignMember> createCampaignMemberRecord(Integer counter) {
        /*Campaign campaign = new Campaign();         
        campaign.Name = 'TestCampaign';
        campaign.ZTS_EU_Field_Targeting__c = 'Open';
        insert campaign;
        conListIns = ZTS_EU_DataUtilityTest.createContactRecord(counter);
        insert conListIns;*/
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
        /*accListIns = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        insert accListIns;
        conListIns = ZTS_EU_DataUtilityTest.createContactRecord(1);
        insert conListIns;*/
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
        /*//accList =  ZTS_EU_DataUtilityTest.createAccountRecord(1);
        //insert accList;
        //List<Account> accList = new List<Account>();
        listAccConAffIns = createAccConAffiliationRecord(1);
        insert listAccConAffIns;
        listCampAccsIns = createCampAcc(1);
        insert listCampAccsIns;
        campaignMemberListIns = createCampaignMemberRecord(1);
        insert campaignMemberListIns;*/
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        accListIns = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        accListIns[0].ZTS_EU_Zip_Postal_Code__c = '12345';
        accListIns[0].BillingPostalCode = '12345';
        accListIns[0].BillingCity = 'Boca Raton';
        accListIns[0].BillingState = 'Florida';
        accListIns[0].BillingStreet = 'Elm Lane';
        accListIns[0].ZTS_EU_Market__c = 'United States';
        System.runAs(usr){
            insert accListIns;
        }
        conListIns = ZTS_EU_DataUtilityTest.createContactRecord(1);
        insert conListIns;
        conListIns[0].ZTS_EU_Contact_Status__c = 'Active';
        conListIns[0].AccountId = accListIns[0].id;
        update conListIns;
        listCampsIns = createCampaignRecord(1);
        insert listCampsIns;
        listCampAccsIns = createCampAcc(1);
        insert listCampAccsIns;
        listAccConAffIns = createAccConAffiliationRecord(1);
        insert listAccConAffIns;
        system.debug('accListIns>>>>>>>>>>>>>>>>>>>>'+accListIns);
        system.debug('conListIns>>>>>>>>>>>>>>>>>>>>'+conListIns);
        system.debug('listAccConAffIns>>>>>>>>>>>>>>>>>>>>'+listAccConAffIns);
        
        
        /*
        ZTS_EU_Campaign_Account__c campAcc1 = new ZTS_EU_Campaign_Account__c();
        campAcc1.ZTS_EU_Account__c = accListIns[0].id;
        campAcc1.ZTS_EU_Campaign__c = listCampsIns[0].id;
        listCampAccsIns.add(campAcc1);
        insert campAcc1;
        */
        
        //system.debug('campAcc1>>>>>>>>>>>>>>>>>>>>'+campAcc1);
    }


    static testmethod void testZTS_EU_targetAccountCont(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            createTestData();
            system.debug('@@@@@ listCampAccsIns[0].ZTS_EU_Account__c is :  '+listCampAccsIns[0].ZTS_EU_Account__c);
            system.debug('@@@@@ listCampAccsIns size is :  '+listCampAccsIns.size());
            
            /* 
            ZTS_EU_Campaign_Account__c ca = new ZTS_EU_Campaign_Account__c();
            ca.ZTS_EU_Account__c = accListIns[0].id;
            ca.ZTS_EU_Campaign__c = listCampsIns[0].id;
            ca.ZTS_EU_Member_Status__c = 'Added';
            insert ca;
            */ 
            
            ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);
            
            PageReference myPage = Page.ZTS_EU_targetAccount;
            myPage.getParameters().put('campId',listCampsIns[0].id);
            test.setCurrentPage(myPage);
            
            ZTS_EU_targetAccountController tarAccCont = new ZTS_EU_targetAccountController(cont);
            Test.startTest();
            tarAccCont.selectedAccId = accListIns[0].id;
            tarAccCont.campId = listCampsIns[0].Id;
            tarAccCont.addTargetAccount();
            Test.stopTest();
        }
    }
    
    static testmethod void testZTS_EU_targetAccountCont1(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            createTestData();
            system.debug('@@@@@ listCampAccsIns[0].ZTS_EU_Account__c is :  '+listCampAccsIns[0].ZTS_EU_Account__c);
            system.debug('@@@@@ listCampAccsIns size is :  '+listCampAccsIns.size());
            
            
            
            PageReference myPage = Page.ZTS_EU_targetAccount;
            test.setCurrentPage(myPage);
            ApexPages.currentPage().getParameters().put('campId',listCampsIns[0].id);
            
            ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);
            
            ZTS_EU_targetAccountController tarAccCont = new ZTS_EU_targetAccountController(cont);
            Test.startTest();
            
            tarAccCont.selectedAccId = accListIns[0].id;
            tarAccCont.campId = listCampsIns[0].Id;
            tarAccCont.campAccnt = listCampAccsIns[0];
            tarAccCont.addTargetAccount();
            
            Test.stopTest();
        }
    }
}