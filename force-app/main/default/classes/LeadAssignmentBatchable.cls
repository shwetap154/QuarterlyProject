/*
This class is manually scheduled through the execute anonymous window to run every 10 minutes.   To do so the following code was was executed:
System.schedule('Lead Assignment Scheduled Job 1', '0 0 * * * ?', new LeadAssignmentBatchable());
System.schedule('Lead Assignment Scheduled Job 2', '0 10 * * * ?', new LeadAssignmentBatchable());
System.schedule('Lead Assignment Scheduled Job 3', '0 20 * * * ?', new LeadAssignmentBatchable());
System.schedule('Lead Assignment Scheduled Job 4', '0 30 * * * ?', new LeadAssignmentBatchable());
System.schedule('Lead Assignment Scheduled Job 5', '0 40 * * * ?', new LeadAssignmentBatchable());
System.schedule('Lead Assignment Scheduled Job 6', '0 50 * * * ?', new LeadAssignmentBatchable());
*/

/**
* File Name     :  LeadAssignmentBatchable
* @description  :  Batch class to attempt lead assignment based on business rules. 
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/13/2019		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.  This has been deprecated/deactivated due to low success in matching rates
* 3.0     3/10/2021     Mila Imas SC-008118,SC-008460  additional logic Marketing leads 
* 4.0     03/11/2022    Chelsea Paice @Zoetis       Updating logic to clean up DX leads vs others
* 5.0     6/13/2022     Padma                     TPBUILD-21-Automation: Update Lead Assignment logic so that the assignment for DX Global Lead also applies to Zoetis Reference Lab Lead.

**/
global without sharing class LeadAssignmentBatchable implements Database.Batchable<sObject>, Schedulable{
    //Due to the nature of fuzzy matching on the account name, the batch will operate in a size of 1 to perform querys for only a single lead.
	static final Integer BATCH_SIZE = 1;
    static final String US_UNKNOWN_QUEUE_NAME = 'Unassigned_United_States_Market_Leads';
    static final String CATCH_QUEUE_NAME = 'Catch_Queue_Leads_Not_Auto_Assigned'; 

    
    private String query = 'SELECT Id, Name, Address, Area__c, Company,RecordTypeId,RecordType.DeveloperName, isConverted, Lead_Assignment_Status__c, ' + 
    'ConvertedDate, Description, Email, FirstName,	Industry, LastName, Lead_Assignment_Processed__c, ' +
    'LeadSource, Street, City, State, Country, PostalCode, Account_ID__c,Status, Market__c, MC_Form_Name__c ,ZTS_Country__c,Country__c,' +
    'ZTS_Address_Line_1__c,ZTS_Zip_Postal_Code__c,ZTS_US_State_Province__c' +
    ' FROM Lead ' +
    'WHERE Lead_Assignment_Processed__c != true AND IsConverted != true AND LastModifiedDate >= YESTERDAY';
	
    global LeadAssignmentBatchable() {

	}
    //Overoaded constructor to allow exectution of a single lead for testing.
    global LeadAssignmentBatchable(String leadId) {
        this.query = this.query + ' AND Id = ' + '\'' + leadId +'\'';
	}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
	}

  	global void execute(Database.BatchableContext BC, List<Lead> scope) {
        List<Marketing_Cloud_Form__mdt> formNames = [SELECT Label FROM Marketing_Cloud_Form__mdt];
        Set<String> formLabels = new Set<String>();
        for (Marketing_Cloud_Form__mdt mcf : formNames) {
            formLabels.add(mcf.Label);
        }

        for(Lead lead : scope) {
            //scope should always equal 1            
            //update lead assignment status to in-progress
            lead.Lead_Assignment_Status__c = 'In progress';
            try{
                if (formLabels.contains(lead.MC_Form_Name__c)){
                    lead.Market__c = 'United States';
                    lead.Country = 'United States';
                }
                update lead;
                system.debug('in execute after lead update, market/country is:' + lead.Market__c + '/'+ lead.Country);
            }          
            catch(Exception ex) {
                ErrorLogUtil.log(ex);
                System.debug('An exception Occurred updating the lead to in-progess' + ex);
            }


            try{ 
                List<Account> accounts =  new List<Account>(); 
                Id accountId;
                ZTS_EU_Account_Position__c leadOwnerTeamMember;
                
                if ((lead.RecordType.DeveloperName == 'International_Leads')||(lead.RecordType.DeveloperName == 'Zoetis_Reference_Labs_Lead')) {
                    //diagnostics leads get special possible assignment, try to identify account
                    system.debug('Trying to find specific owner for DX lead');
                    if (lead.Account_ID__c != null){
                        accountId = lead.Account_ID__c;          
                    } else {
                        System.debug('before getPossibleAccounts ');
                        LeadAssignmentBatchHelper.WrapLeadAddress lwrap = new LeadAssignmentBatchHelper.WrapLeadAddress(lead);
                        //get possible account matches, goal is list of size == 1
                        accounts = LeadAssignmentBatchHelper.getPossibleAccounts(
                            lead.Company, 
                            lwrap.Street, 
                            lwrap.PostalCode, 
                            lwrap.State, 
                            lwrap.Country
                        );
                        if (accounts.size() == 1) {
                            accountId = accounts[0].Id;
                        }
                    }

                    if (accountId != null) {
                        // When we actually matched a single acount from the query determine if there is an owner in the account group
                        leadOwnerTeamMember = LeadAssignmentBatchHelper.determineLeadAssignment(accountId);
                    }
                }

                if(leadOwnerTeamMember != null) {
                    //Single lead owner found, attempting to assign
                    LeadAssignmentBatchHelper.assignLead(
                        lead,    
                        leadOwnerTeamMember.ZTS_Employee_ID__c,
                        'Assigned to ' + leadOwnerTeamMember.ZTS_EU_Employee__c + ' on ' + System.now()
                    );
                } else {
                    //assign to default group/queue based on US or not
                    system.debug('assigning to queue');
                    LeadAssignmentBatchHelper.assignUnmatchedLeadToQueue(lead);
                }
                LeadAssignmentBatchHelper.updateLead(lead);
            } catch(Exception ex2) {
                System.debug('exception error ===>' + ex2);
                ErrorLogUtil.log(ex2);
            }           
        }        
	}
	
	global void finish(Database.BatchableContext bc) {}

    global void execute(SchedulableContext ctx){
		LeadAssignmentBatchable batchObject = new LeadAssignmentBatchable();
		Id batchId = Database.executeBatch(batchObject, BATCH_SIZE);
	}	   
    
}