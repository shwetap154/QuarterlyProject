/****************************************************************************************************************************************** 
 * Class Name : USZTS_EU_Account_PositionTriggerService
 * Description  : This Trigger populates Account Position/Teams with notification user,externalID account userterrkey and has subscribe/unsubscibe logic to accountrecord feeds.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 17 Mar 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   03/17/2014           Created
 * Art Smorodin			   02/13/2020	      	Moved to Service Class
 * Chelsea Paice           10/08/2021           Added triggerOldMap to before update call of SL_ZTS_Account_PositionTriggerHandler
*****************************************************************************************************************************************/
public class INTLZTS_EU_Account_PositionTrigerService {

	public static void beforeInsert(List<ZTS_EU_Account_Position__c> triggerNew){
        
		SL_ZTS_Account_PositionTriggerHandler objHandler = new SL_ZTS_Account_PositionTriggerHandler();
        objHandler.onBeforeInsertUpdate(triggerNew,null);
    }

    public static void beforeUpdate(List<ZTS_EU_Account_Position__c> triggerOld, Map<Id, ZTS_EU_Account_Position__c> triggerOldMap, List<ZTS_EU_Account_Position__c> triggerNew, Map<Id, ZTS_EU_Account_Position__c> triggerNewMap){

        SL_ZTS_Account_PositionTriggerHandler objHandler = new SL_ZTS_Account_PositionTriggerHandler();
        objHandler.onBeforeInsertUpdate(triggerNew,triggerOldMap);
    }

    public static void afterInsert(List<ZTS_EU_Account_Position__c> triggerNew, Map<Id, ZTS_EU_Account_Position__c> triggerNewMap){

       
        SL_ZTS_Account_PositionTriggerHandler objHandler = new SL_ZTS_Account_PositionTriggerHandler();
        //if (ZTS_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS) 
        //{
            objHandler.onAfterInsertAutoFollow(triggerNew);
        //}
    }

    public static void afterUpdate(List<ZTS_EU_Account_Position__c> triggerOld, Map<Id, ZTS_EU_Account_Position__c> triggerOldMap, List<ZTS_EU_Account_Position__c> triggerNew, Map<Id, ZTS_EU_Account_Position__c> triggerNewMap){

        
		SL_ZTS_Account_PositionTriggerHandler objHandler = new SL_ZTS_Account_PositionTriggerHandler();
        //if (ZTS_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS) 
        //{
            objHandler.onAfterUpdateAutoFollow(triggerNew, triggerOldMap);
        //}
    }    	
    
    public static void afterUndelete(List<ZTS_EU_Account_Position__c> triggerNew, Map<Id, ZTS_EU_Account_Position__c> triggerNewMap){
        
        
		SL_ZTS_Account_PositionTriggerHandler objHandler = new SL_ZTS_Account_PositionTriggerHandler();
        //if (ZTS_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS) 
        //{
            objHandler.onAfterInsertAutoFollow(triggerNew);
        //}
    }
}