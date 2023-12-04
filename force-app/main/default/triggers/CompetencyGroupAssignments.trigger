/**
Trigger Name	: CompetencyGroupAssignments
Description	    : Trigger created as part of TPDEV-533 for the Competency_Group_Assignment__c object. 
Created By		: Sibin Kuriakose
Created Date	: 04-06-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Sibin Kuriakose			04-06-2023   Added beforeInsert operations to call TriggerHandler

*/
trigger CompetencyGroupAssignments on Competency_Group_Assignment__c (before insert) {
	new CompetencyGroupAssignmentsHandler().run();
}