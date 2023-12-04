/*******************************************************************************************************************************************
* File Name     :  CalendarPageController_Test
* Description   :  Test class for CalendarPageController
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class CalendarPageController_Test {

static testMethod void validate_CalendarPageController () {

        CalendarPageController calPageController = new CalendarPageController();
        Test.startTest();
        PageReference pgRef;
        pgRef = calPageController.RedirectToCalendar();
        system.assertNotEquals(pgRef,null);
        Test.stopTest();
    
}


}