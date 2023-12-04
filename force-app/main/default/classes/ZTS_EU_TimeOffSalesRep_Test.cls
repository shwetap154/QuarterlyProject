/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_TimeOffSalesRep_Test
* Description   :  Test class for TimeoffSalesRep trigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_TimeOffSalesRep_Test {

static testMethod void validate_ZTS_EU_TimeOffSalesRep_Test() {
    try{ 
        List<ZTS_EU_Coaching__c>coachingList = ZTS_EU_DataUtilityTest1.createCoachingRecord(1);
        Test.startTest();
       insert coachingList;
       Test.stopTest();
    }catch(Exception e){
          System.assert( e.getMessage().contains('The assigned sales rep is on Time OFF'), 
                e.getMessage() );
    }
    
   }


}