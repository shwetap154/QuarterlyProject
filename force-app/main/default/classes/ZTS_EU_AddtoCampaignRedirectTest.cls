/**
 * @description       : Test class for ZTS_EU_AddtoCampaignRedirect
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-02-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                           Modification
 * 1.0   06-14-2014   Ketan Prakash Singh @ Deloitte   Initial Version
 * 1.1   08-02-2022   Ethan Hirsch @ Zoetis Inc        Remove SeeAllData from test. This does result in lost code 
 *                                                     coverage overall, but ZTS_EU_AddtoCampaignRedirect is at 86%
 *                                                     before and after the change. This was done to avoid issues with
 *                                                     custom settings when creating a Contact.
**/
@isTest(SeeAllData = false)
public class ZTS_EU_AddtoCampaignRedirectTest{

Public static List<Account> accList = new List<Account>();
Public static List<ZTS_EU_Campaign_Account__c> listCampAccsIns = new List<ZTS_EU_Campaign_Account__c>();
Public static List<Campaign> listCampsIns = new List<Campaign>();
Public static List<CampaignMember> campaignMemberListIns = new List<CampaignMember>();

/****************************Insert Campaign**************************************************************************/
    public static List<Campaign> createCampaignRecord(Integer counter) { // 6/14
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=0;i<counter;i++) {
            Campaign campaign = new Campaign();         
            campaign.Name = 'TestCampaign';
            campaign.IsActive = true;
            campaign.ZTS_EU_Field_Targeting__c = 'Open';
            campaign.Campaign_Name_English__c = 'TestCampaign';
            campaign.ZTS_EU_Market__c ='United Kingdom';
            campaign.StartDate=system.today();
            campaign.EndDate=system.today()+5;
            campaignList.add(campaign);
        }        
        return campaignList;  
           
    }


/*-------------insert ZTS_EU_Campaign_Account__c objects---------------*/
    public static List<ZTS_EU_Campaign_Account__c> createCampAcc(Integer counter){ // 6/14
    
        accList =  ZTS_EU_DataUtilityTest.createAccountRecord(2);
        insert accList;
        listCampsIns = createCampaignRecord(2);
        insert listCampsIns;
        counter = listCampsIns.size();
        
        List<ZTS_EU_Campaign_Account__c> listCampAccs = new List<ZTS_EU_Campaign_Account__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_EU_Campaign_Account__c campAcc = new ZTS_EU_Campaign_Account__c();
            campAcc.ZTS_EU_Account__c = accList[0].id;
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
        Campaign campaign = new Campaign();         
        campaign.Name = 'TestCampaign';
        campaign.ZTS_EU_Field_Targeting__c = 'Open';
        campaign.Campaign_Name_English__c = 'TestCampaign';
        campaign.ZTS_EU_Market__c = 'United Kingdom';
        campaign.IsActive = true;
        campaign.StartDate=system.today();
        campaign.EndDate=system.today()+5;
        insert campaign;
        system.debug('campaign.isactive>>>'+campaign);
        List<Contact> contactList = ZTS_EU_DataUtilityTest.createContactRecord(counter);
        insert contactList;
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
        accList =  ZTS_EU_DataUtilityTest.createAccountRecord(1);
        insert accList;
        List<Account> accList = new List<Account>();
        listCampAccsIns = createCampAcc(2);
        insert listCampAccsIns;
        campaignMemberListIns = createCampaignMemberRecord(1);
        //system.debug('Campaign status before member insert>'+campaignMemberListIns[0].Campaign.Id);
        /*listCampsIns.add(new Campaign(Name = 'TestCampaign',IsActive = true,ZTS_EU_Field_Targeting__c = 'Open',Campaign_Name_English__c = 'TestCampaign',ZTS_EU_Market__c ='United Kingdom',
                                     StartDate=system.today(),EndDate=system.today()+5));
        insert listCampsIns;
        accList =  ZTS_EU_DataUtilityTest.createAccountRecord(2);
        insert accList;
		List<Contact> contactList = new List<Contact>();
		contactList.add(new Contact(firstname = 'test',lastname='contact',accountid = accList[0].id,ZTS_EU_Market__c='United Kingdom'));
        insert contactList;
        listCampAccsIns.add(new ZTS_EU_Campaign_Account__c(ZTS_EU_Account__c = accList[0].id,ZTS_EU_Campaign__c = listCampsIns[0].id,ZTS_EU_Campaign_Hidden__c=listCampsIns[0].id,ZTS_EU_Member_Status__c = 'Added'));
        listCampAccsIns.add(new ZTS_EU_Campaign_Account__c(ZTS_EU_Account__c = accList[1].id,ZTS_EU_Campaign__c = listCampsIns[0].id,ZTS_EU_Campaign_Hidden__c=listCampsIns[0].id,ZTS_EU_Member_Status__c = 'Added'));
        insert listCampAccsIns;
        system.debug('Campaign before insert-->'+listCampsIns[0]);
        campaignMemberListIns.add(new CampaignMember(CampaignId = listCampsIns[0].id,ContactId = contactList[0].Id));
        insert campaignMemberListIns;*/
        
    }


    static testmethod void testZTS_EU_AddtoCampaignRedirect(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            createTestData();
        }
        
        ApexPages.standardController cont =  new ApexPages.StandardController(listCampAccsIns[0]);
        PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        myPage.getParameters().put('records',accList[0].id+','+accList[1].id);
        test.setCurrentPage(myPage);
        ZTS_EU_AddtoCampaignRedirect addCampRedir = new ZTS_EU_AddtoCampaignRedirect(cont);
        addCampRedir.campAccnt = listCampAccsIns[0];
        Test.startTest();
            addCampRedir.fromCampMethod();
            addCampRedir.addAccCampaign();
            addCampRedir.dupTargetAccUpdate();
        
        
        myPage.getParameters().put('records',accList[0].id+','+accList[1].id);
        myPage.getParameters().put('fromCamp','true');
        myPage.getParameters().put('fromCampId',listCampsIns[0].id);
        test.setCurrentPage(myPage);
        addCampRedir = new ZTS_EU_AddtoCampaignRedirect(cont);
       
            addCampRedir.fromCampMethod();
            addCampRedir.addAccCampaign();
            addCampRedir.dupTargetAccUpdate();
        Test.stopTest();
        
    }
}