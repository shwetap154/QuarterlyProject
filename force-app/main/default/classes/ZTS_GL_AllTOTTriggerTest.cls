/*******************************************************************************************************************************************
* File Name     :  ZTS_GL_AllTOTTriggerTest
* Description   :  Test class for ZTS_GL_AllTOTTrigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Keshika         Created the Class.

***************************************************************************************************************/
@isTest
public class ZTS_GL_AllTOTTriggerTest{
    
    static testMethod void validate_ZTS_GL_AllTOTTriggerTest(){
    ZTS_DataUtilityTest.activateTriggerSettings();
    
    date d = Date.today();
    date d1 = d +3;
    List <Time_Out_of_Territory__c > totList= new List <Time_Out_of_Territory__c>();
    Test.startTest();
    
    Time_Out_of_Territory__c  tot = new Time_Out_of_Territory__c(ZTS_EU_Status__c='Planned',ZTS_EU_Reason__c='Vacation/Personal',ZTS_EU_Start_Date__c= d,ZTS_EU_End_Date__c=d1,ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM',ZTS_EU_Description__c='test');
    totList.add(tot);
    
    insert totList;
    
    totList[0].ZTS_EU_Description__c='testnew';
    update totList;
    delete totList;
    Test.stopTest();
    }
    
  
}