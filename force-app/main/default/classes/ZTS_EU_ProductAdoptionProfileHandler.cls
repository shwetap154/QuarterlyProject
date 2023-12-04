public with sharing class ZTS_EU_ProductAdoptionProfileHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  {
    
    private Schema.sObjectField marketField = ZTS_EU_Product_Adoption_Profile__c.ZTS_EU_Market_from_Parent__c.getDescribe().getSObjectField();


    public void beforeInsert(List<SObject> triggerNew){
         
        List<ZTS_EU_Product_Adoption_Profile__c> UsNewListProdAdopProfileToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true); 
        List<ZTS_EU_Product_Adoption_Profile__c> IntlNewListProdAdopProfileToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlNewListProdAdopProfileToProcess.isEmpty()) INTZTS_EU_ProductAdoptionProfileService.beforeInsert(IntlNewListProdAdopProfileToProcess);
    }
    
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        List<ZTS_EU_Product_Adoption_Profile__c> UsNewListProdAdopProfileToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true); 
        List<ZTS_EU_Product_Adoption_Profile__c> IntlNewListProdAdopProfileToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlNewListProdAdopProfileToProcess.isEmpty()) INTZTS_EU_ProductAdoptionProfileService.beforeUpdate(IntlNewListProdAdopProfileToProcess);
        
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        List<ZTS_EU_Product_Adoption_Profile__c> UsNewListProdAdopProfileToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true); 
        List<ZTS_EU_Product_Adoption_Profile__c> IntlNewListProdAdopProfileToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlNewListProdAdopProfileToProcess.isEmpty()) INTZTS_EU_ProductAdoptionProfileService.afterInsert(IntlNewListProdAdopProfileToProcess);
        
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        List<ZTS_EU_Product_Adoption_Profile__c> UsNewListProdAdopProfileToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true); 
        List<ZTS_EU_Product_Adoption_Profile__c> IntlNewListProdAdopProfileToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlNewListProdAdopProfileToProcess.isEmpty()) INTZTS_EU_ProductAdoptionProfileService.afterUpdate(IntlNewListProdAdopProfileToProcess);
        
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}