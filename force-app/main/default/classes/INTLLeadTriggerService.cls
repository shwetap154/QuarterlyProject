/****************************************************************************************************************************************** 
 * Trigger Name : INTLLeadTriggerService
 * Description  : All INTL Trigger Logic for Lead object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 28th May, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           05/28/2020          Created 
*****************************************************************************************************************************************/
public with sharing class INTLLeadTriggerService 
{
    public static void beforeInsert(List<Lead> triggerNew) 
    {
        //TriggerHelperD.CheckToken(triggerNew, 'Lead', null);       
        //TriggerHelperD.checkCommit(triggerNew);
    }
    public static void beforeUpdate(List<Lead> triggerOld, Map<Id, Lead> triggerOldMap, List<Lead> triggerNew, Map<Id, Lead> triggerNewMap) 
    { 
        //TriggerHelperD.CheckToken(triggerNew, 'Lead', triggerOldMap);       
        //TriggerHelperD.checkCommit(triggerNew);
    }
    public static void afterInsert(List<Lead> triggerNew, Map<Id, Lead> triggerNewMap) 
    {
        //TriggerHelperD.checkCommit2(triggerNew, 'Lead', null);     
    }
    public static void afterUpdate(List<Lead> triggerOld, Map<Id, Lead> triggerOldMap, List<Lead> triggerNew, Map<Id, Lead> triggerNewMap) 
    {
        //TriggerHelperD.checkCommit2(triggerNew, 'Lead', triggerOldMap);   
        //TriggerHelperD.convertationForLead(triggerNew, triggerOldMap);  
    }
}