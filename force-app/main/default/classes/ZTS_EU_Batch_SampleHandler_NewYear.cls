/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Batch_SampleHandler_NewYear
* Description   :  Batch class that will handle deactivation of samples and creation of new samples on change of year.                       

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     21st-Nov-14   Shreyas             Created the class.

********************************************************************************************************************************************/

global class ZTS_EU_Batch_SampleHandler_NewYear implements Database.Batchable<SObject> {
    
   global Database.queryLocator start(Database.BatchableContext bc) { 
       
       integer currentYear = System.today().year();
       integer previousYear = currentYear - 1;
       string previousYearString = string.valueof(previousYear);
       List<String> listOfApplicableMarkets = new  List<String>();
       listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();
       
       
       String query = 'Select Id, Name, ZTS_EU_Account__c, ZTS_EU_Contact__c, ZTS_EU_Contact_Name__c, ZTS_EU_Is_Active__c, ZTS_EU_Is_used_for_old_SKUs__c, ';
            query = query + 'ZTS_EU_Item_Code__c, ZTS_EU_Lot__c, ZTS_EU_Sample_Unique_Id__c,  ZTS_EU_Ship_Date__c, ZTS_EU_Product__c, ZTS_EU_Start_Quantity__c, ZTS_EU_Year__c ';
            query = query + 'from ZTS_EU_Sample__c where ZTS_EU_Year__c =: previousYearString AND ZTS_EU_Contact__r.ZTS_EU_Market__c IN: listOfApplicableMarkets AND ZTS_EU_Is_Active__c = True';     
       return Database.getQueryLocator(query);   
    }
        
    
    global void execute(Database.BatchableContext bc, List<ZTS_EU_Sample__c> scope) {
           
           ZTS_EU_Batch_SampleHandlerController.processSamplesOnYearChange(scope);
    }
     
    
    global void finish(Database.BatchableContext bc) {
                

    } 


}