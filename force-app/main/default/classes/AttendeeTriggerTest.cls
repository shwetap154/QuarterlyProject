/*******************************************************************************************************************************************
* File Name     :  AttendeeTriggerTest
* Description   :  Test class for AttendeeTrigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/16         Keshika         Created the Class.

***************************************************************************************************************/
@isTest
public class AttendeeTriggerTest{
    
    static testMethod void validate_AttendeeTriggerTest(){
        User usrAdmin = new User();
        usrAdmin = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usrAdmin.FirstName = 'davidsUser';
        usrAdmin.zts_eu_market__c = 'United States';
        insert usrAdmin;
        
        System.runAs(usrAdmin)
        {
            ZTS_DataUtilityTest.activateTriggerSettings();
            
            
            List <Attendee__c> attendeeList= ZTS_DataUtilityTest.createAttendee(1);
            List<ZTS_EU_Colleague__c> createColleague = ZTS_DataUtilityTest.createColleague(1);
            List<ZTS_Events__c> Eventrec = ZTS_DataUtilityTest.createEvents(1);
            List<User> usersLis = ZTS_DataUtilityTest.createcoacherUser();
            for (User u : usersLis) u.ZTS_EU_Market__c = 'United States';
            Test.startTest();
            
            insert attendeeList;
            insert createColleague;
            insert Eventrec;
            insert usersLis;
            attendeeList[0].ZTS_EU_Campaign_Response__c='test';
            delete Eventrec;
            delete createColleague;
            update attendeeList;
            delete attendeeList;
            Test.stopTest();
        }
    }
    
    
}