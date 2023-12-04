/**
 * @description       : All Dispatch Trigger Logic for Address object.
 *                      Updates Address fields on Account whenever the Primary Address is changed 
 *                      or existing Primary Address is modified.
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
public with sharing class USAddressTriggerService {

    public static void afterInsert(List<Address__c> triggerNew, Map<Id, Address__c> triggerNewMap){
        //if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_AddressUpdateOnAccount'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        //update account address on creation of primary address record
        ZTS_addrUpdateOnAccount.updateAccOnPrimAddrCreation(triggerNew,triggerNewMap);
        AddressesService.unblockRelatedRefLabOnboardingCases(triggerNew, null);

        //Code below depends on FieldAware AppExchange package. Waiting for decision to move it to INTL
        //Keep commented out until such decision is reached 
        // Art Smorodin Slalom 02/17/2020
        /*  if(FAW.shouldIRun.canIRunLocationImplementationTrigger()) {
            list < FAW__FA_ClientFieldMapping__c > fmList = new list < FAW__FA_ClientFieldMapping__c > ([select FAW__ClientFieldName__c, FAW__ClientObjectName__c, FAW__FAFieldName__c, FAW__FAObjectName__c, FAW__IsActive__c from FAW__FA_ClientFieldMapping__c where FAW__IsActive__c = : true]);
            map<string,string> addressMapping = new map<string,string>();
            for(FAW__FA_ClientFieldMapping__c m:fmList)
            {
                if(m.FAW__FAObjectName__c == 'Location__c' && m.FAW__IsActive__c && m.FAW__ClientObjectName__c == 'Address__c'){
                    addressMapping.put(m.FAW__FAFieldName__c,m.FAW__ClientFieldName__c);
                } 
            }
            
            list<FAW__FA_Location__c> locations = new list<FAW__FA_Location__c>();
            
            for(Address__c a:triggerNew)
            {
                system.debug('a.ZTS_US_Source_Account_Number__c '+a.ZTS_US_Source_Account_Number__c);
                system.debug('a.FA_Customer_UUID__c '+a.FA_Customer_UUID__c);
                if((a.ZTS_EU_Address_Type__c == 'Ship Address' || a.ZTS_EU_Address_Type__c == 'Bill/Ship Address' ) && a.ZTS_US_Source_Account_Number__c != null && a.FA_Customer_UUID__c != null && a.FA_Customer_UUID__c != '')  
                {
                    system.debug('processing ');
                    FAW__FA_Location__c t = new FAW__FA_Location__c();
                    t.FAW__IsCustom__c = true;
                    if(a.Name!= null)
                        t.name = a.Name; 
                    t.FAW__clientObjectId__c = a.id;
                    if(a.FA_Location_UUID__c != null)
                        t.FAW__UUID__c = a.FA_Location_UUID__c;
                    for(string fAFieldName:addressMapping.keySet())
                    {
                        String sFFieldName = addressMapping.get(fAFieldName);
                        t.put(fAFieldName,a.get(sFFieldName));
                    }
                    t.FAW__isReady__c = true;
                    locations.add(t);                  
                    
                }               
            }  
            if(locations != null && locations.size() >0 )
            insert locations;
        }   */
    }

    public static void afterUpdate(List<Address__c> triggerOld, Map<Id, Address__c> triggerOldMap, List<Address__c> triggerNew, Map<Id, Address__c> triggerNewMap){
        //if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_AddressUpdateOnAccount'))) return; // by pass trigger logic according to isActive checkbox in custom setting            
        //update account address on modification of primary address record
        ZTS_addrUpdateOnAccount.updateAccOnPrimAddrModification(triggerNew,triggerOldMap,triggerNewMap);
        AddressesService.unblockRelatedRefLabOnboardingCases(triggerNew, triggerOldMap);
    }

    public static void beforeInsert(List<Address__c> triggerNew){

        //Code below depends on FieldAware AppExchange package. Waiting for decision to move it to INTL
        //Keep commented out until such decision is reached 
        // Art Smorodin Slalom 02/17/2020

        /*  map<string,string> addAcctMap = new map<string,string>();  
        list<string> accountIDs = new list<string>(); 
        
        for(Address__c ad:triggerNew){
            accountIDs.add(ad.ZTS_EU_Account__c);
        }  
        
        list<account> act = [select FAW_UUID__c from account where id in :accountIDs AND ZTS_EU_Market__c = 'United States'];  
        if(act.size() > 0){
            for(account a: act){
                if(a.FAW_UUID__c != null) addAcctMap.put(a.id,a.FAW_UUID__c); 
            }
        }
            
        for(Address__c add:triggerNew){
            if(addAcctMap.get(add.ZTS_EU_Account__c) != null) add.FA_Customer_UUID__c = addAcctMap.get(add.ZTS_EU_Account__c);    
        }   */
    }

    public static void beforeUpdate(List<Address__c> triggerOld, Map<Id, Address__c> triggerOldMap, List<Address__c> triggerNew, Map<Id, Address__c> triggerNewMap){

        //Code below depends on FieldAware AppExchange package. Waiting for decision to move it to INTL
        //Keep commented out until such decision is reached 
        // Art Smorodin Slalom 02/17/2020
        
        /*  map<string,string> addAcctMap = new map<string,string>();  
        list<string> accountIDs = new list<string>(); 
        
        for(Address__c ad:triggerNew){
            accountIDs.add(ad.ZTS_EU_Account__c);
        }  
        
        list<account> act = [select FAW_UUID__c from account where id in :accountIDs AND ZTS_EU_Market__c = 'United States'];  
        if(act.size() > 0){
            for(account a: act){
                if(a.FAW_UUID__c != null) addAcctMap.put(a.id,a.FAW_UUID__c); 
            }
        }
            
        for(Address__c add:triggerNew){
            if(addAcctMap.get(add.ZTS_EU_Account__c) != null) add.FA_Customer_UUID__c = addAcctMap.get(add.ZTS_EU_Account__c);    
        }   */
    }
}