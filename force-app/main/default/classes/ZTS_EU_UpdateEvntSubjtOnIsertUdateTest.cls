/*************************************************************************************************************************
Class Name     : ZTS_EU_UpdateEvntSubjtOnIsertUdateTest
Description    : This test class for ZTS_EU_UpdateEventSubjectOnIsertUdate Ref : INC0385931.
Created By     : Deloitte Consulting/Fayas Mansoor
Created On     : 08/10/2015

Modification Log    :
------------------------------------------------------------------------------------------------------------------------
Developer                             Date                    Description
---------                             ----                    -----------
*****************************************************************************************/

@isTest
public class ZTS_EU_UpdateEvntSubjtOnIsertUdateTest
{
    public static testMethod void TestUpdateEventSubjectOnIsertUdate()
    {
        
        EventTriggerHandler eventHandler = new EventTriggerHandler();
        eventHandler.disableTrigger = true;
        CallTriggerHandler callHandler = new CallTriggerHandler();
        callHandler.disableTrigger = true;
        
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        u.ZTS_EU_Market__c = 'Brazil';
        State_Country__c sc = new State_Country__c(Name = 'Test',ZTS_EU_Country__c = 'Brazil');
        insert sc;
        Account acc = new Account(Name = 'Test',Type = 'Farm', ZTS_EU_Sub_Type__c = 'Beef', ZTS_EU_Address_Line_1__c = 'EST ALIPIO DE OLIVEIRA REMIAO', ZTS_EU_Country__c = 'Brazil',ZTS_EU_State_County__c = sc.id,ZTS_EU_Zip_Postal_Code__c = '94430020',
                                  ZTS_EU_Market__c='Brazil',
                                  Practice_Management_Software__c = 'Other',
                                  Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                  ZTS_EU_VAT_Code__c = 'please add VAT no');
        System.runAs(u)
        {
            insert acc;
        }
        Call__C call = new Call__C(ZTS_EU_Sub_Type__c = 'Account Call', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = System.now(),ZTS_EU_End_Date_Time__c = System.now(),ZTS_EU_Duration__c = '0.5 Hour');       
        test.starttest();
        System.runAs(u)
        {
            insert call;
        }
        Event eve = new event(Subject = call.Name, OwnerId = u.Id, WhatId = acc.id,ActivityDateTime = call.ZTS_EU_Start_Date_Time__c,EndDateTime = call.ZTS_EU_End_Date_Time__c,CallRecordId__c = call.id);    
        
        System.runAs(u)
        {
            insert eve;
        }
        ZTS_EU_UpdateEventSubjectOnIsertUdate.updateEventSubject(new List<Event>{eve});
        List<event> eveList = [Select Id, CallRecordId__c from Event where WhatId=: acc.id AND ZTS_EU_Market__c != 'United States'];
        System.assertEquals(1,eveList.size());
        test.stopTest();
    }
}