/****************************************************************************************************************************************** 
 * Trigger Name : ZTSEUBrickToTerritoryTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_GL_BrickToTerr__c object.
 * Created By   : Slalom(Allister McKenzie) 
 * Created Date : 3rd December, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie            12/03/2020         Created 
*****************************************************************************************************************************************/
public with sharing class ZTSEUBrickToTerritoryTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {
    //Field used for Account segmentation logic
    private Schema.sObjectField marketField = ZTS_GL_BrickToTerr__c.ZTS_EU_Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) {}

    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) { }
    
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        //Filter triggerNew List for INTL accounts 
        List<ZTS_GL_BrickToTerr__c> IntlNewListBrickToTerrToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,ZTS_GL_BrickToTerr__c> IntlNewMapBrickToTerrToProcess = new Map<Id, ZTS_GL_BrickToTerr__c>(IntlNewListBrickToTerrToProcess);

        if (!IntlNewListBrickToTerrToProcess.isEmpty() && !IntlNewMapBrickToTerrToProcess.isEmpty())
            INTLBrickToTerritoryTriggerHandlerServ.afterUpdate(IntlNewListBrickToTerrToProcess, IntlNewMapBrickToTerrToProcess);
    }
    
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}

    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public override Boolean isDisabled() {
        return super.isDisabled();
    }

    /*public override Boolean isFirstTime() { 
        return super.isFirstTime(); 
    }

    public override List<String> getTriggerContextsForRecursion() { 
        return super.getTriggerContextsForRecursion(); 
    }

    public static void setBypassField(Schema.SObjectField bypassField) {}*/
}