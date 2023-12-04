/*****************************************************************************************************************************************************************
* Name          :    ContactAttendeeCleanupBatchNoCallers
* Description   :    Batch class to blank out RecentCallers field on Contact based if no calls are created in this year. Need to run once on 1st day of the year.
* Author        :    Aritra Chakraborty(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
Mar 20, 2019     Aritra Chakraborty(Cognizant)      Created

****************************************************************************************************************************************************************/

global class ContactAttendeeCleanupBatchNoCallers implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id,RecentCallers__c from Contact where AccountId!=NULL AND ZTS_EU_Contact_Status__c='Active' AND ZTS_EU_Last_Call_Date__c!=THIS_YEAR AND RecentCallers__c!='' AND ZTS_EU_Market__c = 'United States']);
        
    }
    global void execute(Database.BatchableContext BC, List<Contact> contacts) {
        Set<Id> contactIds = new Set<Id>();
        List<Contact> finalContactList = new List<Contact>();
        for (Contact c: contacts )
        {
                c.RecentCallers__c = '';
                finalContactList.add(c);
        }
        if(finalContactList.size() > 0){
            try{ 
                // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
                 Database.DMLOptions dml = new Database.DMLOptions(); 
                 dml.DuplicateRuleHeader.allowSave = true;
                 dml.DuplicateRuleHeader.runAsCurrentUser = true;
                 List<Database.SaveResult> sr = Database.update(finalContactList,dml);
                 
                 //Database.update(finalContactList, false); -- commented for SC-008149
            }catch(Exception ex){
                System.debug('Exception nullifying RecentCallers field on Contacts with no callers');
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        //Yet to be added
    }
    
}