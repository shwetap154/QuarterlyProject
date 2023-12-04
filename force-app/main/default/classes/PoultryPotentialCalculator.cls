public class PoultryPotentialCalculator extends AbstractPotentialCalculator {

    //TODO: Add Medicated food intaked into the equasion!!!
    Override
    public Decimal calculatePotentialFactorForBU(Account account, String buName, ZTS_EU_Account_Species_Potential__c accountConsultation, ZTS_EU_Potential_Brands__c product) {
        Decimal potentialFactor = product.Number_of_Doses_per_Animal__c;
       
        system.debug('Poultry - Multiplying additional potential factors for potential of product ' + product.Id +'No. Of Doses per animal>>>'+ product.Number_of_Doses_per_Animal__c);
       
        if(potentialFactor!=null && accountConsultation.Yearly_Cost_per_1000_Eggs__c>0){
           potentialFactor *= accountConsultation.Yearly_Cost_per_1000_Eggs__c; 
         }
        else if(potentialFactor!=null && product.Product_Rotation__c > 0 && product.Treated_Food_Yearly_Intake_by_Animal__c > 0) {
           system.debug('potential factor before calculation>'+potentialFactor);
            potentialFactor *= (product.Product_Rotation__c/100) * product.Treated_Food_Yearly_Intake_by_Animal__c;
            system.debug('Poultry ->>>>'+potentialFactor  +'ProductRotation>>>'+product.Product_Rotation__c/100+ 'Treated food>>>>'+product.Treated_Food_Yearly_Intake_by_Animal__c);
        } 
        
         if(potentialFactor==null)
        {
          potentialFactor=0;
        }     
        return potentialFactor;
        
    }
}