/**
Class Name	    : BenchmarksTriggerHandler
Description	    : Trigger_Handler Class as part of TPDEV-167 for the iDevelop_Configurations object. 
Created By		: Raut, Pranav
Created Date	: 02-28-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					 Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Raut, Pranav Krushnarao	 02-28-2023   Added Methods to call Service class upon beforeUpdate
*/

public With Sharing class BenchmarksTriggerHandler extends TriggerHandler {
    
/*
* @Description : This methode will call service class upon Updation of a record      
* @Author      : Raut, Pranav @ Zoetis Inc | 02-28-2023 
* @param       : Benchmarks record
*/
    public override void beforeUpdate() {
        BenchmarksService.benchmarkMarkCompleteValidations((Map<Id,Benchmark__c>)trigger.newMap, (Map<Id,Benchmark__c>)trigger.oldMap);
    }
    
}