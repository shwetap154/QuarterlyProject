/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 05-18-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-09-2023   Padma Nerella @ Zoetis Inc  Batch class to update the child accounts corporate flag from parent account TPDEV-109
 * 1.1   05-18-2023   Padma Nerella @ Zoetis Inc  Added parentAccs list to send parentId to parentMap and added logger to catch exception
**/
global class UpdateAccountCorporateFlagBatch implements Database.Batchable<sObject>,Database.Stateful{
    global Set<Id> parentAccIds;
    @TestVisible Private List<Account> parentAccs = new List<Account>();
    @TestVisible Private static Boolean forceMapContainsParent = true;
   
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        parentAccs = AccountSelector.newInstance().SelectINTLParentAccs(parentAccIds);
        return Database.getQueryLocator(AccountSelector.newInstance().retrieveInternationalParentAccountsByIdQuery(parentAccIds));
    }
    
    global void execute(Database.BatchableContext BC,List<Account> scope){
        try{
            if(scope.size()>0){
                Map<Id,Account> parentMap = new Map<Id, Account>(scope);
                Map<Id,Account> newParentMap = new Map<Id,Account>(parentAccs);
                for(Account accs :parentMap.values()){
                    if((!parentMap.containsKey(accs.ZTS_EU_Parent_Id__c) || (!forceMapContainsParent&&Test.isRunningTest()))){
                        parentMap.put(accs.ZTS_EU_Parent_Id__c,newParentMap.get(accs.ZTS_EU_Parent_Id__c));
                    }
                }
                List<Account> accList = AccountsService.setZTSEUCorporateFlagFromINTLParentAcc(parentMap);
                DispatchTriggerHandler.bypass('AccountTriggerHandler');
                Database.SaveResult [] updateResult = Database.update(accList, false);
                DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
                Logger.error('Failed to Update Corporate Flag on Account. Please make sure it matches its Parent: ', updateResult);
                
            }
        }catch(Exception e) {
            Logger.error('Failed to Update Corporate Flag on Account. Please make sure it matches its Parent: ', +e.getMessage(), null);
        }
        
    }
    global void finish(Database.BatchableContext BC){
    }
}