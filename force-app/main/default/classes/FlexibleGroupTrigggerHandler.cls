/**
* File Name     :  
* @description  :  Handler class for FlexibleGroupTriggger
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     2/20/2020		Ramiro Alvarez @ ATG     Created the Class.

**/

public with sharing class FlexibleGroupTrigggerHandler {   

     /**
	 * @description  Update FlexibleGroupItem parent relationship 
    */    
    public static void updateFlexibleGroupItemRelation(Map<Id,Flexible_Group__c> newMap){

        System.debug('Entering updateFlexibleGroupItemRelation..'); 

        Map<String,Id> flexibleGroupNumbersMap = new Map<String,Id> ();       
        Set<String> flexibleGroupNumbers = new Set<String> ();
        
        for (Flexible_Group__c flexibleGroup : newMap.values()) {
            flexibleGroupNumbersMap.put(flexibleGroup.Flexible_Group_Number__c,flexibleGroup.Id);
            flexibleGroupNumbers.add(flexibleGroup.Flexible_Group_Number__c);
        }

        List<Flexible_Group_Item__c> flexibleGroupItems = [SELECT Id, Flexible_Group_Number__c
                                                        FROM Flexible_Group_Item__c
                                                        WHERE Flexible_Group__c = null
                                                        AND Flexible_Group_Number__c IN : flexibleGroupNumbers];

        
        for (Flexible_Group_Item__c flexibleGroupItem : flexibleGroupItems){
            //System.debug('Value on Map: ' + flexibleGroupNumbersMap.get(flexibleGroupItem.Flexible_Group_Number__c));
            flexibleGroupItem.Flexible_Group__c = flexibleGroupNumbersMap.get(flexibleGroupItem.Flexible_Group_Number__c);            
        }

        System.debug('Updating flexibleGroupItemsToUpdate..' + flexibleGroupItems);

        update flexibleGroupItems;
    }
}