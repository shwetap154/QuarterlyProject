/**
 * @description Set Owner on Account updated in the last 7 days not in the United States, Australia, or New Zealand Market. 
 *              Owner is set to the User specified in the AccountAndContactOwnerId__c Custom Setting.
 * @author Amitabh Chandra @ Cognizant 
 * @since 01-14-2019
 * * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-14-2019   Amitabh Chandra @ Cognizant Initial Version (SC-004029)
 * 1.1   01-09-2023   Ethan Hirsch @ Zoetis Inc   Bypass the Account Trigger when updating Accounts in execute to improve performance (TPDEV-82)
 */
global class ZTS_EU_AccountOwner implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT ID, Ownerid, ZTS_EU_Market__c, ZTS_EU_Country__c, ZTS_EU_Account_Status__c' 
            + ' FROM Account'
            + ' WHERE LastModifiedDate = LAST_N_DAYS:7'
            +  ' AND ZTS_EU_Market__c != \'New Zealand\''
            +  ' AND ZTS_EU_Market__c != \'Australia\''
            +  ' AND ZTS_EU_Market__c != \'United States\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) 
    {
        //boolean isUpdate = false;
        string accOwner; 
        List<AccountAndContactOwnerId__c> ownerids= AccountAndContactOwnerId__c.getall().values(); 
        Map<string, string> MarketUserIdMap=new Map<string,string>(); 
        for(AccountAndContactOwnerId__c customvalues:ownerids)
        { 
            MarketUserIdMap.put(customvalues.Market__c,customvalues.OwnerId__c); 
        }
        List<Account> AccountOwnerToUpdate = new List<Account>();
        for(Account AccountOwnerId : scope)
        {
            if(MarketUserIdMap.containsKey(AccountOwnerId.ZTS_EU_Market__c) && AccountOwnerId.OwnerId!=MarketUserIdMap.get(AccountOwnerId.ZTS_EU_Market__c) && MarketUserIdMap.containsKey(AccountOwnerId.OwnerId)!=null)
            { 
                AccountOwnerId.OwnerId=MarketUserIdMap.get(AccountOwnerId.ZTS_EU_Market__c);
                //isUpdate = true;
                //System.debug('Owner ID***'+MarketUserIdMap.get(AccountOwnerId.ZTS_EU_Market__c));
	            AccountOwnerToUpdate.add(AccountOwnerId);
            } 
        }

        // Bypass Account Trigger as setting Owner does not kick off any trigger logic.
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update AccountOwnerToUpdate;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
    }
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}