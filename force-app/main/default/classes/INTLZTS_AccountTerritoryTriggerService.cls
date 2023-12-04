/****************************************************************************************************************************************** 
* Class Name   : INTLZTS_AccountTerritoryTriggerService
* Description  : Logic for all INTL ZTS_AccountTerritory__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 26 June 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Cognizant (Aritra)	  12/13/2019   	      Changed codes to accept Account SFDC Id or Account SAP ID in the Account territory data 
                                              feed from SPM Interface (SZTS_Zoetis_SFDC_ID__cC-004455)
* David Stern(Slalom)     06/26/2020          Created, Logic from all triggers moved to this class.
* Morgan Marchese(Zoetis) 01/22/2021          Consolidated logic (and notes) from SL_ZTS_AccountTerritoryTriggerHandler which added 
                                              an additional layer of method chaining for no reason. All actions taken on 
                                              ZTS_AccountTerritory__c happen here
* Ethan Hirsch(Zoetis)    04/07/2022          Replaced the query for Accounts by Id calling AccountUtil to use the AccountSelector 
                                              class instead
* Sathiya SB(Cognizant)	  07/13/2022		  Added  before insert method to check whether duplicate Account Territory Exist before 
											  creating account territory.
* Mayank Garg(Cognizant)  11/10/2023          Added fix for INTL users so that the security is not enforced on INTL AT Deletions.
*****************************************************************************************************************************************/

public without sharing class INTLZTS_AccountTerritoryTriggerService 
{
    /**
    * @description Trigger Handler for International ZTS_AccountTerritory__c records after insert
    * @author Morgan Marchese @ Zoetis Inc | 01-22-2021 
    * @param List<ZTS_AccountTerritory__c> triggerNew 
    * @param Map<Id ZTS_AccountTerritory__c> triggerNewMap 
    **/
    
    //Added as a part of SC-009021 - Checking Duplicate Account Territory Before Creating a new Account Territory
    public static void beforeInsert(List<ZTS_AccountTerritory__c> triggerNew)
    {      
        set<String>  accountIdSet = new set<String>(); 
        for(ZTS_AccountTerritory__c accTerr : triggerNew)
        {
           accountIdSet.add(accTerr.ZTS_EU_Account__c);                   
        }
        List<ZTS_AccountTerritory__c> accList = [Select ZTS_EU_Account__c, ZTS_EU_Territory__c
                                                    from  ZTS_AccountTerritory__c 
                                                    where ZTS_EU_Account__c  IN: accountIdSet];                                                   
        Set<String> uniqueKeySet = New Set<String>();
        for(ZTS_AccountTerritory__c accountTerritory : accList){
             System.debug('Checking insert');
        	 String accTerrKey =  accountTerritory.ZTS_EU_Account__c + ':' + accountTerritory.ZTS_EU_Territory__c ;
             uniqueKeySet.add(accTerrKey);
        }
        
             Id currUsrId = UserInfo.getUserId();              
        	 String userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name;
            //Code to exclude System Administrator , Integration User and System Developer from duplication check
             if(!userProfile.equalsIgnoreCase('SYSTEM ADMINISTRATOR') && !userProfile.containsIgnoreCase('INTEGRATION') && !userProfile.containsIgnoreCase('DEVELOPER')){
        		for(ZTS_AccountTerritory__c accounTerritory : triggerNew){
            		 String accTerrKey =  accounTerritory.ZTS_EU_Account__c + ':' + accounTerritory.ZTS_EU_Territory__c ;   
              		 if(uniqueKeySet.contains(accTerrKey)){
               	     	accounTerritory.addError('AccountTerritory already exist');
                     }
             	     else{
                       	uniqueKeySet.add(accTerrKey); 
             	     }  
            	}
       	 	}	
            
      }
    public static void afterInsert(List<ZTS_AccountTerritory__c> triggerNew, Map<Id, ZTS_AccountTerritory__c> triggerNewMap) 
    {
        Set<Id> accIdSet = new Set<Id>();
        Set<String> accSFDCIdSet = new Set<String>(); //Added for Changes requested in SC-004455
        Map<String,Account> narcIdAccListMap = new Map<String,Account>();//Added for Changes requested in SC-004455
        Map<String,Account> SFDCSAPIdAccListMap = new Map<String,Account>();//Added for Changes requested in SC-004455
        String accountId;
        String positionId;
        String accountTerritoryId;
        String accountPositionUniqueKey;
        Set<Id> terrIds = new Set<Id>();
        List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>();
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        List<ZTS_EU_Account_Position__c> accountPositionList = new List<ZTS_EU_Account_Position__c>();
        Set<ZTS_EU_Account_Position__c> accountPositionSet = new Set<ZTS_EU_Account_Position__c>();
        List<ZTS_AccountTerritory__c> updateAccTerrList=new List<ZTS_AccountTerritory__c>();
        List<ZTS_EU_Position__c> positions;
        ZTS_EU_Account_Position__c accountPosition;
               
        //GET ALL TERRITORY FOR NEWLY CREATED ACC TERR RECORDS
        for (ZTS_AccountTerritory__c accTerr: triggerNew) 
        {
            terrIds.add(accTerr.ZTS_EU_Territory__c);
        }
       
        Map <Id, ZTS_EU_Territory__c> terrMap = new Map <Id, ZTS_EU_Territory__c> ([SELECT Id, Name, ZTS_EU_Parent_Territory__c, 
                                                                                        ZTS_EU_Type__c, 
                                                                                            (SELECT Name, ZTS_EU_Territory__c, 
                                                                                            Id,ZTS_EU_Is_Active__c, 
                                                                                            ZTS_EU_Employee__c 
                                                                                            FROM Positions__r)
                                                                                        FROM ZTS_EU_Territory__c 
                                                                                        WHERE Id IN: terrIds]);
		 system.debug('terrMap outside->'+terrMap);
        /**************************** INSERT ACCOUNT POSITIONS TO NEW ACCOUNT TERRITORY RECORDS **************************/
        
        for (ZTS_AccountTerritory__c accTerr: triggerNew)  
        {
            accountId = accTerr.ZTS_EU_Account__c;
            accountTerritoryId = accTerr.Id;
            positions = terrMap.get(accTerr.ZTS_EU_Territory__c).Positions__r;
            system.debug('accTerr->'+accTerr);
            system.debug('Positions->'+positions);
            for (ZTS_EU_Position__c ut: positions) 
            {
                positionId = ut.Id;
                if(ut.ZTS_EU_Is_Active__c)
                { 
                    accountPositionUniqueKey = accountId+':'+positionId;
                    accountPosition = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = accountId,
                                                                    ZTS_EU_Position__c = positionId,
                                                                    ZTS_AccountTerritory__c=accountTerritoryId,
                                                                    ZTS_EU_Active__c = true,
                                                                    ZTS_AccountUserTerrUniqueKey__c=accountPositionUniqueKey);                    
                    accountPositionSet.add(accountPosition);
                }
            }
            //update ProcessFlag
            updateAccTerrList.add(new ZTS_AccountTerritory__c(Id=accountTerritoryId,
                                                              ZTS_Processed__c=true));
        }

        accountPositionList.addAll(accountPositionSet);
        upsertResults = Database.upsert(accountPositionList,Schema.ZTS_EU_Account_Position__c.ZTS_AccountUserTerrUniqueKey__c, false);
        ZTS_Logger.error(upsertResults, 'Territory Management ZTS_PopulateAccTSF-AccountTeam/Positions Upsert');
        
        saveResults = Database.update(updateAccTerrList, false);
        ZTS_Logger.error(saveResults, 'Territory Management ZTS_PopulateAccTSF-AccTerrProcessFlag Update');

        /************************** GRANT ACCOUNT RECORD ACCESS TO TERRITORY GROUPS ********************************************/
        
        List<ObjectTerritory2Association> accShareList = new List<ObjectTerritory2Association>();

        for (ZTS_AccountTerritory__c acc_terr: triggerNew) 
        {  
            accShareList.addAll(ZTS_TerritoryManager.createAccountShares(acc_terr.ZTS_EU_Account__c, acc_terr.ZTS_Territory_SF_ID__c));
        }
        saveResults = Database.insert(accShareList, false);
        ZTS_Logger.error(saveResults, 'Territory Management ZTS_PopulateAccTSF-AccountShare Insert');
    }

    /**
    * @description Trigger Handler for International ZTS_AccountTerritory__c records after update
    * @author Morgan Marchese @ Zoetis Inc | 01-22-2021 
    * @param List<ZTS_AccountTerritory__c> triggerNew 
    * @param Map<Id ZTS_AccountTerritory__c> triggerNewMap 
    **/
    public static void afterUpdate(List<ZTS_AccountTerritory__c> triggerOld, Map<Id, ZTS_AccountTerritory__c> triggerOldMap, List<ZTS_AccountTerritory__c> triggerNew, Map<Id, ZTS_AccountTerritory__c> triggerNewMap) 
    {
        List<Id> accTerrIdsToDelete = new List<Id>();
        String accountId;
        String oldAccountId;
        String territoryId;
        String accountTerritoryId;
        ZTS_AccountTerritory__c oldTerritory;

        for(ZTS_AccountTerritory__c accterr:triggerNew)
        {
            if(accterr.ZTS_ChangeFlag__c==ZTS_GlobalConstants.CHANGE_FLAG_STATUS_DELETE)
            accTerrIdsToDelete.add(accterr.id);
        }
        
        if(!accterrIdsToDelete.isEmpty())
         {   
            List<Database.DeleteResult> delResults = Database.delete(accterrIdsToDelete, false);
            ZTS_Logger.error(delResults, 'Territory Management-Account ChangeFlag Delete status');
        }
        
       // SC-004268 - To Avoid the duplicate Account Territory (Added By Keerthi Chandra)
        List<ObjectTerritory2Association> accShareList = new List<ObjectTerritory2Association>();
        Set <Id> accIdSet = new Set <Id> ();
        for (ZTS_AccountTerritory__c accTerr: triggerNew){ 
            accIdSet.add(accTerr.ZTS_EU_Account__c);          
        }  

        for (ZTS_AccountTerritory__c accTerr: triggerNew) 
        {   
            accountId = accTerr.ZTS_EU_Account__c;
            accountTerritoryId = accTerr.Id;
            territoryId = accTerr.ZTS_Territory_SF_ID__c;
            oldTerritory = triggerOldMap.get(accountTerritoryId);
            oldAccountId = oldTerritory.ZTS_EU_Account__c;
            if(accountId != oldAccountId){
                if (!String.isBlank(territoryId)) 
                accShareList.addAll(ZTS_TerritoryManager.createAccountShares(accountId, territoryId));
            }
        }
        system.debug('**************accShareList'+accShareList);
        List<Database.SaveResult> saveResults = Database.insert(accShareList, false);
        ZTS_Logger.error(saveResults, 'Territory Management ZTS_PopulateAccTSF-AccountShare Insert');
    }

    /**
    * @description Trigger Handler for International ZTS_AccountTerritory__c records before delete
    * @author Morgan Marchese @ Zoetis Inc | 01-22-2021 
    * @param List<ZTS_AccountTerritory__c> triggerNew 
    * @param Map<Id ZTS_AccountTerritory__c> triggerNewMap 
    **/
    public static void beforeDelete(List<ZTS_AccountTerritory__c> triggerOld, Map<Id, ZTS_AccountTerritory__c> triggerOldMap) 
    {
        Id recordId;
        Id accountId;
        String narcId;
        String territoryId;
        String dmlErrors;
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> recordIdSet = new Set<Id>();
        Set<String> narcIdSet = new Set<String>();
        Set<Id> territoryIdSet = new Set<Id>();
        List<ZTS_EU_Account_Position__c> accountPositionList = new List<ZTS_EU_Account_Position__c>();
        List<ObjectTerritory2Association> accSharesToDelete;
        Map<Id, Account> accountMapById;
        List<Database.SaveResult> saveResults;
        List<Database.DeleteResult> deleteResults;

        for (ZTS_AccountTerritory__c record : triggerOld) 
        {
            recordId = record.Id;
            accountId = record.ZTS_EU_Account__c;
            territoryId = record.ZTS_Territory_SF_ID__c;
            accIdSet.add(accountId);
            recordIdSet.add(recordId);
            territoryIdSet.add(territoryId);
        }

        // Get Map of International Accounts by Account Id
        AccountSelector.enforceSecurity = false;// TPDEV-2054
        accountMapById = new Map<Id, Account>(AccountSelector.newInstance().selectByIdAndMarket(new List<Id>(accIdSet), false)); // United States FALSE (Is International)
        AccountSelector.enforceSecurity = true;// TPDEV-2054

        // Get Account Positions By Id
        accountPositionList = AccountPositionsSelector.newInstance().selectByAcctTerritoryId(recordIdSet, true); // International TRUE
        
        // Inactivate all of the Account Position Records
        accountPositionList = AccountPositionsService.setRecordsInactive(accountPositionList);
        if(!accountPositionList.isEmpty()){
            saveResults = Database.update(accountPositionList, false);
            ZTS_Logger.error(saveResults, 'INTLZTS_AccountTerritoryTriggerService - Update Positions');
        }

        // ObjectTerritory2Association Records to Delete for the Accounts/Territories
        // Get List
        accSharesToDelete = SharingUtil.getObjTerritoryAssociations(accountMapById.keySet(), territoryIdSet);
        // Delete List
        if(!accSharesToDelete.isEmpty()){
            deleteResults = SharingUtil.deleteObjTerritoryAssociations(accSharesToDelete);
            ZTS_Logger.error(deleteResults,'INTLZTS_AccountTerritoryTriggerService - Delete Account Shares');
        }

        //update TSF field in Account records
        ZTS_TerritoryManager.populateAccountTSF(triggerOld, true);
    }

    /**
    * @description Trigger Handler for International ZTS_AccountTerritory__c records after delete
    * @author Morgan Marchese @ Zoetis Inc | 01-22-2021 
    * @param List<ZTS_AccountTerritory__c> triggerNew 
    * @param Map<Id ZTS_AccountTerritory__c> triggerNewMap 
    **/
    public static void afterDelete(List<ZTS_AccountTerritory__c> triggerOld, Map<Id, ZTS_AccountTerritory__c> triggerOldMap) 
    {

    }

    /**
    * @description Trigger Handler for International ZTS_AccountTerritory__c records after undelete
    * @author Morgan Marchese @ Zoetis Inc | 01-22-2021 
    * @param List<ZTS_AccountTerritory__c> triggerNew 
    * @param Map<Id ZTS_AccountTerritory__c> triggerNewMap 
    **/
    public static void afterUndelete(List<ZTS_AccountTerritory__c> triggerNew, Map<Id, ZTS_AccountTerritory__c> triggerNewMap) 
    {
        afterInsert(triggerNew, triggerNewMap);
    }
}