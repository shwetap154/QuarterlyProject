/**
 * @description       : Test class for ZTS_EU_AddtoCampaignRedirect
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-02-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   07-15-????   Mayank Agarawl @ Unknown     Initial Version
 * 1.1   08-02-2022   Ethan Hirsch @ Zoetis Inc    Remove SeeAllData from test. This does result in lost code 
 *                                                 coverage overall, but ZTS_US_removeTargetAccntsController is at 77%
 *                                                 before and after the change. This was done to avoid issues with
 *                                                 custom settings when creating a Contact.
**/
@isTest(SeeAllData = false)
public class ZTS_US_removeTargetAccntsControllerTest{
    
    Public static List<Account> accListIns = new List<Account>();
    Public static List<Contact> conListIns = new List<Contact>();
    Public static List<ZTS_EU_Campaign_Account__c> listCampAccsIns = new List<ZTS_EU_Campaign_Account__c>();
    Public static List<Campaign> listCampsIns = new List<Campaign>();
    Public static List<CampaignMember> campaignMemberListIns = new List<CampaignMember>();
    Public static List<ZTS_EU_Affiliations__c> listAccConAffIns = new List<ZTS_EU_Affiliations__c>();
    
    
    /*-------------insert ZTS_EU_Campaign_Account__c objects---------------*/
    public static List<ZTS_EU_Campaign_Account__c> createCampAcc(Integer counter){ // 6/14
        
        counter = listCampsIns.size();
        
        List<ZTS_EU_Campaign_Account__c> listCampAccs = new List<ZTS_EU_Campaign_Account__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_EU_Campaign_Account__c campAcc = new ZTS_EU_Campaign_Account__c();
            campAcc.ZTS_EU_Account__c = accListIns[i].id;
            campAcc.ZTS_EU_Campaign__c = listCampsIns[i].id;
            campAcc.ZTS_EU_Campaign_Hidden__c = listCampsIns[i].id;
            campAcc.ZTS_EU_Member_Status__c = 'Added';
            
            listCampAccs.add(campAcc);
        }
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
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            accListIns =  ZTS_DataUtilityTest.createAccountRecord(2);
            insert accListIns;
            
            conListIns = ZTS_DataUtilityTest.createContactRecord(1);
            insert conListIns;
            
            listCampsIns = ZTS_DataUtilityTest.createCampaignRecord(2);
            for(Campaign camp : listCampsIns) camp.Campaign_Name_English__c = 'Test';
            insert listCampsIns;
            
            listCampAccsIns = createCampAcc(2);
            insert listCampAccsIns;
            
            listAccConAffIns = createAccConAffiliationRecord(1);
            insert listAccConAffIns;
            
            campaignMemberListIns = createCampaignMemberRecord(1);
            insert campaignMemberListIns;
        }
        
    }
    
    
    static testmethod void testZTS_US_removeTargetAccntsCont(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);
        
        PageReference myPage = Page.ZTS_US_removeTargetAccnts;
        myPage.getParameters().put('campId',listCampsIns[0].id);
        myPage.getParameters().put('records',listCampAccsIns[0].id+','+listCampAccsIns[1].id);
        test.setCurrentPage(myPage);
        
        ZTS_US_removeTargetAccntsController remTarAccCont = new ZTS_US_removeTargetAccntsController(cont);
        Test.startTest();
        remTarAccCont.removeTargetAccnts();
        
        Test.stopTest();
        
    }    
    
}