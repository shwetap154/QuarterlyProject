/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Speaker_Utils_test
* Description   :  Test class for ZTS_US_Speaker_Utils
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.

***************************************************************************************************************/


@isTest (Seealldata = false)
public class ZTS_US_Speaker_Utils_test{

  public static testMethod void TestZTS_US_Speaker_Utils(){
        User usrAdmin = new User();
        usrAdmin = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usrAdmin.FirstName = 'davidsUser';
        usrAdmin.zts_eu_market__c = 'United Kingdom';
        insert usrAdmin;
 
        System.runAs(usrAdmin)
        {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            test.starttest();
            List<Contact> Con = ZTS_DataUtilityTest.createContactRecord(1);
            Con[0].ZTS_US_Speaker_Flag__c = true;
            Insert Con;
            ZTS_EU_KOL__c kolSpeaker = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[0].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
            insert kolSpeaker;
            List<ZTS_Events__c> Eventspeaker =  ZTS_DataUtilityTest.createEvents(2);
            Eventspeaker[0].ZTS_US_End_Date__c = system.today().addDays(20);
            Eventspeaker[1].ZTS_US_End_Date__c = system.today().addDays(20);
            insert Eventspeaker ;
            ZTS_US_Speaker__c USSpeaker = new  ZTS_US_Speaker__c();
            USSpeaker.ZTS_US_Speaker_Fee__c = 500;
            USSpeaker.ZTS_US_Contact__c=Con[0].id;
            USSpeaker.ZTS_US_Event__c= Eventspeaker[0].id;
            USSpeaker.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
            USSpeaker.ZTS_US_Speaking_Date__c = system.today().addDays(1);
            USSpeaker.ZTS_US_Therapeutic_Area_Experience__c = '1';
            Insert USSpeaker;
          
            List<ZTS_US_Speaker__c> recSpeaker = new List<ZTS_US_Speaker__c>();
            recSpeaker.add(USSpeaker);
           
           ZTS_US_Speaker_Utils.validateOnInsertAndUpdate(recSpeaker);
            
            test.stoptest();
       
      	}
  	}
  }