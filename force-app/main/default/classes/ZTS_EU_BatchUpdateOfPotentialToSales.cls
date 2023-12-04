/*************************************************************************************************************************
  Class Name     : ZTS_EU_BatchUpdateOfPotentialToSales
  Description    : This class is a batch class that is used to calculate the Potential of Brands as per the Potential region
                   of Account. This Batch class takes all Accounts in the org and uses data in Account Species Potential
                   for the calculation.
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Deloitte Constulting/Teresa          05/08/2014              Created

***************************************************************************************************************************/
global class ZTS_EU_BatchUpdateOfPotentialToSales implements Database.Batchable<sObject>, Database.Stateful{
//String query = 'SELECT Id, Name, ZTS_EU_Potential_Region__c FROM Account where Id IN (\'001L000000KYjQU\') AND ZTS_EU_Market__c != 'United States'';
String query = 'SELECT Id, Name, ZTS_EU_Potential_Region__c FROM Account';
global integer recordsProcessed = 0;
global DateTime startTime = System.now();
global DateTime endTime ;
/* Get all accounts in the org */
global Database.querylocator start(Database.BatchableContext BC){
            
            return Database.getQueryLocator(query);
}
 /*
     * Execute method of Batch class.
     * @param Scope : List of Accounts
     * @return none 
    */
global void execute(Database.BatchableContext BC, List<sObject> scope){
    Map<String,Map<String,double>> accountSpeciesAnimalConsultMap = new Map<String,Map<String,double>>();
    Map<String,double> speciesAnimalConsultMap = new Map<String,double>();
    Map<String,String>accountPotRegionMap = new Map<String,String>();
    Map<String,List<String>>speciesBrandMap = new Map<String,List<String>>();
    Set<String> speciesIdSet   = new Set<String>();
    List<String> speciesIdList = new List<String>();
    Map<String,Map<String,double>> speciesRegionPotentialMap = new Map<String,Map<String,double>>();
    Map<String,double> brandPotRegionWiseMap = new Map<String,double>();
    Map<String,Map<String,Double>> accountBrandPotMap = new Map<String,Map<String,Double>>();
    Map<String,Double> brandPot = new Map<String,Double>();
    Map<String,String> brandIdNameMap = new Map<String,String>();
    List<Account> accList = new List<Account>();
            
 //   for(sObject s : scope){
        //Account acc = (Account)s;
        //accList.add(acc);
   // }
   try{
   	    /* Fetch Account Species Potential  as per the Account */
        List<ZTS_EU_Account_Species_Potential__c> acctSpeciesPot = [SELECT ZTS_EU_Animal_Consultations_new__c, ZTS_EU_Animals_Consultations_actual__c, Account__c, ZTS_EU_Species_Potential__c,
                                                                     ZTS_EU_Species_Potential__r.Name,Account__r.Name, Account__r.ZTS_EU_Potential_Region__c FROM ZTS_EU_Account_Species_Potential__c WHERE Account__c IN : scope];
        
        for(ZTS_EU_Account_Species_Potential__c asp : acctSpeciesPot){
              speciesAnimalConsultMap = new Map<String,double>();
              accountPotRegionMap.put(asp.Account__c,asp.Account__r.ZTS_EU_Potential_Region__c);
              speciesIdSet.add(asp.ZTS_EU_Species_Potential__c);
              if(accountSpeciesAnimalConsultMap.get(asp.Account__c) != null){
                speciesAnimalConsultMap = accountSpeciesAnimalConsultMap.get(asp.Account__c);
                    if(speciesAnimalConsultMap.get(asp.ZTS_EU_Species_Potential__c) != null){
                         speciesAnimalConsultMap.put(asp.ZTS_EU_Species_Potential__c, (speciesAnimalConsultMap.get(asp.ZTS_EU_Species_Potential__c) + asp.ZTS_EU_Animals_Consultations_actual__c));
                    } else {
                         speciesAnimalConsultMap.put(asp.ZTS_EU_Species_Potential__c,asp.ZTS_EU_Animals_Consultations_actual__c);
                    }
               } else {
                    speciesAnimalConsultMap.put(asp.ZTS_EU_Species_Potential__c,asp.ZTS_EU_Animals_Consultations_actual__c);
               }
               accountSpeciesAnimalConsultMap.put(asp.Account__c,speciesAnimalConsultMap);
              
        }
        // create list of species from Account Species potential
        if(accountSpeciesAnimalConsultMap != null && accountSpeciesAnimalConsultMap.keySet().size() > 0){
            system.debug('**********accountSpeciesAnimalConsultMap********************'+accountSpeciesAnimalConsultMap);
            speciesIdList.addAll(speciesIdSet);
            // Get Potential Brands for all regions as per species
            List<ZTS_EU_Potential_Brands__c> potBrands = [ SELECT Id, Brand__c, CurrencyIsoCode, Brand__r.Name, Brand__r.ZTS_EU_Parent_Species_Product__r.Name, Potential__r.Name, Potential__r.ZTS_EU_Business_Unit__r.Name, Potential__c, 
                                                          ZTS_EU_Value_Region_1__c, ZTS_EU_Value_Region_2__c, ZTS_EU_Value_Region_3__c, ZTS_EU_Value_Region_4__c
                                                          FROM ZTS_EU_Potential_Brands__c WHERE Potential__c =: speciesIdList ORDER BY Brand__r.Name];
            List<String> brNamesList;                                             
            for(ZTS_EU_Potential_Brands__c pb : potBrands){
                brNamesList = new List<String>();
                //map storing region wise potential
                brandPotRegionWiseMap = new Map<String,double>{'1'=>pb.ZTS_EU_Value_Region_1__c,'2'=>pb.ZTS_EU_Value_Region_2__c,
                                                               '3'=>pb.ZTS_EU_Value_Region_3__c,'4'=>pb.ZTS_EU_Value_Region_4__c};
                speciesRegionPotentialMap.put(pb.Id,brandPotRegionWiseMap);
                brandIdNameMap.put(pb.Id,pb.Brand__c);
                if(speciesBrandMap.get(pb.Potential__c) != null){
                    brNamesList = speciesBrandMap.get(pb.Potential__c);
                    brNamesList.add(pb.Id);
                } else {
                    brNamesList.add(pb.Id);
                }
                speciesBrandMap.put(pb.Potential__c,brNamesList);
            }
            system.debug('**********speciesRegionPotentialMap********************'+speciesRegionPotentialMap);
            system.debug('**********speciesBrandMap********************'+speciesBrandMap);
            system.debug('**********speciesAnimalConsultMap********************'+speciesAnimalConsultMap);
            system.debug('**********accountSpeciesAnimalConsultMap********************'+accountSpeciesAnimalConsultMap);
            /* Loop through accountSpeciesAnimalConsultMap to get the species wise animal count map.
            *  Multiply animal consult no * value got from brand for the potential region.
            *  Create a map of account and sales data
            */
            
            for(String acct : accountSpeciesAnimalConsultMap.keySet()){
                speciesAnimalConsultMap = accountSpeciesAnimalConsultMap.get(acct);
                brandPot = new Map<String,double>();
                for(String spName : speciesAnimalConsultMap.keySet()){
                if(speciesBrandMap != null && spName != null && speciesBrandMap.get(spName) != null){
                    for(String bId : speciesBrandMap.get(spName)){
                        Double potential = 0.0;
                        brandPotRegionWiseMap = speciesRegionPotentialMap.get(bId);
                        if(brandPot.get(brandIdNameMap.get(bId)) != null){
                            potential = brandPot.get(brandIdNameMap.get(bId)) + (brandPotRegionWiseMap.get((accountPotRegionMap.get(acct))) * speciesAnimalConsultMap.get(spName));
                            brandPot.put(brandIdNameMap.get(bId),potential);
                        } else {
                            potential =brandPotRegionWiseMap.get((accountPotRegionMap.get(acct))) * speciesAnimalConsultMap.get(spName);
                            brandPot.put(brandIdNameMap.get(bId),potential);
                        }   
                    }
                  }   
                }
                accountBrandPotMap.put(acct,brandPot);
            }   
            brandPot = new Map<String,double>();
            system.debug('**********accountBrandPotMap********************'+accountBrandPotMap);        
            Double potentialSales = 0.0;
            List<ZTS_EU_Sales__c> updateSalesAcctList = new List<ZTS_EU_Sales__c>();
            // get Sales data for Account and Product and update the value in potential
            List<ZTS_EU_Sales__c> salesAcctList = [SELECT ZTS_EU_Product__c,ZTS_EU_Account__c,ZTS_EU_Potential__c FROM ZTS_EU_Sales__c WHERE ZTS_EU_Account__c IN :accountBrandPotMap.keySet()];
            for(ZTS_EU_Sales__c sAList : salesAcctList){
                brandPot  = accountBrandPotMap.get(sAList.ZTS_EU_Account__c);
                sAList.ZTS_EU_Potential__c = 0;
                if(brandPot != null && brandPot.get(sAList.ZTS_EU_Product__c) != null){
                    potentialSales = brandPot.get(sAList.ZTS_EU_Product__c);
                    brandPot.remove(sAList.ZTS_EU_Product__c);
                    sAList.ZTS_EU_Potential__c = potentialSales;
                    accountBrandPotMap.put(sAList.ZTS_EU_Account__c,brandPot);
                    system.debug('**********accountBrandPotMap***111111*****************'+accountBrandPotMap);
                }
                updateSalesAcctList.add(sAList);
            }   
            system.debug('**********accountBrandPotMap**2222222222*****************'+accountBrandPotMap);       
            system.debug('**********brandIdNameMap*******************'+brandIdNameMap);                                                  
            for(String acct : accountBrandPotMap.keySet()){
                brandPot = accountBrandPotMap.get(acct);
                for(String bId : brandPot.keySet()){
                    ZTS_EU_Sales__c salesObj = new ZTS_EU_Sales__c();
                    salesObj.ZTS_EU_Potential__c = brandPot.get(bId);
                    salesObj.ZTS_EU_Account__c   = acct;
                    salesObj.ZTS_EU_Product__c   = bId;
                    updateSalesAcctList.add(salesObj);
                }
            }
            system.debug('**********updateSalesAcctList*******************'+updateSalesAcctList);       
            recordsProcessed = recordsProcessed + updateSalesAcctList.size();
            Database.upsert(updateSalesAcctList);
        }
   }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
   }catch(Exception ex) {
                System.debug('The following exception has occurred: ' + ex.getMessage());
   } 
}
/* Finish Method is used to send email to the user who has started the batch process
*/
global void finish(Database.BatchableContext BC){
endTime = System.now();
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String userId = UserInfo.getUserId();
User activeUser = [Select Email From User where Id = : userId AND ZTS_EU_Market__c != 'United States'];
String userEmail = activeUser.Email;
mail.setTargetObjectId(UserInfo.getUserId());  
 mail.setSaveAsActivity(false);  
mail.setSubject('Batch Process Completed');
String bodyOfMail = 'Records updated/inserted in Sales Object :'+recordsProcessed +
                    '\n Start time of Batch Process           :'+startTime+
                    '\n End time of Batch Process           :'+endTime;
mail.setPlainTextBody(bodyOfMail);


Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}