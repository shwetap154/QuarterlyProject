/**
* File Name     :  LeadOwnerHelper.cls
* @description  :  Handler class for LeadTrigger
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     09/08/2020		Ramiro Alvarez @ ATG     Created the Class.
* 2.0     10/21/2020		Cesar Sandrigo @ ATG     Renamed the class from LeadTriggerHandler to LeadOwnerHelper.
*                                                    This was the LeadTriggerHandler class, but it was conflicting with Slalom code.
* 2.1     10/21/2020		Cesar Sandrigo @ ATG     Moved updateOwnerOnLead method to before context.
**/
public class LeadOwnerHelper {
  public static void updateOwnerOnLead(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap) {
    Map<Id, Lead> leadTobeUpd = new Map<Id, Lead>();
    Set<Id> accountIds = new Set<Id>();

    for (Lead lead : newLeadList) {
      Lead oldLead = oldLeadMap.get(lead.Id);
        
      System.debug('NEW ACCOUNT: ' + lead.Account_ID__c);
      System.debug('OLD ACCOUNT: ' + oldLead.Account_ID__c);
        
      //Check if Account on lead was changed and is not null
      if ((lead.Account_ID__c != oldLead.Account_ID__c) && lead.Account_ID__c != null) {
        leadTobeUpd.put(lead.Id, lead);
        accountIds.add(lead.Account_ID__c);
      }
    }

    // Call LeadAssignmentBatchHelper as it being done by CreateLeadFromCall
    Map<Id, Account> accountMap = LeadAssignmentBatchHelper.getAccountsWithTeam(accountIds);
    Map<String, Group> leadAssignmentQueueMap = LeadAssignmentBatchHelper.getLeadAssignmentQueues();

    // Loop into leads that has to be updated due Account lookup change
    for (Lead lead : leadTobeUpd.values()) {
      String ownerId = '';
      Account acct = accountMap.get(lead.Account_ID__c);
      // Use same method in CreateLeadFromCall to determine Lead Assigment
      ZTS_EU_Account_Position__c owner = LeadAssignmentBatchHelper.determineLeadAssignment(acct.Id);
      //If no direct owner was found determin the queue to use based on the account data given
      if (owner == null) {
        ownerId = LeadAssignmentBatchHelper.getQueueAssignment(leadAssignmentQueueMap, acct.ZTS_EU_Market__c);
      } else {
        ownerId = owner.ZTS_Employee_ID__c;
      }
      lead.OwnerId = ownerId;
      lead.Lead_Assignment_Processed__c = true;
    }
  }
}