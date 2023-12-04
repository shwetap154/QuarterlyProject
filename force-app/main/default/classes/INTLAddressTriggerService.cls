/**
 * @description       : All Dispatch Trigger Logic for Address object.
 * @author            : Art Smorodin @ Slalom
 * @group             : 
 * @last modified on  : 04-13-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                           Modification
 * 1.0   03-23-2014   Ketan Prakash Singh @ Deloitte   Initial Version
 * 1.1   02-17-2020   Art Smorodin @ Slalom            Moved to Service Class
 * 1.2   04-11-2022   Ethan Hirsch @ Zoetis            Added calls for AddressesService.unblockRelatedRefLabOnboardingCases
 * 1.3   04-13-2022   Ethan Hirsch @ Zoetis            Added calls for AddressesService.unblockRelatedRefLabOnboardingCases on insert
**/
public with sharing class INTLAddressTriggerService {

    public static void afterInsert(List<Address__c> triggerNew, Map<Id, Address__c> triggerNewMap){
    	if(UtilityService.isAddressTriggerRun()){
            ZTS_EU_Update_Address.updateAccountContactAddress(triggerNew, null, triggerNewMap,false,true);
        }
        
        AddressesService.unblockRelatedRefLabOnboardingCases(triggerNew, null);
    }

    public static void afterUpdate(List<Address__c> triggerOld, Map<Id, Address__c> triggerOldMap, List<Address__c> triggerNew, Map<Id, Address__c> triggerNewMap){
        if(UtilityService.isAddressTriggerRun()){
            ZTS_EU_Update_Address.updateAccountContactAddress(triggerNew, triggerOldMap, triggerNewMap,true,false);
        }

        AddressesService.unblockRelatedRefLabOnboardingCases(triggerNew, triggerOldMap);
    }

    public static void beforeInsert(List<Address__c> triggerNew){
        List<Address__c> AddinsertList = new List<Address__c>();
        for(Address__c Address : triggerNew){
                AddinsertList.add(Address);  
        }
        ZTS_Account_Utility.populateCity(AddinsertList);
       	// ZTS_Account_Utility.populateCity(Trigger.new);    //sai
    }

    public static void beforeUpdate(List<Address__c> triggerOld, Map<Id, Address__c> triggerOldMap, List<Address__c> triggerNew, Map<Id, Address__c> triggerNewMap){
        List<Address__c> AddList = new List<Address__c>();
        for(Address__c Add : triggerNew){
            if(triggerNewMap.get(Add.id).ZTS_EU_City_Country__c != triggerOldMap.get(Add.id).ZTS_EU_City_Country__c){  AddList.add(Add);
            } 
        }
        ZTS_Account_Utility.populateCity(AddList);
        
     	/*  for(Integer i=0; i<trigger.new.size() ;i++){
             if(trigger.new[i].ZTS_EU_City_Country__c != trigger.old[i].ZTS_EU_City_Country__c){ 
                ZTS_Account_Utility.populateCity(Trigger.new);
             }
		} */	
    }
}