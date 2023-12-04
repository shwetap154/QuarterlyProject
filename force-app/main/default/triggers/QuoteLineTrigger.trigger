/**
* File Name     :  QuoteLineTrigger
* @description  :  Trigger for CPQ SBQQ__QuoteLine__c object.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/24         Cesar Sandrigo @ ATG     Created the trigger.
* 2.0     1/10/20      Cory Bartholomew @ ATG   Updated to remove deal text from quote after QL deletion
*/
trigger QuoteLineTrigger on SBQQ__QuoteLine__c(before insert, after insert, before update, after update, before delete, after delete) {
  QuoteLineTriggerHandler handler = new QuoteLineTriggerHandler(Trigger.new, Trigger.oldMap);

  // Before insert
  if (Trigger.IsInsert && Trigger.isBefore) {
    handler.handleBeforeInsert();
  } else if (Trigger.IsInsert && Trigger.IsAfter) {
    handler.handleAfterInsert();
  } else if (Trigger.IsUpdate && Trigger.isBefore) {
    // Before update
    handler.handleBeforeUpdate();
  } else if (Trigger.IsUpdate && Trigger.IsAfter) {
    handler.handleAfterUpdate();
  } else if (Trigger.IsDelete && Trigger.isBefore) {
    // Before delete
    handler.handleBeforeDelete();
  } else if (Trigger.IsDelete && Trigger.IsAfter) {
    // After delete
    handler.handleAfterDelete();
  }
}