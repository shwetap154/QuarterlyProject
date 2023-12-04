/**
* @ClassName    : SL_ZTS_US_AccountTerritoryTriggerHandler 
* @JIRATicket   : ZETM-16
* @CreatedOn    : 23rd November,2018
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Handler for the trigger ZTS_US_AccountTerritory on the object ZTS_AccountTerritory__c for the various event functionality.
*/
public with sharing class SL_ZTS_US_AccountTerritoryTriggerHandler 
{
	/***********
	  * Method name  : onAfterInsert
	  * Description  : This will INSERT ACCOUNT POSITIONS TO NEW ACCOUNT TERRITORY RECORDS and  GRANT ACCOUNT RECORD ACCESS TO TERRITORY GROUPS.
	  * Return Type  : None.
	  * Parameters   : trigger parameters.
	  ***********/  
	public void onAfterInsert(List<ZTS_AccountTerritory__c> lstAccountTerritoryNew)
	{
        Set < Id > accIdSet = new Set < Id > ();
        for (ZTS_AccountTerritory__c accTerr: lstAccountTerritoryNew) 
            accIdSet.add(accTerr.ZTS_EU_Account__c);

        Map < String, Account > narcIdAccListMap = USZTS_TerritoryManager.getAccountInfo(new List<Id>(accIdSet));

        for (ZTS_AccountTerritory__c acc_terr: lstAccountTerritoryNew) 
        {
            //Accounts with NARCIDs update TSF field
            if (narcIdAccListMap.containsKey(acc_terr.ZTS_NARC_ID__c)) 
            {
                Account acc = narcIdAccListMap.get(acc_terr.ZTS_NARC_ID__c);
            
                if (String.isNotBlank(acc.ZTS_US_TSF__c)) 
                {
                    Set < String > tsf_tokens = new Set < String > ();
                    tsf_tokens.addAll((acc.ZTS_US_TSF__c).split(';'));
                    //prevent duplicates entry in Account TSF field
                    if (!tsf_tokens.contains(acc_terr.ZTS_TerrName__c)) 
                    {
                        acc.ZTS_US_TSF__c += ';' + acc_terr.ZTS_TerrName__c;
                        narcIdAccListMap.put(acc.ZTS_US_NARC_ID__c, acc);
                    }
                } 
                else 
                {
                    acc.ZTS_US_TSF__c = acc_terr.ZTS_TerrName__c;
                    narcIdAccListMap.put(acc.ZTS_US_NARC_ID__c, acc);
                }
            }
        }
        
        if (!narcIdAccListMap.isEmpty()) 
        {
            //Bypass the Account Trigger when updating Accounts (TPDEV-80)
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            List < Database.Saveresult > results = Database.update(narcIdAccListMap.values(), false);
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            ZTS_EU_Logger.error(results, 'Territory Management ZTS_US_PopulateAccTSF-account update');
        }

        Set < Id > terrIds = new Set < Id > ();
        List < Id > stdTerrIds = new List < Id > ();
        
        //GET ALL TERRITORY FOR NEWLY CREATED ACC TERR RECORDS
        for (ZTS_AccountTerritory__c accTerr: lstAccountTerritoryNew) 
        {
            terrIds.add(accTerr.ZTS_EU_Territory__c);
            stdTerrIds.add(accTerr.ZTS_Territory_SF_ID__c);
        }

        Map < Id, ZTS_EU_Territory__c > terrMap = new Map < Id, ZTS_EU_Territory__c > ([SELECT Id, Name, ZTS_EU_Parent_Territory__c, ZTS_EU_Type__c, (SELECT Name, ZTS_EU_Territory__c, Id, ZTS_EU_Employee__c FROM Positions__r)
                                                                                        FROM ZTS_EU_Territory__c WHERE Id IN: terrIds]);

        /**************************** INSERT ACCOUNT POSITIONS TO NEW ACCOUNT TERRITORY RECORDS **************************/
        
        List < ZTS_EU_Account_Position__c > acc_post_list = new List < ZTS_EU_Account_Position__c > ();
        Set < ZTS_EU_Account_Position__c > acc_pos_set = new Set < ZTS_EU_Account_Position__c > ();
        List<ZTS_AccountTerritory__c> updateAccTerrList=new List<ZTS_AccountTerritory__c>();

        for (ZTS_AccountTerritory__c accTerr: lstAccountTerritoryNew) 
        {
            for (ZTS_EU_Position__c ut: terrMap.get(accTerr.ZTS_EU_Territory__c).Positions__r) 
            {
                String acc_userterr_key=accTerr.ZTS_EU_Account__c+':'+ut.id;
                ZTS_EU_Account_Position__c acc_pos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = accTerr.ZTS_EU_Account__c, 
                                                                                    ZTS_EU_Position__c = ut.id,
                                                                                    ZTS_AccountTerritory__c=accTerr.id,
                                                                                    ZTS_AccountUserTerrUniqueKey__c=acc_userterr_key);
                acc_pos_set.add(acc_pos);
            }
            //update ProcessFlag
            updateAccTerrList.add(new ZTS_AccountTerritory__c(id=accTerr.id,ZTS_Processed__c=true));
        }

        acc_post_list.addAll(acc_pos_set);

        List < Database.Upsertresult > results = Database.upsert(acc_post_list,Schema.ZTS_EU_Account_Position__c.ZTS_AccountUserTerrUniqueKey__c, false);
        ZTS_EU_Logger.error(results, 'Territory Management ZTS_US_PopulateAccTSF-AccountTeam/Positions Upsert');
        
        List < Database.Saveresult > update_results = Database.update(updateAccTerrList, false);
        ZTS_EU_Logger.error(update_results, 'Territory Management ZTS_US_PopulateAccTSF-AccTerrProcessFlag Update');
        
        acc_post_list = null;
        

        /************************** GRANT ACCOUNT RECORD ACCESS TO TERRITORY GROUPS ********************************************/
        
        /*Map < Id, List < Group >> terrGrpMap = USZTS_TerritoryManager.getTerritoryGroupMap(stdTerrIds);*/
        List<ObjectTerritory2Association> accShareList = new List<ObjectTerritory2Association>();

        for (ZTS_AccountTerritory__c acc_terr: lstAccountTerritoryNew) 
        {   
            Account acc = narcIdAccListMap.get(acc_terr.ZTS_NARC_ID__c);

            if (!String.isBlank(acc_terr.ZTS_Territory_SF_ID__c) && acc != null) 
                accShareList.addAll(USZTS_TerritoryManager.createAccountShares(acc.id, acc_terr.ZTS_Territory_SF_ID__c));
        }
        List < Database.Saveresult > save_results = Database.insert(accShareList, false);
        ZTS_EU_Logger.error(save_results, 'Territory Management ZTS_US_PopulateAccTSF-AccountShare Insert');
	}

	/***********
	  * Method name  : onAfterUpdate
	  * Description  : This will delete the ZTS_AccountTerritory__c records.
	  * Return Type  : None.
	  * Parameters   : trigger parameters.
	  ***********/ 
	public void onAfterUpdate(List<ZTS_AccountTerritory__c> lstAccountTerritoryNew)
	{
		List<Id> accterrIdsToDelete=new List<Id>();

        for(ZTS_AccountTerritory__c accterr:lstAccountTerritoryNew)
        {
            if(accterr.ZTS_ChangeFlag__c==ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_DELETE)
                accterrIdsToDelete.add(accterr.id);
        }
        
        if(!accterrIdsToDelete.isEmpty())
        {
            List < Database.DeleteResult > delResults = Database.delete(accterrIdsToDelete, false);
            ZTS_EU_Logger.error(delResults, 'Territory Management-Account ChangeFlag Delete status');
        }
	}
}