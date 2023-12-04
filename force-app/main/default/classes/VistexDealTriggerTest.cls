/**
* File Name     :  VistexDealTriggerTest
* @description  :  Test coverage for the vistex deal trigger.  The trigger simply notifies users of record insertion
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     9/20/2019 	Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.

**/

@isTest
public class VistexDealTriggerTest {
    @TestSetup static void setup(){
        CPQNotificationSettings__c cpqNotificationSettings = new CPQNotificationSettings__c();
        cpqNotificationSettings.Name = 'Test';
        cpqNotificationSettings.CPQ_Error_Log_Created__c = true;
        cpqNotificationSettings.Eligibility_Load_Created__c = true;
        cpqNotificationSettings.Recipient__c = 'cory.bartholomew@atginfo.com';
        cpqNotificationSettings.Vistex_Deal_Changed__c = true;
        cpqNotificationSettings.Vistex_Deal_Header__c = true;
        cpqNotificationSettings.Vistex_Flexible_Group_Created__c = true;
        insert cpqNotificationSettings;
    }   
    
    @isTest
    public static void testAfterInsert(){
       List<CPQNotificationSettings__c> settings = [SELECT Id, Recipient__c FROM CPQNotificationSettings__c];
       System.assert(settings.size() > 0);
       Vistex_Deal_Header__c header =  CPQ_TestDataFactory.createVistexDealHeader('1234567890', '1436', false);
       insert header;
       Vistex_Deal_Header__c headerAfterInsert = [SELECT Id FROM Vistex_Deal_Header__c LIMIT 1];
       system.assertNotEquals(null, headerAfterInsert);
    }
}