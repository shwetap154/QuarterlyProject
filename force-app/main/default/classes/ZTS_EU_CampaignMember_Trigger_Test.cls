/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_CampaignMember_Trigger_Test
* Description   :  Test class for CampaignMember trigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_CampaignMember_Trigger_Test {

static testMethod void validate_ZTS_EU_CampaignMember_Trigger () {
ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      string userName = generateRandomUserName(); 
      User u = new User(Alias = 'standt', Email=userName, 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName=userName,ZTS_EU_Market__c = 'United Kingdom');

      System.runAs(u) {
        List<CampaignMember>campaignMemberList = ZTS_EU_DataUtilityTest1.createCampaignMemberRecord(1);
        Test.startTest();
        insert campaignMemberList;
        delete campaignMemberList;
        
        system.assertNotEquals(campaignMemberList.size(),0);
        Test.stopTest();
      }


}

    public static string generateRandomUserName() {
            double a=(Math.random() + 1)*100000;
            integer b = a.intValue();
            string c = String.valueOf(b);
            string userName = 'standarduser' + c + '@testorg.com';
            return userName;     
        } 




}