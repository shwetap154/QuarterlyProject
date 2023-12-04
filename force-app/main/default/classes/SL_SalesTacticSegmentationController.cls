/**
* @ClassName    : SL_SalesTacticSegmentationController 
* @JIRATicket   : LIGHTNI-161
* @CreatedOn    : 15th May 2019
* @CreatedBy    : Prem
* @ModifiedBy   : 
* @Description  : Controller class for the Lightning Component(SL_SalesTacticSegmentation.cmp) for dispalying 
                  the Sales Tactic Segmentation data. 
* @Update Logs  :
***********************************************************************************************
Date                Author                  Description/Comments
***********************************************************************************************
April-2020          Aritra(Cognizant)       Added code to accumulate SUB BU data in Parent BU. Accumulation logic is present in 
                                            custom settings ZTS_EU_Exception_Potential_Calculation__c. Only one row for Parent BU 
                                            will be added in the list instead of SUB BU rows. Canada will have a separate
											EQ Related record. See SC-004846.
May-2020			Aritra(Cognizant)		Corrected the API Name finding logic for the Rating fields to enable non-english users.
											See SC-004858.
*/
public with sharing class SL_SalesTacticSegmentationController {
    
    public class SalesTacticSegmentation {
       
        @AuraEnabled 
        public String BusinessUnit;
        @AuraEnabled 
        public String Rating;
        @AuraEnabled 
        public Decimal Potential;
        @AuraEnabled 
        public Decimal Sales;
        @AuraEnabled 
        public Decimal Penetration;
        @AuraEnabled 
        public String SalesTactic;
        
        public SalesTacticSegmentation( String BusinessUnit, String Rating, Decimal Potential, 
                                        Decimal Sales, Decimal Penetration, String SalesTactic) {
            
            this.BusinessUnit = BusinessUnit;
            this.Rating = Rating;
            this.Potential = Potential;
            this.Sales = Sales;
            this.Penetration = Penetration;
            this.SalesTactic = SalesTactic;
        }
    }
    
    @AuraEnabled
    public static List<SalesTacticSegmentation> fetchSegmentationData(Id AccountId) {
        
        List<SalesTacticSegmentation> lstSalesTacticSegmentation = new List<SalesTacticSegmentation>();//final list
        set<String> setAccountFieldNames = new set<String>();
        
        //lines added by Aritra - SC-004846 starts here
        List<SalesTacticSegmentation> lstAllSTS = new List<SalesTacticSegmentation>();//initial list
        Boolean runAccumCalculation = FALSE;
        Set<String> setAccumAffectedBU = new Set<String>();
        Map<String,Set<String>> mapBUaccumulation = new Map<String,Set<String>>();
        Set<String> sourceBUSet = new Set<String>();
        String ratingPrefix = 'ZTS_EU_RAT_';//Added for (SC-004858)
        String ratingSuffix = '__c';//Added for (SC-004858)
        Set<String> exceptionMarketSet = new Set<String>();
        List<ZTS_EU_Exception_Potential_Calculation__c> expList = ZTS_EU_Exception_Potential_Calculation__c.getall().values();
        for(ZTS_EU_Exception_Potential_Calculation__c e: expList){
            exceptionMarketSet.add(e.ZTS_EU_Market__c);
        }
        List<Account> lstAcc = Database.query('Select ZTS_EU_Market__c from Account WHERE Id =: AccountId AND ZTS_EU_Market__c != \'United States\'' );
        if(exceptionMarketSet.contains(lstAcc[0].ZTS_EU_Market__c))
        { 
            runAccumCalculation = TRUE;
            for(ZTS_EU_Exception_Potential_Calculation__c e: expList)
                {
                    if(e.ZTS_EU_Market__c == lstAcc[0].ZTS_EU_Market__c)
                    {
                        setAccumAffectedBU.add(e.ZTS_EU_BU__c);
                        setAccumAffectedBU.addAll(e.ZTS_EU_Potential_Fields_to_Sum_up__c.split(';'));
                        sourceBUSet.addAll(e.ZTS_EU_Potential_Fields_to_Sum_up__c.split(';'));
                        mapBUaccumulation.put(e.ZTS_EU_BU__c, sourceBUSet);
                        setAccountFieldNames.add(ratingPrefix +e.ZTS_EU_BU__c.replace(' ','')+ ratingSuffix); //Adding the parent BU from Custom Setting in the BU list to be fetched
                    }
                }
        }
        system.debug('setAccumAffectedBU>>>>>>'+setAccumAffectedBU);
        //lines added by Aritra - SC-004846 ends here
        
        map<String, List<ZTS_EU_Account_Species_Potential__c>> mapASPGroupedByBusinessUnit = fetchAndGroupASP(AccountId);
        map<String, List<ZTS_EU_Sales__c>> mapSalesGroupedByBusinessUnit = fetchAndGroupSales(AccountId);
        map<String, Sales_Tactic__c> mapSalesTactic = new map<String, Sales_Tactic__c>();
        
        if( !mapASPGroupedByBusinessUnit.keyset().isEmpty() )  {
            
            for(String strBusinessUnit : mapASPGroupedByBusinessUnit.keySet()) {
                setAccountFieldNames.add(ratingPrefix + strBusinessUnit.replace(' ','') + ratingSuffix);// build Rating field API name (SC-004858)
            }
            system.debug('setAccountFieldNames---------'+setAccountFieldNames);
            //map<String, String> mapAccountFields = fetchFieldAPINames( setAccountFieldNames );
            //system.debug('mapAccountFields---------'+mapAccountFields);
            String query = 'SELECT ZTS_EU_Market__c, ' + String.join( new List<String>( setAccountFieldNames ), ', ' ) + ' FROM Account WHERE Id =: AccountId';
            system.debug (query);
            List<Account> lstAccount = Database.query( query);
            system.debug('lstAccount%%%%%%%'+lstAccount);
            /*for(Sales_Tactic__c st : [Select BU_Abbrv__c, Penetration_Threshold__c, Potential_Threshold__c
                                          From Sales_Tactic__c
                                          Where BU_Abbrv__c IN : mapASPGroupedByBusinessUnit.keySet()
                                          AND Market__c =: lstAccount[0].ZTS_EU_Market__c ]) {*/// commented this SOQL and added below SOQL (Added by Aritra for SC-004846)
            
            for(Sales_Tactic__c st : [Select BU_Abbrv__c, Penetration_Threshold__c, Potential_Threshold__c
                                          From Sales_Tactic__c
                                          Where Market__c =: lstAccount[0].ZTS_EU_Market__c ]) {
                mapSalesTactic.put(st.BU_Abbrv__c, st);
            }
            
            for(String strBusinessUnit : mapASPGroupedByBusinessUnit.keySet()) {
                
                String rating = (String)lstAccount[0].get( ratingPrefix + strBusinessUnit.replace(' ','') + ratingSuffix );// build Rating field API name(SC-004858)
                Decimal totalPotential = 0;
                for(ZTS_EU_Account_Species_Potential__c objAPP : mapASPGroupedByBusinessUnit.get(strBusinessUnit)) {
                    totalPotential += objAPP.Calculated_Value_of_Potentail__c;
                }
                
                Decimal totalSales = 0;
                if(mapSalesGroupedByBusinessUnit.keyset().contains(strBusinessUnit)) {
                    for(ZTS_EU_Sales__c objSales : mapSalesGroupedByBusinessUnit.get(strBusinessUnit)) {
                        totalSales += objSales.ZTS_EU_Total_MAT_Current_Sales__c;
                    }
                }
                
                Decimal penetration = 0;
                if(totalPotential > 0)
                    penetration = (totalSales/totalPotential);
                
                String salesTactic = 'N/A';
                
                //String salesTacticKey = strBusinessUnit + '<-->' + rating;
                if(mapSalesTactic.containsKey(strBusinessUnit)) {
                    Sales_Tactic__c objST = mapSalesTactic.get(strBusinessUnit);
                    Decimal penPercentage = penetration * 100;
                    if(penPercentage > objST.Penetration_Threshold__c && totalPotential > objST.Potential_Threshold__c)
                        salesTactic = 'SWITCH';
                    else if(penPercentage < objST.Penetration_Threshold__c && totalPotential > objST.Potential_Threshold__c)
                        salesTactic = 'GROW';
                    else if(penPercentage < objST.Penetration_Threshold__c && totalPotential < objST.Potential_Threshold__c)
                        salesTactic = 'DEVELOP';
                    else if(penPercentage > objST.Penetration_Threshold__c && totalPotential < objST.Potential_Threshold__c)
                        salesTactic = 'ALTERNATIVE';
                }
                    
                lstAllSTS.add( new SalesTacticSegmentation(strBusinessUnit, rating, totalPotential, totalSales, penetration, salesTactic) );//adding SUB BU details in initial list
                
            }
            // Added by Aritra - SC-004846
            if(runAccumCalculation == TRUE)//
            {
                //Adding non-affected BUs from initial list to final list
                for(SalesTacticSegmentation obj: lstAllSTS)
                {
                    if(!setAccumAffectedBU.contains(obj.BusinessUnit)||((lstAccount[0].ZTS_EU_Market__c == 'Canada') && (obj.BusinessUnit == 'EQ' )))//For Canada EQ Record should be visible(SC-004846)
                    {
                        lstSalesTacticSegmentation.add(obj);
                    }
                }
                //Accumulation calculation and Parent BU added in final List
                for (String accBU: mapBUaccumulation.keyset())
                {
                    String accumulatedRating;
                    Decimal accumulatedPotential =0;
                    Decimal accumulatedSales=0;
                    Decimal accumulatedPenetration = 0;
                    String accumulatedST = 'N/A';
                    accumulatedRating = (String)lstAccount[0].get( ratingPrefix + accBU.replace(' ','') + ratingSuffix ); // build Rating field API name(SC-004858)
                    for(SalesTacticSegmentation sts: lstAllSTS)
                    {
                        if(mapBUaccumulation.get(accBU).contains(sts.BusinessUnit))
                        {
                            accumulatedPotential = accumulatedPotential+sts.Potential;
                            accumulatedSales = accumulatedSales+sts.Sales;
                            
                        }
                        
                    }
                    if(accumulatedPotential>0){accumulatedPenetration = (accumulatedSales/accumulatedPotential);}
                    //for Tactic calculation:
                    if(mapSalesTactic.containsKey(accBU)) {
                        Sales_Tactic__c objST = mapSalesTactic.get(accBU);
                        Decimal penPercentage = accumulatedPenetration * 100;
                        if(penPercentage > objST.Penetration_Threshold__c && accumulatedPotential > objST.Potential_Threshold__c)
                            accumulatedST = 'SWITCH';
                        else if(penPercentage < objST.Penetration_Threshold__c && accumulatedPotential > objST.Potential_Threshold__c)
                            accumulatedST = 'GROW';
                        else if(penPercentage < objST.Penetration_Threshold__c && accumulatedPotential < objST.Potential_Threshold__c)
                            accumulatedST = 'DEVELOP';
                        else if(penPercentage > objST.Penetration_Threshold__c && accumulatedPotential < objST.Potential_Threshold__c)
                            accumulatedST = 'ALTERNATIVE';
                    }
                    //for Tactic calculation: ends
                    lstSalesTacticSegmentation.add( new SalesTacticSegmentation(accBU, accumulatedRating, accumulatedPotential, accumulatedSales, accumulatedPenetration, accumulatedST) );
                    
                }
                
            }
            else{ lstSalesTacticSegmentation.addAll(lstAllSTS);}
            // Added by Aritra - SC-004846 - ends here
             
        }
        system.debug('lstSalesTacticSegmentation&&&&&&&'+lstSalesTacticSegmentation);
        return lstSalesTacticSegmentation;
    }
    
    private static map<String, List<ZTS_EU_Account_Species_Potential__c>> fetchAndGroupASP(Id AccountId) {
        
        map<String, List<ZTS_EU_Account_Species_Potential__c>> mapASPGroupedByBusinessUnit = new map<String, List<ZTS_EU_Account_Species_Potential__c>>();
        for(ZTS_EU_Account_Species_Potential__c objASP : [Select Calculated_Value_of_Potentail__c, ZTS_EU_BU_Abbr__c
                                                          From ZTS_EU_Account_Species_Potential__c
                                                          Where Account__c =: AccountId] ) {
            
            if(mapASPGroupedByBusinessUnit.containsKey(objASP.ZTS_EU_BU_Abbr__c))
                mapASPGroupedByBusinessUnit.get(objASP.ZTS_EU_BU_Abbr__c).add( objASP );
            else 
                mapASPGroupedByBusinessUnit.put(objASP.ZTS_EU_BU_Abbr__c, new List<ZTS_EU_Account_Species_Potential__c>{ objASP });
        }
        
        return mapASPGroupedByBusinessUnit;
    }
    
    private static map<String, List<ZTS_EU_Sales__c>> fetchAndGroupSales(Id AccountId) {
        
        map<String, List<ZTS_EU_Sales__c>> mapSalesGroupedByBusinessUnit = new map<String, List<ZTS_EU_Sales__c>>();
        for(ZTS_EU_Sales__c objSales : [Select ZTS_EU_Total_MAT_Current_Sales__c, ZTS_EU_Business_Units__c
                                      From ZTS_EU_Sales__c
                                      Where ZTS_EU_Account__c =: AccountId] ) {
            
            if(mapSalesGroupedByBusinessUnit.containsKey( objSales.ZTS_EU_Business_Units__c ))
                mapSalesGroupedByBusinessUnit.get( objSales.ZTS_EU_Business_Units__c ).add( objSales );
            else 
                mapSalesGroupedByBusinessUnit.put( objSales.ZTS_EU_Business_Units__c, new List<ZTS_EU_Sales__c>{ objSales });
        }
        
        return mapSalesGroupedByBusinessUnit;
    }
    //Commenting the below method as API Name generation is done by formula in above method "fetchSegmentationData" itself (SC-004858)
    /*private static map<String, String> fetchFieldAPINames( set<String> setAccountFieldNames ) {
        
        map<String, String> mapFields = new map<String, String>();
        Map<String, Schema.SObjectField> AccountFieldMap = Account.getSObjectType().getDescribe().fields.getMap();
        system.debug('AccountFieldMap--'+AccountFieldMap);
        for(String strField : AccountFieldMap.keyset()) {
            Schema.DescribeFieldResult desribedFieldResult = AccountFieldMap.get(strField).getDescribe();
            system.debug('desribedFieldResult--'+desribedFieldResult);
            if( setAccountFieldNames.contains( desribedFieldResult.getLabel() ))
                mapFields.put( desribedFieldResult.getLabel(), desribedFieldResult.getName() );
        }
        
        return mapFields;
    }*/
}