/**
 * @description       : Handler for the trigger ZTS_Account on the object Account for the various event functionality.
 * @author            : Poonam Dalvi @ Unknown
 * @group             : 
 * @last modified on  : 05-03-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-21-2018   Poonam Dalvi @ Unknown      Initial Version (ZETM-16)
 * 1.1   05-25-2022   Ethan Hirsch @ Zoetis Inc   Add logic to call AccountService.mergeRelatedDataInternational to 
 *                                                merge related Addresses, Account Positions, and Territories when 
 *                                                Accounts are merged.
 * 1.1   08-29-2022   Ethan Hirsch @ Zoetis Inc   Add call to AccountsService.setSendToDMRFlagUpdate method before update.
 * 1.2   08-30-2022   Ethan Hirsch @ Zoetis Inc   Add call to AccountsService.setSendToDMRFlagCreate method before insert.
 * 1.3   08-30-2022   Ethan Hirsch @ Zoetis Inc   Change call to setSendToDMRFlag methods to a single setSendTODMRFlag method.
 * 1.4   01-25-2023   Padma Nerella @ Zoetis Inc  TPDev-103 - added logic to get the accounts with emails changes and passed those accounts to ContactsService class to update the contact
 * 1.5   03-21-2023   Padma Nerella @ Zoetis Inc  TPDEV-105 Removed execution of ZTS_EU_Account_Vetsave_Functionality.updateParentAccount from onAfterUpdate of an Account.         
 * 1.6   04-11-2023   Padma Nerella @ Zoetis Inc  TPDEV-104 Removed updateAccountContactAffilation in ZTS_EU_Affiliation_Update class and moved logic to  AffiliationsService as part of refactoring code and prevent recursion.   
 * 1.7   05-03-2023   Padma Nerella @ Zoetis Inc  TPDEV-109 Moved ZTS_EU_Corporate_Flag_Update logic AccountsService class updateZTSEUCorporateFlagFromINTLParentAcc method   
 * 1.8   10-03-2023   Prasun Dubey @ Cognizant    TPDEV-1005 Update the account contact affliation name on accountMerge 
**/
public with sharing class SL_AccountTriggerHandler 
{
  /***********
  * Method name  : onBeforeInsert
  * Description  : This will update MZR fields on Account.
  * Return Type  : None.
  * Parameters   : trigger parameters.
  ***********/  
    public void onBeforeInsert(List<Account> lstAccountNew)
    {
        // SC-004119 - Account Name Split Functionality Starts here    
        User usr = [SELECT Id, ZTS_EU_Primary_Business_Unit__c,ZTS_EU_Market__c,Profile.name FROM User WHERE id=: UserInfo.getUserId()];
        String  loginUserProfileName = usr.Profile.name;
        if(loginUserProfileName != 'Integration Profile'){
            for(Account acc : lstAccountNew){
                if(!String.isBlank(acc.ZTS_EU_Market__c) || (acc.ZTS_EU_Market__c !=NULL))
                {
                 if(!Label.Exclude_Country_Name_Split_List.contains(acc.ZTS_EU_Market__c))
                 {
                     ZTS_addrCreationAndUpdateFromAccount.splitAccountName(acc);
                 } 
                }
            }
         }
        // SC-004119 - Account Name Split Functionality Ends here
        
        // SC-004119 - Logic for Parent Account Population based on Vetsave and Vetsave HO ID Starts Here
        ZTS_EU_Account_Vetsave_Functionality.updateParentAccount(lstAccountNew, new Map<id,Account>(), false, true, false);
        ZTS_Account_Utility.checkTerrAlignment(lstAccountNew);  
        // SC-004119 - Logic for Parent Account Population based on Vetsave and Vetsave HO ID Ends Here
        // SC-004119 - Added other functionalities
        ZTS_addrCreationAndUpdateFromAccount.populatePotentialRegion(lstAccountNew);    
        
        // Run this last after all other processing in case any Account fields changed that are integrated to DMR
        AccountsService.setSendToDMRFlag(lstAccountNew, null);
    }
    
    public void onAfterInsert(List<Account> lstAccountNew) {
        updateVatCode(lstAccountNew);
    }

  /***********
  * Method name  : onBeforeUpdate
  * Description  : This will update MZR fields on Account.
  * Return Type  : None.
  * Parameters   : trigger parameters.
  ***********/
    public void onBeforeUpdate(List<Account> lstAccountNew, Map<Id, Account> mapAccountOld)
    {
        // update Account Contact Affiliation to inactive if Account is inactive.
        Map <Id,Account> updMap = new Map <Id,Account>();
        ZTS_addrCreationAndUpdateFromAccount.updateAccConAffInactive(lstAccountNew);
        
        
        // SC-004119 - Account Name Split Functionality Starts here    
        User usr = [SELECT Id, ZTS_EU_Primary_Business_Unit__c,ZTS_EU_Market__c,Profile.name FROM User WHERE id=: UserInfo.getUserId()];
        String  loginUserProfileName = usr.Profile.name;
        if(loginUserProfileName != 'Integration Profile'){
            for(Account acc : lstAccountNew){
                if(!String.isBlank(acc.ZTS_EU_Market__c) || (acc.ZTS_EU_Market__c !=NULL))
                {
                 if((!Label.Exclude_Country_Name_Split_List.contains(acc.ZTS_EU_Market__c)) && (mapAccountOld.get(acc.id).Name!=acc.Name))
                 {
                     ZTS_addrCreationAndUpdateFromAccount.splitAccountName(acc);
                 }
                }
            }
         }
        // SC-004119 - Account Name Split Functionality Ends here    
        // Logic for Parent Account Population based on Vetsave and Vetsave HO ID Starts Here
         if(UtilityService.isaccountTriggerRun()){
             if(UtilityService.isVetSaveRun()){
                    ZTS_EU_Account_Vetsave_Functionality.updateParentAccount(lstAccountNew, mapAccountOld, true, true, false);
                }
          ZTS_EU_BUG_Parentpopulate.updateParentIDBlankAccount(lstAccountNew);
        }
        // SC-004119 - Logic for Parent Account Population based on Vetsave and Vetsave HO ID Ends Here
        // SC-004119 - Added other functionalities
        ZTS_addrCreationAndUpdateFromAccount.populatePotentialRegion(lstAccountNew); 

        // Run this last after all other processing in case any Account fields changed that are integrated to DMR
        AccountsService.setSendToDMRFlag(lstAccountNew, mapAccountOld);
  }

  /***********
  * Method name  : onBeforeDelete
  * Description  : This will delete ZTS_Animal_Count_Potential__c records.
  * Return Type  : None.
  * Parameters   : trigger parameters.
  ***********/
    public void onBeforeDelete(List<Account> lstAccountOld)
    {
    //SC-004119 - Replaced all Animal Count Potential references with ZTS_EU_Account_Species_Potential__c
    list<ZTS_EU_Account_Species_Potential__c> animalCountList= new list<ZTS_EU_Account_Species_Potential__c> ();
    Map<Id, List<ZTS_EU_Account_Species_Potential__c>> mapIdToAnimalCountPotentials = new Map<Id, List<ZTS_EU_Account_Species_Potential__c>>{};

    for(ZTS_EU_Account_Species_Potential__c objACP : [SELECT Id,ZTS_EU_Species_Potential__c, Account__c FROM ZTS_EU_Account_Species_Potential__c 
                                                         WHERE Account__c IN: lstAccountOld])
    {
      if(!mapIdToAnimalCountPotentials.containsKey(objACP.Account__c))
        mapIdToAnimalCountPotentials.put(objACP.Account__c, new List<ZTS_EU_Account_Species_Potential__c>());
      mapIdToAnimalCountPotentials.get(objACP.Account__c).add(objACP);
      
    }

    for (Account acc: lstAccountOld)
    {
      /********* START - Modified by: Poonam to avoid the SOQL inside the For Loop.*************/
        /*list<ZTS_Animal_Count_Potential__c> acfList = [SELECT Id,RecordTypeId FROM ZTS_Animal_Count_Potential__c 
                                                                                       WHERE ZTS_EU_Account__c =: acc.Id
                                                                                       AND ZTS_EU_Market_from_Parent__c = 'United States'];  
      if(!acfList.isEmpty())
      {
        StaticACFVars.mapOldACFLoser.put(acc.Id, acfList);
        animalCountList.addAll(acfList);
      }*/
      /*********END - Modified by: Poonam to avoid the SOQL inside the For Loop.*************/


      if(mapIdToAnimalCountPotentials.containsKey(acc.Id) && mapIdToAnimalCountPotentials.get(acc.Id) != null)
      {
        StaticACFVars.mapOldACFLoser.put(acc.Id, mapIdToAnimalCountPotentials.get(acc.Id));
        animalCountList.addAll(mapIdToAnimalCountPotentials.get(acc.Id));
      }
    }
    if(!animalCountList.isEmpty())
        Database.delete(animalCountList, false); 
        
    }

  /***********
  * Method name  : onAfterDelete
  * Description  : This will undelete ZTS_Animal_Count_Potential__c records.
  * Return Type  : None.
  * Parameters   : trigger parameters.
  ***********/
    public void onAfterDelete(List<Account> lstAccountOld)
    {
    //SC-004119 - Replaced all Animal Count Potential references with ZTS_EU_Account_Species_Potential__c
    List<ZTS_EU_Account_Species_Potential__c> undACFAll = new List<ZTS_EU_Account_Species_Potential__c> ();
    //List<ZTS_Animal_Count_Potential__c> undACF = new List<ZTS_Animal_Count_Potential__c> ();
    
    /**********
      * Modifed By: Poonam
      * Description: Optimized code to avoid For inside For and SOQL within FOR....
    ***********/
    
    Map<Id, List<ZTS_EU_Account_Species_Potential__c>> mapACPIdToAnimalCountPotentials = new Map<Id, List<ZTS_EU_Account_Species_Potential__c>>();

    Set<Id> mergeMasterRecordIds = new Set<Id>();
    for(Account acct : lstAccountOld) 
    {
      // If MasterRecordId is specified, this Account is being merged into another Account.
      if(String.isNotBlank(acct.MasterRecordId) && StaticACFVars.mapOldACFLoser.containsKey(acct.Id)) 
        mapACPIdToAnimalCountPotentials.put(acct.MasterRecordId, new List<ZTS_EU_Account_Species_Potential__c>());

      if (String.isNotBlank(acct.MasterRecordId)) {
        mergeMasterRecordIds.add(acct.MasterRecordId);
      }
    }

    for(ZTS_EU_Account_Species_Potential__c objACP : [SELECT Id,ZTS_EU_Species_Potential__c, Account__c FROM ZTS_EU_Account_Species_Potential__c 
                                                    WHERE Account__c IN: mapACPIdToAnimalCountPotentials.keySet() ])
    {
      mapACPIdToAnimalCountPotentials.get(objACP.Account__c).add(objACP);
    }

    for(Account acct : lstAccountOld) 
    { 
      if(String.isNotBlank(acct.MasterRecordId) && StaticACFVars.mapOldACFLoser.containsKey(acct.Id)) 
      { // Means the account is deleted due to merge
          //existing species of Winner Record are inserted into this set
          Set <Id> setWinnerACFspecies = new Set <Id>();
          if(mapACPIdToAnimalCountPotentials.containsKey(acct.MasterRecordId)) 
          {
            //if winner account has existing ACFs present then only non-duplicate ACF records from loser are moved
            for (ZTS_EU_Account_Species_Potential__c acf1: mapACPIdToAnimalCountPotentials.get(acct.MasterRecordId))
              setWinnerACFspecies.add(acf1.ZTS_EU_Species_Potential__c);

            //Now get the Loser Account ACF List
            List <ZTS_EU_Account_Species_Potential__c> listCheck = StaticACFVars.mapOldACFLoser.get(acct.Id);
            //Loop through the Loser Account ACF List
            for (ZTS_EU_Account_Species_Potential__c acp: listCheck)
            {
              if(!setWinnerACFspecies.contains(acp.ZTS_EU_Species_Potential__c)) // if the Loser ACF Species does not exist in Winner
                undACFAll.add(acp);
            }
          }
          else
          {
            //if winner account doesn't have ACFs present,then copy all ACF from loser account
            undACFAll.addAll(StaticACFVars.mapOldACFLoser.get(acct.Id));
          }
      }  
    }      
    undelete undACFAll;

    // Run this logic asynchronously to avoid performance degerdation and limit issues
    if (!mergeMasterRecordIds.isEmpty()) {
      System.enqueueJob(new MergeAccountsQueueable(mergeMasterRecordIds));
    }

    /**********END Optmized Code ***********/
    //SC-004119 - Added other existing functionalities
        Set<Id> setAccounts = new Set<Id>();
            for(Account objAccount : lstAccountOld){
            system.debug('++++++++objAccountfirst'+objAccount);
                if(objAccount.parentId == null){
                    setAccounts.add(objAccount.Id);
                }
                 system.debug('++++++++objAccount Second'+objAccount);
            }
           
       ZTS_EU_BUG_Parentpopulate.deletedAccounts(setAccounts);
   		
       // TPDEV-1005 Update the account contact affliation name on accountMerge 
      	AffiliationsService.updateAffliationNameOnMerge(lstAccountOld);
    }

  /***********
  * Method name  : onAfterUpdate
  * Description  : This will delete inactive Account records.
  * Return Type  : None.
  * Parameters   : trigger parameters.
  ***********/
  public void onAfterUpdate(List<Account> lstAccountNew, List<Account> lstAccountOld, Map<Id, Account> mapAccountOld, Map<Id, Account> mapAccountNew)
  {
    List<Account> accountList = New List<Account>();
    Map<Id,Account> accmapparent = new Map<Id,Account>();
    Map<Id,Account> accmapVGP = new Map<Id,Account>();
    Map<Id,Account> accmapMVP = new Map<Id,Account>();
    List<Account> accmapchild = new List<Account>();
    list<Account> childacclist = new list<Account>(); //sai
    
    //Moved forloop to AccountsService class and upadted the logic to bulkification TPDev-103
    accountList = AccountsService.getAccountsWithEmailChanges(mapAccountNew, mapAccountOld);
    if(!accountList.isEmpty()){
      ContactsService.updateContactwithAccountEmail(accountList);
    }
    /* EOD by SOHIL For DEF-001643 */
    
    List<Id> inActiveAccIdList=new List<Id>(); 

    //remove access to Inactive Accounts
    for(Account acc:lstAccountNew)
    {
      if(mapAccountOld.get(acc.id).ZTS_EU_Account_Status__c!=acc.ZTS_EU_Account_Status__c && acc.ZTS_EU_Account_Status__c==ZTS_GlobalConstants.INACTIVE_STATUS)
        inActiveAccIdList.add(acc.id);
    }
    //system.debug('Inactive list mohamed: ' + inActiveAccIdList);
    if(!inActiveAccIdList.isEmpty())
      ZTS_TerritoryManager.deleteAccountTerritoryShares(inActiveAccIdList);
    //update Address record on updation of Account.
    ZTS_addrCreationAndUpdateFromAccount.updateAddressRecord(lstAccountNew,mapAccountOld);       
    // update Account Contact Affiliation to inactive if Account is inactive.
    //update contact address with changed Billing Address in account.
    ZTS_addrCreationAndUpdateFromAccount.updateAccContactsAddress(mapAccountOld, mapAccountNew);      
   
    //SC-004119 - insert Buying Group and Vetsave Functionality - Starts Here   
    if(UtilityService.isAccAffinsUpdateRun()){
                ZTS_EU_BUG_Parentpopulate.updateAccounts(lstAccountNew, mapAccountOld);
        
        //TPDEV-1095: added filters
        List<Market_Setting__mdt> marketList = [ SELECT Id, Market__c, Exclude_Buying_Group_Account_Affiliation__c  FROM Market_Setting__mdt WHERE Exclude_Buying_Group_Account_Affiliation__c = true ]; 
        Map<String, Boolean> excludeBuyingGroupMarketsMap = new Map<String, Boolean>(); //map to hold market names and checkbox values
        for (Market_Setting__mdt marketSetting : marketList) {
            excludeBuyingGroupMarketsMap.put(marketSetting.Market__c, marketSetting.Exclude_Buying_Group_Account_Affiliation__c);
        }
        List<Account> recordsToProcess = new List<Account>(); //hold records that meet criteria
        for (Account acc: lstAccountNew) {
            if(!(excludeBuyingGroupMarketsMap.containsKey(acc.ZTS_EU_Market__c) && excludeBuyingGroupMarketsMap.get(acc.ZTS_EU_Market__c))) {
                recordsToProcess.add(acc);
            }
        }
        if(recordsToProcess.size()>0) {
            ZTS_EU_BUG_AccountAffiliation.insertAffiliatesfromAccount(recordsToProcess);
        }
        
                
                ZTS_EU_Affiliation_Update.updateAccountAffiliation(lstAccountNew,mapAccountNew,mapAccountOld);
                //Update ACA when Account status becomes inactive
            AffiliationsService.updateAccountContactAffilation(lstAccountNew, lstAccountOld, mapAccountNew,mapAccountOld); 
                
                UtilityService.AccAffInsertRun = false;
            }
            if(UtilityService.isAddressTriggerRun()){
                ZTS_EU_Update_Address.updateAddressRecordWithAccountFields(lstAccountNew,mapAccountOld);    
            } 
        //ZTS_EU_Corporate_Flag_Update.updateCorporateFlag(mapAccountNew, mapAccountOld);
        AccountsService.updateZTSEUCorporateFlagFromINTLParentAcc(mapAccountNew, mapAccountOld);
            ZTS_EU_HQRating_Update.HQRating_Update(mapAccountNew, mapAccountOld); 
            ZTS_addrCreationAndUpdateFromAccount.updateContactonPrimAddrUpdate(lstAccountNew,mapAccountOld);
            ZTS_addrCreationAndUpdateFromAccount.syncOptOutFlagGermany(lstAccountNew);
       //SC-004119 - insert Buying Group and Vetsave Functionality - Ends Here   
      updateVatCode(lstAccountNew);
  }
  
    /***********
      * Method name  : updateVatCode
      * Description  : This will update the unique Vat code else will throw error if duplicate vat code exists.
      * Return Type  : None.
      * Parameters   : trigger parameters.
      ***********/
    private void updateVatCode(List<Account> lstAccountNew) { 
        Map<String, Account> mapUniqueVatCodeToAccount = new Map<String, Account>();
        Set<String> setVatCode = new Set<String>();
        
        for(Account objAcc : lstAccountNew) {
            String strVatCode = objAcc.ZTS_EU_VAT_Code_Uniqueness_Key__c;
            if(String.isNotBlank(strVatCode))
                setVatCode.add(strVatCode.trim());
        }
        
        for(Account objAcc : lstAccountNew) {
            String strVatCode = objAcc.ZTS_EU_VAT_Code_Uniqueness_Key__c;
            if(mapUniqueVatCodeToAccount.containsKey(strVatCode)) {
                objAcc.addError( System.Label.SL_Duplicate_Vat_Code + ' ' 
                                + mapUniqueVatCodeToAccount.get(strVatCode).Name 
                                +  ' ' 
                                + mapUniqueVatCodeToAccount.get(strVatCode).Id);
            }
             
        }
    }

    private class MergeAccountsQueueable implements Queueable {
      Set<Id> mergedMasterRecordIds;
      public MergeAccountsQueueable(Set<Id> mergedMasterRecordIds) {
        this.mergedMasterRecordIds = mergedMasterRecordIds;
      }

      public void execute(QueueableContext context) {
        AccountsService.mergeRelatedDataInternational(mergedMasterRecordIds);
      }
    }
}