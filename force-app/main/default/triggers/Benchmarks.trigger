/*
Trigger Name	: Benchmarks
Description	    : Trigger created as part of TPDEV-422 for the Benchmark object. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 02-28-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	02-28-2023   Added beforeUpdate trigger operations to call TriggerHandler

*/
trigger Benchmarks on Benchmark__c (before update) {
    new BenchmarksTriggerHandler().run();
}