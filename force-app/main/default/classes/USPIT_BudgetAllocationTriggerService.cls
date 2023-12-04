/****************************************************************************************************************************************** 
* Class Name   : USPIT_BudgetAllocationTriggerService
* Description  : Logic for all US PIT_Budget_Allocation__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 24 July 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Mohamed Seliman (Slalom)     07/24/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public class USPIT_BudgetAllocationTriggerService 
{
    public static void beforeInsert(List<PIT_Budget_Allocation__c> triggerNew) 
    {
        PIT_BudgetAllocationTriggerHandler handler = new PIT_BudgetAllocationTriggerHandler();
		handler.onBeforeInsert(triggerNew);
    }
    
    public static void beforeUpdate(List<PIT_Budget_Allocation__c> triggerOld, Map<Id, PIT_Budget_Allocation__c> triggerOldMap, List<PIT_Budget_Allocation__c> triggerNew, Map<Id, PIT_Budget_Allocation__c> triggerNewMap) 
    {
        PIT_BudgetAllocationTriggerHandler handler = new PIT_BudgetAllocationTriggerHandler();
		handler.onBeforeUpdate(triggerNew);
    }
    
}