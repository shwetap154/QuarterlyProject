public interface IPotentialCalculator {
   //Changed method defination, Passing key acocunts as parametr - Pavan
    ZTS_EU_Account_Product_Potential__c calculatePotential(Account account, ZTS_EU_Account_Species_Potential__c accountConsultation,
                                        Id therGroup, List<ZTS_EU_Species_Product__c> products,
                                        List<ZTS_EU_Potential_Brands__c> potentialProductsBySpecie,
                                        list<Key_Account_Product_Price__c> keyAccounts); 

     void setSpecieParametersMap(Map<String, Map<String, List<ASC_Administration__c>>> questionGroupsPerSpecie);

}