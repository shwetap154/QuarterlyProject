/****************************************************************************************************************************************** 
 * Trigger Name : AccountProductPotentialTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Account_Product_Potential__c object.
 * Created By   : Slalom(Allister McKenzie) 
 * Created Date : 24th November, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie            11/24/2020         Created 
*****************************************************************************************************************************************/
public with sharing class AccountProductPotentialTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {

    //Field used for Account segmentation logic
    private Schema.sObjectField marketField = ZTS_EU_Account_Product_Potential__c.Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) {
        //Filter triggerNew List for INTL accounts 
        List<ZTS_EU_Account_Product_Potential__c> IntlAccProdPotProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlAccProdPotProcess.isEmpty()) 
            INTLAccountPotentialProductService.beforeInsert(IntlAccProdPotProcess);
    }

    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        //Filter triggerOld List for INTL accounts 
        List<ZTS_EU_Account_Product_Potential__c> IntlOldListAccProdPotProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Account_Product_Potential__c> IntlOldMapAccProdPotProcess = new Map<Id, ZTS_EU_Account_Product_Potential__c>(IntlOldListAccProdPotProcess);
        //Filter triggerNew List for INTL accounts 
        List<ZTS_EU_Account_Product_Potential__c> IntlNewListAccProdPotProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Account_Product_Potential__c> IntlNewMapAccProdPotProcess = new Map<Id, ZTS_EU_Account_Product_Potential__c>(IntlNewListAccProdPotProcess);

        if (!IntlOldListAccProdPotProcess.isEmpty() && !IntlOldMapAccProdPotProcess.isEmpty() && !IntlNewListAccProdPotProcess.isEmpty() && !IntlNewMapAccProdPotProcess.isEmpty())
            INTLAccountPotentialProductService.beforeUpdate(IntlOldListAccProdPotProcess, IntlOldMapAccProdPotProcess, IntlNewListAccProdPotProcess, IntlNewMapAccProdPotProcess);
    }

    public static void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}

    public static void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public static void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public static void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}

    public static void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public override Boolean isDisabled() {
        return super.isDisabled();
    }

    public override Boolean isFirstTime() { 
        return super.isFirstTime(); 
    }

    public override List<String> getTriggerContextsForRecursion() { 
        return super.getTriggerContextsForRecursion(); 
    }

    public static void setBypassField(Schema.SObjectField bypassField) {}
    
}