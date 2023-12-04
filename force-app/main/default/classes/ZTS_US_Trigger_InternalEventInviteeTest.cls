/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Trigger_InternalEventInviteeTest
* Description   :  Test class for ZTS_US_Trigger_InternalEventInvitee
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.

***************************************************************************************************************/


@istest (Seealldata = False)


public class ZTS_US_Trigger_InternalEventInviteeTest{

   /*
    public static testMethod void ZTS_US_Trigger_InternalEventInviteeTest(){
     Test.starttest();
      List<ZTS_Events__c> Eventspeaker =  ZTS_DataUtilityTest.createEvents(2);
      Eventspeaker[0].ZTS_US_End_Date__c = system.today().addDays(20);
      Eventspeaker[1].ZTS_US_End_Date__c = system.today().addDays(20);
      insert Eventspeaker ;
     ZTS_US_Internal_Attendee__c Attendee = New ZTS_US_Internal_Attendee__c
     (
         ZTS_US_Event_Percentage_Payment__c = 0,
         ZTS_US_Is_Speaking__c = True,
         ZTS_US_User__c = userinfo.getuserid(),
         ZTS_US_Events__c =  Eventspeaker[0].id 
    );
    insert Attendee ;
    Delete Attendee;
     
     Test.stoptest();  
   }
  */
    
    public static testMethod void USInternalAttendeeTriggerServiceTest(){
        
        Test.starttest();
        	List<ZTS_Events__c> Eventspeaker =  ZTS_DataUtilityTest.createEvents(1);
        	Eventspeaker[0].ZTS_US_End_Date__c = system.today().addDays(20);
          	insert Eventspeaker ;
        
        	ZTS_Events__c testEvt = [Select id, ZTS_EU_Market__c FROM ZTS_Events__c WHERE ZTS_US_Name__c = 'Test Event0' LIMIT 1];
        	System.assertEquals('United States', testEvt.ZTS_EU_Market__c);
        
        	ZTS_US_Internal_Attendee__c Attendee = New ZTS_US_Internal_Attendee__c
            (
                ZTS_US_Event_Percentage_Payment__c = 0,
                ZTS_US_Is_Speaking__c = True,
                ZTS_US_User__c = userinfo.getuserid(),
                ZTS_US_Events__c = testEvt.Id
            );
        	Insert Attendee ;
        	Delete Attendee;
        
        Test.stoptest();  
   }
   
}