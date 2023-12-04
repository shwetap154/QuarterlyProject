/*
Trigger Name	: CompetencyGroups
Description	    : Trigger created as part of TPDEV-558 for the Benchmark object. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 03-28-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	03-28-2023   Added beforeInsert, beforeUpdate trigger operations to call TriggerHandler

*/
trigger CompetencyGroups on Competency_Group__c (before insert,before Update) {
    new CompetencyGroupsHandler().run();
}