public class CAPotentialCalculator extends AbstractPotentialCalculator{

  
  //parameter that influences CA potential
  public static String CA_PARAM_PROTOCOL = 'ZTS_EU_Calculated_Protocol__c';
  public static String CA_PARAM_ACCTYPE= 'ZTS_EU_CA_Account_Type__c';

  public static Integer countOfSKUsStamped=Integer.valueOf(System.Label.No_of_SKUs_stamped_on_Account_Product_Potential);

  /**
  * The map contains of keys -> names of fields on the account
  * which depict whether the product potential is influenced by the parameter in question
  * The value of the map -> a wrapper class containing the info on the field type (so the proper condition can be used)
  * and the name of the field parameter used to store the account value. 
  */
  public static Map<String, FieldParameter> CAFieldParameters = new Map<String, FieldParameter> {
    CA_PARAM_PROTOCOL => new FieldParameter('ZTS_EU_Calculated_Protocol__c',  ParamFieldType.PICKLIST),
    CA_PARAM_ACCTYPE => new FieldParameter('ZTS_EU_CA_Account_Type__c',ParamFieldType.PICKLIST)
  };
  

  public static Map<String,  Map<String, FieldParameter>> CAParameters = new Map<String,  Map<String, FieldParameter>>
              {'CA' => CAFieldParameters};

 Override
  public Decimal calculatePotentialFactorForBU(Account account,String buName,ZTS_EU_Account_Species_Potential__c accountConsultation,
                    ZTS_EU_Potential_Brands__c productPotential) {

    Decimal Doses=0;
    Decimal potentialFactor=0;
    
    Doses= getDosesForCA(account, CAParameters.get(buName), accountConsultation, productPotential);
      system.debug('&&&&&&&'+Doses);

     if(Doses!=0)
      {
            if(productPotential.Number_of_Doses_per_Animal__c != null && productPotential.Potential_Factor__c ){
              potentialFactor=Doses*accountConsultation.Number_of_Animal_Interval__c;
             } 
             else
              {
                potentialFactor=0;
              
              }
 
     }
     

    return potentialFactor;

  }

private Decimal getDosesForCA(Account account, Map<String, FieldParameter> parameterMap, ZTS_EU_Account_Species_Potential__c accountConsultation, ZTS_EU_Potential_Brands__c product) { 
   Decimal Doses1=0;
   Boolean checkProtocol=false;
   Boolean checkAccType=false;
   for(String parameterName : parameterMap.keySet()) {
   
       if(parameterMap.get(parameterName).fieldType == ParamFieldType.PICKLIST){
       system.debug('%%%%%%'+account.get(parameterMap.get(parameterName).apiName)+'%%%%%%%'+product.Protocol_For_CA__c+'%%%%%'+product.ZTS_EU_CA_Account_Type__c);
          if(account.get(parameterMap.get(parameterName).apiName) == product.Protocol_For_CA__c) {
             checkProtocol=True;    
        } 
        if(account.get(parameterMap.get(parameterName).apiName) == product.ZTS_EU_CA_Account_Type__c){
          checkAccType=True;
        }
       } 
    }
    
    if(checkProtocol && checkAccType)
    {
      system.debug('>>>>>>>'+Doses1);
      Doses1= product.Number_of_Doses_per_Animal__c;
    }
    
    else
    {
      Doses1=0;
    }
    return Doses1;
 }
 


}