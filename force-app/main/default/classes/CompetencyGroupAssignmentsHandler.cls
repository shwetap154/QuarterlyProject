/**
Class Name	    : CompetencyGroupAssignmentsHandler
Description	    : Trigger_Handler Class as part of TPDEV-533 for the Competency_Group_Assignment__c object. 
Created By		: Sibin Kuriakose
Created Date	: 04-06-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					 Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Sibin Kuriakose       	 04-06-2023   Added Methods to call Service class upon beforeInsert 
*/
public With Sharing class CompetencyGroupAssignmentsHandler extends TriggerHandler{
    /**     * @Description This methode will call service class upon Insertion of a record      
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-06-2023 
			* @param       Competency_Group_Assignment record
    */
    public override void beforeInsert() {
        CompetencyGroupAssignmentsService.competencyGroupValidations(trigger.new);        
    }
}