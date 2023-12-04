/****************************************************************************************************************************************** 
 * Trigger Name : USZTS_EU_PositionTriggerService
 * Description  : Service class to handle ZTS_EU_Position__c trigger logic  
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 14th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman			02/14/2020		Moved from Triggers into service class per framework
 * Triggers/logic added below:
 -----------------------------------------------------------------------------------------------------------------------------------------
 * Trigger Name   : ZTS_US_UserTerritoryTrigger
 * Description    : This Trigger contain operations for insertion of AccountPosition/Team records.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 03 Apr 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   04/03/2014           Created
 * -------------------------------------------------------
* @ClassName    : SL_ZTS_US_UserTerritoryTriggerHandler 
* @JIRATicket   : ZETM-16
* @CreatedOn    : 21st November,2018
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 7th March 2022 : Prasun - Added null check as a part of SC-009379 
* @Description  : Handler for the trigger ZTS_US_UserTerritoryTrigger on after insert functionality.
*****************************************************************************************************************************************/
public class USZTS_EU_PositionTriggerService 
{
    public static void afterUpdate(List<ZTS_EU_Position__c> triggerOld, Map<Id, ZTS_EU_Position__c> triggerOldMap, List<ZTS_EU_Position__c> triggerNew, Map<Id, ZTS_EU_Position__c> triggerNewMap)
    {
        /*****START - Commented to optmize the code to avoid the FOR inside FOR method calling.******/
        /*for(Id bud: Trigger.newmap.keyset())
        {
            if( (Trigger.oldMap.get( bud ).ZTS_US_Employee__c != Trigger.newMap.get( bud ).ZTS_US_Employee__c) 
                  && Trigger.newMap.get( bud ).ZTS_US_Employee__c !=null )
                 PIT_BudgetAllocationTriggerHandler.updateBudgetOwner(trigger.new);
        }*/
        /*****END - Commented to optmize the code to avoid the FOR inside FOR method calling.******/

        //Optimised to avoid the for loop which continously iterated over the controller method for inside for.
        PIT_BudgetAllocationTriggerHandler.updateBudgetOwner(triggerOldMap, triggerNewMap);
    }
    
    public static void afterInsert(List<ZTS_EU_Position__c> triggerNew, Map<Id, ZTS_EU_Position__c> triggerNewMap)
    {

        Set<Id> terrIdentifierSet=new Set<Id>();
        for(ZTS_EU_Position__c userTerr:triggerNew){
            //fetch the custom territory identifier for all new positions
            if(userTerr.ZTS_EU_Territory__c != null && !String.isBlank(userTerr.ZTS_EU_Territory__c)) // Added null check as a part of SC-009379 : Start
            	terrIdentifierSet.add(userTerr.ZTS_EU_Territory__c);
        }
        
        // Added null check as a part of SC-009379 : Start
        Integer ACC_TERR_COUNT = 0;
        if(terrIdentifierSet != null && terrIdentifierSet.size() > 0){
            //check the account territory count
        	ACC_TERR_COUNT=[SELECT count() from ZTS_AccountTerritory__c WHERE ZTS_EU_Territory__c IN :terrIdentifierSet];
        }
        // Added null check as a part of SC-009379 : End
        Integer TOTAL_ACC_TEAMS_INSERT_COUNT=ACC_TERR_COUNT * triggerNew.size();
        boolean THRESHOLD_LIMIT_EXCEEDS=TOTAL_ACC_TEAMS_INSERT_COUNT>=Limits.getLimitDmlRows();
        List<ZTS_EU_Position__c> usrTerrWithInsertChgFlagList=new List<ZTS_EU_Position__c>();
        
        for(ZTS_EU_Position__c usrterr:triggerNew){
            if(usrterr.ZTS_ChangeFlag__c==ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT){
                usrTerrWithInsertChgFlagList.add(usrterr);
            }
            
        }
        if(THRESHOLD_LIMIT_EXCEEDS){
            //execute batch to create account teams records
            Database.executeBatch(new USZTS_CreateAccountTeamFromUsrTerrBatch(usrTerrWithInsertChgFlagList));
        }
        
        else{
            List<ZTS_AccountTerritory__c> accTerrList=[SELECT ZTS_NARC_ID__c,ZTS_EU_Territory__c,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c WHERE ZTS_EU_Territory__c IN :terrIdentifierSet];                                       
            
            USZTS_TerritoryManager.createAccountTeams(usrTerrWithInsertChgFlagList,accTerrList);
        }
	}
}