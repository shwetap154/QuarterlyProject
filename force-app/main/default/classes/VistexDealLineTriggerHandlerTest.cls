/**
* File Name     :  VistexDealLineTriggerHandlerTest
* @description  :  Test coverage for the vistex deal line trigger and handler
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     11/15/2019	Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.

**/

@istest
public class VistexDealLineTriggerHandlerTest {
    @testSetup
    public static void setup() {
        Vistex_Deal_Header__c header =  CPQ_TestDataFactory.createVistexDealHeader('1234567890', '1436', false);
        insert header;

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
    public static void testDealChanged(){

        Vistex_Deal_Header__c header = [SELECT Id,DEALNUM__c,ORGID__c,CreatedDate FROM Vistex_Deal_Header__c LIMIT 1];        
        Test.setCreatedDate(header.Id, DateTime.newInstance(Date.today().year(), Date.today().month(),Date.today().day()-3));
        Test.StartTest();
        Vistex_Deal_Line_E1KOMG__c line = CPQ_TestDataFactory.createVistexDealLine(header,'ZCON', '8675309', null, null, null, 'S1', true);
        Test.StopTest();
        //set deletion indicator to fire after update trigger
        line.LOEVM_KO__c = 'X';
        update line;


    }

}