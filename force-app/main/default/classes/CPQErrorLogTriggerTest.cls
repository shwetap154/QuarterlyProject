/**
* File Name     :  CPQErrorLogTriggerTest
* @description  :  Test class for CPQ Error Log Trigger.  The trigger emails users when a CPQ error lof is inserted
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     11/13/2019	Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.

**/

@IsTest
public class CPQErrorLogTriggerTest {
    @TestSetup static void setup(){
        CPQNotificationSettings__c cPQNotificationSettings = new CPQNotificationSettings__c();
        cPQNotificationSettings.Name = 'Test';
        cPQNotificationSettings.CPQ_Error_Log_Created__c = true;
        cPQNotificationSettings.Eligibility_Load_Created__c = true;
        cPQNotificationSettings.Recipient__c = 'cory.bartholomew@atginfo.com';
        cPQNotificationSettings.Vistex_Deal_Changed__c = true;
        cPQNotificationSettings.Vistex_Deal_Header__c = true;
        cPQNotificationSettings.Vistex_Flexible_Group_Created__c = true;
        insert cPQNotificationSettings;

    }    
    
    @isTest static void testinsert(){
        Error_Log__c log = new Error_Log__c(
            Error_Type__c = 'HttpResponse',
            Developer_Message__c = 'Test'
        );

        insert log;
    }
}