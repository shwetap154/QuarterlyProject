public with sharing class InsertProductInvestigationRequest {
        @InvocableMethod(label='Get Investigations' description='Get all the investigations created' category= 'Product Investigation')
        public static List<List<ZTS_US_Product_Investigation__c>> insertAccounts(List<List<ZTS_US_Product_Investigation__c>> investigations) {
    
          System.debug('Entering inside the method'+ investigations);



    
          List<ZTS_US_Product_Investigation__c> productInvestigations = new List<ZTS_US_Product_Investigation__c>();

          Integer count = 0;

    
          for(List<ZTS_US_Product_Investigation__c> eachInvestigation: investigations){
              for(ZTS_US_Product_Investigation__c aInvestigation: eachInvestigation){
                         
                productInvestigations.add(aInvestigation);
              }
    
          }
          insert productInvestigations;

          System.debug('After inserting the investigation '+ productInvestigations);

    
    
          List<FormulaRecalcResult> results = Formula.recalculateFormulas(productInvestigations);
    
          List<List<ZTS_US_Product_Investigation__c>> listOfInvestigation = new List<List<ZTS_US_Product_Investigation__c>>();
          listOfInvestigation.add(productInvestigations);         
    
          return listOfInvestigation; 
         
    }
}