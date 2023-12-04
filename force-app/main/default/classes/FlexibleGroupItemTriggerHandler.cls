/**
* File Name     :  FlexibleGroupItemTriggerHandler
* @description  :  Handler class for the Flexible Group Item Trigger
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/19/2019		Cesar Sandrigo @ ATG     Created the Class. Added logic to link the Flexible Group Item 
                                                 to the parent Flexible Group and the Material.
*/
public class FlexibleGroupItemTriggerHandler {

    /***
     * @description Handles the Before Insert event.
     * @param triggerNewList List of new Flexible Group Items provided by the Trigger.
     */
    public static void handleBeforeInsert(List<Flexible_Group_Item__c> triggerNewList) {
        setFlexibleGroupAndMaterials(triggerNewList);
    }

    /***
     * @description Sets the relationships to the correspondent Flexible Group header and SAP Material.
     * @param flexibleGroupItemList List of Flexible Group Items.
     */
    public static void setFlexibleGroupAndMaterials(List<Flexible_Group_Item__c> flexibleGroupItemList) {

        Set<String> flexibleGroupNumberSet = new Set<String>();
        Set<String> materialNumberSet = new Set<String>();

        for (Flexible_Group_Item__c flexGroupItem : flexibleGroupItemList) {
            flexibleGroupNumberSet.add(flexGroupItem.Flexible_Group_Number__c);
            materialNumberSet.add(flexGroupItem.SAP_Material_Number__c);
        }

        List<Flexible_Group__c> flexibleGroupList = [SELECT Id, Flexible_Group_Number__c 
                                                     FROM Flexible_Group__c 
                                                     WHERE Flexible_Group_Number__c IN :flexibleGroupNumberSet];
                                                    
        Map<String, Id> flexibleGroupNumberIdMap = new Map<String, Id>();

        for (Flexible_Group__c flexGroup : flexibleGroupList) {
            flexibleGroupNumberIdMap.put(flexGroup.Flexible_Group_Number__c, flexGroup.Id);
        }
        
        List<SAP_Material__c> materialsList = [SELECT Id, SAP_Product_Number__c 
                                                     FROM SAP_Material__c 
                                                     WHERE SAP_Product_Number__c IN :materialNumberSet];

        Map<String, Id> materialNumberIdMap = new Map<String, Id>();

        for (SAP_Material__c material : materialsList) {
            materialNumberIdMap.put(material.SAP_Product_Number__c, material.Id);
        }

        for (Flexible_Group_Item__c flexGroupItem : flexibleGroupItemList) {
            
            if (flexibleGroupNumberIdMap.containsKey(flexGroupItem.Flexible_Group_Number__c)) {
                flexGroupItem.Flexible_Group__c = flexibleGroupNumberIdMap.get(flexGroupItem.Flexible_Group_Number__c);
            }

            if (materialNumberIdMap.containsKey(flexGroupItem.SAP_Material_Number__c)) {
                flexGroupItem.SAP_Material__c = materialNumberIdMap.get(flexGroupItem.SAP_Material_Number__c);
            }
        }
    }
}