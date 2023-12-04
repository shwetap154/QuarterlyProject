/**
* @ClassName    : SL_ZTS_US_UserTerritoryTriggerHandler 
* @JIRATicket   : ZETM-16
* @CreatedOn    : 21st November,2018
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Handler for the trigger ZTS_US_UserTerritoryTrigger on after insert functionality.
*/

public with sharing class SL_ZTS_US_UserTerritoryTriggerHandler 
{
	public void onAfterInsert(List<ZTS_EU_Position__c> lstZTSUSTerritoryNew)
	{
		Set<String> terrIdentifierSet=new Set<String>();
	    for(ZTS_EU_Position__c userTerr:lstZTSUSTerritoryNew){
	        //fetch the custom territory identifier for all new positions
	        terrIdentifierSet.add(userTerr.ZTS_EU_Territory__c);
	    }
	    
	    //check the account territory count
	    Integer ACC_TERR_COUNT=[SELECT count() from ZTS_AccountTerritory__c WHERE ZTS_EU_Territory__c IN :terrIdentifierSet];
	    Integer TOTAL_ACC_TEAMS_INSERT_COUNT=ACC_TERR_COUNT * lstZTSUSTerritoryNew.size();
	    boolean THRESHOLD_LIMIT_EXCEEDS=TOTAL_ACC_TEAMS_INSERT_COUNT>=Limits.getLimitDmlRows();
	    List<ZTS_EU_Position__c> usrTerrWithInsertChgFlagList=new List<ZTS_EU_Position__c>();
	    
	    for(ZTS_EU_Position__c usrterr:lstZTSUSTerritoryNew){
	        if(usrterr.ZTS_ChangeFlag__c==ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT){
	            usrTerrWithInsertChgFlagList.add(usrterr);
	        }
	        
	    }
	    if(THRESHOLD_LIMIT_EXCEEDS){
	        //execute batch to create account teams records
	        Database.executeBatch(new ZTS_CreateAccountTeamFromUsrTerrBatch(usrTerrWithInsertChgFlagList));
	    }
	    
	    else{
	        List<ZTS_AccountTerritory__c> accTerrList=[SELECT ZTS_NARC_ID__c,ZTS_EU_Territory__c,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c WHERE ZTS_EU_Territory__c IN :terrIdentifierSet];                                       
	        USZTS_TerritoryManager.createAccountTeams(usrTerrWithInsertChgFlagList,accTerrList);
	    }
	}
}