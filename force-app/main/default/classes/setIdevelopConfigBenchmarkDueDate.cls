/*
Class Name	    : setIdevelopConfigBenchmarkDueDate
Description	    : Schedulable class to determine Idevelop Configuration Benchmark Due Date.
Created By		: Raut, Pranav Krushnarao
Created Date	: 03-27-2023

Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	03-27-2023   Initial version of schedulable class to query Idevelop Configuration and determine their Benchmark Due Date. 
02   Raut, Pranav Krushnarao	06-05-2023   Modified the class to call the batch class to send email when Current date is same or after the (Due Date - Days To Complete)
*/

Public class setIdevelopConfigBenchmarkDueDate implements schedulable { 
    
    /**
* @description : Method to extecute this schedulable class & call batch class 'sendBenchmarkEmailNotificationBatch'.
* @author      : Raut, Pranav Krushnarao | 04-03-2023 
* @param       : SchedulableContext
*/
    Public void execute(SchedulableContext sc) {  
        Map<String, Integer> mapMonthTextToNumber = new Map<String, Integer>{'January'=> 01,'February'=> 02,'March'=> 03,'April'=> 04,'May'=> 05,'June'=> 06,'July'=> 07,'August'=> 08,'September'=> 09,'October'=> 10,'November'=> 11,'December'=> 12};
            Date benchmarkDueDate; 
        Set<String> setMarket = new Set<String>();
        Map<String,iDevelop_Configuration__c> mapMarktRoleIdevConfig = new Map<String,iDevelop_Configuration__c>();        
        Map<String,Date> mapIdevMarketRoleBenchDueDate = new Map<String,Date>();
        Map<String, iDevelop_Configuration__c> mapIdevConfigWithNoRole = new Map<String, iDevelop_Configuration__c>();        
        Map<String,Date> mapIdevWithNoRoleBenchDueDate = new Map<String,Date>();
        
        List<iDevelop_Configuration__c> lstIdevelopConfig = iDevelopConfigurationsSelector.selectAll();        
        for(iDevelop_Configuration__c objIdevConfig : lstIdevelopConfig){
            if(objIdevConfig.Due_Date_Month__c != null && objIdevConfig.Due_Date_Day__c != null){
                Integer year = System.today().year();
                Integer month = mapMonthTextToNumber.get(objIdevConfig.Due_Date_Month__c);
                Integer day = Integer.valueOf(objIdevConfig.Due_Date_Day__c);                
                Date dueDate = date.newinstance(year, month , day);               
                if(dueDate + 15 > System.today()){
                    benchmarkDueDate = dueDate;
                }
                else{
                    benchmarkDueDate = dueDate.addYears(1);
                }                    
                
                //Current date is same or after the due date - days to complete (System.today() >= benchmarkDueDate-Days_to_Complete__c)
                if(System.today() >= (benchmarkDueDate-Integer.valueOf(objIdevConfig.Days_to_Complete__c))){
                    setMarket.add(objIdevConfig.Market__c);
                    if(objIdevConfig.Market__c != null && objIdevConfig.Role__c != null){
                        mapMarktRoleIdevConfig.put((objIdevConfig.Market__c+objIdevConfig.Role__c),objIdevConfig);                   
                        mapIdevMarketRoleBenchDueDate.put((objIdevConfig.Market__c+objIdevConfig.Role__c), benchmarkDueDate);
                    }
                    if(objIdevConfig.Market__c != null && objIdevConfig.Role__c == null){
                        mapIdevConfigWithNoRole.put(objIdevConfig.Market__c, objIdevConfig);
                        mapIdevWithNoRoleBenchDueDate.put(objIdevConfig.Market__c,benchmarkDueDate);
                    }					
                }
            }
        }          
        sendBenchmarkEmailNotificationBatch objBatchClass = new sendBenchmarkEmailNotificationBatch(setMarket,mapMarktRoleIdevConfig, mapIdevMarketRoleBenchDueDate, mapIdevConfigWithNoRole, mapIdevWithNoRoleBenchDueDate);
        Database.executeBatch(objBatchClass); 
    }    
}