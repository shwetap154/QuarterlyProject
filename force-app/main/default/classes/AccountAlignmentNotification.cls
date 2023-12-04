/*************************************************************************************
* Name          :    AccountAlignmentNotification.
* Description   :    Batch class to notify the user on alignment of an Account.
* Author        :    Sohil Shah(CloudSense)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
12/30/2014       Sohil Shah(CloudSense)            Created
07/16/2015       Sohil Shah(CloudSense)            Modified for SC-001744 - Fetch only those AP's whose SIB flag is True and Send Notification to only ABM and SAM Coaching Group users.    
**************************************************************************************/

global class AccountAlignmentNotification implements Database.Batchable<sObject>{
       
      global Database.QueryLocator start(Database.BatchableContext BC){
     // SC-001744 - Fetch only those AP's whose SIB flag is True      
      return Database.getQueryLocator([Select Id FROM Account]);
   }
    global void execute(Database.BatchableContext BC,List<Account> accounts){        
        Set<Id> empIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();        
        List<User> userList = new List<User>();
        // SC - 001744 Send Notification to only ABM and SAM Coaching Group users
        userList = [Select Name, Email,PIT_Coaching_Group__c from User where id IN: empIdSet and PIT_Coaching_Group__c IN ('TBM','SAM') AND ZTS_EU_Market__c = 'United States'];
        List<Account> accountList = new List<Account>();
        accountList = [Select Name from Account where id IN: accountIdSet AND ZTS_EU_Market__c = 'United States']; 
        Map<Id, List<String>> employeeAccountMap = new Map<Id, List<String>>();
        Map<Id, List<String>> employeeAccountNameMap = new Map<Id, List<String>>();
        List<String> tempList ;
        List<String> tempListName ;
        String sUrlRewrite = System.URL.getSalesforceBaseUrl().getHost();
        
    }
      
    global void finish(Database.BatchableContext BC){
     }
}