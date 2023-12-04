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
 * Chelsea Paice           01/21/2022           Commenting out entity subscription inserts
 * Padma Nerella           05/11/2022           Added a method onAfterInsert inside afterInsert Method to update the Account object SC-005636
*****************************************************************************************************************************************/

public with sharing class USZTS_EU_Account_PositionTriggerService {

    public static void beforeInsert(List<ZTS_EU_Account_Position__c> triggerNew){

        SL_ZTS_US_Account_PositionTriggerHandler objHandler = new SL_ZTS_US_Account_PositionTriggerHandler();
        objHandler.onBeforeInsertUpdate(triggerNew);

    }

    public static void beforeUpdate(List<ZTS_EU_Account_Position__c> triggerOld, Map<Id, ZTS_EU_Account_Position__c> triggerOldMap, List<ZTS_EU_Account_Position__c> triggerNew, Map<Id, ZTS_EU_Account_Position__c> triggerNewMap){

        SL_ZTS_US_Account_PositionTriggerHandler objHandler = new SL_ZTS_US_Account_PositionTriggerHandler();
        objHandler.onBeforeInsertUpdate(triggerNew);

    }

    public static void afterInsert(List<ZTS_EU_Account_Position__c> triggerNew, Map<Id, ZTS_EU_Account_Position__c> triggerNewMap){

        SL_ZTS_US_Account_PositionTriggerHandler objHandler = new SL_ZTS_US_Account_PositionTriggerHandler();
        objHandler.onAfterInsert(triggerNew);
        /****** AUTO-FOLLOW / UNFOLLOW ACCOUNT RECORD FEEDS  - !!! TURNOFF ON BATCH LOADS !!! *****/
        // if (ZTS_EU_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS) 
        // {
            //Commenting out auto-follow inserts as they cause errors in territory inserts from integration
            //objHandler.onAfterInsertAutoFollow(triggerNew);
        // }

    }

    public static void afterUpdate(List<ZTS_EU_Account_Position__c> triggerOld, Map<Id, ZTS_EU_Account_Position__c> triggerOldMap, List<ZTS_EU_Account_Position__c> triggerNew, Map<Id, ZTS_EU_Account_Position__c> triggerNewMap){

        SL_ZTS_US_Account_PositionTriggerHandler objHandler = new SL_ZTS_US_Account_PositionTriggerHandler();
        objHandler.onAfterUpdate(triggerNew);
        /****** AUTO-FOLLOW / UNFOLLOW ACCOUNT RECORD FEEDS  - !!! TURNOFF ON BATCH LOADS !!! *****/
        // if (ZTS_EU_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS) 
        // {
            //Commenting out auto-follow inserts as they cause errors in territory inserts from integration
            //objHandler.onAfterUpdateAutoFollow(triggerNew, triggerOldMap);
        // }

    }

}