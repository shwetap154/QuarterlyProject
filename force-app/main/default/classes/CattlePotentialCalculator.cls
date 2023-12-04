/**
* Class implementing calculations necessary for Cattle BU Potential
* Inherits AbstractPotentialCalculator
* Defines the maps with the fields defining cattle questions and it's influence on products
* @author Natasa Cvrlje
*/
public class CattlePotentialCalculator extends AbstractPotentialCalculator {

    public static String PICKLIST_YES = 'Yes';

    public static String FEEDLOT_PARAM_ANIMALS_BOUGHT_FROM_HERDS = 'ZTS_EU_Influenced_By_Other_Herds_Animals__c';
    public static String FEEDLOT_PARAM_FATTENING_MANAGEMENT = 'ZTS_EU_Influenced_By_Fattening_Mgmnt__c';

    public static String DAIRY_PARAM_TIMED_ARTIFICIAL_INSEMINATION = 'ZTS_EU_Influenced_By_Farm_Artificial_Sem__c';
    public static String DAIRY_PARAM_SUBSISTENCE_ACTIVITY = 'ZTS_EU_Influenced_By_Farm_Subsistence__c';
    public static String DAIRY_PARAM_PUREBRED_CALVES = 'ZTS_EU_Influenced_By_Purebreed_Calves__c';

    public static String COWCALF_PARAM_FATTENING_MAN = 'ZTS_EU_Influenced_By_Fattening_Mgmnt__c';
    public static String COWCALF_PARAM_REPRODUCTIVE_MAN = 'ZTS_EU_Influenced_By_Reproductive_Mgmnt__c';
    public static String COWCALF_PARAM_NUTRITIONAL_MAN = 'ZTS_EU_Influenced_By_Nutritional_Mgmnt__c';
    public static String COWCALF_PARAM_SLAUGHTERED_FEMALES = 'ZTS_EU_Influenced_By_Slaughtered_Females__c';
    public static String COWCALF_PARAM_GENETIC_IMPROVEMENT = 'ZTS_EU_Influenced_By_Genetic_Improvement__c';

    public static Map<String, ParamFieldType> fieldTypes = new Map<String, ParamFieldType> { FEEDLOT_PARAM_ANIMALS_BOUGHT_FROM_HERDS => ParamFieldType.CALCULATION,
                                                                                            FEEDLOT_PARAM_FATTENING_MANAGEMENT => ParamFieldType.CHECKBOX_POSITIVE,
                                                                                            DAIRY_PARAM_TIMED_ARTIFICIAL_INSEMINATION => ParamFieldType.CHECKBOX_POSITIVE,
                                                                                            DAIRY_PARAM_SUBSISTENCE_ACTIVITY => ParamFieldType.CHECKBOX_NEGATIVE,
                                                                                            DAIRY_PARAM_PUREBRED_CALVES => ParamFieldType.CALCULATION,
                                                                                            COWCALF_PARAM_FATTENING_MAN => ParamFieldType.CHECKBOX_POSITIVE,
                                                                                            COWCALF_PARAM_REPRODUCTIVE_MAN => ParamFieldType.CHECKBOX_POSITIVE,
                                                                                            COWCALF_PARAM_NUTRITIONAL_MAN => ParamFieldType.CHECKBOX_POSITIVE,
                                                                                            COWCALF_PARAM_SLAUGHTERED_FEMALES => ParamFieldType.CALCULATION,
                                                                                            COWCALF_PARAM_GENETIC_IMPROVEMENT => ParamFieldType.CALCULATION};

    public static Integer countOfSKUsStamped=Integer.valueOf(System.Label.No_of_SKUs_stamped_on_Account_Product_Potential);

    /**
    * The map contains of keys -> names of fields on the product hierarchy
    * which depict whether the product potential is influenced by the parameter in question
    * The value of the map -> a wrapper class containing the info on the field type (so the proper condition can be used)
    * and the name of the field parameter used to store the account value. Only in case of calculations
    * will the value be stored on the Account Consultation and not the Account object, as these
    * parameters are numbers of animals.
    */

    Override
    public Decimal calculatePotentialFactorForBU(Account account, String buName, ZTS_EU_Account_Species_Potential__c accountConsultation, ZTS_EU_Potential_Brands__c product) {
        if(product.Annual_Number_of_treatments_Animal__c == null || product.Number_of_Doses_per_Animal__c == null) {
            return 0.00;
        }

        Decimal potentialFactor = product.Annual_Number_of_treatments_Animal__c * product.Number_of_Doses_per_Animal__c;

        Map<String, List<ASC_Administration__c>> parameterMap = questionGroupsPerSpecie.get(accountConsultation.ZTS_EU_Species_Potential__c);

        if(parameterMap == null) {
            System.debug(LoggingLevel.WARN, 'There are no parameters defined in ASC for this specie ' + accountConsultation.ZTS_EU_Species_Potential__c);
            return potentialFactor;
        }
        
        for(String parameterName : parameterMap.keySet()) {
            //Allowing below code as some parameters were null during testing phase
            if(parameterName == null) {
                system.debug(LoggingLevel.ERROR, 'Skipping found parameter null for cattle in map ' + parameterMap);
                continue;
            }
        
            system.debug('Checking parameter ' + parameterName);
            //Check if the parameter in question influences this product
            //by checking the checkbox on the product itself. If the checkbox is true,
            //the product is influenced, if false - this calculation should be skipped
            if(! (Boolean)product.getSobject('Brand__r').get(parameterName)) {
                system.debug('Value of parameter of influence is ' + (Boolean)product.getSobject('Brand__r').get(parameterName));
                continue;
            }

            List<ASC_Administration__c> parameters = parameterMap.get(parameterName);
            if(parameters == null) {
                //If there are no parameters for this group, skip the group and continue through the loop
                continue;
            }

            potentialFactor *= calculateParametersGroupInfluence(accountConsultation, parameterName, parameters,product);

            if(potentialFactor <= 0.00) {
                break;
            }
            
        }
        
        
        return potentialFactor;
    }


    private Decimal calculateParametersGroupInfluence(ZTS_EU_Account_Species_Potential__c accountConsultation, String parameterName, List<ASC_Administration__c> parameters, ZTS_EU_Potential_Brands__c product) {
        Decimal potentialFactor = 1;

        if(fieldTypes.get(parameterName) == ParamFieldType.CHECKBOX_POSITIVE) {
                Boolean isOneTrueParameterFromGroup = false;
                for(ASC_Administration__c parameter : parameters) {
                    if(accountConsultation.get(parameter.API_Name__c) != null && (Boolean) accountConsultation.get(parameter.API_Name__c)) {
                        isOneTrueParameterFromGroup = true;
                        break;
                    }
                }
                if(!isOneTrueParameterFromGroup) {
                    potentialFactor = 0;
                }
  //Added Dairy Parameter Change- Mamta
        } else if(fieldTypes.get(parameterName) == ParamFieldType.CHECKBOX_NEGATIVE) {
              for(ASC_Administration__c parameter : parameters) {
                    if(accountConsultation.get(parameter.API_Name__c) != null && (Boolean) accountConsultation.get(parameter.API_Name__c)) {
                        potentialFactor = 0;
                        break;
                    }
                }
               
        } else if(fieldTypes.get(parameterName) == ParamFieldType.CALCULATION) {
            //If the parameter is a calculation, it means it's a percentage of animals in that parameter
            //compared to the total number of animals
            for(ASC_Administration__c parameter : parameters) {
                if(accountConsultation.get(parameter.API_Name__c) != null && product.Adjustment_Factor__c>0) {
                    potentialFactor *=  accountConsultation.ZTS_EU_Animals_Consultations_actual__c > 0 ? ((Decimal) accountConsultation.get(parameter.API_Name__c) / accountConsultation.ZTS_EU_Animals_Consultations_actual__c)/(product.Adjustment_Factor__c/100) : 0;
                } else {
                    potentialFactor = 0;
                    break;
                }
            }
        } else {
            system.debug(LoggingLevel.ERROR, 'There is no such type for parameters ' + parameters);
        }

        return potentialFactor;

    }

}