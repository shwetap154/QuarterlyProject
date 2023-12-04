/**
* File Name     :  
* @description  :  Handler class for OpportunityTrigger
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     2/12/2020		Ramiro Alvarez @ ATG     Created the Class.

**/


public with sharing class ATGOpportunityTriggerHandler {

    /**
	 * @description  Update Territory lookup on Opportunity considering opportunity Owner Territory 
    */    
    public static void updateTerritory(Map<Id,Opportunity> newMap){

        System.debug('Entering updateTerritory..'); 

        Set<Id> OwnerIds = new Set<Id> ();
        List<Opportunity> opptys = new List<Opportunity>();        
    
        for (Opportunity oppty : newMap.values()) {
            OwnerIds.add(oppty.OwnerId);
        }

        List<UserTerritory2Association> queriedTerritories = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE UserId IN : OwnerIds];
        Map<Id,Id> userTerritoryMap = new Map<Id,Id>();
        for (UserTerritory2Association queriedTerritory : queriedTerritories) {
            userTerritoryMap.put(queriedTerritory.UserId, queriedTerritory.Territory2Id);    
        }
        
        System.debug('userTerritory Map: ' + userTerritoryMap);

        for (Opportunity oppty : newMap.values()){
            if (userTerritoryMap.containsKey(oppty.OwnerId)) {
                //Opportunity opptytoUpdate = new Opportunity (Id = oppty.Id);
                //System.debug('oppty.OwnerID: ' + oppty.OwnerId + ' value of map: ' + userTerritoryMap.get(oppty.OwnerId));
                //opptytoUpdate.Territory2Id = userTerritoryMap.get(oppty.OwnerId);
                //opptys.add(opptytoUpdate);                
            }         
        }
        System.debug('Updating Opportunity Territory..');    
        update opptys;
    }
 
}