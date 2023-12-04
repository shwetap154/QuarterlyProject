/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Contact_populateCallDatesTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Akanksha             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_EU_Contact_populateCallDatesTest 
{ 
    static testMethod void validate_ZTS_EU_Contact_populateCallDates(){      
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting(); 
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Map <id, date> mapConIdDate = new Map<id, Date>();
            Map <ID, List<Attendee__C>> mapCallAttendees = new Map<ID, List<Attendee__C>>();
            Map <id, id> mapAttcon = new Map<id, id>();
            List<Contact> listCon = new List<Contact>();
            LIst <Attendee__C> listAttendee = new List<Attendee__C>();
            List <Attendee__C> listAllAttendee = new List<Attendee__C>();  
            
            ZTS_EU_Contact_populateCallDates popdates= new ZTS_EU_Contact_populateCallDates();
            List<Contact> contactList=ZTS_EU_DataUtilityTest1.createContactRecord(1);
            contactList[0].ZTS_EU_Market__c = 'United Kingdom';
            insert contactList;
            test.startTest();
            List<Call__c> callList =  ZTS_EU_DataUtilityTest1.createCallRecord(1);
            //Below line added by Chanbash NBSK on 01/25 to increase code coverage part.
            callList[0].ZTS_EU_Status__c = 'Completed';
            insert callList;
            
            List<Attendee__c> attenList=new List<Attendee__c>();
            //List<Attendee__c> attenList=ZTS_EU_DataUtilityTest1.createAttendee(1);
            //insert attenList;
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_Contact__c = contactList[0].Id;
            attendee.ZTS_EU_call__c = callList[0].Id;
            attenList.add(attendee);
            insert attenList;
            //mapCallAttendees.put(callList[0].id,attenList);
            popdates.getLastCAllDate(callList);
            test.stopTest();  
        }     
    }   
}