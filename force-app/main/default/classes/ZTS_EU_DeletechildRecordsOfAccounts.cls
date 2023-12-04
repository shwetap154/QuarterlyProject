/*************************************************************************************
* Name          :    ZTS_EU_DeletechildRecordsOfAccounts.
* Description   :    Delete Account positions of merged records Ref: INC0449170 via Account Trigger on before delete
* Author        :    Sohil Shah(cloudSense)
 
Modification Log
----------------
Date             Developer                         Comments  
---------------------------------------------------------------------------------------
09/28/2015       Sohil Shah(cloudSense)            Created

*/

public class ZTS_EU_DeletechildRecordsOfAccounts{
    public static void deleteChildRecordsOfAccountOnMerge(List<Account> TriggerOld){
        
        list<ZTS_EU_Account_Position__c> accountPositionList = [SELECT Id, Name, ZTS_EU_Account__c 
        FROM ZTS_EU_Account_Position__c 
        WHERE ZTS_EU_Account__c IN: TriggerOld
          AND ZTS_EU_Market__c != 'United States'];  
        
        if(accountPositionList.size() > 0 && !(accountPositionList.isEmpty())){
            Database.delete(accountPositionList, false);    
        }
    }
}