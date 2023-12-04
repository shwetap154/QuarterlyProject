public class EQPotentialCalculator extends AbstractPotentialCalculator{


 Override
  public Decimal calculatePotentialFactorForBU(Account account,String buName,ZTS_EU_Account_Species_Potential__c accountConsultation,
                    ZTS_EU_Potential_Brands__c productPotential) {

    Decimal potentialFactor=0;
    

            if(productPotential.Number_of_Doses_per_Animal__c != null && productPotential.Potential_Factor__c){
              potentialFactor=productPotential.Number_of_Doses_per_Animal__c;
             } 
             
             else
              {
                potentialFactor=0;
              
              }

    return potentialFactor;

  }


}