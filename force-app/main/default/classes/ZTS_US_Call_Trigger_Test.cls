/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Call_Trigger_Test
* Description   :  Test class for ZTS_US_Call_Trigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/11         Akanksha          Created the Class.

***************************************************************************************************************/

@isTest
public with sharing class ZTS_US_Call_Trigger_Test {

static testMethod void validate_ZTS_US_Call_Trigger() {
    User u = ZTS_DataUtilityTest.createcoacherUser()[0];
    u.ZTS_EU_Market__c = 'United States';
    insert u;
    System.runAS(u){
        ZTS_DataUtilityTest.activateTriggerSettings();
        List<Call__c>callList = ZTS_DataUtilityTest.createCallRecord(1);
        Test.startTest();
        insert callList ;
        delete callList;
        system.assertNotEquals(callList.size(),0);
        Test.stopTest();
    }
}

//method to validate Call Utils
static testMethod void validate_CallUtils () {
    User u = ZTS_DataUtilityTest.createcoacherUser()[0];
    u.ZTS_EU_Market__c = 'United States';
    insert u;
    
    System.runAs(u){
        List<Call__c>callList = ZTS_DataUtilityTest.createCallRecord(1);
        Account acc = [SELECT Id, ZTS_EU_Market__c FROM Account WHERE Id = :callList[0].ZTS_EU_Account__c];
        acc.ZTS_EU_Market__c = 'United States';
        update acc;
        
        Test.startTest();        
        Call__c call = new Call__c();         
   
        insert callList ;
        CallUtils.syncOnInsert(callList);
        callList[0].ZTS_EU_Start_Date_Time__c  = datetime.newInstance(2014, 9, 1, 11, 30, 2);        
        callList[0].ZTS_EU_End_Date_Time__c  = datetime.newInstance(2014, 9, 1, 11, 30, 2).addHours(1);
        callList[0].ZTS_EU_Status__c='Submitted';
        update callList;
        
        CallUtils.syncOnUpdate(callList);
        system.assertNotEquals(callList.size(),0);
        ZTS_DataUtilityTest.createCustomTerritory(1);
        CallUtils.createCallCredits(callList);
        callList[0].ZTS_EU_Start_Date_Time__c  = datetime.newInstance(2015, 9, 1, 11, 30, 2);        
        callList[0].ZTS_EU_End_Date_Time__c  = datetime.newInstance(2015, 9, 1, 11, 30, 2).addHours(1);
        update callList;
        CallUtils.setCallTerritory(callList);
        Test.stopTest();
    }
    
}

static testMethod void testCallSubmit(){

  User u = ZTS_DataUtilityTest.createcoacherUser()[0];
  u.ZTS_EU_Market__c = 'United States';
  insert u;
  
  System.runAs(u){
  
      ZTS_DataUtilityTest.activateTriggerSettings();
      
      List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(2);
      for (Account acc : acclist) acc.ZTS_EU_Market__c = 'United States';
      insert acclist;
      System.debug(' acclist '+ acclist);
      List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(2);
      for (ZTS_EU_Territory__c terr : customterrList) terr.ZTS_EU_Market__c = 'United States';
      insert customterrList;
      System.debug('customterrList '+ customterrList);

      List<ZTS_EU_Position__c> userterrlist;
     
      userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
      insert userterrlist;
      System.debug(' userterrlist '+ userterrlist);

      List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
      insert accterr;
      System.debug(' accterr '+ accterr);
      ZTS_EU_Account_Position__c ap1 = new ZTS_EU_Account_Position__c();
    
      ap1.ZTS_EU_Account__c = acclist[0].Id;
      ap1.ZTS_AccountTerritory__c = accterr[0].Id;
      ap1.ZTS_EU_Position__c = userterrlist[0].Id;

      //insert ap1;
      System.debug(' ap1 '+ ap1);
      ZTS_EU_Account_Position__c ap2 = new ZTS_EU_Account_Position__c();
    
      ap2.ZTS_EU_Account__c = acclist[1].Id;
      ap2.ZTS_AccountTerritory__c = accterr[1].Id;
      ap2.ZTS_EU_Position__c = userterrlist[1].Id;
      
      //insert ap2;
      System.debug(' ap2 '+ ap2);


        Test.startTest();

        Call__c call = new Call__c();         
        System.runAs(u){
            call.ZTS_EU_Account__c = acclist[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';      
            call.ZTS_EU_Call_Owner__c = u.Id;
            insert call;
       
        
            /*ZTS_EU_Colleague__c colleague = new ZTS_EU_Colleague__c();
            colleague.ZTS_EU_User__c = UserInfo.getUserId();
            colleague.ZTS_EU_Call__c = call.Id;
            insert colleague;*/
            
           call.ZTS_EU_Status__c=ZTS_EU_GlobalConstants.CALL_STATUS_COMPLETED;
           update call;
          }    
           Test.stopTest();
           Integer cc_count=[SELECT COUNT() FROM ZTS_US_Call_Credit__c WHERE ZTS_US_Call__c = :call.id];

           //System.assert(cc_count>0,'Call Credit creation failed');
    }           
        
  
}
    
    static testMethod void testcreateOpportunity(){
      User u = ZTS_DataUtilityTest.createcoacherUser()[0];
      u.ZTS_EU_Market__c = 'United States';
      insert u;
      
      System.runAs(u){
          ZTS_DataUtilityTest.activateTriggerSettings();
          DiscussionMapping__c cs = new DiscussionMapping__c();
          cs.Name='CARYSTA – After Visit iCard'; 
          cs.Disc_Item__c='CARYSTA HVC Hot Lead – After Visit iCard'; 
          cs.Oppty_Type__c = 'CARYSTA HVC';
          insert cs;
          List<Call__c> calls = ZTS_DataUtilityTest.createSOCallRecord(1);  
          calls.add(new Call__c(Name = 'Test carysta',Opportunity_Type__c = 'CARYSTA HVC', ZTS_EU_Account__c = calls[0].ZTS_EU_Account__c, ZTS_EU_Status__c = 'submitted'));
          insert calls; 
          
          List<Id> callIds = new List<Id>();
          for(Call__c c : calls){
              callIds.add(c.Id);
          }
          Test.startTest();
          CallUtils.createOpportunity(callIds);
          Test.stopTest();
      }
    }
    /*
    static testMethod void testcreateOpportunity2(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        Id carystaRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CARYSTA_HVC').getRecordTypeId();
        DiscussionMapping__c cs = new DiscussionMapping__c();
        cs.Name='CARYSTA – After Visit iCard'; 
        cs.Disc_Item__c='CARYSTA HVC Hot Lead – After Visit iCard'; 
        cs.Oppty_Type__c = 'CARYSTA HVC';
        insert cs;
        List<Call__c> calls = ZTS_DataUtilityTest.createSOCallRecord(1);  
        calls.add(new Call__c(Name = 'Test carysta',Opportunity_Type__c = 'CARYSTA HVC', ZTS_EU_Account__c = calls[0].ZTS_EU_Account__c, ZTS_EU_Status__c = 'submitted'));
        insert calls; 
        Opportunity o = new Opportunity(Name='Test',StageName='New Lead Received (Petcare/Conference/Other)',CloseDate=System.today(),RecordTypeId=carystaRecTypeId, AccountId = calls[0].ZTS_EU_Account__c);  
        insert o;
        System.assert(o.id != null);
    }
    */
    static testMethod void testcreateOpportunity3(){
      User u = ZTS_DataUtilityTest.createcoacherUser()[0];
      u.ZTS_EU_Market__c = 'United States';
      insert u;
      
      System.runAs(u){
          ZTS_DataUtilityTest.activateTriggerSettings();
          Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('People_First').getRecordTypeId();
          DiscussionMapping__c cs = new DiscussionMapping__c();
          cs.Name='LCP Enrollment'; 
          cs.Disc_Item__c='PeopleFirst - LCP Enrollment'; 
          cs.Oppty_Type__c = 'PeopleFirst';
          insert cs;
          List<Call__c> calls = ZTS_DataUtilityTest.createSOCallRecord(1);  
          calls.add(new Call__c(Name = 'Test PF',Opportunity_Type__c = 'PeopleFirst', ZTS_EU_Account__c = calls[0].ZTS_EU_Account__c, ZTS_EU_Status__c = 'submitted'));
          insert calls; 
          Opportunity o = new Opportunity(Name='Test',StageName='Open',CloseDate=System.today(),RecordTypeId=recTypeId, AccountId = calls[0].ZTS_EU_Account__c);  
          //insert o;
          //System.assert(o.id != null);
      }
    }

}