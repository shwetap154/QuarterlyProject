/* Salesforce CPQ Quote Trigger
Implemented by ATG:  Cory.Bartholomew@atginfo.com
Created 5/3/2019
Last Updated 5/3/2019
*/

trigger Quote_Trigger on SBQQ__Quote__c (before insert, after insert, before update, after update) {

	QuoteTriggerHandler handler = new QuoteTriggerHandler(Trigger.New, Trigger.NewMap, Trigger.oldMap);

	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
			handler.beforeInsert();
		}
	}

	if(Trigger.isAfter){
		if(Trigger.isInsert) {
			handler.afterInsert();
		}
	}

	if(Trigger.isAfter){
		if(Trigger.isUpdate) {
			handler.afterUpdate();
		}
	}

	// Before update
	if (Trigger.isBefore && Trigger.isUpdate) {

		// Update 'Vistex pricing in sync' flag
		handler.beforeUpdate();		
	}
}