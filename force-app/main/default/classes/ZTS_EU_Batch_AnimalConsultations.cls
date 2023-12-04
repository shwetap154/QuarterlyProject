/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Batch_AnimalConsultations
* Description   :  This batch queries all the records from the object 'ZTS_EU_Account_Species_Potential__c' of CLAR region and copied the
                   value in the field 'ZTS_EU_Animal_Consultations_new__c' to the field 'ZTS_EU_Animals_Consultations_actual__c'                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     10th-Sep-14   Shreyas             Created the class.

********************************************************************************************************************************************/
global class ZTS_EU_Batch_AnimalConsultations implements Database.Batchable<SObject>

{
    
   global Database.queryLocator start(Database.BatchableContext bc) { 
       
       List<MarketGeoMapping__c> marketGeoMappingList = new List<MarketGeoMapping__c>();
       List<ExcludefromPotentialCopyJob__c> excludeCopyMarketList = new List <ExcludefromPotentialCopyJob__c>();
       Set <String> excludeSet = new Set<String>();
       List<String> marketList = new List<String>();
       marketGeoMappingList = [Select Id, Name, Geo__c from MarketGeoMapping__c where Geo__c = 'CLAR'];
       //marketGeoMappingList = [Select Id, Name, Geo__c from MarketGeoMapping__c];
       excludeCopyMarketList = [Select Id, Market__c from ExcludefromPotentialCopyJob__c];
       for(ExcludefromPotentialCopyJob__c exc: excludeCopyMarketList)
         {
             excludeSet.add(exc.Market__c);
         }
       for(MarketGeoMapping__c mgm: marketGeoMappingList){
          //Exclude the markets for which Value will not be copied from "New" to "Actual" field (Added on 14-Aug-2017 as a part of SC-003258)
          if(!excludeSet.contains(mgm.Name))
          {
           marketList.add(mgm.Name);
          }
       }
       
       String query = 'Select Id, ZTS_EU_Animal_Consultations_new__c, ZTS_EU_Animals_Consultations_actual__c, Account__r.ZTS_EU_Market__c from ZTS_EU_Account_Species_Potential__c where Account__r.ZTS_EU_Market__c IN: marketList';
       
       return Database.getQueryLocator(query);   
    }
        
    
    global void execute(Database.BatchableContext bc, List<ZTS_EU_Account_Species_Potential__c> scope) {
       
       List<ZTS_EU_Account_Species_Potential__c> accountSpeciesPotentialUpdateList = new List<ZTS_EU_Account_Species_Potential__c>();
       
        for(ZTS_EU_Account_Species_Potential__c asp: scope){
            asp.ZTS_EU_Animals_Consultations_actual__c = asp.ZTS_EU_Animal_Consultations_new__c;
            accountSpeciesPotentialUpdateList.add(asp);
        }
        database.update(accountSpeciesPotentialUpdateList); 
       
    }
     
    
    global void finish(Database.BatchableContext bc) {
                

    } 


}