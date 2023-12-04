/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchCusEvents_Test.cls
   Description: Test Class for Batch Apex ZTS_EU_BatchCusEvents.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   15-04-2016   1.0     Priya               Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest

public class ZTS_EU_BatchCusEvents_Test {
    Public static User u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', true);
    Public static User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', true);
    static void setUpData(){        
        
        ZTS_Events__c e = new ZTS_Events__c();
        e.ZTS_US_Name__c = 'test event';
        e.ZTS_EU_Market__c = system.label.Market_Value;
        e.ZTS_US_Event_Category__c = 'Loyalty / VAS Event';
        e.ZTS_US_Number_of_Attendees__c = 2;
        //e.ZTS_US_Purpose_Agenda__c = 'test';
        e.Purpose_Agenda__c = 'test';
        insert e;
        
        ZTS_US_Internal_Attendee__c att = new ZTS_US_Internal_Attendee__c();
        att.ZTS_US_User__c= u.id;
        att.ZTS_US_Events__c = e.id;
        insert att;
        
        ZTS_US_Internal_Attendee__c att1 = new ZTS_US_Internal_Attendee__c();
        att1.ZTS_US_User__c= u1.id;
        att1.ZTS_US_Events__c = e.id;
        insert att1;
    }
        static testMethod void testevent(){ 
             setUpData();   
             ZTS_EU_BatchCusEvents b = new ZTS_EU_BatchCusEvents();
             database.executeBatch(b); 
         }
}