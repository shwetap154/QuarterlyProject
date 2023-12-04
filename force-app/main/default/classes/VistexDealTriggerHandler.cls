/**
* File Name     :  VistexDealTriggerHandler.cls
* @description  :  Handler class for VistexDeal Trigger
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     09/16/2020		Ramiro Alvarez @ ATG     Created the Class.
**/

public with sharing class VistexDealTriggerHandler {

    @TestVisible
    public static void updateExistingProducts(Set<Id> dealIds) {
    
        List<CPQ_VistexDealValidator.DealValidationResult> validationResults = new List<CPQ_VistexDealValidator.DealValidationResult>();
           
          List<Vistex_Deal_Header__c> deals = queryDeal(dealIds);
          List<Vistex_Deal_Header__c> dealsToUpd = new List<Vistex_Deal_Header__c> ();
          
          for(Vistex_Deal_Header__c deal : deals) {
    
            if(deal.Exclude_From_Batch__c){
                validationResults.add(CPQ_VistexDealValidator.createResult('- This deal is already marked for exclusion.  No processing will occur.', false, deal.Id));
            }
            
            //Make assertions about this deal before we do anything else           
            validationResults.addAll(CPQ_VistexDealValidator.runPreValidations(deal, deal.Vistex_Deal_Line__r));  
            
             // *** IF PRE VALIDATIONS RESULTS IS NOT EMPTY HERE, SET ERROR AND STOP PROCESS ***            
            if(!CPQ_VistexDealValidator.isDealValid(validationResults)) {
              dealsToUpd.add(new Vistex_Deal_Header__c (Id = deal.Id,
                                                         Deal_Validity_Issues__c = CPQ_VistexDealValidator.concatValidationResults(validationResults),
                                                         Exclude_From_Batch__c = true));
              break;
            }
    
            AutoBundleDataCollector collector = new AutoBundleDataCollector(deal);      
            //Get the data for the deal				
            AutoBundleDataWrapper dealData = collector.collectDealBundleData();
            //Add validation results from data collector
            validationResults.addAll(collector.validationResults);
          
            //Check the validation results again.  We only want to create the bundle if there were no issues with the bundle structure
            if(!collector.excludeFromDealCreation && CPQ_VistexDealValidator.isDealValid(validationResults)){								
                //Build the bundle for this deal
                if(dealData != null) {
                    System.debug('Call to AutoBundleBuilder...' + dealData);
                    AutoBundleBuilder builder = new AutoBundleBuilder(dealData);
                    builder.createBundle();
                }
            }
            if(collector.excludeFromDealCreation || !CPQ_VistexDealValidator.isDealValid(validationResults)) {
                if(collector.excludeFromDealCreation){
                    validationResults.add(CPQ_VistexDealValidator.createResult('- The Deal was marked for exlusion because it does not contain either a device, consumable or flexible group.', false, deal.Id));
                }
                //If there was no ZDev or ZCon we donb't want the deal to be created.  Update the exclusion indicator so the batch will not pick it up in the future
                dealsToUpd.add(new Vistex_Deal_Header__c (Id = deal.Id, Exclude_From_Batch__c = true));
                if(!CPQ_VistexDealValidator.isDealValid(validationResults)){
                    System.debug('Updated deal validity issues');
                    dealsToUpd.add(new Vistex_Deal_Header__c (Id = deal.Id, Deal_Validity_Issues__c = CPQ_VistexDealValidator.concatValidationResults(validationResults)));                
                }
              }
        }
        try {
          if (!dealsToUpd.IsEmpty()){
            update dealsToUpd;
          }
        } catch(exception e) {
            System.debug('VistexDealTriggerHandler > updateExistingProducts: ERROR updating bundle: ' + e.getMessage());
            ErrorLogUtil.log('VistexDealTriggerHandler > updateExistingProducts: ERROR updating bundle: ', e); ErrorLogUtil.commitLogs();
        }    
      }
    
      private static List<Vistex_Deal_Header__c> queryDeal(Set<Id> dealIds) {
        return [
            SELECT Id, Name, BOART_AG__c, Commitment_Indicator__c, CURRENCY__c, DEALK01_Ext_Id__c, DEALNUM__c, DEALNUM_EXT__c, DEALTXT__c, ORGID__c, 
                QULAF__c, Transaction_Type_CPQ__c, VALID_FROM__c, VALID_TO__c, CPQ_Transaction_Type_Text__c, Exclude_From_Batch__c,
                ( 
                    SELECT Id, Name, DEALK01_Ext_Id__c, LOEVM_KO__c, E1KOMG_Ext_Id__c, EBONU__c, EKKOA__c, 
                    KOTBNR__c, KSCHL__c, LIFNR__c, MATNR__c, VAKEY__c, DEALK01_Ext_Id__r.ORGID__c 
                    FROM Vistex_Deal_Line__r 
                    WHERE LOEVM_KO__c = NULL OR LOEVM_KO__c = ''
                ), 
                ( 
                    SELECT Id 
                    FROM BundleWrapperProducts__r )
            FROM Vistex_Deal_Header__c
            WHERE Id IN :dealIds
        ];
    }	
}