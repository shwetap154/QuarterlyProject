/****************************************************************************************************************************************** 
 * Trigger Name : FormTriggerHandler
 * Description  : All Dispatch Trigger Logic for Form object.
 * Created By   : Aritra (Cognizant)
 * Created Date : 28th Oct, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra Chakraborty      10/28/2021          Created 
******************************************************************************************************************************************/
public with sharing class FormTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{

    public void beforeInsert(List<SObject> triggerNew)
    {
        FormTriggerService.beforeInsert(triggerNew);
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {       
        FormTriggerService.beforeUpdate(triggerOld,triggerOldMap,triggerNew,triggerNewMap);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}