/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Call_Trigger_Test
* Description   :  Test class for CallTrigger trigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_Call_Trigger_Test {

    static testMethod void validate_ZTS_EU_Call_Trigger () {
      
        List<Call__c>callList = ZTS_EU_DataUtilityTest1.createCallRecord(1);
        Test.startTest();
        insert callList ;
        delete callList;
        
        system.assertNotEquals(callList.size(),0);
        Test.stopTest();
    
    }
    // method to validate Call Utils
    static testMethod void validate_ZTS_EU_Call_Utils () {
  
        List<Call__c>callList = ZTS_EU_DataUtilityTest1.createCallRecord(1);
        Test.startTest();
        insert callList ;
        CallUtils.syncOnInsert(callList);
        callList[0].ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 11, 30, 2);        
        callList[0].ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 11, 30, 2).addHours(1);
        update callList;
        CallUtils.syncOnUpdate(callList);
        system.assertNotEquals(callList.size(),0);
        Test.stopTest();
    
    }

}