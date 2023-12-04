/****************************************************************************************************************************************** 
 * Trigger Name : MarketEnableTrigger
 * Description  : All Trigger Logic for Market__c object.
 * Created By   : Priti Kumar @Deloitte 
 * Created Date : 13th June, 2023
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------

*****************************************************************************************************************************************/
trigger MarketEnableTrigger on Market__c (after insert, after update) {
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        MarketEnableTriggerHandler.insertRebateAmount(Trigger.new, Trigger.oldMap, Trigger.isInsert);
    }      
}