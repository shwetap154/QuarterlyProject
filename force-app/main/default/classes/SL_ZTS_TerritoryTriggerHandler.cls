/**
* @ClassName    : SL_ZTS_US_TerritoryTriggerHandler 
* @JIRATicket   : ZETM-24
* @CreatedOn    : 6th Dec, 2018
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Handler for the trigger SL_ZTS_US_Territory.
*/
public with sharing class SL_ZTS_TerritoryTriggerHandler 
{
	/***********
	  * Method name  : onBeforeDelete
	  * Description  : this method will validate the Parent territory if tried to delete the territory record.
	  * Return Type  : None.
	  * Parameters   : trigger parameters.
	  ***********/
	public void onBeforeDelete(List<ZTS_EU_Territory__c> lstTerritoryOld) 
	{	
		Set<Id> setParentTerritoryId = new Set<Id>();

		for(ZTS_EU_Territory__c objChildPerritory :  [Select Id, ZTS_EU_Parent_Territory__c From ZTS_EU_Territory__c Where ZTS_EU_Parent_Territory__c IN: lstTerritoryOld AND ZTS_EU_Market__c != 'United States'])
			setParentTerritoryId.add(objChildPerritory.ZTS_EU_Parent_Territory__c);

		for(ZTS_EU_Position__c objUT : [Select Id, ZTS_EU_Territory__c From ZTS_EU_Position__c Where ZTS_EU_Territory__c IN: lstTerritoryOld])
			setParentTerritoryId.add(objUT.ZTS_EU_Territory__c);

		for(ZTS_AccountTerritory__c objAT : [Select Id, ZTS_EU_Territory__c From ZTS_AccountTerritory__c Where ZTS_EU_Territory__c IN: lstTerritoryOld])
			setParentTerritoryId.add(objAT.ZTS_EU_Territory__c);

		for(ZTS_EU_Territory__c objTerritory : lstTerritoryOld)
		{
			if(setParentTerritoryId.contains(objTerritory.Id))
				objTerritory.addError('This record still has related Position, Account and/or Child Territories. Please delete all related records before deleting this Territory.');
		}
	}
}