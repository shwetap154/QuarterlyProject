/**
Trigger Name	: iDevelopConfigurations
Description	    : Trigger created as part of TPDEV-167 for the iDevelop_Configurations object. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 02-10-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	02-10-2023   Added beforeInsert & beforeUpdate trigger operations to call TriggerHandler

*/
trigger iDevelopConfigurations on iDevelop_Configuration__c (before insert, before update) {
    new iDevelopConfigurationsTriggerHandler().run();
}