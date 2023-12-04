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
* File Name     :  ZTS_EU_removeTargetAccntsControllerTest
* Description   :           
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/15         Ketan             Created the Class.

********************************************************************************************************************************************/
@isTest(SeeAllData = false)
public class ZTS_EU_removeTargetAccntsControllerTest{

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
            campaign.Campaign_Name_English__c = 'TestCampaign '+i;
            campaignList.add(campaign);
        }        
        return campaignList;  
           
    }


/*-------------insert ZTS_EU_Campaign_Account__c objects---------------*/
    public static List<ZTS_EU_Campaign_Account__c> createCampAcc(Integer counter){ // 6/14
    
        //accListIns =  ZTS_EU_DataUtilityTest.createAccountRecord(2);
        //insert accListIns;
        //listCampsIns = createCampaignRecord(2);
        //insert listCampsIns;
        counter = listCampsIns.size();
        
        List<ZTS_EU_Campaign_Account__c> listCampAccs = new List<ZTS_EU_Campaign_Account__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_EU_Campaign_Account__c campAcc = new ZTS_EU_Campaign_Account__c();
            campAcc.ZTS_EU_Account__c = accListIns[i].id;
            campAcc.ZTS_EU_Campaign__c = listCampsIns[i].id;
            campAcc.ZTS_EU_Campaign_Hidden__c = listCampsIns[i].id;
            //campAcc.ZTS_EU_Targeted_Account_Unique__c = 'TestUniqueAcc'+i;
            campAcc.ZTS_EU_Member_Status__c = 'Added';
            
            listCampAccs.add(campAcc);
        }
        return listCampAccs;
        
    }

 /****************************Insert Campaign Member**************************************************************************/
    public static List<CampaignMember> createCampaignMemberRecord(Integer counter) {
        /*
        Campaign campaign = new Campaign();         
        campaign.Name = 'TestCampaign';
        campaign.ZTS_EU_Field_Targeting__c = 'Open';
        insert campaign;
        */
        
       // conListIns = ZTS_EU_DataUtilityTest.createContactRecord(counter);
       // insert conListIns;
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
        //accListIns = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        //insert accListIns;
        //conListIns = ZTS_EU_DataUtilityTest.createContactRecord(1);
        //insert conListIns;
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
        //accList =  ZTS_EU_DataUtilityTest.createAccountRecord(1);
        //insert accList;
        //List<Account> accList = new List<Account>();
        accListIns =  ZTS_EU_DataUtilityTest.createAccountRecord(2);
        insert accListIns;
        
        conListIns = ZTS_EU_DataUtilityTest.createContactRecord(1);
        insert conListIns;
        
        listCampsIns = createCampaignRecord(2);
        insert listCampsIns;
        
        listCampAccsIns = createCampAcc(2);
        insert listCampAccsIns;
        
        listAccConAffIns = createAccConAffiliationRecord(1);
        insert listAccConAffIns;
        
        system.debug('------listAccConAffIns is: '+listAccConAffIns);
        system.debug('------listAccConAffIns size is: '+listAccConAffIns.size());
        
        
        campaignMemberListIns = createCampaignMemberRecord(1);
        insert campaignMemberListIns;
        
    }


    static testmethod void testZTS_EU_removeTargetAccntsCont()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            createTestData();
            ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);
            
            PageReference myPage = Page.ZTS_EU_removeTargetAccnts;
            myPage.getParameters().put('campId',listCampsIns[0].id);
            myPage.getParameters().put('records',listCampAccsIns[0].id+','+listCampAccsIns[1].id);
            test.setCurrentPage(myPage);
            
            ZTS_EU_removeTargetAccntsController remTarAccCont = new ZTS_EU_removeTargetAccntsController(cont);
            Test.startTest();
            remTarAccCont.removeTargetAccnts();
            //tarAccCont.
            Test.stopTest();
        }
    }    
}