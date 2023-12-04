/**
* File Name     :  AutoBundleBatchable
* @description  :  Auto bundling batch class to pull in Vistex Deal Banner records and use the related data to contruct the CPQ bundle structure for the Vistex Deal.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     9/3/2019		Cory Bartholomew @ ATG     Created the Class.
*/

global class AutoBundleBatchable implements Database.Batchable<sObject>, Schedulable {
	static final Integer SCHEDULABLE_BATCH_SIZE = 1;
 String dealLineQuery = '( SELECT Id, Name, DEALK01_Ext_Id__c, LOEVM_KO__c, E1KOMG_Ext_Id__c, EBONU__c, EKKOA__c, KOTBNR__c, KSCHL__c, LIFNR__c, MATNR__c, VAKEY__c, DEALK01_Ext_Id__r.ORGID__c ' +
	 'FROM Vistex_Deal_Line__r WHERE LOEVM_KO__c = NULL OR LOEVM_KO__c = \'\'), ';

 String bundleProductQuery = '( SELECT Id ' +
	 'FROM BundleWrapperProducts__r ) ';

 String dealQuery = 'SELECT Id, Name, BOART_AG__c, Commitment_Indicator__c, ' +
	 'CURRENCY__c, DEALK01_Ext_Id__c, DEALNUM__c, DEALNUM_EXT__c, DEALTXT__c, '+
	 'ORGID__c, QULAF__c, Transaction_Type_CPQ__c, VALID_FROM__c, VALID_TO__c, CPQ_Transaction_Type_Text__c, ' +  dealLineQuery + bundleProductQuery +    
	 'FROM Vistex_Deal_Header__c WHERE Exclude_From_Batch__c = FALSE ' ;   
 
 public AutoBundleBatchable() {

 }
 public AutoBundleBatchable(String dealId) {
	 dealquery += 'AND Id = \'' + dealId + '\'';
 }
 global Database.QueryLocator start(Database.BatchableContext bc) {
	 System.debug(dealQuery);
	 return Database.getQueryLocator(dealQuery);
 }

 global void execute(Database.BatchableContext BC, List<Vistex_Deal_Header__c> scope) {
		 
	 for(Vistex_Deal_Header__c deal : scope){
		 AutoBundleDataCollector collector = new AutoBundleDataCollector(deal);		
		 
		 //Make assertions about this deal before we do anything else			
		 List<CPQ_VistexDealValidator.DealValidationResult> validationResults = new List<CPQ_VistexDealValidator.DealValidationResult>();
		 validationResults.addAll(CPQ_VistexDealValidator.runPreValidations(deal, deal.Vistex_Deal_Line__r));		
			 
		 //Get the data for the deal				
		 AutoBundleDataWrapper dealData = collector.collectDealBundleData();
		 //Add validation results from data collector
		 validationResults.addAll(collector.validationResults);
		 //Check the validation results again.  We only want to create the bundle if there were no issues with the bundle structure
		 if(!collector.excludeFromDealCreation && CPQ_VistexDealValidator.isDealValid(validationResults)){				
			 System.debug('Attempting bundle build for: ' + deal.DEALNUM__c);				
			 //Build the bundle for this deal
			 if(dealData != null){
				 AutoBundleBuilder builder = new AutoBundleBuilder(dealData);
				 System.debug('Bundle Builder deal data parent product: ' + dealData.bundleParent );
				 builder.createBundle();
			 }
		 }		

		 if(collector.excludeFromDealCreation || !CPQ_VistexDealValidator.isDealValid(validationResults)){
			  if(collector.excludeFromDealCreation){
				 validationResults.add(CPQ_VistexDealValidator.createResult('- The Deal was marked for exlusion because it does not contain either a device, consumable or flexible group.',
				  false, deal.Id));
			 }				
			 //If there was no ZDev or ZCon we donb't want the deal to be created.  Update the exclusion indicator so the batch will not pick it up in the future
			 deal.Exclude_From_Batch__c = true;
			 if(!CPQ_VistexDealValidator.isDealValid(validationResults)){
				 System.debug('Updated deal validity issues');
				 deal.Deal_Validity_Issues__c = CPQ_VistexDealValidator.concatValidationResults(validationResults);
			 }
			 try{
			 update deal;
			 } catch(exception e) {
				 System.debug('There was an error while trying to update the excusion indicator: ' + deal.DEALNUM_EXT__c + ' Ex: ' + e.getMessage());
			 }
		 }							
	 }
 }
 
 global void finish(Database.BatchableContext bc) {		
 }

 //Schedulable Interface    
 global void execute(SchedulableContext ctx){
	 AutoBundleBatchable batchObject = new AutoBundleBatchable();
	 Id batchId = Database.executeBatch(batchObject, SCHEDULABLE_BATCH_SIZE);
 }	
}