public Class ZTS_EU_PotFactorAdjstTblCtrl
{
    public decimal numberOfDosesPerSku { get; set; }
    public decimal periodOfUse { get; set; }
    public decimal numOfDosesPerMl { get; set; }
    public decimal annualNoOfTreatments { get; set; }
    public decimal mpgSKUMix { get; set; }
    public decimal adjustmentFactr { get; set; }
    public string selectedCAAccountType { get; set; }
    public string selectedProtocolForCA { get; set; }
    public ZTS_EU_Potential_Brands__c[] potentialBrandsToUpsert{get;set;}
    public boolean setFactorsFlag{get;set;}
    public List<SelectOption> selectedBrandOptions{get;set;}
    public List<SelectOption> speciesOptions{get;set;}
    public List<SelectOption> cAAccountTypeOptions {set;}
    public Boolean checkCAAnimal{get;set;}
    
    public  List<SelectOption> getcAAccountTypeOptions(){
    List<SelectOption> options =  new List<SelectOption>();      
        Schema.DescribeFieldResult fieldResult = ZTS_EU_Potential_Brands__c.ZTS_EU_CA_Account_Type__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new selectOption('',''));    
        for(Schema.picklistEntry f : ple)    
        {    
            options.add(new selectOption(f.getValue(),f.getValue()));                  
        }  

        return Options;   
   }
   
    public List<SelectOption> protocolForCAOptions {set;}
    public  List<SelectOption> getprotocolForCAOptions(){
    List<SelectOption> options =  new List<SelectOption>();      
        Schema.DescribeFieldResult fieldResult = ZTS_EU_Potential_Brands__c.Protocol_For_CA__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
         options.add(new selectOption('','')); 
        for(Schema.picklistEntry f : ple)    
        {    
            //options.add(new selectOption('--none--','--none--'));
            options.add(new selectOption(f.getValue(),f.getValue()));                  
        }  

        return Options;   
   }
    public PageReference save(){
          system.debug('>>>>adjustmentFactr>>>'+adjustmentFactr);
         //try{

                List<ZTS_EU_Potential_Brands__c> upsertList =new List<ZTS_EU_Potential_Brands__c>();
                 //potentialBrandsToUpsert= new List<ZTS_EU_Potential_Brands__c>();
                
                System.debug('######potentialBrandsToUpsert'+potentialBrandsToUpsert);
                for(ZTS_EU_Potential_Brands__c potBrands :potentialBrandsToUpsert){
                    //potBrands.CurrencyIsoCode=selectedCurrency;
                    potBrands.Adjustment_Factor__c=adjustmentFactr; 
                    potBrands.Annual_Number_of_treatments_Animal__c=annualNoOfTreatments;
                    potBrands.MPG_SKU_Mix__c=mpgSKUMix; 
                    potBrands.Number_of_Doses_per_Animal__c=numOfDosesPerMl;
                    potBrands.Number_of_Doses_per_SKU__c=numberOfDosesPerSku;
                    potBrands.Period_of_Use_Months__c=periodOfUse;
                    potBrands.Protocol_For_CA__c=selectedProtocolForCA;
                    potBrands.ZTS_EU_CA_Account_Type__c=selectedCAAccountType;
                    potBrands.Potential_Factor__c=true;
                    upsertList.add(potBrands);
                    
                }
               
                system.debug('******'+upsertList);
                database.upsert(upsertList);
         //}catch(Exception e){
          //   String error = e.getMessage(); 
        // }
         setFactorsFlag=false;
         selectedBrandOptions=null;
         speciesOptions=null;
         PageReference pRef = null;
        try{
            pRef = new PageReference(System.Label.BU_Admin_Set_Up_Page_URL);
            pRef.setRedirect(true);
        }catch(Exception e){
            String error=e.getMessage();
        }
        return pRef;
     }

    
}