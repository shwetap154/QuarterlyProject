/**
* File Name     :  CPQ_PreInstallCheckListTrigger
* @description  :  Trigger for SFDC PreInstallCheckList__c object.
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/19/2019		Cesar Sandrigo @ ATG     Created the Class. Call the handler on after update create all the SAP Contract Texts.
*/
trigger CPQ_PreInstallCheckListTrigger on PreInstallCheckList__c (before update, after update, before insert) {

    // Before update
    if (Trigger.isUpdate && Trigger.isBefore) {
        CPQ_PreInstallCheckListTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    
    }
    
    /*
    
    // After update
    else if (Trigger.isUpdate && Trigger.isAfter) {
        CPQ_PreInstallCheckListTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    // Before Insert
    else if (Trigger.isInsert && Trigger.isBefore) {
        CPQ_PreInstallCheckListTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    
    */
}