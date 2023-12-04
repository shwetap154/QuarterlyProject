/**
* File Name     :  FlexibleGroupItemTrigger
* @description  :  Trigger for the Flexible Group Item object
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/19/2019		Cesar Sandrigo @ ATG     Created the Class. Call the handler on before insert to associate the record to parent Flexible Group and SAP Material.
*/
trigger FlexibleGroupItemTrigger on Flexible_Group_Item__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        FlexibleGroupItemTriggerHandler.handleBeforeInsert(Trigger.new);
    }

}