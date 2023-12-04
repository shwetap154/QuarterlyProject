/**
* File Name     :  LeadAssignmentBatchHelper
* @description  :  Helper class for LeadAssignmentbatchable.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/13/2019     Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020      Cory Bartholomew @ ATG     Added descriptions.  This has been deprecated/deactivated due to low success in matching rates
* 3.0     8/13/2020     Cory Bartholomew @ ATG     CPQATG-636 Refactor class to utilize lead and account address in query matching.  
                                                    Also added in Account team members to assignment criteria
* 4.0     2/16/2021     Mila Imas                   SC-008118,SC-008460  
* 5.0     3/9/2022      Chelsea Paice               SC-009382, fix assignment for US queues
* 6.0     6/13/2022     Padma                     TPBUILD-21-Automation: Update Lead Assignment logic so that the assignment for DX Global Lead also applies to Zoetis Reference Lab Lead.
* 7.0 	  7/12/2022		Prasun Dubey				SC-009830, updated query in getAccountsWithTeam method to not look for SIB flag
* 8.0     7/27/2022     Morgan Marchese             Migrated Field Force Final Strings to FieldForceSettingsService
**/

public without sharing class LeadAssignmentBatchHelper {
  // public static final String US_UNKNOWN_LEAD_QUEUE = 'Unknown US Lead Owner';
   public static final String TERRITORY_TYPE_TERRITORY = 'Territory';
   public static final String TERRITORY_TYPE_AREA = 'Area';
   public static final String VACANT_EMPLOYEE = 'Vacant Vacant';
   public static final String US_UNKNOWN_QUEUE_NAME = 'Unassigned_United_States_Market_Leads';//correct one
   public static final String CATCH_QUEUE_NAME = 'Catch_Queue_Leads_Not_Auto_Assigned';
  
    /**
     * getPossibleAccounts description
     * @param  companyName The company name passed from a lead
     * @param  street      The street passed from a lead
     * @param  postalCode  The postal code passed from a lead
     * @param  state       the state passed from a lead
     * @param  country     the country passed from a lead
     * @return List<Account> account that are possible matches based on company name and address info
     */ 
    public static List<Account> getPossibleAccounts(String companyName, String street, String postalCode, String state, String country ){
       List<Account> accountsToReturn = new List<Account>();
          System.debug('getPossibleAccounts!');   
        if (
            //If there is no data, we can't make an accurate query, so return empty list
            String.isBlank(street) && String.isBlank(postalCode) && String.isBlank(state) && String.isBlank(country)
        ){
            return accountsToReturn;
        } else{
            String queryFields = 'Id, Name, BillingStreet, BillingCity, BillingState, OwnerId ';
            String whereClause = 'WHERE ';                     
            if(!String.isBlank(companyName)){            
            whereClause += 'Name LIKE \'%' + escapeSpecialChars(companyName) + '%\' ';         
            }            
            if(!String.isBlank(street)){
                whereClause += ' AND BillingStreet LIKE \'%' + street + '%\'';
            }    
            if(!String.isBlank(postalCode)){
                whereClause += ' AND BillingPostalCode LIKE \'%' + postalCode + '%\'';
            }   
            if(!String.isBlank(state)){
                whereClause += ' AND BillingState LIKE \'%' + state + '%\'';
            }     
            if(!String.isBlank(country)){
                whereClause += ' AND BillingCountry LIKE \'%' + country + '%\'';
            }   
    
            String queryString =  'SELECT ' + queryFields + 'FROM Account ' + whereClause;      
            accountsToReturn = Database.query(queryString);    
    
            return accountsToReturn;
        }   
    } 
    
    public static String escapeSpecialChars(String s){
        if(s.contains('\'')){
            System.debug('Replacing single quote');
            s = s.replace('\'','\\\'');
        } 
        return s;
    }

    /**
     * getAccountTeam Get the account team members that meet all necessary criteria to use for determining lead assignment
     * @param  accountId The account that the lead was matched to
     * @return  return List<ZTS_EU_Account_Position__c> the team members that meet the criteria
     */ 
    public static ZTS_EU_Account_Position__c determineLeadAssignment(Id accountId){
        ZTS_EU_Account_Position__c leadAssignment = new ZTS_EU_Account_Position__c();
        Map<Id,Account> accountMap = getAccountsWithTeam(new Set<Id>{accountId});
        List<ZTS_EU_Account_Position__c> teamMembers = new List<ZTS_EU_Account_Position__c>();
        if(accountMap.containsKey(accountId)){
            teamMembers = accountMap.get(accountId).Account_Positions__r;
        }
        System.debug('Determining Lead Assignment from Account Team: ' + teamMembers);
        if(teamMembers.isEmpty()){
            return null;
        } else{
            List<ZTS_EU_Account_Position__c> diagnosticsTeamMembers = findTeamMembers(teamMembers, FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS,TERRITORY_TYPE_TERRITORY);
            System.debug('Diagnostics team members check');
            //If a single diagnostics team member was found assign them as the lead owner
            if(!diagnosticsTeamMembers.isEmpty() && diagnosticsTeamMembers.size() == 1){
                leadAssignment = diagnosticsTeamMembers[0];
                return leadAssignment;
            } else {
                System.debug('Diagnostics area managers check');
                //If no diagnostics team member was found, try for a Diagnostics area manager
                List<ZTS_EU_Account_Position__c> diagnosticsAreaManagers = findTeamMembers(teamMembers, FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS,TERRITORY_TYPE_AREA);
                if(!diagnosticsAreaManagers.isEmpty() && diagnosticsAreaManagers.size() == 1){
                    leadAssignment = diagnosticsAreaManagers[0];
                    return leadAssignment;
                } else {
                    System.debug('inside diagnostics sales rep check');
                    // If no area managers move to the final level, inside diagnostics sales reps
                    List<ZTS_EU_Account_Position__c> insideDiagnosticsSalesReps = findTeamMembers(teamMembers, FieldForceSettingsService.FIELD_FORCE_INSIDE_SALES_DIAGNOSTICS,TERRITORY_TYPE_TERRITORY);
                    if(!insideDiagnosticsSalesReps.isEmpty() && insideDiagnosticsSalesReps.size() == 1){
                        leadAssignment = insideDiagnosticsSalesReps[0];
                        return leadAssignment;
                    } else{
                        return null;
                    }
                } 
            }
        }
    }  

     /**
     * getAccountTeam Get the account team members that meet all necessary criteria to use for determining lead assignment
     * @param  accountId The account that the lead was matched to
     * @return  return List<ZTS_EU_Account_Position__c> the team members that meet the criteria
     */ 
    public static Map<Id,Account> getAccountsWithTeam(Set<Id> accountIds){
        Map<Id,Account> accounts = new Map<Id,Account>([
            SELECT Id,   Name, Company_Specialty__c,ZTS_EU_Zip_Postal_Code__c,OwnerId,ZTS_EU_Market__c,BillingStreet,  BillingCity,  BillingState,BillingCountry, BillingPostalCode,
                (SELECT Id, Name,  ZTS_EU_Account__c, Account_Market__c, ZTS_NotificationUser__c, ZTS_AccountTerritory__c, Account_Type__c, ZTS_EU_Active__c, ZTS_City__c, 
                        ZTS_EU_Employee__c, ZTS_EU_Employee_Id__c,ZTS_Employee_ID__c, ZTS_Field_Force_Name__c, ZTS_EU_Employee_Role__c, ZTS_EU_Is_Active__c, ZTS_EU_Market__c,ZTS_EU_Position__c,
                        ZTS_SIB_Flag__c, Standard_Territory_ID__c, ZTS_EU_Territory__c,
                        ZTS_AccountTerritory__r.ZTS_EU_Territory__r.ZTS_EU_Type__c
                    FROM Account_Positions__r WHERE ZTS_EU_Employee__c != :VACANT_EMPLOYEE AND ZTS_EU_Employee__c != ' ' // Removed condition as part of SC-009830 -- AND ZTS_SIB_Flag__c = true
                        AND (ZTS_Field_Force_Name__c = :FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS OR ZTS_Field_Force_Name__c = :FieldForceSettingsService.FIELD_FORCE_INSIDE_SALES_DIAGNOSTICS)
                    AND (ZTS_AccountTerritory__r.ZTS_EU_Territory__r.ZTS_EU_Type__c = :TERRITORY_TYPE_TERRITORY  OR ZTS_AccountTerritory__r.ZTS_EU_Territory__r.ZTS_EU_Type__c = :TERRITORY_TYPE_AREA)
                ) FROM Account  WHERE Id IN :accountIds ]); 
          
        System.debug('Accounts: ' + accounts.values().size());
        if(accounts.values().size() > 0){
            for(Account account : accounts.values()){
                System.debug(account);
                System.debug('Account positions: ' + account.Account_Positions__r);
            }
        }
        return accounts;
    }

    /**
     * 
     * @param  teamMembers The list of account team members to filter
     * @param  fieldForceName The field force name to compare against the account team member
     * @param  territoryType The territory type to compare against the account team member
     * @return List<ZTS_EU_Account_Position__c> of team members that matched the filter criteria.
     */ 
    public static List<ZTS_EU_Account_Position__c> findTeamMembers(List<ZTS_EU_Account_Position__c> teamMembers, String fieldForceName, String territoryType){
        List<ZTS_EU_Account_Position__c> teamMembersToReturn = new List<ZTS_EU_Account_Position__c>();

        for(ZTS_EU_Account_Position__c member : teamMembers){
            if( 
                (member.ZTS_Field_Force_Name__c == fieldForceName) &&
                (member.ZTS_AccountTerritory__r.ZTS_EU_Territory__r.ZTS_EU_Type__c == territoryType)                
            ){
                teamMembersToReturn.add(member);
            }
        }
        return teamMembersToReturn;
    }
    
    public static void assignUnmatchedLeadToQueue(Lead lead){
        String queueId = null;
        string market = lead.Market__c;
        if (String.isBlank(market)) {
            if (!String.isBlank(lead.Country)) {
                market = lead.Country;
            } else {
                market = lead.Country__c;
            }
        }
        system.debug('In assignUnmatchedLeadToQueue, market is: ' + market);
        String queueUsed = '';
        if(market == 'United States'){
            if (lead.RecordType.DeveloperName == 'International_Leads' || lead.RecordType.DeveloperName == 'Zoetis_Reference_Labs_Lead') {
                queueId = getQueueId(US_UNKNOWN_QUEUE_NAME);
                queueUsed = US_UNKNOWN_QUEUE_NAME;
            } else {
                queueId = getQueueId(CATCH_QUEUE_NAME);
                queueUsed = CATCH_QUEUE_NAME;
            }
        } else {
            if(String.isBlank(market)){                
                queueId = getQueueId(CATCH_QUEUE_NAME);
                queueUsed = CATCH_QUEUE_NAME;
            } else{
                String queueNameSearch = 'Unassigned ' + market + ' Market Leads';
                String queueDevNameSearch = queueNameSearch.replace(' ','_');
                queueId = getQueueIdByMarket(queueDevNameSearch);
                queueUsed = queueNameSearch;     
            }
                  
        }
        system.debug('line 190 market ===>' + market + '  US_UNKNOWN_QUEUE_NAME ==>'+queueId );
        //Fallback to the catch queue if a queue wasn't found based on the other search crtieria
        if(String.isBlank(queueId)){
            queueId = getQueueId(CATCH_QUEUE_NAME);
            queueUsed = CATCH_QUEUE_NAME;
        }
        
        assignLead(
            lead, 
            queueId,
            'No account or owner was matched.  Lead was assigned to the ' + queueUsed + ' queue on ' + System.now()
        );        
    }

    public static String getQueueAssignment(Map<String,Group> queueMap, String market){
        String queueId = null;  
        if(String.isBlank(market)){                
            queueId = null;                
        } else {
            String queueName = 'Unassigned_' + market.replace(' ','_') + '_Market_Leads';
            if(queueMap.containsKey(queueName)){
                queueId = queueMap.get(queueName).Id;
            } else {
                queueId = null;
            }                            
        }                  
        
        //Fallback to the catch queue if a queue wasn't found based on the other search crtieria
        if(String.isBlank(queueId)){
            queueId = queueMap.get(CATCH_QUEUE_NAME).Id;            
        }
        return queueId;        
    }

    public static void assignLead(Lead lead, String ownerId, String assignmentStatus){
        lead.OwnerId = ownerId;
        lead.Lead_Assignment_Status__c = assignmentStatus;
        lead.Lead_Assignment_Processed__c = true;
    }


    public static Id getQueueId(String queueName){
        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName =: queueName LIMIT 1];
        System.debug('line 234 Attemping to query  queue ' + queueName);
        if (queue == null){System.debug('Queue NOT Found');return null;}
        else { System.debug('Queue Found: ' + queue.DeveloperName + ': ' +  queue.Id); return queue.Id;}
        
    }
    
    public static Id getQueueIdByMarket(String marketQueueName){
        System.debug('Attemping to query market queue ' + marketQueueName);
        List<Group> queues = [ SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :marketQueueName LIMIT 1];
        System.debug('line 243 Market Queue' + queues);
        if(queues.size() > 0){ return queues[0].Id;}
        else{return null;}
    }
    

    public static void updateLead(Lead lead){
        system.debug('Trying to update Lead line 250 ===>'+lead);
        try{ update lead;
        } catch(Exception e) {
            ErrorLogUtil.log(e);System.debug(LoggingLevel.WARN, 'Could not update the assignment status of this lead ' + lead); System.debug(LoggingLevel.WARN, e);
            ErrorLogUtil.commitLogs();

            Lead errorLead = new Lead();
            errorLead.Id = lead.Id;
            errorLead.Lead_Assignment_Status__c = 'Error: ' + e.getMessage().left(200);
            errorLead.Lead_Assignment_Processed__c = true;
        

            try{ 
                update errorLead;
            } catch(Exception e2){
                ErrorLogUtil.log(e2);
                System.debug(LoggingLevel.WARN, 'Could not update the assignment status of this lead ' + lead);
                System.debug(LoggingLevel.WARN, e2);
                ErrorLogUtil.commitLogs();
            }
        }
    }
    //Get all of the relevant queues for lead assignment from the org
    public static Map<String, Group> getLeadAssignmentQueues(){
        Map<String, Group> queueMap = new Map<String,Group>();
        
        List<Group> queues = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND (DeveloperName LIKE '%Market_Leads%' OR DeveloperName =: CATCH_QUEUE_NAME) ];

        for(Group queue : queues){
            if(!queueMap.containsKey(queue.DeveloperName)){
                queueMap.put(queue.DeveloperName, queue);
            }
        }
        return queueMap;
    } 

    public class WrapLeadAddress {
        public String street {get; set;}
        public String postalCode {get; set;}
        public String state {get; set;}
        public String country {get; set;}
 
        public WrapLeadAddress(Lead l) {
            //created to handle the several different possible address fields that exist on Lead
            if (l.ZTS_Address_Line_1__c != null) {street = l.ZTS_Address_Line_1__c;}
            if (l.ZTS_Zip_Postal_Code__c != null) {postalCode = l.ZTS_Zip_Postal_Code__c;}
            if (l.ZTS_US_State_Province__c != null) {state = l.ZTS_US_State_Province__c;}
            if (l.ZTS_Country__c != null) {country = l.ZTS_Country__c;}
            //other set
            if (l.Street != null) {street = l.Street;}
            if (l.PostalCode != null) {postalCode = l.PostalCode;}
            if (l.State != null) {state = l.State;}
            if (l.Country != null) {country = l.Country;}
        }
    }

}