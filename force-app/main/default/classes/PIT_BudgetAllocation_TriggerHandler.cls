/****************************************************************************************************************************************** 
 * Class Name   : PIT_BudgetAllocation_TriggerHandler
 * Description  : All Dispatch Trigger Logic for PIT_BudgetAllocation_TriggerHandler object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 24th July, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           07/24/2020          Created 
*****************************************************************************************************************************************/
public with sharing class PIT_BudgetAllocation_TriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{

    public void beforeInsert(List<SObject> triggerNew) 
    {
    	USPIT_BudgetAllocationTriggerService.beforeInsert((List<PIT_Budget_Allocation__c>)triggerNew);    
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        USPIT_BudgetAllocationTriggerService.beforeUpdate((List<PIT_Budget_Allocation__c>)triggerOld, (Map<Id, PIT_Budget_Allocation__c>)triggerOldMap, (List<PIT_Budget_Allocation__c>)triggerNew, (Map<Id, PIT_Budget_Allocation__c>)triggerNewMap);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}