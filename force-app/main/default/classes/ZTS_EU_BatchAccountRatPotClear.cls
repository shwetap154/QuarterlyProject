/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchAccountRatPotClear.cls
   Description: Batch used for clearing the account Rating and Potential FOR International Markets which have Account Segmentation Threshold created for them.
   Date         Version   Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
   18-09-2017   1.0       Mayukh              Initial Version       
------------------------------------------------------------------------------------------------------------------------ */

global class ZTS_EU_BatchAccountRatPotClear implements Database.Batchable<sObject> /*Database.Stateful*/{
    List<string> csMarketList = new List<String>();
    Set<String> astMarketSet= new Set<String>();
    List<Account_Segmentation_threshold__c> acctSegThresholdList = [SELECT Id,ZTS_EU_Market__c,ZTS_EU_Segmentation_Rating__c,ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c,BU_Abbrv__c FROM Account_Segmentation_threshold__c];
    Set<string> finalMarketSet = new Set<string>();
    List<Account> accList = new List<Account>();
    Set<Account> accSet = new Set<Account>();
    
    //SOQL to get the Account Species/Consultations (ZTS_EU_Account_Species_Potential__c) for the all International Markets
    String query = 'SELECT Id,ZTS_EU_RAT_CA__c,ZTS_EU_RAT_EQ__c,ZTS_EU_RAT_PY__c,ZTS_EU_RAT_RU__c,ZTS_EU_RAT_SW__c,ZTS_EU_RAT_VPS__c,ZTS_EU_RAT_CTDY__c,ZTS_EU_RAT_CTFL__c,ZTS_EU_RAT_CTBF__c,ZTS_EU_RAT_CADPre__c,ZTS_EU_RAT_CADTher__c,ZTS_EU_All_Rating__c,ZTS_EU_All_Potential__c,ZTS_EU_CA_Potential__c,ZTS_EU_EQ_Potential__c,ZTS_EU_RU_Potential__c,ZTS_EU_SW_Potential__c,ZTS_EU_PY_Potential__c,ZTS_EU_VPS_Potential__c,ZTS_EU_CTDY_Potential__c,ZTS_EU_CTFL_Potential__c,ZTS_EU_CTBF_Potential__c,ZTS_EU_CADPre_Potential__c,ZTS_EU_CADTher_Potential__c FROM Account WHERE ZTS_EU_Account_Status__c = \'Active\' AND ZTS_EU_Omit_Segmentation_Calculations__c = false AND ZTS_EU_Market__c IN:finalMarketSet';
        
    /**********************************************************************************************************************
    * Author: Mayukh
    * Date: 18-SEP-2017
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
                finalMarketSet.add(mCheck);
            }
        }
        return Database.getqueryLocator(query);
    }
    
    /**********************************************************************************************************************
    * author: Mayukh
    * Date: 18-SEP-2017
    * Param: BatchableContext object,scope
    * Return: void
    * Description: This method calculates the total Calculated Potential Value 
     for every Business Unit for every Account, compares with the Account 
     Segmentation Threshold values, fetches the corresponding Rating and 
     updates the Account record.  
    * Summary of Changes : 
    **********************************************************************************************************************/
    global void execute(Database.BatchableContext BC,List<Account> scope){
        //Iterate on every Account from the scope and clear all the Rating and Potential field values
        for (Account acc : scope){
            accSet.add(acc);
        }
        
        accList.addall(accSet);
        
        for(Account acc : accList){
            acc.ZTS_EU_RAT_CA__c = '';
            acc.ZTS_EU_RAT_EQ__c = '';
            acc.ZTS_EU_RAT_PY__c = '';
            acc.ZTS_EU_RAT_RU__c = '';
            acc.ZTS_EU_RAT_SW__c = '';
            acc.ZTS_EU_RAT_VPS__c = '';
            acc.ZTS_EU_RAT_CTDY__c = '';
            acc.ZTS_EU_RAT_CTFL__c = '';
            acc.ZTS_EU_RAT_CTBF__c = '';
            acc.ZTS_EU_RAT_CADPre__c = '';
            acc.ZTS_EU_RAT_CADTher__c = '';
            acc.ZTS_EU_All_Rating__c = '';
            acc.ZTS_EU_All_Potential__c = null;
            acc.ZTS_EU_CA_Potential__c = null;
            acc.ZTS_EU_EQ_Potential__c = null;
            acc.ZTS_EU_RU_Potential__c = null;
            acc.ZTS_EU_SW_Potential__c = null;
            acc.ZTS_EU_PY_Potential__c = null;
            acc.ZTS_EU_VPS_Potential__c = null;
            acc.ZTS_EU_CTDY_Potential__c = null;
            acc.ZTS_EU_CTFL_Potential__c = null;
            acc.ZTS_EU_CTBF_Potential__c = null;
            acc.ZTS_EU_CADPre_Potential__c = null;
            acc.ZTS_EU_CADTher_Potential__c = null;
        }
        
        //Final Account update
        Database.SaveResult[] sr = Database.update(accList,false);
        
        //Error Debug Logic
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
    * Date: 18-SEP-2017
    * Param: BatchableContext object
    * Return: void
    * Description: Yet to be defined.  
    * Summary of Changes : 
    **********************************************************************************************************************/
    global void finish(Database.BatchableContext BC){
        //Yet to implement
    }
}