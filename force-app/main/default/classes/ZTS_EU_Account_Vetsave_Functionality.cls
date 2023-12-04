/*************************************************************************************************************************
    Class Name     : ZTS_EU_Account_Vetsave_Functionality
    Description    : This class is called from trigger on account for updating parent account for all accounts in U.K and Ireland.
    as per business rule.
        : When Account is created or undeleted where Vetsave HO ID is filled in and HO Flag = false (so no Headoffice): 
        Link this Account to the Parent Account which has this Vetsave ID and HO Flag = true.
        : When Account is updated where Vetsave HO ID is filled in and HO Flag = false (so no Headoffice): 
        Link this Account to the Parent Account which has this Vetsave ID and HO Flag = true.
        : When Account is created or undeleted where Vetsave ID is filled in and HO Flag = true (so is a Headoffice): 
        Look for all Accounts where Vetsave HO ID is filled with the Vetsave ID of this Headoffice and HO Flag = false and link these Accounts to the Parent.
        : When Account is updated where Vetsave ID is filled in and HO Flag = true (so is a Headoffice): 
        Look for all Accounts where Vetsave HO ID is filled with the Vetsave ID of this Headoffice and HO Flag = false and link these Accounts to the Parent.
        : For Ireland Market
        : When Account is created or undeleted where ZTS_EU_Ref_ID2_Value__c is filled in and HO Flag = false (so no Headoffice): 
        Link this Account to the Parent Account which has this ZTS_EU_Ref_ID1_Value__c and HO Flag = true.
        : When Account is updated where ZTS_EU_Ref_ID2_Value__c is filled in and HO Flag = false (so no Headoffice): 
        Link this Account to the Parent Account which has this ZTS_EU_Ref_ID1_Value__c and HO Flag = true.
        : When Account is created or undeleted where ZTS_EU_Ref_ID1_Value__c is filled in and HO Flag = true (so is a Headoffice): 
        Look for all Accounts where ZTS_EU_Ref_ID2_Value__c is filled with the ZTS_EU_Ref_ID1_Value__c of this Headoffice and HO Flag = false and link these Accounts to the Parent.
        : When Account is updated where ZTS_EU_Ref_ID1_Value__c is filled in and HO Flag = true (so is a Headoffice): 
        Look for all Accounts where ZTS_EU_Ref_ID2_Value__c is filled with the ZTS_EU_Ref_ID1_Value__c of this Headoffice and HO Flag = false and link these Accounts to the Parent.
                     
    Created By     : Teresa
    Created On     : 04/07/2014
                                                             
    Modification Log    :
    -----------------------------------------------------------------------------------------------------------------------
    Developer                            Date                   Description
    ---------                            ----                 -----------
    Teresa                            04/07/2014              Created
    Priya Krishnamurthy               02/03/2016              Modified to expand functionality for multiple markets.
    Chandana                          07/07/2016              Modified code to split the transaction of records using future method
    Morgan Marchese                   12/01/2020              Fixed messy code formatting, replaced multiple map.get() calls which  
                                                              pulled individual field values with a single Account reference 
                                                              to improve CPU performance. Improved overall readability.
***************************************************************************************************************************/
public class ZTS_EU_Account_Vetsave_Functionality
{   
    static Map<String,Account> accountHoMap;
    static List<String> oldHOIds; 
    static List<String> accIds;
    static List<String> oldHOIdsForHO;
    static Map<String,Account> accountHoMapIreland;
    static List<String> oldHOIdsIreland; 
    static List<String> HOIdsIreland; 
    static List<String> accIdsIreland; 
    static List<String> oldHOIdsForHOAccountsIreland;
    static List<Account> accountUpdate;
        
    /***********
     * Method name  : updateParentAccount
     * Description  : This will update parent Account Id if there is a valid Vetsave HO Id field filled.
     * Return Type  : None.
     * Parameters   : trigger parameters.
     ***********/
            
    public static void updateParentAccount(List<Account> triggerNew, Map<Id,Account> triggerOldMap, 
                                    Boolean triggerIsUpdate, Boolean triggerIsBefore, Boolean triggerIsAfter)
    {
        Id acctId;
        String accountMarket = '';
        String vetSaveId;
        String oldVetSaveId;
        String vetSaveHomeId;
        String oldVetSaveHomeId;
        String refId1;
        String oldRefId1;
        String refId2;
        String oldRefId2;
        Boolean isHomeOffice = false;
        Boolean isOldHomeOffice = false;
        Account oldAccount;
        Account homeOfficeAccount;
        Set<String> accountMarkets = new Set<String>();
        Set<String> accountMarketsUK = new Set<String>();
        try {
            // Variables for UK Market
            List<Account> accountList = new List<Account>();
            List<String> HOIds = new List<String>();
            accountUpdate = new List<Account>();
            accountHoMap = new Map<String,Account>();
            accIds = new List<String>();
            oldHOIds = new List<String>();
            oldHOIdsForHO = new List<String>();
            Set<String> vetsaveUK = new Set<String>();
                
            // Variables for Ireland Market
            List<Account> accountListIreland = new List<Account>();
            accountHoMapIreland = new Map<String,Account>();
            HOIdsIreland = new List<String>();
            accIdsIreland = new List<String>();
            oldHOIdsIreland = new List<String>();
            oldHOIdsForHOAccountsIreland = new List<String>();

            //HO Accounts that have their Ref Id1 and Ref Id2 updated but are still HO Accounts
               
            Map<string, VetSave_Market__c> marketMap = new Map<string, VetSave_Market__c>();
            List<VetSave_Market__c> markets = VetSave_Market__c.getall().values();
                
            for(VetSave_Market__c customValues:markets){
                marketMap.put(customValues.name,customValues);
            }
            Map<string, Vetsave_UK__c> marketMapUK = new Map<string, Vetsave_UK__c>();
            List<Vetsave_UK__c> marketsUK = Vetsave_UK__c.getall().values();
            for(Vetsave_UK__c customValues : marketsUK){
                marketMapUK.put(customValues.name,customValues);
            }
                
            // loop through the existing accounts and create a map of all accounts have same HO
            for(Account a : triggerNew){
                acctId = a.Id;
                accountMarket = a.ZTS_EU_Market__c;
                vetSaveId = a.ZTS_EU_Vetsave_ID__c;
                vetSaveHomeId = a.ZTS_EU_Vetsave_HO_ID__c;
                isHomeOffice = a.ZTS_EU_HO_Flag__c;
                refId1 = a.ZTS_EU_Ref_ID1_Value__c;
                refId2 = a.ZTS_EU_Ref_ID2_Value__c;
                oldAccount = triggerOldMap.get(acctId);
                if(oldAccount != null){
                    oldVetSaveId = oldAccount.ZTS_EU_Vetsave_ID__c;
                    oldVetSaveHomeId = oldAccount.ZTS_EU_Vetsave_HO_ID__c;
                    isOldHomeOffice = oldAccount.ZTS_EU_HO_Flag__c;
                    oldRefId1 = oldAccount.ZTS_EU_Ref_ID1_Value__c;
                    oldRefId2 = oldAccount.ZTS_EU_Ref_ID2_Value__c;
                }
                
                if(!String.isBlank(accountMarket) && MarketMapUK.containsKey(accountMarket)){
                    //marketValueUK = accountMarket;
                    accountMarketsUK.add(accountMarket);
                    if(isHomeOffice){
                        accountHoMap.put(accountMarket + vetSaveId,a);
                        if(triggerIsUpdate && !String.isBlank(oldVetSaveHomeId) && oldVetSaveHomeId != vetSaveHomeId){
                            // The list is used to delete the reference in child accounts to old HO Accounts
                            oldHOIdsForHO.add(oldVetSaveHomeId); 
                        }
                    } 
                    else {
                        //If the account has just become Non-HO from HO, we make a list of oldHoIds and a list of accIds of such accounts
                        if(triggerIsUpdate && isHomeOffice != isOldHomeOffice){
                            oldHOIds.add(oldVetSaveId);
                            accIds.add(acctId);
                        }
                        // If account is not a HO Account we are putting it in a list
                        if(!String.isBlank(vetSaveHomeId)) {
                            accountList.add(a);
                            // we add the HOId of the Non-HO Account to a list
                            HOIds.add(vetSaveHomeId);
                        } 
                        else if(triggerIsUpdate && oldVetSaveHomeId != vetSaveHomeId){
                            // if the account old value had Vetsave Ho Id and has now been updated to empty Vetsave HO Id we add it to accountList
                            accountList.add(a);
                        }  
                    }
                }
                else if(!String.isBlank(accountMarket) && MarketMap.containsKey(accountMarket)){
                    accountMarkets.add(accountMarket);
                    if(isHomeOffice){
                        accountHoMapIreland.put(refId1,a);
                        if(triggerIsUpdate && refId1 != oldRefId1){
                            // The list is used to delete the reference in child accounts to old HO Accounts
                            oldHOIdsForHOAccountsIreland.add(oldRefId1); 
                        }
                    } 
                    else {
                        //If the account has just become Non-HO from HO, we make a list of oldHoIds and a list of accIds of such accounts
                        if(triggerIsUpdate && isHomeOffice != isOldHomeOffice){
                            oldHOIdsIreland.add(oldRefId1);
                            accIdsIreland.add(acctId);
                        }
                        // If account is not a HO Account we are putting it in a list
                        if(!String.isBlank(refId2)) {
                            accountListIreland.add(a);
                            // we add the HOId of the Non-HO Account to a list
                            HOIdsIreland.add(refId2);
                        } 
                        else if(triggerIsUpdate && refId2 != oldRefId2){
                            // if the account old value had Vetsave Ho Id and has now been updated to empty Vetsave HO Id we add it to accountList
                            accountListIreland.add(a);
                        }    
                    }
                }
            }

            if(triggerIsBefore){
                //for all the accounts that are Non-HO in trigger.new on basis of the list HOIds we get the HO Account and put it in accountHoMap
                if(!HOIds.isEmpty()){
                    List<account> parentAccounts = [SELECT ParentID,Id,ZTS_EU_Vetsave_HO_ID__c,
                                                    ZTS_EU_Vetsave_ID__c,ZTS_EU_HO_Flag__c,
                                                    ZTS_EU_Market__c 
                                                    FROM 
                                                    Account 
                                                    WHERE ZTS_EU_Vetsave_ID__c IN :HOIds 
                                                    AND ZTS_EU_HO_Flag__c = true 
                                                    AND ZTS_EU_Market__c IN :accountMarketsUK];
                    for(Account record : parentAccounts){
                        System.debug('Parent Account: ' + record);
                        accountMarket = record.ZTS_EU_Market__c;
                        vetSaveId = record.ZTS_EU_Vetsave_ID__c;
                        accountHOMap.put(accountMarket + vetSaveId,record);
                    }
                }
                //Iterate through accountList and on basis of accountHoMap get the appropriate parentId and assign it to the account
                for(Account record : accountList){
                    System.debug('Account List Account: ' + record);
                    accountMarket = record.ZTS_EU_Market__c;
                    vetSaveHomeId = record.ZTS_EU_Vetsave_HO_ID__c;
                    homeOfficeAccount = accountHOMap.get(accountMarket + vetSaveHomeId);
                    if(homeOfficeAccount != null && record.Id != homeOfficeAccount.Id) { 
                            record.ParentId = homeOfficeAccount.Id;
                    }
                    else if(triggerIsUpdate){
                        record.ParentId = null;
                    }
                }
                //For Ireland
                if(!HOIdsIreland.isEmpty()){
                    List<account> parentAccountsIreland = [SELECT ParentID,ZTS_EU_Market__c,Id,
                                                            ZTS_EU_Ref_ID1_Value__c,ZTS_EU_Ref_ID2_Value__c,
                                                            ZTS_EU_HO_Flag__c 
                                                            FROM Account 
                                                            WHERE ZTS_EU_Ref_ID1_Value__c IN :HOIdsIreland 
                                                            AND ZTS_EU_HO_Flag__c = true 
                                                            AND ZTS_EU_Market__c IN :accountMarkets];
                    for(Account record : parentAccountsIreland){
                        accountMarket = record.ZTS_EU_Market__c;
                        refId1 = record.ZTS_EU_Ref_ID1_Value__c;
                        accountHoMapIreland.put(accountMarket + refId1,record);
                    }
                }
                //Iterate through accountList and on basis of accountHoMap get the appropriate parentId and assign it to the account
                for(Account record : accountListIreland){
                    accountMarket = record.ZTS_EU_Market__c;
                    refId2 = record.ZTS_EU_Ref_ID2_Value__c;
                    homeOfficeAccount = accountHOMapIreland.get(accountMarket + refId2);
                    if(homeOfficeAccount != null && record.Id != homeOfficeAccount.Id){
                        record.ParentId = homeOfficeAccount.Id;
                    }
                    else if(triggerIsUpdate){
                        record.ParentId = null;
                    }
                }
            }
            /*Commenting out this future method as it was determined to do
            nothing because all of the values being accessed are out of future scope.
            - Morgan Marchese @ ZTS | 12/15/2020*/
            //methodforTransc(triggerIsAfter);
              
        }catch(DmlException e) {
            system.debug('Exception is ***********'+e.getMessage());
            ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Account_Vetsave_Functionality-update Parent Account Id');
        } catch(Exception ex) {
            system.debug('Exception is ex***********'+ex.getMessage());
            ZTS_EU_Logger.error('Non DMLException : '+ex.getMessage(), null, 'ZTS_EU_Account_Vetsave_Functionality-update Parent Account Id');
        }
    }

    /*******************************************************
    *
    *   The below future method was commented out on 12/2/2020 as it was determined
    *   to not do anything. It references values outside of its transaction scope 
    *   without setting those values first, so every value & query in the method 
    *   always returns null. - Morgan Marchese @ Zoetis (12/2/2020)
    *
    ********************************************************
    @Future
    public static void methodforTransc(Boolean triggerIsAfterVar){                        
        if(triggerIsAfterVar){
            List<account> childAccounts           = new List<Account>();
            List<account> oldChildAccounts        = new List<Account>();
            List<account> oldHOChildAccountsUK = new List<Account>();
            List<account> childAccountsIreland    = new List<Account>();
            List<account> oldChildAccountsIreland = new List<Account>();
            List<account> oldHOChildAccountsIreland = new List<Account>();
            if(accountHoMap != null && accountHoMap.keySet().size() > 0){
                childAccounts = [SELECT ParentID,Id,ZTS_EU_Vetsave_HO_ID__c,
                                ZTS_EU_Vetsave_ID__c,ZTS_EU_HO_Flag__c 
                                FROM Account 
                                WHERE ZTS_EU_Vetsave_HO_ID__c IN :accountHoMap.keySet() 
                                AND ZTS_EU_HO_Flag__c = false 
                                AND ZTS_EU_Market__c =: marketValueUK];
            }
            if(oldHOIds != null && oldHOIds.size() > 0){
                oldChildAccounts = [SELECT ParentID,Id,ZTS_EU_Vetsave_HO_ID__c,
                                    ZTS_EU_Vetsave_ID__c,ZTS_EU_HO_Flag__c 
                                    FROM Account 
                                    WHERE ZTS_EU_Vetsave_HO_ID__c IN :oldHOIds 
                                    AND Id NOT IN:accIds 
                                    AND ZTS_EU_HO_Flag__c = false 
                                    AND ZTS_EU_Market__c =: marketValueUK];
            }
            // System.debug('******check Size' +oldHOIdsForHO.size());
            if(oldHOIdsForHO != null && oldHOIdsForHO.size() > 0){
                oldHOChildAccountsUK = [SELECT ParentID,Id,ZTS_EU_Vetsave_HO_ID__c,
                                        ZTS_EU_Vetsave_ID__c,ZTS_EU_HO_Flag__c 
                                        FROM Account 
                                        WHERE ZTS_EU_Vetsave_HO_ID__c IN :oldHOIdsForHO 
                                        AND ZTS_EU_HO_Flag__c = false 
                                        AND ZTS_EU_Market__c =: marketValueUK];        
            }
                    
            // For Ireland
            if(accountHoMapIreland != null && accountHoMapIreland.keySet().size() > 0){
                childAccountsIreland = [SELECT ParentID,Id,ZTS_EU_Ref_ID1_Value__c,
                                        ZTS_EU_Ref_ID2_Value__c,ZTS_EU_HO_Flag__c 
                                        FROM Account 
                                        WHERE ZTS_EU_Ref_ID2_Value__c IN :accountHoMapIreland.keySet() 
                                        AND ZTS_EU_HO_Flag__c = false 
                                        AND ZTS_EU_Market__c =: marketValue];
            }
            if(oldHOIdsIreland != null && oldHOIdsIreland.size() > 0){
                oldChildAccountsIreland = [SELECT ParentID,Id,ZTS_EU_Ref_ID1_Value__c,
                                            ZTS_EU_Ref_ID2_Value__c,ZTS_EU_HO_Flag__c 
                                            FROM Account 
                                            WHERE ZTS_EU_Ref_ID2_Value__c IN :oldHOIdsIreland 
                                            AND Id NOT IN:accIdsIreland 
                                            AND ZTS_EU_HO_Flag__c = false 
                                            AND ZTS_EU_Market__c =: marketValue];
            }
            system.debug('***************oldChildAccountsIreland**********************'+oldChildAccountsIreland);
            if(oldHOIdsForHOAccountsIreland != null && oldHOIdsForHOAccountsIreland.size() > 0){
                oldHOChildAccountsIreland = [SELECT ParentID,Id,ZTS_EU_Ref_ID1_Value__c,
                                            ZTS_EU_Ref_ID2_Value__c,ZTS_EU_HO_Flag__c 
                                            FROM Account 
                                            WHERE ZTS_EU_Ref_ID2_Value__c IN :oldHOIdsForHOAccountsIreland 
                                            AND ZTS_EU_HO_Flag__c = false 
                                            AND ZTS_EU_Market__c =: marketValue];
            }
            for(Account acc : childAccounts){
                if(acc.Id != accountHoMap.get(acc.ZTS_EU_Vetsave_HO_ID__c).Id){
                    acc.parentId = accountHoMap.get(acc.ZTS_EU_Vetsave_HO_ID__c).Id;
                    accountUpdate.add(acc);
                }
            }
            for(Account acc : oldChildAccounts){
                acc.parentId = null;
                accountUpdate.add(acc);
            }
            for(Account acc : oldHOChildAccountsUK){
                acc.parentId = null;
                accountUpdate.add(acc);
            }
            for(Account acc : childAccountsIreland){
                if(acc.Id != accountHoMapIreland.get(acc.ZTS_EU_Ref_ID2_Value__c).Id){
                    acc.parentId = accountHoMapIreland.get(acc.ZTS_EU_Ref_ID2_Value__c).Id;
                    accountUpdate.add(acc);
                }
            }
            for(Account acc : oldChildAccountsIreland){
                acc.parentId = null;
                accountUpdate.add(acc);
            }
            for(Account acc : oldHOChildAccountsIreland){
                acc.parentId = null;
                accountUpdate.add(acc);
            }
            if(accountUpdate != null && accountUpdate.size() > 0){
                List<Database.Saveresult> results=Database.update(accountUpdate,false);
                ZTS_EU_Logger.error(results, 'ZTS_EU_Account_Vetsave_Functionality-update Parent Account Id');
            }
        }
    }*/
}