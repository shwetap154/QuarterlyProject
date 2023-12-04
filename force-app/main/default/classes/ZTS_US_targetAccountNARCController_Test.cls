/*******************************************************************************************************************************************
* File Name     :  ZTS_US_targetAccountNARCController_Test
* Description   :  Test class for ZTS_US_targetAccountNARCController
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.

***************************************************************************************************************/


@isTest(SeeAllData=false) 
public class ZTS_US_targetAccountNARCController_Test {


public static testMethod void ZTS_US_targetAccountNARCController_CheckTest() {
        Test.startTest();
        //Creating the test data
       List<Campaign>  Camp = ZTS_DataUtilityTest.createCampaignRecord(2);
       for (Campaign cmp : Camp) cmp.Campaign_Name_English__c = 'English';
        insert Camp;
       User usr = new User();
       usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
       usr.FirstName = 'eltonUser';
       usr.zts_eu_market__c = 'United Kingdom';
       insert usr;
       List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
       Acc[0].ZTS_US_NARC_ID__c = '123';
       System.runAs(usr)
       {
           Insert Acc;
       }
       
       ZTS_EU_Campaign_Account__c USCampagin = new ZTS_EU_Campaign_Account__c(
       
               ZTS_EU_Member_Status__c = 'Removed',
               ZTS_EU_Targeted_Account_Unique__c = '1',
               ZTS_US_NARC_IDs__c = '123;456;789',
               ZTS_EU_Campaign__c = camp[0].id,
               ZTS_EU_Account__c = Acc[0].id
       );
       insert USCampagin ;
     
            
            
            //Initializing the Visualforce Page
            PageReference pgRef = Page.ZTS_US_targetAccountNARC;
            Test.setCurrentPageReference (pgRef);
          
           ApexPages.currentPage().getParameters().put('campId',camp[0].id); 
           
    
            ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(USCampagin);
            ZTS_US_targetAccountNARCController  Target = new ZTS_US_targetAccountNARCController(controller);
            Target.campAccnt = USCampagin ;
            Pagereference P = Target.addTargetAccountNARC();
            Set<id>IDs =new Set<id>();
            IDs.add(Acc[0].id);
            Target.dupTargetAccUpdate(IDs);

            test.stoptest();
    }


  public static testMethod void ZTS_US_targetAccountNARCController_Test() {
        Test.startTest();
        //Creating the test data
       List<Campaign>  Camp = ZTS_DataUtilityTest.createCampaignRecord(2);
       for (Campaign cmp : Camp) cmp.Campaign_Name_English__c = 'English';
        insert Camp;
       User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
       List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
       Acc[0].ZTS_US_NARC_ID__c = '112233';
       System.runAs(usr)
       {
           Insert Acc;
       }

       
       ZTS_EU_Campaign_Account__c USCampagin = new ZTS_EU_Campaign_Account__c(
       
               ZTS_EU_Member_Status__c = 'Removed',
               ZTS_EU_Targeted_Account_Unique__c = '1',
               ZTS_US_NARC_IDs__c = '123;456;789',
               ZTS_EU_Campaign__c = camp[0].id,
               ZTS_EU_Account__c = Acc[0].id
       );
       insert USCampagin ;
     
            
            
            //Initializing the Visualforce Page
            PageReference pgRef = Page.ZTS_US_targetAccountNARC;
            Test.setCurrentPageReference (pgRef);
          
           ApexPages.currentPage().getParameters().put('campId',USCampagin.id); 
           
    
            ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(USCampagin);
            ZTS_US_targetAccountNARCController  Target = new ZTS_US_targetAccountNARCController(controller);
            Target.campAccnt = USCampagin ;
            Pagereference P = Target.addTargetAccountNARC();
            Set<id>IDs =new Set<id>();
            IDs.add(Acc[0].id);
            Target.dupTargetAccUpdate(IDs);
            
            Acc[0].ZTS_US_NARC_ID__c = '123';
            update Acc;
            
            USCampagin.ZTS_US_NARC_IDs__c = '123\n456';
            update USCampagin;
            
            Target.campAccnt = USCampagin ;
            Pagereference P1 = Target.addTargetAccountNARC();
            
            USCampagin.ZTS_US_NARC_IDs__c = '123';
            update USCampagin;
            
            Target.campAccnt = USCampagin ;
            Pagereference P2 = Target.addTargetAccountNARC();
            
            
           test.stoptest();
         }
         
}