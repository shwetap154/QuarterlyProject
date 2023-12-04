public abstract class AbstractPotentialCalculator implements IPotentialCalculator {

    protected abstract Decimal calculatePotentialFactorForBU(Account account, String buName, ZTS_EU_Account_Species_Potential__c accountConsultation, ZTS_EU_Potential_Brands__c product);

    public Decimal calculateBasicPotentialFactors(Boolean potentialFactor, Decimal adjustmentFactor, Decimal MpgSkuMix,
                                                Decimal pricePerDose) {
                return potentialFactor? (adjustmentFactor/100) * (MpgSkuMix/100) * pricePerDose: 0.0 ;
    }
    
    public static Integer countOfSKUsStamped=Integer.valueOf(System.Label.No_of_SKUs_stamped_on_Account_Product_Potential);

    protected Map<String, Map<String, List<ASC_Administration__c>>> questionGroupsPerSpecie;

    public void setSpecieParametersMap(Map<String, Map<String, List<ASC_Administration__c>>> questionGroupsPerSpecie) {
        this.questionGroupsPerSpecie = questionGroupsPerSpecie;
    }

    /**
    * Method used to calculate potential for an account consultation record and a certain
    * therapeutic group product - it will be used across all BUs
    * in order for this method to work, the specific BU class needs to implement the abstract 
    * calculatePotentialFactorForBU
    * @author Natasa Cvrlje
    */
    //Pavan & Mamta added bug fixes and changes for Key Accounts
    //Changed method defination, Passing key acocunts as parametr - Pavan
    public ZTS_EU_Account_Product_Potential__c calculatePotential(Account account, ZTS_EU_Account_Species_Potential__c accountConsultation,
                    Id therGroupId, List<ZTS_EU_Species_Product__c> products,
                    List<ZTS_EU_Potential_Brands__c> potentialProductsBySpecie,
                     list<Key_Account_Product_Price__c> keyAccounts) {
    ZTS_EU_Account_Product_Potential__c accountPotential = new ZTS_EU_Account_Product_Potential__c(
                                  Account_Species_Consultation__c = accountConsultation.Id,
                                  Account__c = account.Id, Product_Hierarchy__c = therGroupId);
    map<string,decimal> keyAccountProductPrice = new map<string,decimal>();
    for(Key_Account_Product_Price__c kap : keyAccounts){
        if(kap.Price__c != null && kap.Product__c != null){
            keyAccountProductPrice.put(kap.Product__c,kap.Price__c);
        }
    } 
    
    Integer i = 1;
    Decimal therGroupPotential = 0;
    String buName = accountConsultation.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c;
    system.debug('Potential products by specie : ' + potentialProductsBySpecie);
    for(ZTS_EU_Potential_Brands__c productPotential : potentialProductsBySpecie) {
    //Assigning zero values if the values of parameters are null 
      decimal productPrice = 0;
      if(productPotential.Adjustment_Factor__c == null){
        productPotential.Adjustment_Factor__c=0;
      }
      if(productPotential.MPG_SKU_Mix__c == null){
      productPotential.MPG_SKU_Mix__c=0;
      }
      /*Handling Key accounts product price - Pavan  */ 
      if(account.Key_Account__c == true){
        if(keyAccountProductPrice.get(productPotential.Brand__c) != null && productPotential.Number_of_Doses_per_SKU__c != null && productPotential.Number_of_Doses_per_SKU__c > 0){
            productPrice = keyAccountProductPrice.get(productPotential.Brand__c)/productPotential.Number_of_Doses_per_SKU__c;
        }
      }else{
        productPrice = productPotential.Price_Doses_or_ml__c;
      }
      Decimal potentialPerAnimal = calculateBasicPotentialFactors(TRUE, productPotential.Adjustment_Factor__c, productPotential.MPG_SKU_Mix__c,productPrice);

      Decimal potentialFactor = calculatePotentialFactorForBU(account, buName, accountConsultation, productPotential);

      system.debug('Potential per Animal is ' + potentialPerAnimal + ' and the cattle paramter is ' + potentialFactor);
      potentialPerAnimal *= potentialFactor;
      // Inserting only non-zero potential records in Account Product Potential
      if(potentialPerAnimal!=0 && potentialPerAnimal!=null){
          accountPotential.put('ZTS_EU_Product_ID_' + i + '__c', productPotential.Brand__r.ZTS_EU_Product_Unique_ID__c);
          accountPotential.put('ZTS_EU_Product_Name_' + i + '__c', productPotential.Brand__r.Name);
          accountPotential.put('ZTS_EU_Product_Potential_' + i + '__c', potentialPerAnimal);
    
          accountPotential.put('PAC_' + i + '__c', potentialPerAnimal * accountConsultation.ZTS_EU_Animals_Consultations_actual__c);
    
          therGroupPotential += potentialPerAnimal * accountConsultation.ZTS_EU_Animals_Consultations_actual__c;
          i++;
     }
 
      if(i > countOfSKUsStamped)  {
        System.debug(LoggingLevel.ERROR, 'The number of stamped products on one record can not be more than ' + countOfSKUsStamped);
        break;
      }
    }
    if(accountPotential!=null && accountPotential.ZTS_EU_Product_Name_1__c!=null){
        //NC commented and added setting currency per account consultation
        //accountPotential.CurrencyIsoCode = potentialProductsBySpecie.get(0).CurrencyIsoCode;
        accountPotential.CurrencyIsoCode = accountConsultation.CurrencyIsoCode;
        //Calculate the sum of all product potentials and stamp it on the record
        accountPotential.ZTS_EU_Sum_Of_Product_Account_Potential__c = therGroupPotential;
        return accountPotential;
    }
    else
     return null;
    
  }


      //Added Dairy Parameter Change- Mamta
    public enum ParamFieldType {CHECKBOX_POSITIVE,CHECKBOX_NEGATIVE, PICKLIST,MULTIPICKLIST,CALCULATION}

    public class FieldParameter {
    public String apiName { get; set; }
    public ParamFieldType fieldType { get; set; }
       
    public FieldParameter(String apiName,ParamFieldType fieldType) {
      this.apiName = apiName;
      this.fieldType = fieldType;
    }

  }

}