/**
* File Name     :  CPQ_OrderTrigger
* @description  :  Trigger for SFDC Order object. CPQ_ preffix was added since there was already a trigger called OrderTrigger for custom Order object.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/19/2019		Cesar Sandrigo @ ATG     Created the Class. Call the handler on after update create all the SAP Contract Texts.
*/
trigger CPQ_OrderTrigger on Order (before update, after update, before insert) {
    // TO-DO : Incorporate Trigger Handler Framework to this Trigger & Handlers
    // TO-DO : While incorporating Handler FW, merge Alpha Order trigger with this trigger

    // the following code has been added to filter out Distributor Orders from this trigger 
	// so that we don't needlessly run unrelated CPQ code.
	// - Morgan Marchese 8/15/2021
    Id distributorOrderRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
    /*
     *Code section added by Sourav Mitra @ CTS to make sure Orders for SAP Staging record type
	 *doesn't fire the trigger as these orders will not be having quotes
	 *TPDEV-1999
    */
    Id sapStagingOrderRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('SAP_Staging').getRecordTypeId();
    List<Order> newList = new List<Order>();
    for(Order record : Trigger.new){
        // Mode of Transport is a Distributor specific field. Fix in Hypercare.
        if(record.RecordTypeId != distributorOrderRTId && record.RecordTypeId != sapStagingOrderRTId ){
        	newList.add(record);    
        }
    }

    // Before update
    if (Trigger.isUpdate && Trigger.isBefore) {
        CPQ_OrderTriggerHandler.handleBeforeUpdate(newList, Trigger.oldMap);
    }
    // After update
    else if (Trigger.isUpdate && Trigger.isAfter) {
        CPQ_OrderTriggerHandler.handleAfterUpdate(newList, Trigger.oldMap);
    }
    // Before Insert
    else if (Trigger.isInsert && Trigger.isBefore) {
        CPQ_OrderTriggerHandler.handleBeforeInsert(newList);
    }
}