/*******************************************************************************************************************************************
* File Name     :  ZTS_US_AddtoCampaignRedirectTest
* Description   :           
* @author       :  Mayank Agarwal
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/8         Mayank             Created the Class.

********************************************************************************************************************************************/
@isTest /*(SeeAllData = true)*/
public class ZTS_US_AddtoCampaignRedirectTest{

Public static List<Account> accList = new List<Account>();
Public static List<ZTS_EU_Campaign_Account__c> listCampAccsIns = new List<ZTS_EU_Campaign_Account__c>();
Public static List<Campaign> listCampsIns = new List<Campaign>();
Public static List<CampaignMember> campaignMemberListIns = new List<CampaignMember>();


/*-------------insert ZTS_EU_Campaign_Account__c objects---------------*/
    public static List<ZTS_EU_Campaign_Account__c> createCampAcc(Integer counter){ // 6/14
    
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        accList =  ZTS_DataUtilityTest.createAccountRecord(2);
        for(Account a: accList)
        {
            a.ZTS_EU_Market__c='United States';
        }
        System.runAs(usr)
        {
            insert accList;
        }
        
        listCampsIns = ZTS_DataUtilityTest.createCampaignRecord(2);   
        for (Campaign c : listCampsIns) {
            c.Campaign_Name_English__c = 'English';
            c.ZTS_EU_Market__c = 'United States';
            c.StartDate = System.today();
            c.EndDate = System.today()+4;
        }
        insert listCampsIns;
        counter = listCampsIns.size();
        
        List<ZTS_EU_Campaign_Account__c> listCampAccs = new List<ZTS_EU_Campaign_Account__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_EU_Campaign_Account__c campAcc = new ZTS_EU_Campaign_Account__c();
            campAcc.ZTS_EU_Account__c = accList[i].id;
            campAcc.ZTS_EU_Campaign__c = listCampsIns[0].id;
            campAcc.ZTS_EU_Campaign_Hidden__c = listCampsIns[i].id;
            //campAcc.ZTS_EU_Targeted_Account_Unique__c = 'TestUniqueAcc'+i;
            campAcc.ZTS_EU_Member_Status__c = 'Added';
            
            listCampAccs.add(campAcc);
        }
        return listCampAccs;
        
    }

 /****************************Insert Campaign Member**************************************************************************/
    public static List<CampaignMember> createCampaignMemberRecord(Integer counter) {
        Campaign campaign = new Campaign();         
        campaign.Name = 'TestCampaign';
        campaign.ZTS_EU_Field_Targeting__c = 'Open';
        campaign.IsActive = true;
        campaign.StartDate = System.today();
        campaign.EndDate = System.today()+3;
        campaign.Campaign_Name_English__c = 'English';
        insert campaign;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        List<Contact> contactList = ZTS_DataUtilityTest.createContactRecord(counter);
        for(Contact c: contactList)
            {
                c.ZTS_EU_Market__c='United States';
            }
        System.runAs(usr)
        {
            insert contactList;
        }
        
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        for(Integer i=0;i<counter;i++) {
            CampaignMember campaignMember = new CampaignMember();         
            campaignMember.CampaignId = campaign.Id;
            campaignMember.ContactId = contactList[0].Id;        
            campaignMemberList.add(campaignMember);
        }        
        return campaignMemberList;  
           
    }



    public static void createTestData(){
        
        listCampAccsIns = createCampAcc(2);
        insert listCampAccsIns;
        campaignMemberListIns = createCampaignMemberRecord(1);
        insert campaignMemberListIns;
        
    }


    static testmethod void testZTS_US_AddtoCampaignRedirect(){
        createTestData();
   
    
        
        ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);
        PageReference myPage = Page.ZTS_US_AddtoCampaign_Redirect;
        myPage.getParameters().put('records',accList[0].id+','+accList[1].id);
        test.setCurrentPage(myPage);
        ZTS_US_AddtoCampaignRedirect addCampRedir = new ZTS_US_AddtoCampaignRedirect(cont);
        Test.startTest();
            addCampRedir.fromCampMethod();
            addCampRedir.addAccCampaign();
            //addCampRedir.dupTargetAccUpdate();
        
        
        myPage.getParameters().put('records',accList[0].id+','+accList[1].id);
        myPage.getParameters().put('fromCamp','true');
        myPage.getParameters().put('fromCampId',listCampsIns[0].id);
        test.setCurrentPage(myPage);
        addCampRedir = new ZTS_US_AddtoCampaignRedirect(cont);
       
            addCampRedir.fromCampMethod();
            addCampRedir.addAccCampaign();
            //addCampRedir.dupTargetAccUpdate();
            //
        addCampRedir.listAccID.add(accList[0].id);
        addCampRedir.listAccID.add(accList[1].id);
        addCampRedir.fromCampId = listCampsIns[0].Id;
        addCampRedir.dupTargetAccUpdate();
        
        
        Test.stopTest();
        
    }
    static testmethod void testdeleteCampaignAccount(){
        
        createTestData();
        delete listCampAccsIns;
    }
}