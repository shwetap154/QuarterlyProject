/****************************************************************************************************************************************** 
 * Trigger Name : INTLZTS_US_ExpensesTriggerService
 * Description  : Service class to handle ZTS_US_Expenses__c trigger logic  
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman			02/11/2020		Consolidated trigger logic in service class
 * Added below triggers:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Trigger Name   : ZTS_US_Update_Expense_Record
 * Description    : This trigger is used to update the Expense object with the following fields after insert & after update
                        1. Cost Center
                        2. Project Code
                        3. Sub Account
                    Theese values are fetched by querying the user record of the user who created the expense. 
 * Created By   : Deloitte Consulting
 * Created Date : May 1st, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sameep Agrawal           05/01/2014          Created 
*****************************************************************************************************************************************/
public class INTLZTS_US_ExpensesTriggerService 
{
    public static void beforeDelete(List<ZTS_US_Expenses__c> triggerOld, Map<Id, ZTS_US_Expenses__c> triggerOldMap) 
    {
        ZTS_US_Class_Expense_Trigger_Helper.deleteExpenseRecord(triggerOld);
    }
    
    public static void afterInsert(List<ZTS_US_Expenses__c> triggerNew, Map<Id, ZTS_US_Expenses__c> triggerNewMap)
    {
        ZTS_US_Class_Expense_Trigger_Helper.processExpenseRecord(triggerNew,triggerNewMap); 
        ZTS_US_CustomEvents_Utils.createEntitySubscriptionForExpense(triggerNew);
	}
    
    public static void afterUpdate(List<ZTS_US_Expenses__c> triggerOld, Map<Id, ZTS_US_Expenses__c> triggerOldMap, List<ZTS_US_Expenses__c> triggerNew, Map<Id, ZTS_US_Expenses__c> triggerNewMap)
    {
        ZTS_US_CustomEvents_Utils.updateEntitySubscriptionForExpense(triggerNew, triggerOldMap);
        ZTS_US_Class_Expense_Trigger_Helper.createFeedItem(triggerNew, triggerOldMap);
    }
}