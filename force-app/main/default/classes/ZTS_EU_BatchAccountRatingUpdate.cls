/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchAccountRatingUpdate.cls
   Description: Batch used for calculating the account Rating FOR All International Markets per business unit and
                using that calculation for setting the appropriate account segmentation
                rating for each business unit. The account rating is fetched by finding the
                account segmentation threshold record with the corresponding range.
                    
   Date         Version   Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
   07-09-2017   1.0       Mayukh              Initial Version       
------------------------------------------------------------------------------------------------------------------------ */

global class ZTS_EU_BatchAccountRatingUpdate implements Database.Batchable<sObject>/*,Database.Stateful*/{
    List<string> csMarketList = new List<String>();
    Set<String> astMarketSet= new Set<String>();
    List<Account_Segmentation_threshold__c> acctSegThresholdList = [SELECT Id,ZTS_EU_Market__c,ZTS_EU_Segmentation_Rating__c,ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c,BU_Abbrv__c FROM Account_Segmentation_threshold__c];
    List<string> finalMarketList = new List<string>();
    Map<Id,Map<String,Double>> acctIdWithBusUnitTotalPotMap = new Map<Id,Map<String,Double>>();
    Map<Id,Double> acctAndTotalPotValueFinalMap = new Map<Id,Double>();
    Set<String> exceptionMarketSet = new Set<String>();

    //SOQL to get the Account Species/Consultations (ZTS_EU_Account_Species_Potential__c) for the all International Markets
    String query = 'SELECT Id,Name,Account__c,ZTS_EU_BU_Abbr__c,Calculated_Value_of_Potentail__c FROM ZTS_EU_Account_Species_Potential__c WHERE Account__r.ZTS_EU_Account_Status__c = \'Active\' AND Account__r.ZTS_EU_Omit_Segmentation_Calculations__c = false AND Account__r.ZTS_EU_Market__c IN:finalMarketList';

    public static String AllBU = 'All';
    public static String CA = 'CA';
    public static String EQ = 'EQ';
    public static String PY = 'PY';
    public static String RU = 'RU';
    public static String SW = 'SW';
    public static String VPS = 'VPS';
    public static String CTBF = 'CT BF';
    public static String CTFL = 'CT FL';
    public static String CTDY = 'CT DY';
    public static String AG ='AG';
    public static String CADPre = 'CAD Pre';
    public static String CADTher = 'CAD Ther';
    
    public static String ratingPrefix = 'ZTS_EU_RAT_';
    public static String ratingSuffix = '__c';
    public static String allRatingField = 'ZTS_EU_All_Rating__c';
    Public static String allPotField = 'ZTS_EU_All_Potential__c';
    public static String potentialPrefix = 'ZTS_EU_';
    public static String potentialSuffix = '_Potential__c';
    
    /**********************************************************************************************************************
    * Author: Mayukh
    * Date: 07-SEP-2017
    * Param: Database.BatchableContext BC
    * Return: QueryLocator Object 
    * Description: Returns the queryLocator object
    * Summary of Changes : 
    **********************************************************************************************************************/ 
    global Database.queryLocator start(Database.BatchableContext BC){
        //Get the Market list for All International Markets from Custom Settings
        List<MarketGeoMapping__c> gmList = MarketGeoMapping__c.getAll().values();
        for(MarketGeoMapping__c gm : gmList){
            csMarketList.add(gm.Name);
        }
        //Get the Unique Market list from Account Segmentation Threshold object
        for(Account_Segmentation_threshold__c ast : acctSegThresholdList){
            astMarketSet.add(ast.ZTS_EU_Market__c);
        }
        //Checking the Custom Settings Market with AST Market and creating a final list of market
        for(String mCheck : csMarketList){
            if(astMarketSet.contains(mCheck)){
                finalMarketList.add(mCheck);
            }
        }
        return Database.getqueryLocator(query);
    }
    
    /**********************************************************************************************************************
    * author: Mayukh
    * Date: 07-SEP-2017
    * Param: BatchableContext object,scope
    * Return: void
    * Description: This method calculates the total Calculated Potential Value 
     for every Business Unit for every Account, compares with the Account 
     Segmentation Threshold values, fetches the corresponding Rating and 
     updates the Account record.  
    * Summary of Changes : 
    **********************************************************************************************************************/
    global void execute(Database.BatchableContext BC,List<ZTS_EU_Account_Species_Potential__c> scope){
        Set<Id> accIdSet = new Set<Id>();
        String fieldToUpdate;
        String allPotFieldToUpdate;
        String fieldValueForAllRating;
        String ratingFieldtoUpdate;
        String ratingValForAccount;
        String potentialFieldtoUpdate;
        Double sumPotential;
        String destPotField;
        String destRatVal;
        String destRatField;
        List<Account> accountsToUpdateList = new List<Account>();
        
        //Iterate on every Account Species Consultations from the scope and creating an Account List
        for (ZTS_EU_Account_Species_Potential__c accSC : scope){
            accIdSet.add(accSC.Account__c);
        }
        
        //Get the list of Exception Markets i.e. Canada
        List<ZTS_EU_Exception_Potential_Calculation__c> expList = ZTS_EU_Exception_Potential_Calculation__c.getall().values();
		for(ZTS_EU_Exception_Potential_Calculation__c e: expList){
		    exceptionMarketSet.add(e.ZTS_EU_Market__c);
		}
        
        //Creation of two maps to hold Account Id and Calculated Potential Values and All Potential value
        for(Id acc : accIdSet){
            Double fieldValueForAllPotential = 0.0;
            Double calPotentialTotal = 0.0;
            Map<String,Double> BusUnitPotentialValMap = new Map<String,Double>{CA => 0.0, EQ => 0.0, PY => 0.0, RU => 0.0, SW => 0.0, VPS => 0.0, CTBF=> 0.0, CTFL => 0.0, CTDY => 0.0,CADPre => 0.0,CADTher => 0.0};
            Set<String> allBUs = BusUnitPotentialValMap.keySet();
            for(ZTS_EU_Account_Species_Potential__c accSC : scope){
                if(accSC.Account__c == acc){
                    if(accSC.ZTS_EU_BU_Abbr__c != NULL){
                        calPotentialTotal = BusUnitPotentialValMap.get(accSC.ZTS_EU_BU_Abbr__c);
                        if(calPotentialTotal == null){
                            calPotentialTotal=0.0;
                        }
                        calPotentialTotal += accSc.Calculated_Value_of_Potentail__c;
                        BusUnitPotentialValMap.put(accSC.ZTS_EU_BU_Abbr__c,calPotentialTotal);
						fieldValueForAllPotential += accSC.Calculated_Value_of_Potentail__c;
                    }
                }
            }
            acctIdWithBusUnitTotalPotMap.put(acc,BusUnitPotentialValMap);
            acctAndTotalPotValueFinalMap.put(acc,fieldValueForAllPotential);
        }
        
        //Query to fetch all the Accounts from accIdSet and storing the result in a list
        List<Account> accList = [SELECT Id,ZTS_EU_Market__c,ZTS_EU_RAT_CA__c,ZTS_EU_RAT_EQ__c,ZTS_EU_RAT_PY__c,ZTS_EU_RAT_RU__c,ZTS_EU_RAT_SW__c,ZTS_EU_RAT_VPS__c,ZTS_EU_RAT_CTDY__c,ZTS_EU_RAT_CTFL__c,ZTS_EU_RAT_CTBF__c,ZTS_EU_RAT_CADPre__c,ZTS_EU_RAT_CADTher__c,ZTS_EU_All_Rating__c,ZTS_EU_All_Potential__c,ZTS_EU_CA_Potential__c,ZTS_EU_EQ_Potential__c,ZTS_EU_RU_Potential__c,ZTS_EU_SW_Potential__c,ZTS_EU_PY_Potential__c,ZTS_EU_VPS_Potential__c,ZTS_EU_CTDY_Potential__c,ZTS_EU_CTFL_Potential__c,ZTS_EU_CTBF_Potential__c,ZTS_EU_CADPre_Potential__c,ZTS_EU_CADTher_Potential__c FROM Account WHERE Id IN:accIdSet AND ZTS_EU_Market__c != 'United States'];
		//Perform summation for exception markets and put the summed data into correct potential field.
        for(Account ac : accList)
        {
            if(exceptionMarketSet.contains(ac.ZTS_EU_Market__c))
            {
                for(ZTS_EU_Exception_Potential_Calculation__c e: expList)
                {
                    if(e.ZTS_EU_Market__c == ac.ZTS_EU_Market__c)
                    {
                        Map<String,Double> bupotMap =  acctIdWithBusUnitTotalPotMap.get(ac.Id);
                        sumPotential = 0.0;
                        List<String> sourceBUList = e.ZTS_EU_Potential_Fields_to_Sum_up__c.split(';');
                        for(String s:sourceBUList){
                              sumPotential = sumPotential + bupotMap.get(s);
                        }
                        bupotMap.put(e.ZTS_EU_BU__c, sumPotential);
                        acctIdWithBusUnitTotalPotMap.put(ac.Id, bupotMap);
                    }
                }
            }
            
        }
		
        //Main logic to calculate Rating and Potential for Account
        for(Account acc : accList){
		    Map<String,Double> innerMap =  acctIdWithBusUnitTotalPotMap.get(acc.Id);
			Boolean isAccountUpdated = false;
			for(Account_Segmentation_threshold__c tempThreshold : acctSegThresholdList){
			    if(acc.ZTS_EU_Market__c ==  tempThreshold.ZTS_EU_Market__c){
				    //For ALL BU 
					if(tempThreshold.BU_Abbrv__c.replace(' ','') == AllBU){
					    Double allPotValue = acctAndTotalPotValueFinalMap.get(acc.Id);
						if( (allPotValue > tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c && (allPotValue < tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c || tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c == null) || allPotValue == tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c)){
							fieldToUpdate = allRatingField;
							allPotFieldToUpdate = allPotField;
							fieldValueForAllRating = tempThreshold.ZTS_EU_Segmentation_Rating__c;
                            if((acc.get(allPotFieldToUpdate)!= allPotValue)||(acc.get(fieldToUpdate)!= fieldValueForAllRating) )
                            {
								acc.put(fieldToUpdate,fieldValueForAllRating);
								acc.put(allPotFieldToUpdate,allPotValue);
								isAccountUpdated = true;
                            }
						}
					}
					else if(innerMap.containsKey(tempThreshold.BU_Abbrv__c) && (tempThreshold.BU_Abbrv__c != AllBU) ){
                            Double BusUnitPotValue = innerMap.get(tempThreshold.BU_Abbrv__c);
							if( (BusUnitPotValue > tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c && (BusUnitPotValue < tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c || tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c == null) || BusUnitPotValue == tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c)){
							    ratingValForAccount = tempThreshold.ZTS_EU_Segmentation_Rating__c;
								ratingFieldtoUpdate =  ratingPrefix + (tempThreshold.BU_Abbrv__c.replace(' ',''))+ ratingSuffix;
								potentialFieldtoUpdate = potentialPrefix + (tempThreshold.BU_Abbrv__c.replace(' ','')) + potentialSuffix;
								if((acc.get(potentialFieldtoUpdate)!= BusUnitPotValue)||(acc.get(ratingFieldtoUpdate)!= ratingValForAccount) )
                            	{
                                	acc.put(ratingFieldtoUpdate,ratingValForAccount);
							    	acc.put(potentialFieldtoUpdate,BusUnitPotValue);
									isAccountUpdated = true;
                                }
								
							}
                    }
				}
			}
            if(isAccountUpdated){
				accountsToUpdateList.add(acc);
			}
				
        }
       
        //Final Account update logic
        Database.SaveResult[] sr = Database.update(accountsToUpdateList,false);
        for(Database.SaveResult succ : sr){
            if(succ.isSuccess()){
				system.debug('BRBSuccessfully updated Account,Account Id-->'+succ.getId());
            }
            else{
				for(Database.Error err: succ.getErrors()){
                    System.debug('BRBError is'+ err.getStatusCode() + 'ErrMessage is' + err.getMessage()) ;
                }
            }
        }
    }
    
     /**********************************************************************************************************************
    * author: Mayukh
    * Date: 07-SEP-2017
    * Param: BatchableContext object
    * Return: void
    * Description: Yet to be defined.  
    * Summary of Changes : 
    **********************************************************************************************************************/
    global void finish(Database.BatchableContext BC){
	    //Yet to use
	    
    }
}