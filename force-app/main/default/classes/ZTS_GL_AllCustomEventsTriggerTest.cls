/*******************************************************************************************************************************************
* File Name     :  ZTS_GL_AllCustomEventsTriggerTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/15         Vidya             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_GL_AllCustomEventsTriggerTest 
{   
     
    static List<ZTS_Events__c> listEvents;
    static List<ZTS_US_Event_Invitee__c> listEventInvitees;
    
    static testMethod void createTestData2(){
        test.startTest();
        listEvents = createEvents(2);
        insert listEvents;
        test.stopTest();
    }
    
    static testMethod void createTestData1(){
        listEvents = createEvents(2);
        insert listEvents;
        listEvents[0].Total_Number_of_Invitees__c = 10;
        update listEvents;
    }
    
    static testMethod void createTestData3(){
        listEvents = createEvents(2);
        insert listEvents;
        test.startTest();
        listEvents[0].Total_Number_of_Invitees__c = 10;
        update listEvents;
        test.stopTest();
    }
    
     /*-------------insert ZTS_Events__c objects---------------*/
    public static List<ZTS_Events__c> createEvents(Integer counter){ // 6/14
        List<ZTS_Events__c> listEvents1 = new List<ZTS_Events__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_Events__c event = new ZTS_Events__c();
            event.ZTS_US_Will_Firearms_be_Present__c = true;
            event.ZTS_US_Type__c = 'Cattle General';
            event.Total_Number_of_Invitees__c = i;
            event.ZTS_US_Status__c = 'New';
            event.ZTS_US_Start_Date__c = system.now();
            event.ZTS_US_Is_Event_Private__c = false;
            event.ZTS_US_Name__c = 'Test Event'+i;
            //event.ZTS_US_End_Date__c = system.today().addDays(i);
            event.ZTS_US_End_Date__c = system.now().addDays(i);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
           // event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';
            listEvents1.add(event);
        }
        return listEvents1;
    }
    
    /*-------insert ZTS_US_Internal_Attendee__c object records------*/
    public static List<ZTS_US_Event_Invitee__c> createInternalAttendees(List<ZTS_Events__c> listEvnts){
                    List<ZTS_US_Event_Invitee__c> listEventAttendees = new List<ZTS_US_Event_Invitee__c>();
                    List<Contact> conList = ZTS_EU_DataUtilityTest.createContactRecord(1);
                    insert conList;
                    for(ZTS_Events__c event: listEvnts){
                                    ZTS_US_Event_Invitee__c evntAtten = new ZTS_US_Event_Invitee__c(ZTS_US_Contact__c=conList[0].Id, ZTS_US_Event__c=event.Id);
                                    listEventAttendees.add(evntAtten);
                    }
                    return listEventAttendees;
    }
    
    static testMethod void coverEventInviteeTrig(){
        test.startTest();
        listEvents = createEvents(2);
        insert listEvents;
        listEventInvitees = createInternalAttendees(listEvents);
        insert listEventInvitees;
        test.stopTest();
    }
}