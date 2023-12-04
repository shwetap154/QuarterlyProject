/**
* File Name     :  ProductDescriptionTrigger
* @description  :  Trigger for Product_Description__c object.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group.
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0	  2/27/2020     Cesar Sandrigo @ ATG	Created the trigger.
*/
trigger ProductDescriptionTrigger on Product_Description__c (after insert, after update) {

    ProductDescriptionTriggerHandler handler = new ProductDescriptionTriggerHandler();

    if (Trigger.isInsert && Trigger.isAfter) {
        handler.handleAfterInsert(Trigger.new);
    }
    else if (Trigger.isUpdate && Trigger.isAfter) {
        handler.handleAfterUpdate(Trigger.new);
    }
}