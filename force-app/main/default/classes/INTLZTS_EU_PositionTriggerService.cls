/****************************************************************************************************************************************** 
 * Trigger Name : INTLZTS_EU_PositionTriggerService
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
 * Pre - refactored code from ZTS_EU_PositionTrigger
 * ZTS_EU_PositionTriggerHandler pre-refactored code
 -----------------------------------------------------------------------------------------------------------------------------------------
 * Aritra Chakraborty       01/19/2021      Added null checking on territory in AfterInsert context, SPM Position feed was failing due to null territory (SC-008020)
*****************************************************************************************************************************************/
public class INTLZTS_EU_PositionTriggerService 
{
    public static void beforeDelete(List<ZTS_EU_Position__c> triggerOld, Map<Id, ZTS_EU_Position__c> triggerOldMap)
    {
        //Code Added by CloudSense:Parvez  
        /* 
		ZTS_EU_PositionUtilityClass.checkForChildRecords(triggerOld,triggerOldMap);
        */
        //EOC Added by CloudSense:Parvez
    }

    public static void afterUpdate(List<ZTS_EU_Position__c> triggerOld, Map<Id, ZTS_EU_Position__c> triggerOldMap, List<ZTS_EU_Position__c> triggerNew, Map<Id, ZTS_EU_Position__c> triggerNewMap)
    {
        Set<String> terrIdentifierSet=new Set<String>();
        
        for(Id pos:triggerNewMap.keyset())
        {
        //fetch the custom territory identifier for all new positions
            if((triggerNewMap.get(pos).ZTS_EU_Territory__c<>null) && (triggerOldMap.get(pos).ZTS_EU_Territory__c == null) && (triggerOldMap.get(pos).ZTS_EU_Territory__c != triggerNewMap.get(pos).ZTS_EU_Territory__c))
            {
                terrIdentifierSet.add(triggerNewMap.get(pos).ZTS_EU_Territory__c);
            }
        }
        if(terrIdentifierSet<>null) //checks if territory is populated
        {
            //check the account territory count
            Integer ACC_TERR_COUNT=[SELECT count() from ZTS_AccountTerritory__c WHERE 	ZTS_EU_Territory__c IN :terrIdentifierSet];
            Integer TOTAL_ACC_TEAMS_INSERT_COUNT=ACC_TERR_COUNT * terrIdentifierSet.size();
            boolean THRESHOLD_LIMIT_EXCEEDS=TOTAL_ACC_TEAMS_INSERT_COUNT>=Limits.getLimitDmlRows();
            List<ZTS_EU_Position__c> positionWithInsertChgFlagList=new List<ZTS_EU_Position__c>();        
        
            for(ZTS_EU_Position__c postn :triggerNew)
            {
                if(postn.ZTS_ChangeFlag__c == 'Insert')
                {
                    positionWithInsertChgFlagList.add(postn);
                }
            }
            if(THRESHOLD_LIMIT_EXCEEDS)
            {
                //execute batch to create account teams records
                Database.executeBatch(new ZTS_CreateAPFromPositionBatch(positionWithInsertChgFlagList));
            }
            else
            {
                List<ZTS_AccountTerritory__c> accTerrList=[SELECT ZTS_EU_Territory__c,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c WHERE ZTS_EU_Territory__c IN :terrIdentifierSet];                                       
                ZTS_EU_createAccountPosition.createAccountPosition(positionWithInsertChgFlagList,accTerrList);
            }
        }
    }
    
    public static void afterInsert(List<ZTS_EU_Position__c> triggerNew, Map<Id, ZTS_EU_Position__c> triggerNewMap)
    {
        
        /* 
        if(!ZTS_EU_PositionUtilityClass.avoidRecurvise)
		{ 
        ZTS_EU_PositionUtilityClass.InsertAccountPosition(triggerNew);
        } 
		*/
        
        //Added by Tanmoy for ETM defect fix:
        Set<String> terrIdentifierSet=new Set<String>();
        for(ZTS_EU_Position__c pos:triggerNew){
            //fetch the custom territory identifier for all new positions
            if(pos.ZTS_EU_Territory__c<>null) //19-JAN-2021: Aritra added this null checking on territory, SPM Position feed was failing due to null territory (SC-008020) 
            {
            	terrIdentifierSet.add(pos.ZTS_EU_Territory__c);
            }
        }
        // 16-Dec-2019 : AP creation from AT only runs when Territory is populated in Position - added by Aritra (SC-004618)
        if(terrIdentifierSet.size()>0) //checks if territory is populated
        {
            //check the account territory count
            Integer ACC_TERR_COUNT=[SELECT count() from ZTS_AccountTerritory__c WHERE 	ZTS_EU_Territory__c IN :terrIdentifierSet];
            Integer TOTAL_ACC_TEAMS_INSERT_COUNT=ACC_TERR_COUNT * triggerNew.size();
            boolean THRESHOLD_LIMIT_EXCEEDS=TOTAL_ACC_TEAMS_INSERT_COUNT>=Limits.getLimitDmlRows();
            List<ZTS_EU_Position__c> positionWithInsertChgFlagList=new List<ZTS_EU_Position__c>();
            
            
            for(ZTS_EU_Position__c postn :triggerNew){
                if(postn.ZTS_ChangeFlag__c == 'Insert'){
                    positionWithInsertChgFlagList.add(postn);
                }   
            }

            if(THRESHOLD_LIMIT_EXCEEDS){
                //execute batch to create account teams records
                Database.executeBatch(new ZTS_CreateAPFromPositionBatch(positionWithInsertChgFlagList));
            }
            
            else{
                List<ZTS_AccountTerritory__c> accTerrList=[SELECT ZTS_EU_Territory__c,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c WHERE ZTS_EU_Territory__c IN :terrIdentifierSet];                                       
                ZTS_EU_createAccountPosition.createAccountPosition(positionWithInsertChgFlagList,accTerrList);
            }
        }
        //EOC added by Tanmoy
	}
}