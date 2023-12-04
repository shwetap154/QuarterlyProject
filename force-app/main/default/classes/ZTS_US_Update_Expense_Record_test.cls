/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Update_Expense_Record_test
* Description   :   Test class created for 'ZTS_US_Update_Expense_Record' class        
* @author       :  Accenture Services
* Modification Log
===================================================================================================
* Ver.    Date                     Author                     Modification
---------------------------------------------------------------------------------------------------
* 1.0     03-08-2015         Priya Krishnamurthy             Created the Class.
*****************************************************************************************************************************************/

@istest
public class ZTS_US_Update_Expense_Record_test {
    public testMethod static void createTestData(){

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            ZTS_Events__c eve = new ZTS_Events__c();
            eve.ZTS_US_Name__c = 'test';
            eve.ZTS_US_Event_Category__c = 'Farmer Event';
            eve.ZTS_US_Start_Date__c = date.valueOf('2015-11-6T00:00:00Z');
            eve.ZTS_US_End_Date__c = date.valueOf('2015-11-7T00:00:00Z');
            eve.ZTS_US_Number_of_Attendees__c = 2;
           // eve.ZTS_US_Purpose_Agenda__c = 'test purpose';
            eve.Purpose_Agenda__c = 'test purpose';
            eve.ZTS_US_Location__c = 'Test Location';
            eve.ZTS_EU_Market__c = 'United States';
            eve.ZTS_US_Type__c = 'Advisory Board';
            insert eve;
            
            ZTS_US_Expenses__c e = new ZTS_US_Expenses__c();
            
            list<ZTS_US_Expenses__c> listexp = new list<ZTS_US_Expenses__c>();
            e.ZTS_US_EventValue__c = String.ValueOf(eve.id).substring(0,15);
            e.ZTS_US_Events__c= eve.id;
            e.ZTS_US_Expense_Date__c = eve.ZTS_US_Start_Date__c.date();
            e.ZTS_US_Type__c = 'Meals';
            e.ZTS_US_Unit__c = 2;
            e.ZTS_US_Cost__c = 20;
            e.ZTS_US_Payment_Method__c = 'Check';
            e.ZTS_US_Event_Category__c = 'Farmer Event';
           
            insert e;
        }
        //listexp.add(e);
        
        //ZTS_US_CustomEvents_Utils.createEntitySubscriptionForExpense(listexp);
        //ZTS_US_Class_Expense_Trigger_Helper.deleteExpenseRecord(listexp);
    }
}