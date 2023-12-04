/****************************************************************************************************************************************** 
* Class Name   : INTLAccountTriggerService
* Description  : Logic for all Account triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 06 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/06/2020          Created, Logic from all triggers moved to this class.
* Sathiya SB			  02/14/2023		  Added E164 standard for International Ph no. (SC-009335)
* Padma Nerella @ Zoetis  03/21/2023          TPDEV-105 Removed execution of ZTS_EU_Account_Vetsave_Functionality.updateParentAccount from afterInsert of an Account.
*****************************************************************************************************************************************/
public class INTLAccountTriggerService 
{
    public static void beforeInsert(List<Account> triggerNew) 
    {
        //SC-009335 - Extend phone number to E.164 formatting
        List<E164_Format__mdt> e164Lst = new List<E164_Format__mdt>();
        e164Lst = [SELECT id,Country__c,Country_Code__c,NumberofDigits__c from E164_Format__mdt];
        String countryCode = '';
        Integer digitinNum = 0;
        for (Account acc : triggerNew) {
            for(E164_Format__mdt e164Mdt : e164Lst)
           	   if (acc.ZTS_EU_Main_Phone__c != null && acc.ZTS_EU_Market__c == e164Mdt.Country__c ) {
                	countryCode = string.valueof(e164Mdt.Country_Code__c);
               	    digitinNum  = integer.valueof(e164Mdt.NumberofDigits__c);
                   
                	acc.ZTS_EU_Main_Phone__c = UtilityService.getE164FormattedPhoneNumber(acc.ZTS_EU_Main_Phone__c,countryCode,digitinNum , 'INTL');
            }
        }//SC-009335 End
        SL_AccountTriggerHandler objHandler = new SL_AccountTriggerHandler();
        objHandler.onBeforeInsert(triggerNew);
        
        // The lines -21 & 22 are addded by Chanbasha NBSK on 29/06/2021 for To Populate Territory Brick Code field during New Account creation 
        ZIP_TerritoryBrickCodePopulation brickcodepopulate = new ZIP_TerritoryBrickCodePopulation();
        brickcodepopulate.territoryBrickCodePopulation(triggerNew);
        /*if (ObjectSettings__c.getValues('Account') != null && ObjectSettings__c.getValues('Account').Active__c == true)
        {
            List<Account> AccountList = new List<Account>();
            
            for(Account acc: triggerNew)
            {
                try
                {
                    if (acc.get('IsPersonAccount') != null && acc.get('IsPersonAccount') == true)
                    {    
                        AccountList.add(acc);
                    }  
                }
                catch(Exception ex)
                {
                    system.debug('!!!exception!!! ' + ex);
                }
            } 
            if((AccountList.size()>0 && !AccountList.isEmpty()) || Test.isRunningTest())
            {
                TriggerHelperD.CheckToken(AccountList, 'Account', null);       
                TriggerHelperD.checkCommit(AccountList);
            }
        }*/
    }
    
    public static void beforeUpdate(List<Account> triggerOld, Map<Id, Account> triggerOldMap, List<Account> triggerNew, Map<Id, Account> triggerNewMap)
    {
        //SC-009335 - Extend phone number to E.164 formatting
        List<E164_Format__mdt> e164Lst = new List<E164_Format__mdt>();
        e164Lst = [SELECT id,Country__c,Country_Code__c,NumberofDigits__c from E164_Format__mdt];
        String countryCode = '';
        Integer digitinNum = 0;
        for (Account acc : triggerNew) {
            for(E164_Format__mdt e164Mdt : e164Lst)
            	if (acc.ZTS_EU_Main_Phone__c != null && acc.ZTS_EU_Main_Phone__c != triggerOldMap.get(acc.Id).ZTS_EU_Main_Phone__c && acc.ZTS_EU_Market__c == e164Mdt.Country__c ) {
                	countryCode = string.valueof(e164Mdt.Country_Code__c);
                	digitinNum  = integer.valueof(e164Mdt.NumberofDigits__c);
                	acc.ZTS_EU_Main_Phone__c = UtilityService.getE164FormattedPhoneNumber(acc.ZTS_EU_Main_Phone__c,countryCode,digitinNum,'INTL');
            }
        } //SC-009335 End
        SL_AccountTriggerHandler objHandler = new SL_AccountTriggerHandler();
 
        objHandler.onBeforeUpdate(triggerNew, triggerOldMap);
        
        
        /*if (ObjectSettings__c.getValues('Account') != null && ObjectSettings__c.getValues('Account').Active__c == true)
        {
            List<Account> AccountList = new List<Account>();
            
            for(Account acc: triggerNew)
            {
                try
                {
                    if (acc.get('IsPersonAccount') != null && acc.get('IsPersonAccount') == true)
                    {    
                        AccountList.add(acc);
                    }  
                }
                catch(Exception ex)
                {
                    system.debug('!!!exception!!! ' + ex);
                }
            } 
            if((AccountList.size()>0 && !AccountList.isEmpty()) || Test.isRunningTest())
            {
                TriggerHelperD.CheckToken(AccountList, 'Account', Trigger.oldMap);       
                TriggerHelperD.checkCommit(AccountList);
            }
        }*/
    }
    
    public static void beforeDelete(List<Account> triggerOld, Map<Id, Account> triggerOldMap) 
    {
        SL_AccountTriggerHandler objHandler = new SL_AccountTriggerHandler();
        objHandler.onBeforeDelete(triggerOld); 
    }
    
    public static void afterInsert(List<Account> triggerNew, Map<Id, Account> triggerNewMap)
    {
 
  

        SL_AccountTriggerHandler objHandler = new SL_AccountTriggerHandler();  
        ZTS_createAccountTeams.AccountTeamCreation(triggerNew);
        
        ZTS_EU_BUG_Parentpopulate.insertAccounts(triggerNew);
        
        //TPDEV-1095: added filters 
        List<Market_Setting__mdt> marketList = [ SELECT Id, Market__c, Exclude_Buying_Group_Account_Affiliation__c  FROM Market_Setting__mdt WHERE Exclude_Buying_Group_Account_Affiliation__c = true ];
        Map<String, Boolean> excludeBuyingGroupMarketsMap = new Map<String, Boolean>(); //map to hold market names and checkbox values
        for (Market_Setting__mdt marketSetting : marketList) {
            excludeBuyingGroupMarketsMap.put(marketSetting.Market__c, marketSetting.Exclude_Buying_Group_Account_Affiliation__c);
        }
        List<Account> recordsToProcess = new List<Account>(); //hold records that meet criteria
        for (Account acc: triggerNew) {
            if(!(excludeBuyingGroupMarketsMap.containsKey(acc.ZTS_EU_Market__c) && excludeBuyingGroupMarketsMap.get(acc.ZTS_EU_Market__c))) {
                recordsToProcess.add(acc);
            } 
        }
        if(recordsToProcess.size()>0) {
            ZTS_EU_BUG_AccountAffiliation.insertAffiliatesfromAccount(recordsToProcess);
        }
        
        
        ZTS_EU_addressCreationFromAccount.createAddressRecord(triggerNew);
        UtilityService.setAccountTriggerRunFalse(); 
        ZTS_addrCreationAndUpdateFromAccount.syncOptOutFlagGermany(triggerNew);        
        
        // Added by Sreekanth - SC-008755
        Set<String> marketSet = ZTS_EU_ZipToBrickAllignment.territoryMarkets(triggerNew);
        if(!marketSet.isEmpty()){
            ZTS_EU_ZipToBrickAllignment.assignTerritory(triggerNew, null, 'insert', marketSet);
        }
        
        /*if (ObjectSettings__c.getValues('Account') != null && ObjectSettings__c.getValues('Account').Active__c == true)
        {
            List<Account> AccountList = new List<Account>();
            
            for(Account acc: triggerNew)
            {
                try
                {
                    if (acc.get('IsPersonAccount') != null && acc.get('IsPersonAccount') == true)
                    {    
                        AccountList.add(acc);
                    }  
                }
                catch(Exception ex)
                {
                    system.debug('!!!exception!!! ' + ex);
                }
            } 
            if((AccountList.size()>0 && !AccountList.isEmpty()) || Test.isRunningTest())
            {
                TriggerHelperD.checkCommit2(AccountList, 'Account', null);   
            }
        }*/
    }
    
    public static void afterUpdate(List<Account> triggerOld, Map<Id, Account> triggerOldMap, List<Account> triggerNew, Map<Id, Account> triggerNewMap)
    {
        SL_AccountTriggerHandler objHandler = new SL_AccountTriggerHandler();    
        objHandler.onAfterUpdate(triggerNew,triggerOld, triggerOldMap, triggerNewMap);
        
        // Added by Sreekanth - SC-008755
        Set<Id> accId = new Set<Id>();
        for (Account acc : triggerNew) {
            if ((triggerOldMap.get(acc.id).ZTS_EU_Market__c != acc.ZTS_EU_Market__c) 
                  ||(triggerOldMap.get(acc.id).ZTS_EU_Sub_Type__c != acc.ZTS_EU_Sub_Type__c)
                  ||(triggerOldMap.get(acc.id).ZTS_EU_Zip_Postal_Code__c != acc.ZTS_EU_Zip_Postal_Code__c)) {
                accId.add(acc.Id);
            }
        } 
        if(!accId.isEmpty()){
            Set<String> marketSet = ZTS_EU_ZipToBrickAllignment.territoryMarkets(triggerNew);
            if(!marketSet.isEmpty()){
                ZTS_EU_ZipToBrickAllignment.assignTerritory(triggerNew, triggerOldMap, 'update', marketSet);
            }
        }//End SC-08755
        
        /*if (ObjectSettings__c.getValues('Account') != null && ObjectSettings__c.getValues('Account').Active__c == true)
        {
            List<Account> AccountList = new List<Account>();
            
            for(Account acc: triggerNew)
            {
                try
                {
                    if (acc.get('IsPersonAccount') != null && acc.get('IsPersonAccount') == true)
                    {    
                        AccountList.add(acc);
                    }  
                }
                catch(Exception ex)
                {
                    system.debug('!!!exception!!! ' + ex);
                }
            } 
            if((AccountList.size()>0 && !AccountList.isEmpty()) || Test.isRunningTest())
            {
                TriggerHelperD.checkCommit2(AccountList, 'Account', triggerOldMap);  
            }
        }*/
    }
    
    public static void afterDelete(List<Account> triggerOld, Map<Id, Account> triggerOldMap) 
    {
        SL_AccountTriggerHandler objHandler = new SL_AccountTriggerHandler();  
        objHandler.onAfterDelete(triggerOld);
    }
}