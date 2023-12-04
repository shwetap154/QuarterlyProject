/**
* Custom controller for the SetAdjustmentFactors page.
* @author Natasa Cvrlje
*/
public with sharing class ZTS_EU_SetAdjustmentFactorsController {

    

    public String zone1 { get; set; }
 
    public  String adjustmentFactor{get;set;}
    public  String dosage{get;set;}
    public  String price{get;set;}
    public  String selectedUnit{get;set;}
    public  String selectedCurrency{get;set;}
    public  List<ZTS_EU_Potential_Brands__c> potentialBrandsToUpsert{get;set;}
    public decimal numberOfDosesPerSku { get; set; }
    public decimal productRotation { get; set; }
    public decimal numOfDosesPerMl { get; set; }
    public decimal annualNoOfTreatments { get; set; }
    public decimal mpgSKUMix { get; set; }
    public decimal adjustmentFactr { get; set; }
    
    /**
    * Used for accessing the page with the list of potential brands set
    * @author Natasa Cvrlje
    */
    public PageReference goToSetAdjustmentFactors() {
         PageReference pRef = null;
        try{
            pRef = new PageReference(System.Label.AdjustmentFactorURL);
            pRef.setRedirect(false);
        }catch(Exception e){
            String error=e.getMessage();
        }
        return pRef;
    }
    
    /**
    *    Used for setting values in the Unit Picklist
    *    @author Shefali Vinchurkar
    */
     public List<SelectOption> getUnitOptions()    
     {   List<SelectOption> options =  new List<SelectOption>();  
         try{      
            Schema.DescribeFieldResult fieldResult = ZTS_EU_Potential_Brands__c.ZTS_EU_Units__c.getDescribe();    
            List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
            for(Schema.picklistEntry f : ple)    
            {    
                options.add(new selectOption(f.getLabel(),f.getValue()));                    
            } 
        }catch(Exception e){
            String error = e.getMessage();
        }
        return options;    
     }    
     
      
    /**
    *   Used for setting values in the Currency Picklist
    *   @author Shefali Vinchurkar
    */
     public List<SelectOption> getCurrencyOptions()    
     {   List<SelectOption> options =  new List<SelectOption>();
         try{  
            for(CurrencyType cur : [SELECT ISOCode, ConversionRate FROM CurrencyType 
                                    WHERE IsActive=TRUE LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                options.add(new SelectOption(cur.ISOCode,cur.ISOCode));
            }
        }catch(Exception e){
            String error = e.getMessage();  
        }
        return options;    
     }       
    
     
    /**
    *   Used for upserting the records
    *   @author Shefali Vinchurkar
    */
     public PageReference saveAction(){
          
         //try{
                List<ZTS_EU_Potential_Brands__c> upsertList =new List<ZTS_EU_Potential_Brands__c>();
                //potentialBrandsToUpsert= new List<ZTS_EU_Potential_Brands__c>();
                
                System.debug('######potentialBrandsToUpsert'+potentialBrandsToUpsert);
                for(ZTS_EU_Potential_Brands__c potBrands :potentialBrandsToUpsert){
                   // potBrands.ZTS_EU_Adjustment_Factor_1__c = adjustmentFactor;
                   // potBrands.ZTS_EU_Adjustment_Factor_2__c = adjustmentFactor;
                   // potBrands.ZTS_EU_Adjustment_Factor_3__c = adjustmentFactor;
                   // potBrands.ZTS_EU_Adjustment_Factor_4__c = adjustmentFactor;
                   // potBrands.ZTS_EU_Dosage_1_Region_1__c = dosage;
                  //  potBrands.ZTS_EU_Dosage_2_Region_2__c = dosage;
                  //  potBrands.ZTS_EU_Dosage_3_Region_3__c = dosage;
                  //  potBrands.ZTS_EU_Dosage_4_Region_4__c = dosage;
                      potBrands.ZTS_EU_Units__c=selectedUnit;
                      potBrands.ZTS_EU_Dosage__c=dosage;
                     if(price!=null)
                     { 
                      potBrands.ZTS_EU_Price__c=decimal.valueOf(price);
                     }
                  //  potBrands.ZTS_EU_Value_Region_1__c = potBrands.ZTS_EU_Price__c;
                  //  potBrands.ZTS_EU_Value_Region_2__c = potBrands.ZTS_EU_Price__c;
                 //   potBrands.ZTS_EU_Value_Region_3__c = potBrands.ZTS_EU_Price__c;
                //    potBrands.ZTS_EU_Value_Region_4__c = potBrands.ZTS_EU_Price__c;
                    potBrands.CurrencyIsoCode=selectedCurrency;
                    potBrands.Adjustment_Factor__c=adjustmentFactr; 
                    //potBrands.Annual_Number_of_treatments_Animal__c=annualNoOfTreatments;
                    //potBrands.MPG_SKU_Mix__c=mpgSKUMix; 
                    //potBrands.Number_of_Doses_per_Animal__c=numOfDosesPerMl;
                   // potBrands.Number_of_Doses_per_SKU__c=numberOfDosesPerSku;
                   // potBrands.Product_Rotation__c=productRotation;

                    upsertList.add(potBrands);
                    
                }
               
                system.debug('******'+upsertList);
                database.upsert(upsertList);
         //}catch(Exception e){
          //   String error = e.getMessage(); 
        // }
         return null;
     }
     
     /*
      * Method to execute cancel call and redirect to the calling page.
      * 
      */
     public PageReference cancelAction(){
         PageReference pRef=null;
         try{
             pRef = new PageReference(System.Label.AdjustmentFactorURL);
         }catch(Exception e){
             String error =e.getMessage();
         }
         return pRef ;
     }
}