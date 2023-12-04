/******************************************************************************************************************************************* 
* Class Name   : ZTS_US_BatchPopulateAccountTSF
* Description  : This Batch class populates the Zoetis Territory (ZTS_US_TSF__c) field for Active Accounts from its Account Territories 
*                with SIB flag = True
*      
* Created By   : Cognizant/ Aritra
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer               				 Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Cognizant/ Aritra            		0‎6/12/2018           Created
* Slalom / David                    0‎3/11/2020           Edited
*****************************************************************************************************************************************/
public class ZTS_US_BatchPopulateAccountTSF  implements Database.Batchable<sObject> 
{
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {    	
        return Database.getQueryLocator([
            SELECT Id, ZTS_US_TSF__c, ZTS_EU_Account_Status__c 
            FROM Account 
            WHERE ZTS_EU_Account_Status__c = 'Active'
              AND ZTS_EU_Market__c = 'United States'
        ]);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {			
        Map<Account, List<ZTS_AccountTerritory__c>> mapAccwithAccountTerr = new Map<Account, List<ZTS_AccountTerritory__c>>();
        List<Account> lstAccountToUpdate = new List<Account>(); 
        List<Id> lstAccntIdInScope = new List<Id>();
        
        for (Account acc: (List<Account>)scope)
        {
            lstAccntIdInScope.add(acc.Id);
        }
   
        List<Account> accwithAccTerr = [
            SELECT Id, ZTS_US_TSF__c,
            	   (SELECT Id, Name, ZTS_EU_Account__c, ZTS_TerrName__c 
             	    FROM Accounts_Territory__r 
                    WHERE ZTS_SIB_Flag__c = True) 
            FROM Account 
            WHERE Id IN :lstAccntIdInScope
        ];
        
        for (Account account: accwithAccTerr)
        {
            mapAccwithAccountTerr.put(account, account.Accounts_Territory__r);
        }
        
        for(Account acc : mapAccwithAccountTerr.keySet())
        {
            Set<String> accTerrTokenSet = new Set<String>();
            String TSFVal='';
            List<ZTS_AccountTerritory__c> lstAccTerr= mapAccwithAccountTerr.get(acc);
            
            for (ZTS_AccountTerritory__c at : lstAccTerr)
            {
                if(at.ZTS_TerrName__c != null)
                {
                    accTerrTokenSet.add(at.ZTS_TerrName__c);
                }
                
            }
            
            for(String s: accTerrTokenSet)
            {
                TSFVal = TSFVal + s + ';';
            }
            
            acc.ZTS_US_TSF__c = TSFVal;
            lstAccountToUpdate.add(acc);
        }
        
        if(lstAccountToUpdate.size() > 0)
        {
            //Bypass the Account Trigger when updating Accounts (TPDEV-84)
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            List<Database.Saveresult> save_results = Database.update(lstAccountToUpdate, false);
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            String msg = ZTS_EU_Logger.getDMLSuccessMsg(save_results);
            ZTS_EU_Logger.info(msg, null, 'ZTS_US_BatchPopulateAccountTSF-Successinfo');
            ZTS_EU_Logger.error(save_results, 'ZTS_US_BatchPopulateAccountTSF-Account TSF Populated');
        }
    }	
    
    public void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [
            SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE Id = :BC.getJobId()
        ];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'ARITRA.CHAKRABORTY3@cognizant.com', 'Abir.LalBhattacharya@cognizant.com'};
            
        mail.setToAddresses(toAddresses);
        mail.setSubject('US Account TSF Population Job - ' + a.Status);
        mail.setPlainTextBody('Total Batches processed ' + a.TotalJobItems + ' with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});        
    }
    
    /** Run the batch **/
    public static String executeBatch(Integer batchSize)
    {
        return Database.executeBatch(new ZTS_US_BatchPopulateAccountTSF(), batchSize);     
    }
    
    
}