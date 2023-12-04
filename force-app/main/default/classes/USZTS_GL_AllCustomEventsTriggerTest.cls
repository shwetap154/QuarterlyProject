/*******************************************************************************************************************************************
* File Name     :  USZTS_GL_AllCustomEventsTriggerTest
* Description   :  Test class for ZTS_GL_AllCustomEventsTrigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Keshika         Created the Class.

***************************************************************************************************************/
@isTest
public class USZTS_GL_AllCustomEventsTriggerTest{
      

   
    static testMethod void validate_ZTS_GL_AllCustomEventsTriggerTest(){
    ZTS_DataUtilityTest.activateTriggerSettings();
    Integer counter = 2;
    Boolean run = true;
    date d = Date.today();
    List<ZTS_US_Event_Invitee__c> listEventInvitees;
    Test.startTest();
    List<ZTS_Events__c> eveList=ZTS_DataUtilityTest.createEvents(counter);
    insert eveList;
    listEventInvitees = createInternalAttendees(eveList);
    insert listEventInvitees;
   // eveList[0].ZTS_US_Purpose_Agenda__c = 'Test purpose new';
    eveList[0].Purpose_Agenda__c = 'Test Pooja';
    update eveList;
     CheckRecursiveTrigger.runOnce();
    // eveList[1].ZTS_US_Purpose_Agenda__c = 'Test purpose new';
     eveList[1].Purpose_Agenda__c = 'Test Pooja';
     update evelist;
     CheckRecursiveTrigger.runOnce();
    Test.stopTest();
    }
    
     /*-------insert ZTS_US_Internal_Attendee__c object records------*/
    public static List<ZTS_US_Event_Invitee__c> createInternalAttendees(List<ZTS_Events__c> listEvnts)
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
                    List<ZTS_US_Event_Invitee__c> listEventAttendees = new List<ZTS_US_Event_Invitee__c>();
                    List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(1);
                    User usr = new User();
                    usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
                    usr.FirstName = 'davidsUser';
                    usr.zts_eu_market__c = 'United Kingdom';
                    insert usr;

                    System.runAs(usr){
                        insert conList;
                    }
                    
                    for(ZTS_Events__c event: listEvnts){
                                    ZTS_US_Event_Invitee__c evntAtten = new ZTS_US_Event_Invitee__c(ZTS_US_Contact__c=conList[0].Id, ZTS_US_Event__c=event.Id);
                                    listEventAttendees.add(evntAtten);
                    }
                    return listEventAttendees;
    }
    
    static testMethod void validatedeleteTest(){
    ZTS_DataUtilityTest.activateTriggerSettings();
    Integer counter = 2;
    Boolean run = true;
    date d = Date.today();
    List<ZTS_US_Event_Invitee__c> listEventInvitees;
    Test.startTest();
    List<ZTS_Events__c> eveList=ZTS_DataUtilityTest.createEvents(counter);
    insert eveList;
    listEventInvitees = createInternalAttendees(eveList);
    insert listEventInvitees;
    //eveList[0].ZTS_US_Status__c = 'Approved';
    eveList[0].ZTS_US_End_Date__c = System.now()+20;
     //eveList[1].ZTS_US_Status__c = 'Approved';
        eveList[0].ZTS_US_End_Date__c = System.now()+22;
     update evelist;
        delete evelist;
    Test.stopTest();
    }
    
  
}