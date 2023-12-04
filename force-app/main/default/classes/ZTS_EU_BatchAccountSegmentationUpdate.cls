/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchAccountSegmentationUpdate.cls
   Description: Batch used for calculating the account potential FOR CLAR Markets per business unit and
                using that calculation for setting the appropriate account segmentation
                rating for each business unit. The account rating is fetched by finding the
                account segmentation threshold record with the corresponding range.
                    
   Date         Version Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
   12-01-2016   1.0     Saibal              Initial Version   
   01-08-2018           Aritra				Updated the Rating calculation logic for rating where Potential Threshold minimum value is blank (Defect SC-003710)	
------------------------------------------------------------------------------------------------------------------------ */


global class ZTS_EU_BatchAccountSegmentationUpdate implements Database.Batchable<sObject>{

    
    List<String> clarMarketList = new List<String>();
    
    public static String clarRegion = 'CLAR';
    Set<String> exceptionMarketSet = new Set<String>();
   
    //Saibal :  SOQL to get the Potential, Ratings at Account Level AND also to get the Account Species / Consultations (ZTS_EU_Account_Species_Potential__c) for the Accounts
    String query = 'SELECT Id,Name,ZTS_EU_Potential_Region__c,ZTS_EU_Market__c,'+
                        +'ZTS_EU_RAT_CA__c,ZTS_EU_RAT_EQ__c,ZTS_EU_RAT_PY__c,ZTS_EU_RAT_CADPre__c,ZTS_EU_RAT_CADTher__c,ZTS_EU_RAT_RU__c,ZTS_EU_RAT_SW__c,ZTS_EU_RAT_VPS__c,ZTS_EU_RAT_CTDY__c,ZTS_EU_RAT_CTFL__c,ZTS_EU_RAT_CTBF__c,ZTS_EU_All_Rating__c FROM Account' +
                        +' WHERE (ZTS_EU_Omit_Segmentation_Calculations__c = false AND ZTS_EU_Market__c IN:clarMarketList)' ;
                        
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
    public static String allPotentialField = 'ZTS_EU_All_Potential__c';
    public static String potentialPrefix = 'ZTS_EU_';
    public static String potentialSuffix = '_Potential__c';
    
    
    /**********************************************************************************************************************
    * author: Saibal
    * Date: 01-DEC-2016
    * Param: Database.BatchableContext BC
    * Return: QueryLocator Object 
    * Description: Returns the queryLocator object
    * Summary of Changes : 
    **********************************************************************************************************************/ 
    global Database.queryLocator start(Database.BatchableContext BC){
        system.debug('Selected account--->'+query);
        //Get the Market list for CLAR
        List<MarketGeoMapping__c> csList = MarketGeoMapping__c.getAll().values();
        for(MarketGeoMapping__c cs : csList){
            //if(cs.Geo__c == clarRegion){
                clarMarketList.add(cs.Name);
            //}
        }    
        return Database.getqueryLocator(query);
        
    }
    
    /**********************************************************************************************************************
    * author: Saibal
    * Date: 01-DEC-2016
    * Param: BatchableContext object,scope
    * Return: void
    * Description: This method calculates the total Calculated Potential Value 
     for every Business Unit for every Account, compares with the Account 
     Segmentation Threshold values, fetches the corresponding Rating and 
     updates the Account record.  
    * Summary of Changes : 
    **********************************************************************************************************************/
    global void execute(Database.BatchableContext BC,List<Account> scope){
        
        Map<Id,Map<String,Double>> acctIdWithBusUnitTotalPotMap = new Map<Id,Map<String,Double>>();
        Map<String,double> tempBusUnitPotMap = new  Map<String,double>(); 
        Map<Id,String> accountWithRatingMap = new Map<Id,String>();  
        List<Account> accountsToUpdateList = new List<Account>();
        String ratingFieldtoUpdate;
        String ratingValForAccount;
        String potentialFieldtoUpdate; 
        Double fieldValueForAllPotential;
        String fieldToUpdate;
        String fieldValueForAllRating;
        String potfieldToUpdate;
        Double potValueToUpdate;
        List<Double> allPotentialValuesList = new List<Double>();
        Map<Id,List<Double>> AcctWithPotValueMap = new Map<Id,List<Double>>();
        Set<String> remBUPot = new Set<String>();
        List<String> ascPotBUList = new List<String>();
        List<Id> accidList = new List<id>();
        Double sumPotential;
        
        List<ZTS_EU_Exception_Potential_Calculation__c> expList = ZTS_EU_Exception_Potential_Calculation__c.getall().values();
		for(ZTS_EU_Exception_Potential_Calculation__c e: expList){
		    exceptionMarketSet.add(e.ZTS_EU_Market__c);
		}
        for (Account a: scope)
        {
            accidList.add(a.Id);
        }
        Map <Account,List<ZTS_EU_Account_Species_Potential__c>> ascMapforAcc = new Map <Account,List<ZTS_EU_Account_Species_Potential__c>>();
        List<Account> accwithascList =  [SELECT Id,Name,ZTS_EU_Potential_Region__c,ZTS_EU_Market__c,ZTS_EU_RAT_CA__c,ZTS_EU_RAT_EQ__c,ZTS_EU_RAT_PY__c,
                                         ZTS_EU_RAT_CADPre__c,ZTS_EU_RAT_CADTher__c,ZTS_EU_RAT_RU__c,ZTS_EU_RAT_SW__c,ZTS_EU_RAT_VPS__c,ZTS_EU_RAT_CTDY__c,
                                         ZTS_EU_RAT_CTFL__c,ZTS_EU_RAT_CTBF__c,ZTS_EU_All_Rating__c,ZTS_EU_All_Potential__c,ZTS_EU_CA_Potential__c,ZTS_EU_EQ_Potential__c,
                                         ZTS_EU_RU_Potential__c,ZTS_EU_SW_Potential__c,ZTS_EU_PY_Potential__c,ZTS_EU_VPS_Potential__c,ZTS_EU_CTDY_Potential__c,
                                         ZTS_EU_CTFL_Potential__c,ZTS_EU_CTBF_Potential__c,ZTS_EU_CADPre_Potential__c,ZTS_EU_CADTher_Potential__c,
                                         (Select Id,Name,Account__c,ZTS_EU_BU_Abbr__c,ZTS_EU_Sum_Of_Account_Product_Potentials__c, Calculated_Value_of_Potentail__c, 
                                          ZTS_EU_Species_Potential_Value__c FROM Account_Species_Potentials__r) from Account where Id in :accidList AND ZTS_EU_Market__c != 'United States'];
        for (Account account: accwithascList)
        {
            ascMapforAcc.put(account, account.Account_Species_Potentials__r);
        }
        //Iterate on every Account from the scope
        for(Account acc : ascMapforAcc.keySet()){
        //system.debug('Account in scope--->'+acc.Name);
            fieldValueForAllPotential = 0.0;
            //Get the Account Species / Consultations (ZTS_EU_Account_Species_Potential__c) for the Account
            List<ZTS_EU_Account_Species_Potential__c> ascPotList = ascMapforAcc.get(acc);
            system.debug('Scopes related Acct Species Potential--->'+ascPotList);
                        
            //Iterate on each AccountSpeciesPotential record
            Map<String,Double> BusUnitPotentialValMap = new Map<String,Double>{CA => 0.0, EQ => 0.0, PY => 0.0, RU => 0.0, SW => 0.0, 
                                                                                VPS => 0.0, CTBF=> 0.0, CTFL => 0.0, CTDY => 0.0,CADPre => 0.0,CADTher => 0.0};
                                                                        
            system.debug('userCreatedMapToHoldBUFieldValues--->'+BusUnitPotentialValMap);    
            Set<String> allBUs = BusUnitPotentialValMap.keySet();
            if(!ascPotList.isEmpty()){
             //Iterate on each Account Species / Consultations (ZTS_EU_Account_Species_Potential__c) record for the Account record
             for(ZTS_EU_Account_Species_Potential__c tempASPRec : ascPotList){
                ascPotBUList.add(tempASPRec.ZTS_EU_BU_Abbr__c);
                Double calPotentialTotal = BusUnitPotentialValMap.get(tempASPRec.ZTS_EU_BU_Abbr__c);
                
                if(calPotentialTotal == null){
                    calPotentialTotal = 0;
                }
                //Create a map of BusinessUnit and its list of Calculated Potential Values (BusUnitPotentialValMap)
                //Changed using of Calculated Potential Value to Sum of Account Product Potential for the
                //necessary Potential Phase 2 changes - this will only be used for markets which are included in the
                //interim solution for now, until full Engine solution is deployed to Production
                
                calPotentialTotal += tempASPRec.Calculated_Value_of_Potentail__c;
                
                
                //Update BusUnitPotentialValMap Map to mainatain accumulated value of potential at each BU level for the account
                BusUnitPotentialValMap.put(tempASPRec.ZTS_EU_BU_Abbr__c,calPotentialTotal);
                                            
                //Sum all Potential Value for the account               
                fieldValueForAllPotential += calPotentialTotal;        
                
             }             
             
           }           
            
            //Maintain the map of Account <-> accumulated value of Potential Map for different BUs
            acctIdWithBusUnitTotalPotMap.put(acc.Id,BusUnitPotentialValMap);
            //Get the potential value list from the map into a list
            allPotentialValuesList = BusUnitPotentialValMap.values();
            //Maintain the map of Account <-> List of accumulated value of Potential
            AcctWithPotValueMap.put(acc.Id,allPotentialValuesList);
            system.debug('Account-->'+acc+'BU based PotentialMap -->'+AcctWithPotValueMap);
            
        }
        //Create a map that contains Account with the total potential value
        Map<Id,Double> acctAndTotalPotValueFinalMap = new Map<Id,Double>();
        Double totalPotValue =0;
        for(Account acc: ascMapforAcc.keySet()) {
            //Get the List of accumulated value of Potential from Account <-> List            
            List<Double> tempList = AcctWithPotValueMap.get(acc.Id);
            for(Double tempDouble : tempList){
                    totalPotValue = totalPotValue + tempDouble;
            }
            //Maintain the map of Account <-> TOTAL value of Potential
            acctAndTotalPotValueFinalMap.put(acc.Id,totalPotValue);
            system.debug('Account-->'+acc+'TotalAccountPotential -->'+acctAndTotalPotValueFinalMap);
        }
        //Aritra: 10/07: Added this part to accumulate the source potential field values to Dest. Potential fields for exception countries
        for(Account ac : ascMapforAcc.keySet())
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
        
        // This section of the code checks if the threshold amount matches the Account's Potential Value and copies the Segmentation Rating.
        List<Account_Segmentation_threshold__c> acctSegThresholdList =  [SELECT Id,
                                                                                ZTS_EU_Market__c,   
                                                                                ZTS_EU_Segmentation_Rating__c,
                                                                                ZTS_EU_Threshold_Minimum_Value_Potential__c,
                                                                                ZTS_EU_Threshold_Maximum_Value_Potential__c,
                                                                                BU_Abbrv__c
                                                                        FROM    Account_Segmentation_threshold__c];
                                                                       
        for(Account acc : ascMapforAcc.keySet()) {     
             
            system.debug('Threshold records found are--->'+acctSegThresholdList);
            //Read the map of Account <-> accumulated value of Potential Map for different BUs - which was created earlier at line 140
            //and get the Business UNit to Potential value map for the acc
            Map<String,Double> innerMap =  acctIdWithBusUnitTotalPotMap.get(acc.Id);
            system.debug('InnerMap contents--->'+innerMap);
            Boolean isAccountUpdated = false;
            //Iterate through all Account Segmentation Threshold
            for(Account_Segmentation_threshold__c tempThreshold : acctSegThresholdList) {
                if(acc.ZTS_EU_Market__c ==  tempThreshold.ZTS_EU_Market__c) {  
                    //Calculate Overall Rating
                    if(tempThreshold.BU_Abbrv__c.replace(' ','') == AllBU){
                        system.debug('Threshold is All Rating');
                            system.debug('thresholdAll'+tempThreshold.BU_Abbrv__c);
                            system.debug('thresholdAll'+tempThreshold.BU_Abbrv__c);
                            Double allRatingValue = acctAndTotalPotValueFinalMap.get(acc.Id);
                            system.debug('CalculatedTotalAccountPotentialvalue is--->'+allRatingValue+'for the Account ---->'+acc.Name);
                            /*if(allRatingValue>tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c && allRatingValue < tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c || allRatingValue == tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c)*///Commented and added the below part as part of Defect SC-003710
                        /*if( (allRatingValue > tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c && (allRatingValue < tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c || tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c == null) || allRatingValue == tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c)){*/    
                        if((allRatingValue > tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c || (tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c == null && allRatingValue > 0)) && 
							(allRatingValue < tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c || tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c == null || allRatingValue == tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c)
                              ){
                                system.debug('Found the match in threshold');
                                system.debug('ThresholdRatingfetched for Account-->'+acc.Id+'is'+tempThreshold.ZTS_EU_Segmentation_Rating__c);
                                    fieldToUpdate = allRatingField;
                                    fieldValueForAllRating = tempThreshold.ZTS_EU_Segmentation_Rating__c; 
                                   //Aritra: 10/07: Added
                                    potfieldToUpdate = allPotentialField;
                                    potValueToUpdate = allRatingValue;
                                
                                    if((acc.get(fieldToUpdate) != fieldValueForAllRating)||(acc.get(potfieldToUpdate) != potValueToUpdate) ){
                                        acc.put(fieldToUpdate,fieldValueForAllRating);
                                        acc.put(potfieldToUpdate,potValueToUpdate);
                                        isAccountUpdated = true;
                                    }
                            }                     
                    }
                    
                    else if(innerMap.containsKey(tempThreshold.BU_Abbrv__c) && (tempThreshold.BU_Abbrv__c != AllBU)) {
                        system.debug('Matched BU--->'+tempThreshold.BU_Abbrv__c);
                        Double BusUnitPotValue = innerMap.get(tempThreshold.BU_Abbrv__c);
                        system.debug('BUValue--->'+tempThreshold.BU_Abbrv__c+'and its potential value is --->'+BusUnitPotValue);
                        
                        /*if(( BusUnitPotValue > tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c && BusUnitPotValue < tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c) || BusUnitPotValue == tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c) */
                        //Commented and added the below part as part of Defect SC-003710
                        /*if(BusUnitPotValue > tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c && (BusUnitPotValue < tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c || tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c == null) || BusUnitPotValue == tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c)){
                          )*/
                        if((BusUnitPotValue > tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c || (tempThreshold.ZTS_EU_Threshold_Minimum_Value_Potential__c == null && BusUnitPotValue > 0)) && 
						   (BusUnitPotValue < tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c || tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c == null || BusUnitPotValue == tempThreshold.ZTS_EU_Threshold_Maximum_Value_Potential__c)
                          ){
                 			 system.debug('matched BU threshold record');
                            system.debug('For the Business Unit --'+tempThreshold.BU_Abbrv__c+'the rating value found is'+tempThreshold.ZTS_EU_Segmentation_Rating__c); 
                            ratingValForAccount = tempThreshold.ZTS_EU_Segmentation_Rating__c;
                            system.debug('For Bu--'+tempThreshold.BU_Abbrv__c+'The RatingValueforAccount is --'+ratingValForAccount);
                            
                            ratingFieldtoUpdate =  ratingPrefix + (tempThreshold.BU_Abbrv__c.replace(' ',''))+ ratingSuffix;
                            potfieldToUpdate = potentialPrefix + (tempThreshold.BU_Abbrv__c.replace(' ',''))+ potentialSuffix;
                            potValueToUpdate = BusUnitPotValue;
                            system.debug('For Bu--'+tempThreshold.BU_Abbrv__c+'The Ratingfieldtogetupdted is --'+ratingFieldtoUpdate);
                            if((acc.get(ratingFieldtoUpdate) != ratingValForAccount)||(acc.get(potfieldToUpdate) != potValueToUpdate)) {
                                acc.put(ratingFieldtoUpdate,ratingValForAccount);
                                acc.put(potfieldToUpdate,potValueToUpdate);
                                isAccountUpdated = true;
                            }
                            
                        }//end of inner IF
                        
                    }//end of outer IF
                    
                }//end of IF(that checks if the market is the same)     
                
            }//end of inner FOR
            
            //Update the account if any of its ratings actually changed.
            if(isAccountUpdated) {
                accountsToUpdateList.add(acc);

            }
        
        }//end of Outer FOR
        //Update the AccountsList
        //Code added to remove duplicates from List
        Set<Account> AcctSet = new Set<Account>();
        List<Account> UniqueAcctList = new List<Account>();
        AcctSet.addAll(accountsToUpdateList);
        UniqueAcctList.addAll(AcctSet);
        Database.SaveResult[] sr = Database.update(UniqueAcctList,false);
        for(Database.SaveResult succ : sr){
            if(succ.isSuccess()){
                //Operation successful, Account updated ID is
                system.debug('BRBSuccessfully updated Account,Account Id-->'+succ.getId());
            }
            else{
                //Operation failed,get the error
                for(Database.Error err: succ.getErrors()) {
                    System.debug('BRBError is'+ err.getStatusCode() + 'ErrMessage is' + err.getMessage()) ;
                }
            }
        }
    }
    
     /**********************************************************************************************************************
    * author: Saibal
    * Date: 01-DEC-2016
    * Param: BatchableContext object
    * Return: void
    * Description: Yet to be defined.  
    * Summary of Changes : 
    **********************************************************************************************************************/
    global void finish(Database.BatchableContext BC){
    //yet to be defined
    }
}