/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Batch_HolidayToT
* Description   :  This batch queries all the records from the object 'Holiday__c' that have been updated and updates the number of working days
                   between start and end date of all the affected ToT records.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     22nd-Sep-14   Shreyas             Created the class.

********************************************************************************************************************************************/

global class ZTS_EU_Batch_HolidayToT implements Database.Batchable<SObject> {

    List<Holiday__c> holidayListToProcess = new List<Holiday__c>();
    
    global Database.queryLocator start(Database.BatchableContext bc) { 
        
        string currentYearHoliday = 'Yes';
        String query = 'Select Id, Name, ZTS_EU_Holiday_Date__c, ZTS_EU_Market__c, ZTS_EU_Default_Holiday__c';
        query = query + ', ZTS_EU_Is_Updated__c, ZTS_EU_Current_Year_Holiday__c from Holiday__c ';
        query = query + 'where ZTS_EU_Is_Updated__c = True AND ZTS_EU_Current_Year_Holiday__c =: currentYearHoliday AND ZTS_EU_Market__c != \'United States\'';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<Holiday__c> scope) {
    
        List<String> marketList = new List<String>(); 
        List<Time_Out_of_Territory__c> ToTListToUpdate = new List<Time_Out_of_Territory__c>();
    
        for(Holiday__c h: scope){
            marketList.add(h.ZTS_EU_Market__c);
        }
        
        ToTListToUpdate = [Select ZTS_Market__c, ZTS_EU_Start_Date__c, ZTS_EU_End_Date__c, ZTS_EU_Number_of_non_working_days_within__c, 
        ZTS_EU_Days_between_Start_and_End_date__c, ZTS_EU_State_County__c, ZTS_EU_Current_Year_ToT__c from Time_Out_of_Territory__c 
        where ZTS_Market__c in: marketList AND ZTS_Market__c != 'United States' AND ZTS_EU_Current_Year_ToT__c = 'Yes'];
        
        ZTS_EU_TOT_Utils.calculateDayCount(ToTListToUpdate);
        
        update ToTListToUpdate;    
        
    }
    
    
    global void finish(Database.BatchableContext bc) {
        
        List<Holiday__c> holidayListToUpdate = new List<Holiday__c>();
        holidayListToUpdate = [Select Id, Name, ZTS_EU_Is_Updated__c from Holiday__c where ZTS_EU_Is_Updated__c = True];
        
        for(Holiday__c h: holidayListToUpdate){
            h.ZTS_EU_Is_Updated__c = false;
        } 
         
        update holidayListToUpdate; 
    } 


}