public with sharing class PotentialCalculatorEngine {
 
    public static String ACCOUNT_CONSULTATION_LIST_OF_FIELDS_USED = 'Account__c, CurrencyIsoCode, ZTS_EU_Animals_Consultations_actual__c, ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.Name, ZTS_EU_Species_Potential__c, ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c, '
                                + 'ZTS_EU_Animals_bought_from_other_herds__c, Yearly_Cost_per_1000_Eggs__c, The_farm_is_a_subsistence_activity__c, The_farm_fattens_males_without_castratio__c, '
                                + 'Farm_uses_timed_artificial_insemi__c, The_farm_does_not_use_TAI_but_uses_conv__c, The_farm_does_not_have_facilities_that_a__c, The_farm_does_not_use_TAI_or_conventiona__c, The_farm_fattens_males_and_castrate__c, The_farm_offers_mineral_to_the_animals__c, '
                                + 'The_farm_uses_creep_feeding__c, Calculated_No_of_Nelore_Cattle__c, ZTS_EU_No_of_Swiss_Brown_Calves__c, ZTS_EU_No_of_Holstein_Calves__c, ZTS_EU_No_of_Jersey_Calves__c, ZTS_EU_No_of_Purebred_Calves__c,ZTS_EU_No_of_Slaughtered_Cattle__c, ZTS_EU_No_of_Nelore_Cattle_2__c, ZTS_EU_No_of_Nelore_Cattle_In_Genetic__c,Number_of_Animal_Interval__c';
    public static String PRODUCT_HIERARCHY_LIST_OF_FIELDS_USED = 'Account__c, ';
    //Added fields required for CA--Mamta
    //Added Number_of_Doses_per_SKU__c field in below string --Pavan    
   public static String POTENTIAL_PRODUCT_LIST_OF_FIELDS_USED = 'CurrencyIsoCode, Brand__c, Brand__r.Name, Brand__r.ZTS_EU_Product_Unique_ID__c, Adjustment_Factor__c, MPG_SKU_Mix__c, Number_of_Doses_per_Animal__c, Product_Rotation__c, Potential_Factor__c, Price_Doses_or_ml__c, Price_SKU__c, Annual_Number_of_treatments_Animal__c, '
                                + 'Brand__r.ZTS_EU_Influenced_By_Farm_Artificial_Sem__c, Brand__r.ZTS_EU_Influenced_By_Farm_Subsistence__c, Brand__r.ZTS_EU_Influenced_By_Other_Herds_Animals__c, '
                                + 'Brand__r.ZTS_EU_Influenced_By_Fattening_Mgmnt__c, Brand__r.ZTS_EU_Influenced_By_Reproductive_Mgmnt__c, Brand__r.ZTS_EU_Influenced_By_Nutritional_Mgmnt__c, Brand__r.ZTS_EU_Influenced_By_Purebreed_Calves__c,ZTS_EU_CA_Account_Type__c, '
                                + 'Treated_Food_Yearly_Intake_by_Animal__c,Number_of_Doses_per_SKU__c, Brand__r.ZTS_EU_Influenced_By_Slaughtered_Females__c, Brand__r.ZTS_EU_Influenced_By_Genetic_Improvement__c,Protocol_For_CA__c';
                                
    //Added fields required for CA--Mamta
    public static String ACCOUNT_LIST_OF_FIELDS_USED = 'Key_Account__c, '
                                + 'ZTS_EU_Calculated_Protocol__c,ZTS_EU_CA_Account_Type__c';

    //Adding CA to the map--> Mamta
    public static Map<String, String> classEnginePerBUMap = new Map<String, String> { 'CT DY' => 'CattlePotentialCalculator', 'CT FL' => 'CattlePotentialCalculator', 'CT BF' => 'CattlePotentialCalculator', 'CA' => 'CAPotentialCalculator', 'EQ' => 'EQPotentialcalculator','SW' => 'SwinePotentialCalculator','PY' => 'PoultryPotentialCalculator'};

    public Map<Id, List<ZTS_EU_Species_Product__c>> productsPerTherGroup {public get; public set; }
    public Map<Id, List<ZTS_EU_Potential_Brands__c>> potentialProductsBySpecie { public get; set; }
    public Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>> speciePotentialProd { public get; set; }
// The Map will contain <BU Abbr, <Group, List<Questions>>>
    private Map<String, Map<String, List<ASC_Administration__c>>> questionGroupsPerSpecie = new Map<String, Map<String, List<ASC_Administration__c>>>();


    public PotentialCalculatorEngine(Set<String> markets) {
        //Set up all Cattle questions
               List<ASC_Administration__c> questionParametersForBUs = [SELECT Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c, Group__c, Species__c, API_Name__c, Product_Influence_API_Name__c
                                                                        FROM ASC_Administration__c 
                                                                        WHERE Business_Unit__r.ZTS_EU_Market__c IN :markets AND Used_In_Calculation__c = TRUE AND User_Language__c ='en_US'
                                                                    ];
        
        for(ASC_Administration__c ascAdmin: questionParametersForBUs) {
            Map<String, List<ASC_Administration__c>> questionsPerGroup = questionGroupsPerSpecie.get(ascAdmin.Species__c);
            if(questionsPerGroup == null) {
                questionsPerGroup = new Map<String, List<ASC_Administration__c>>();
                questionGroupsPerSpecie.put(ascAdmin.Species__c ,questionsPerGroup);
            }

            List<ASC_Administration__c> questions = questionsPerGroup.get(ascAdmin.Product_Influence_API_Name__c);
            if(questions == null) {
                questions = new List<ASC_Administration__c>();
                questionsPerGroup.put(ascAdmin.Product_Influence_API_Name__c, questions);
            }
            questions.add(ascAdmin);
        }

    }

    /**
    * Calculates the potential per therapeutic group and specie and stores in a list of account potential records
    * of type ZTS_EU_Account_Product_Potential__c.
    * @param 
    * @author Natasa Cvrlje
    */ 
    //Changed method defination, Passing key acocunts as parametr - Pavan
    public List<ZTS_EU_Account_Product_Potential__c> calculatePotential(Account account, List<ZTS_EU_Account_Species_Potential__c> accountConsultations, list<Key_Account_Product_Price__c> keyAccounts) {
        IPotentialCalculator buEngineClass;
        Map<String, List<ZTS_EU_Account_Species_Potential__c>> accountConsultationsByBU = sortByBU(accountConsultations);
        List<ZTS_EU_Account_Product_Potential__c> accountPotentials = new List<ZTS_EU_Account_Product_Potential__c>();
        //Calculate per Therapeutic Group
        for(String buName : accountConsultationsByBU.keySet()) {
            String buEngineClassName = classEnginePerBUMap.get(buName);
            if(buEngineClassName == null) {
                System.debug(LoggingLevel.ERROR, 'The class for the BU abbreviation ' + buName + ' does not exist.' +
                ' Skipping accountConsultations of account ID=' + account.Id + ' with the species for that BU.');
                continue;
            }
            Type potCalClassType = Type.forName(buEngineClassName);
            if(potCalClassType == null) {
                System.debug(LoggingLevel.ERROR, 'The class ' + buEngineClassName + ' does not exist.' +
                ' Skipping accountConsultations of account ID=' + account.Id + ' with the species for the BU ' + buName);
                continue;
            }
            buEngineClass = (IPotentialCalculator) potCalClassType.newInstance();
            buEngineClass.setSpecieParametersMap(questionGroupsPerSpecie);
            for(ZTS_EU_Account_Species_Potential__c accountConsultation : accountConsultationsByBU.get(buName)) {
                if(speciePotentialProd.get(accountConsultation.ZTS_EU_Species_Potential__c) == null) {
                    system.debug(LoggingLevel.INFO, 'There are no products for this specie: ' + accountConsultation.ZTS_EU_Species_Potential__c + ', continuing the loop.');
                    continue;
                }
                Map<Id, List<ZTS_EU_Potential_Brands__c>> potProductsPerTherGroup = speciePotentialProd.get(accountConsultation.ZTS_EU_Species_Potential__c);
                for(Id therGroup : productsPerTherGroup.keySet()) {
                    if(potProductsPerTherGroup!=null && potProductsPerTherGroup.get(therGroup) != null) {
                        //Passing key acocunts as parametr - Pavan
                        ZTS_EU_Account_Product_Potential__c accountPotential = buEngineClass.calculatePotential(account, accountConsultation, therGroup, productsPerTherGroup.get(therGroup), potProductsPerTherGroup.get(therGroup),keyAccounts);//potentialProductsBySpecie.get(accountConsultation.ZTS_EU_Species_Potential__c)
                       if(accountPotential!=null)
                        { 
                          accountPotentials.add(accountPotential);
                        }  
                    } else {
                        system.debug(LoggingLevel.ERROR, 'There are no products for this specie: ' + accountConsultation.ZTS_EU_Species_Potential__c + ' and TG '  + therGroup + ' combination, continuing the loop.');
                    }
                }
            }
        }

        return accountPotentials;

    }

    private static Map<String, List<ZTS_EU_Account_Species_Potential__c>> sortByBU(List<ZTS_EU_Account_Species_Potential__c> accountConsultations) {
        Map<String, List<ZTS_EU_Account_Species_Potential__c>> accountConsByBU = new Map<String, List<ZTS_EU_Account_Species_Potential__c>>();
        for(ZTS_EU_Account_Species_Potential__c accountCons : accountConsultations ) {
            String buName = accountCons.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c;
            List<ZTS_EU_Account_Species_Potential__c> consults = accountConsByBU.get(buName);
            if(consults == null) {
                consults = new List<ZTS_EU_Account_Species_Potential__c>();
            }
            consults.add(accountCons);
            accountConsByBU.put(buName, consults);
        }
        return accountConsByBU;
    }

}