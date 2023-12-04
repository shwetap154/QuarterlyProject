/*******************************************************************************************************************************************
* File Name     :  ZTS_US_TOT_UtilsTest
* Description   :  Test class for ZTS_US_TOT_Utils
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/16         Keshika         Created the Class.

***************************************************************************************************************/
@isTest
public class ZTS_US_TOT_UtilsTest{
    
    static testMethod void validate_ZTS_US_TOT_UtilsTest(){
    ZTS_DataUtilityTest.activateTriggerSettings();
    
    date d = Date.today();
    date d1 = d +3;
    date d2 = d+5;
    date d3 = d +6;
    List <Time_Out_of_Territory__c > totList= new List <Time_Out_of_Territory__c>();
    Test.startTest();
    
    Time_Out_of_Territory__c  tot = new Time_Out_of_Territory__c(ZTS_EU_Status__c='Planned',ZTS_EU_Reason__c='Vacation/Personal',ZTS_EU_Start_Date__c= d,ZTS_EU_End_Date__c=d1,ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM',ZTS_EU_Description__c='test');
    totList.add(tot);
    Time_Out_of_Territory__c  tot1 = new Time_Out_of_Territory__c(ZTS_EU_Status__c='Planned',ZTS_EU_Reason__c='Vacation/Personal',ZTS_EU_Start_Date__c= d2,ZTS_EU_End_Date__c=d2,ZTS_EU_Duration__c = 'AM = 9 AM to 1 PM',ZTS_EU_Description__c='test');
    totList.add(tot1);
    Time_Out_of_Territory__c  tot2 = new Time_Out_of_Territory__c(ZTS_EU_Status__c='Planned',ZTS_EU_Reason__c='Vacation/Personal',ZTS_EU_Start_Date__c= d3,ZTS_EU_End_Date__c=d3,ZTS_EU_Duration__c = 'PM = 1 PM to 5 PM',ZTS_EU_Description__c='test');
    totList.add(tot2);
   
    
    insert totList;
   
    totList[0].ZTS_EU_Description__c='testnew';
   
    update totList;
   
    delete totList;
    Test.stopTest();
    }
    
  
}