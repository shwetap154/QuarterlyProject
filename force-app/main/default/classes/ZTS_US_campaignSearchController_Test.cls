/*******************************************************************************************************************************************
* File Name     :  ZTS_US_campaignSearchController_Test
* Description   :  Test class for ZTS_US_campaignSearchController
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15        Sonali Chhabria       Created the Class.

***************************************************************************************************************/


@isTest(SeeAllData=false) 
public class ZTS_US_campaignSearchController_Test{


  public static testMethod void ZTS_US_Campaign_Test() {
        Test.startTest();
        //Creating the test data
       Campaign testCampaign = new Campaign();
       testCampaign.Name = 'TestCampaign';
       testCampaign.ZTS_EU_Field_Targeting__c = 'Open';
       testCampaign.IsActive = true;
       testCampaign.Is_Active_Campaign__c =true;
       testCampaign.StartDate = System.today();
       testCampaign.ZTS_EU_Market__c = 'United States';
       insert testCampaign;
       PageReference pgRef = Page.ZTS_US_campaignSearchPage;
       Test.setCurrentPageReference (pgRef);
       ApexPages.currentPage().getParameters().put('CampaignIds',testCampaign.id); 
        ZTS_US_campaignSearchController camsearchcon = new  ZTS_US_campaignSearchController();
      	camsearchcon.populateCampaignWrapper();
        camsearchcon.saveResponse();
      }
      }