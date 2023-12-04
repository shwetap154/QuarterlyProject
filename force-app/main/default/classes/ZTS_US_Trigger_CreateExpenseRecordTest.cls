/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Trigger_CreateExpenseRecordTest
* Description   :  Test class for ZTS_US_Trigger_CreateExpenseRecord
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.

***************************************************************************************************************/

@istest (Seealldata = False)


public class ZTS_US_Trigger_CreateExpenseRecordTest{

   public static testMethod void ZTS_US_Trigger_Create_Expense_Record_Test(){
       ZTS_DataUtilityTest.activateTriggerSettings();
       User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
      List<Contact> Con = ZTS_DataUtilityTest.createContactRecord(1);
        Con[0].ZTS_US_Speaker_Flag__c = true;
        System.runAs(usr)
        {
            Insert Con;
        }
        
        ZTS_EU_KOL__c kolSpeaker = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[0].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
        System.runAs(usr)
        {
            insert kolSpeaker;
        } 
       
        List<ZTS_Events__c> Eventspeaker =  ZTS_DataUtilityTest.createEvents(2);
        Eventspeaker[0].ZTS_US_End_Date__c = system.today().addDays(20);
        Eventspeaker[1].ZTS_US_End_Date__c = system.today().addDays(20);
        insert Eventspeaker ;
     
      ZTS_US_Speaker__c USSpeaker1 = new  ZTS_US_Speaker__c();
        USSpeaker1.ZTS_US_Speaker_Fee__c = 500;
        USSpeaker1.ZTS_US_Contact__c=Con[0].id;
        USSpeaker1.ZTS_US_Event__c= Eventspeaker[0].id;
        USSpeaker1.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker1.ZTS_US_Speaking_Date__c = system.today().addDays(1);
        USSpeaker1.ZTS_US_Therapeutic_Area_Experience__c = '1';
        Insert USSpeaker1;    
        
        USSpeaker1.ZTS_US_Speaker_Fee_Type__c = 'Dollar';
        update USSpeaker1;
        
        delete USSpeaker1;
        
  }
}