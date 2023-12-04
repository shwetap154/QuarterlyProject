/*******************************************************************************************************************************************
* File Name     :  CheckRecursiveTriggerTest
* Description   :           
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Ketan             Created the Class.

********************************************************************************************************************************************/
@isTest
public class  CheckRecursiveTriggerTest {
    static testMethod void validate_CheckRecursiveTrigger () {
        CheckRecursiveTrigger chkRecTrigg = new CheckRecursiveTrigger ();
        Test.startTest();
        CheckRecursiveTrigger.runOnce();
        Test.stopTest();
    
    }

}