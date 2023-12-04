/****************************************************************************************************************************************** 
 * Trigger Name : AttachmentTriggerHandler
 * Description  : All Dispatch Trigger Logic for Attachment object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 17th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/17/2020          Created 
*****************************************************************************************************************************************/
public with sharing class AttachmentTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Attachment segmentation logic
    private Schema.sObjectField parentField = Attachment.OwnerId.getDescribe().getSObjectField();
    private Schema.sObjectField marketField = User.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        List<Id> userIds = new List<Id>();
        for (Attachment a : (List<Attachment>) triggerOld) userIds.add(a.OwnerId);

        List<User> users = [SELECT Id, ZTS_EU_Market__c FROM User WHERE Id IN :userIds];

        //Filter triggerOld List for US Attachments 
        List<Attachment> UsOldListAttachmentToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, parentField, users, true);
        //Filter triggerOldMap Map for US Attachments return Map
        Map<Id,Attachment> UsOldMapAttachmentToProcess = new Map<Id, Attachment>(UsOldListAttachmentToProcess);
        //Filter triggerOld List for INTL Attachments 
        List<Attachment> IntlOldListAttachmentToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, parentField, users, false);
        //Filter triggerOldMap Map for INTL Attachments return Map
        Map<Id,Attachment> IntlOldMapAttachmentToProcess = new Map<Id, Attachment>(IntlOldListAttachmentToProcess);

        if (!UsOldListAttachmentToProcess.isEmpty() && !UsOldMapAttachmentToProcess.isEmpty()) 
            USAttachmentTriggerService.beforeDelete(UsOldListAttachmentToProcess, UsOldMapAttachmentToProcess);
        
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        List<Id> userIds = new List<Id>();
        for (Attachment a : (List<Attachment>) triggerNew)
        {
            userIds.add(a.OwnerId);
        } 

        List<User> users = [SELECT Id, ZTS_EU_Market__c FROM User WHERE Id IN :userIds];

        //Filter triggerNew List for US Attachments 
        List<Attachment> UsNewListAttachmentToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, parentField, users, true);
        //Filter triggerNewMap Map for US Attachments return Map
        Map<Id,Attachment> UsNewMapAttachmentToProcess = new Map<Id, Attachment>(UsNewListAttachmentToProcess);
        //Filter triggerNew List for INTL Attachments 
        List<Attachment> IntlNewListAttachmentToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, parentField, users, false);
        //Filter triggerNewMap Map for INTL Attachments return Map
        Map<Id,Attachment> IntlNewMapAttachmentToProcess = new Map<Id, Attachment>(IntlNewListAttachmentToProcess);

        if (!UsNewListAttachmentToProcess.isEmpty() && !UsNewMapAttachmentToProcess.isEmpty()) 
            USAttachmentTriggerService.afterInsert(UsNewListAttachmentToProcess, UsNewMapAttachmentToProcess);

    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        List<Id> userIds = new List<Id>();
        for (Attachment a : (List<Attachment>) triggerOld) userIds.add(a.OwnerId);

        List<User> users = [SELECT Id, ZTS_EU_Market__c FROM User WHERE Id IN :userIds];

        //Filter triggerOld List for US Attachments 
        List<Attachment> UsOldListAttachmentToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, parentField, users, true);
        //Filter triggerOldMap Map for US Attachments return Map
        Map<Id,Attachment> UsOldMapAttachmentToProcess = new Map<Id, Attachment>(UsOldListAttachmentToProcess);
        //Filter triggerNew List for US Attachments 
        List<Attachment> UsNewListAttachmentToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, parentField, users, true);
        //Filter triggerNewMap Map for US Attachments return Map
        Map<Id,Attachment> UsNewMapAttachmentToProcess = new Map<Id, Attachment>(UsNewListAttachmentToProcess);

        //Filter triggerOld List for INTL Attachments 
        List<Attachment> IntlOldListAttachmentToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, parentField, users, false);
        //Filter triggerOldMap Map for INTL Attachments return Map
        Map<Id,Attachment> IntlOldMapAttachmentToProcess = new Map<Id, Attachment>(IntlOldListAttachmentToProcess);
        //Filter triggerNew List for INTL Attachments 
        List<Attachment> IntlNewListAttachmentToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, parentField, users, false);
        //Filter triggerNewMap Map for INTL Attachments return Map
        Map<Id,Attachment> IntlNewMapAttachmentToProcess = new Map<Id, Attachment>(IntlNewListAttachmentToProcess);

        if (!UsOldListAttachmentToProcess.isEmpty() && !UsOldMapAttachmentToProcess.isEmpty()) 
            USAttachmentTriggerService.afterUpdate(UsOldListAttachmentToProcess, UsOldMapAttachmentToProcess, UsNewListAttachmentToProcess, UsNewMapAttachmentToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        List<Id> userIds = new List<Id>();
        for (Attachment a : (List<Attachment>) triggerOld) userIds.add(a.OwnerId);

        List<User> users = [SELECT Id, ZTS_EU_Market__c FROM User WHERE Id IN :userIds];

        //Filter triggerOld List for US Attachments 
        List<Attachment> UsOldListAttachmentToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, parentField, users, true);
        //Filter triggerOldMap Map for US Attachments return Map
        Map<Id,Attachment> UsOldMapAttachmentToProcess = new Map<Id, Attachment>(UsOldListAttachmentToProcess);
        //Filter triggerOld List for INTL Attachments 
        List<Attachment> IntlOldListAttachmentToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, parentField, users, false);
        //Filter triggerOldMap Map for INTL Attachments return Map
        Map<Id,Attachment> IntlOldMapAttachmentToProcess = new Map<Id, Attachment>(IntlOldListAttachmentToProcess);

        if (!UsOldListAttachmentToProcess.isEmpty() && !UsOldMapAttachmentToProcess.isEmpty()) 
            USAttachmentTriggerService.afterDelete(UsOldListAttachmentToProcess, UsOldMapAttachmentToProcess);

    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        List<Id> userIds = new List<Id>();
        for (Attachment a : (List<Attachment>) triggerNew) userIds.add(a.OwnerId);

        List<User> users = [SELECT Id, ZTS_EU_Market__c FROM User WHERE Id IN :userIds];

        //Filter triggerNew List for US Attachments 
        List<Attachment> UsNewListAttachmentToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, parentField, users, true);
        //Filter triggerNewMap Map for US Attachments return Map
        Map<Id,Attachment> UsNewMapAttachmentToProcess = new Map<Id, Attachment>(UsNewListAttachmentToProcess);
        //Filter triggerNew List for INTL Attachments 
        List<Attachment> IntlNewListAttachmentToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, parentField, users, false);
        //Filter triggerNewMap Map for INTL Attachments return Map
        Map<Id,Attachment> IntlNewMapAttachmentToProcess = new Map<Id, Attachment>(IntlNewListAttachmentToProcess);

        if (!UsNewListAttachmentToProcess.isEmpty() && !UsNewMapAttachmentToProcess.isEmpty()) 
            USAttachmentTriggerService.afterUndelete(UsNewListAttachmentToProcess, UsNewMapAttachmentToProcess);
    }
}