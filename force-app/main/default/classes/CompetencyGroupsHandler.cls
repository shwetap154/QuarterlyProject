/**
Class Name	    : CompetencyGroupsHandler
Description	    : Trigger_Handler Class as part of TPDEV-558 for the Competency_Group__c object. 
Created By		: Raut, Pranav
Created Date	: 03-28-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					 Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Raut, Pranav Krushnarao	 03-28-2023   Added Methods to call Service class upon beforeInsert & beforeUpdate
*/
public With Sharing class CompetencyGroupsHandler extends TriggerHandler {

    /*
    * @Description : This method will call service class before Insertion of a Competency Group record      
    * @Author      : Raut, Pranav @ Zoetis Inc | 03-28-2023 
    * @param       : Competency Group record
    */
        public override void beforeInsert() {
            CompetencyGroupsService.preventDuplicateCompetencyGroup(trigger.new, null);
        }
        
      /*
    * @Description : This method will call service class before Update of a Competency Group record      
    * @Author      : Raut, Pranav @ Zoetis Inc | 04-10-2023 
    * @param       : Competency Group record
    */
        public override void beforeUpdate() {
            CompetencyGroupsService.preventDuplicateCompetencyGroup(trigger.new, (Map<Id,Competency_Group__c>)trigger.oldMap);
            CompetencyGroupsService.preventDuplicateCompGroupForCompModel((Map<Id,Competency_Group__c>)trigger.NewMap, (Map<Id,Competency_Group__c>)trigger.oldMap);
        }
    
    }