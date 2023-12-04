/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_AddtoCampaignFromConControllerTest
* Description   :           
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date              Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     06/14/2014        Ketan                   Created the Class.
* 1.1     03/21/2022        Ethan Hirsch @ Zoetis   Fixed Unit Tests due to new Validation Rule

********************************************************************************************************************************************/
@isTest(SeeAllData = true)
public class ZTS_EU_AddtoCampaignFromConContTest{
/*
Public static List<Account> accList = new List<Account>();
Public static List<ZTS_EU_Campaign_Account__c> listCampAccsIns = new List<ZTS_EU_Campaign_Account__c>();

Public static List<CampaignMember> campaignMemberListIns = new List<CampaignMember>();
*/

Public static List<Contact> conListIns = new List<Contact>();
Public static List<Campaign> listCampsIns = new List<Campaign>();

/****************************Insert Contact(s)**************************************************************************/
    public static List<Contact> createContactRecord(Integer numCont) {
    
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<numCont;i++) {
            Contact con = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            con.firstname='Test First'+i;
            con.lastname = 'Test Contact'+i;
            
            conList.add(con);
        }        
        return conList;  
           
    }



/****************************Insert Campaign**************************************************************************/
    public static List<Campaign> createCampaignRecord(Integer counter) { // 6/14
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=0;i<counter;i++) {
            Campaign campaign = new Campaign();         
            campaign.Name = 'TestCampaign';
            campaign.ZTS_EU_Field_Targeting__c = 'Open';
             campaign.Campaign_Name_English__c = 'TestCampaign';          
            campaignList.add(campaign);
        }        
        return campaignList;  
           
    }


 /****************************Insert Campaign Member**************************************************************************/
    public static List<CampaignMember> createCampaignMemberRecord(Integer counter) {
        Campaign campaign = new Campaign();         
        campaign.Name = 'TestCampaign';
        campaign.ZTS_EU_Field_Targeting__c = 'Open';
        insert campaign;
        List<Contact> contactList = createContactRecord(counter);
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
        
        
        
        listCampsIns = createCampaignRecord(1);
        insert listCampsIns;
        
        conListIns = createContactRecord(1);
        conListIns[0].ZTS_EU_Campaign_for_Contact__c = listCampsIns[0].id;
        insert conListIns;
        
        //campaignMemberListIns = createCampaignMemberRecord(1);
        //insert campaignMemberListIns;
        
    }


    @isTest
    public static void testZTS_EU_AddtoCampaignFromConController(){
        createTestData();
        
        /*CampaignMemberStatus cms = new CampaignMemberStatus ();
        cms.CampaignId = listCampsIns[0].id;
        cms.IsDefault = true;
        cms.Label = 'Sent';
        cms.SortOrder = 1;
        insert cms;*/
       
        PageReference myPage = Page.ZTS_EU_AddtoCampaignFromCon;
        myPage.getParameters().put('conCampId',conListIns[0].id);
        test.setCurrentPage(myPage);
        ApexPages.standardController cont =  new ApexPages.StandardController(conListIns[0]);
        ZTS_EU_AddtoCampaignFromConController addCampFrmCon = new ZTS_EU_AddtoCampaignFromConController(cont);
        addCampFrmCon.conCamp = conListIns[0];
System.debug(addCampFrmCon.conCampId);
System.debug(addCampFrmCon.conCamp);

        Test.startTest();
            addCampFrmCon.addConCampaign();
        Test.stopTest();
        
    }
}