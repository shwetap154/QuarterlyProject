/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_US_VMIPSCaseAccountTrigger
 * Description  : This Trigger assigns tasks to Account Teams associated to Account for VMIPS Case Account creation.
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 08 April 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   04/08/2014           Created 
 * Mayank                  04/27/2014           Modified
 * Akanksha                08/08/2014           Modified
*****************************************************************************************************************************************/
trigger ZTS_US_VMIPSCaseAccountTrigger on ZTS_US_VMIPS_Case_Account__c (after insert) {    
    if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_VMIPSCaseAccountTrigger'))) return; // by pass trigger logic according to isActive checkbox in custom setting
    
    Map<ID, ZTS_US_VMIPS_Case__c> parentOpps = new Map<ID, ZTS_US_VMIPS_Case__c>();
  List<Id> listIds = new List<Id>();

  for (ZTS_US_VMIPS_Case_Account__c childObj : Trigger.new) {
    listIds.add(childObj.ZTS_US_VMIPS_Case_Number__c);
  }

  
  parentOpps = new Map<Id, ZTS_US_VMIPS_Case__c>([SELECT id,ZTS_US_Vmips_Account__c,(SELECT  ZTS_US_Account__c FROM VMIPS_Cases_Accounts__r ) FROM ZTS_US_VMIPS_Case__c WHERE ID IN :listIds]);
    //List<ZTS_US_VMIPS_Case__c> vmipscases = new List<ZTS_US_VMIPS_Case__c>();
  for (ZTS_US_VMIPS_Case_Account__c quote: Trigger.new){
     ZTS_US_VMIPS_Case__c myParentOpp = parentOpps.get(quote.ZTS_US_VMIPS_Case_Number__c);
     System.debug('****vmips case****'+myParentOpp);
     myParentOpp.ZTS_US_Vmips_Account__c = quote.ZTS_US_Account__c;
     //vmipscases.add(myParentOpp);
     System.debug('***Case Account****'+quote);
  }

  update parentOpps.values();
    
}