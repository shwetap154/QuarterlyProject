/****************************************************************************************************************************************** 
 * Class Name   : ZTS_Animal_Count_PotentialTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_Animal_Count_Potential__c object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 29 June, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           06/29/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_Animal_Count_PotentialTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for ZTS_Animal_Count_Potentialation logic
    private Schema.sObjectField marketField = ZTS_Animal_Count_Potential__c.ZTS_EU_Market_from_Parent__c.getDescribe().getSObjectField();
    	
    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US ZTS_Animal_Count_Potential 
        List<ZTS_Animal_Count_Potential__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL ZTS_Animal_Count_Potential 
        List<ZTS_Animal_Count_Potential__c> IntlAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!UsNewListAccToProcess.isEmpty()) USZTS_Animal_Count_PotentTriggerService.beforeInsert(UsNewListAccToProcess);        
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    { 
        //Filter triggerOld List for US ZTS_Animal_Count_Potential 
        List<ZTS_Animal_Count_Potential__c> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US ZTS_Animal_Count_Potential return Map
        Map<Id,ZTS_Animal_Count_Potential__c> UsOldMapAccToProcess = new Map<Id, ZTS_Animal_Count_Potential__c>(UsOldListAccToProcess);
        //Filter triggerNew List for US ZTS_Animal_Count_Potential 
        List<ZTS_Animal_Count_Potential__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_Animal_Count_Potential return Map
        Map<Id,ZTS_Animal_Count_Potential__c> UsNewMapAccToProcess = new Map<Id, ZTS_Animal_Count_Potential__c>(UsNewListAccToProcess);

        //Filter triggerOld List for INTL ZTS_Animal_Count_Potential 
        List<ZTS_Animal_Count_Potential__c> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL ZTS_Animal_Count_Potential return Map
        Map<Id,ZTS_Animal_Count_Potential__c> IntlOldMapAccToProcess = new Map<Id, ZTS_Animal_Count_Potential__c>(IntlOldListAccToProcess);
        //Filter triggerNew List for INTL ZTS_Animal_Count_Potential 
        List<ZTS_Animal_Count_Potential__c> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_Animal_Count_Potential return Map
        Map<Id,ZTS_Animal_Count_Potential__c> IntlNewMapAccToProcess = new Map<Id, ZTS_Animal_Count_Potential__c>(IntlNewListAccToProcess);

        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty() && !UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USZTS_Animal_Count_PotentTriggerService.beforeUpdate(UsOldListAccToProcess, UsOldMapAccToProcess, UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}