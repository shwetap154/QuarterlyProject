public with sharing class SwinePotentialCalculator extends AbstractPotentialCalculator {

    //TODO: Add Medicated food intaked into the equasion!!!
    Override
    public Decimal calculatePotentialFactorForBU(Account account, String buName, ZTS_EU_Account_Species_Potential__c accountConsultation, ZTS_EU_Potential_Brands__c product) {
        Decimal potentialFactor = product.Number_of_Doses_per_Animal__c;

        system.debug('Swine - Multiplying additional potential factors for potential of product ' + product.Id);

        //Take into account Product Rotation and Treated Food Intake only if both are populated with valid values
        if(potentialFactor!=null && product.Product_Rotation__c > 0 && product.Treated_Food_Yearly_Intake_by_Animal__c > 0) {
            potentialFactor *= (product.Product_Rotation__c/100) * product.Treated_Food_Yearly_Intake_by_Animal__c;
        }
        if(potentialFactor==null)
        {
          potentialFactor=0;
        }
        return potentialFactor;
        
    }
}