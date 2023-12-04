/**
 * @description       : Handler for the trigger ZTS_US_Account_PositionTrigger on the after insert, update functionality for the object ZTS_EU_Account_Position__c.
 * @author            : Poonam Dalvi @ Unknown
 * @group             : 
 * @last modified on  : 05-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-21-2018   Poonam Dalvi @ Unknown      Initial Version
 * 1.0   04-13-2022   Ethan Hirsch @ Zoetis Inc   Remove unused methods onAfterInsertAutoFollow and onAfterUpdateAutoFollow
 * 1.0   05-11-2022   Padma Nerella @ Zoetis Inc  Added new method onAfterInsert
**/
public with sharing class SL_ZTS_US_Account_PositionTriggerHandler 
{
    /***********  
     * Method name  : onBeforeInsertUpdate
     * Description  : create the ZTS_EU_Account_Position__c record with required fields.
     * Return Type  : N.A.
     * Parameters   : trigger parameters
     ***********/
    public void onBeforeInsertUpdate(List<ZTS_EU_Account_Position__c> lstAccountPositionNew)
    {
        for (ZTS_EU_Account_Position__c ap: lstAccountPositionNew) {
            ap.ZTS_NotificationUser__c = ap.ZTS_Employee_ID__c;
            ap.ZTS_AccountUserTerrUniqueKey__c=(ap.ZTS_EU_Account__c!=null && ap.ZTS_EU_Position__c!=null)?ap.ZTS_EU_Account__c+':'+ap.ZTS_EU_Position__c:null;
        }
    }

    /***********  
     * Method name  : onAfterUpdate
     * Description  : update the Account record fields based on the user territory.
     * Return Type  : N.A.
     * Parameters   : trigger parameters
     ***********/
    public void onAfterUpdate(List<ZTS_EU_Account_Position__c> lstAccountPositionNew)
    {
        AccountsService.setPrimaryProgramOwnerOnAccounts(lstAccountPositionNew);
    }

    /***********  
     * Method name  : onAfterInsert
     * Description  : Insert of Account position record on Account record.
     * Return Type  : N.A.
     * Parameters   : trigger parameters
     ***********/

    public void onAfterInsert(List<ZTS_EU_Account_Position__c> lstAccountPositionNew)
    {
        AccountsService.setPrimaryProgramOwnerOnAccounts(lstAccountPositionNew);
    }
}