/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_ChangeRequest_Test
* Description   :  Test class for ZTS_EU_ChangeRequest trigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_ChangeRequest_Test {

static testMethod void validate_ZTS_EU_ChangeRequest_Test () {
    User usr = new User();
    usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
    usr.FirstName = 'davidsUser';
    usr.zts_eu_market__c = 'United Kingdom';
    insert usr;

    System.runAs(usr)
    {  
      List<ZTS_EU_Request__c>cRequestList = ZTS_EU_DataUtilityTest1.createChangeRequestRecord(1);
      Test.startTest();
      insert cRequestList;
      cRequestList[0].ZTS_EU_Status__c = 'Submitted';
      update cRequestList;
      Test.stopTest();    
    }
  }
  static testMethod void validate_ZTS_EU_submit_CR_record(){
      User usr = new User();
      usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
      usr.FirstName = 'davidsUser';
      usr.zts_eu_market__c = 'United Kingdom';
      insert usr;

    System.runAs(usr)
    {
      String recid;
      Test.startTest();
      //Group grp=new Group(Name = 'Change Request Queue',Type = 'Queue');
      //insert grp;
      List<ZTS_EU_Request__c>cRequestList = ZTS_EU_DataUtilityTest1.createChangeRequestRecord(1);
      ZTS_EU_Request__c req=cRequestList[0];
      insert req;
      req.ZTS_EU_Status__c = 'Submitted';
      update req;
      ZTS_EU_submit_CR_record.submitRecord(req.id);
      Test.stopTest();
    }
  }
}