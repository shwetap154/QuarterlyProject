/**
* File Name     :  FlexibleGroupTriggerTest
* @description  :  Test coverage for the email notification sent by the flexible group trigger
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     9/20/2019		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.

**/
@isTest
public class FlexibleGroupTriggerTest {
	
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
    
    @isTest
    public static void testAfterInsert(){
       Flexible_Group__c grp =  CPQ_TestDataFactory.createFlexibleGroup('1234567890', 'ZFLX', false);
       insert grp;
       Flexible_Group__c grpAfterInsert = [SELECT Id FROM Flexible_Group__c LIMIT 1];
       system.assertNotEquals(null, grpAfterInsert);
    }
    
    @isTest
    public static void testAfterInsertToUpdateItemsParent(){

        Flexible_Group_Item__c fgi = CPQ_TestDataFactory.createFlexibleGroupItem('TEST-NUM', '','', false);
        insert fgi;        
        Flexible_Group__c grp =  CPQ_TestDataFactory.createFlexibleGroup('TEST-NUM', 'ZFLX', false);
        insert grp;
        Flexible_Group_Item__c fgiAfterInsert = [SELECT Id, Flexible_Group__c, Flexible_Group_Number__c FROM Flexible_Group_Item__c][0];
        system.assertNotEquals(null, fgiAfterInsert.Flexible_Group__c);
     }
}