/**
* File Name     :  CreateLeadFromCall
* @description  :  Helper class to create a lead from a call when the call has a discussion item of "Diagnostic Equipment Lead" associate to it.
                    The lead is created for the first attendee associated to the discussion.
                    Once the lead has been created, it is assigned to the account owner of the account associated to the call.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     9/4/2019		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020		Cory Bartholomew @ ATG     Added descriptions.
* 3.0     2/11/2021     Mila Imas changes per 
* 4.0     7/21/2021     Mila Imas  SC-008625,SC-008281
* 5.0     9/12/2022     Padma Nerella @ Zoetis TPBuild-39 US-0001756.Update CreateLeadFromCall to Create Reference Lab Leads with New Record Type and Lead Source value will be same for both discussions
**/

public class CreateLeadFromCall {
    public Map<Id,Call__c> callsMap;
    public Map<Id,leadData> callToLeadDataMap = new Map<Id,leadData>();
    public string dname = '';
    
    //Inner class to associate lead information to the call it was sourced from
    public class LeadData{
        public List<Attendee__c> attendees;
        public Call__c call; //mi
        public Account account;
        public String lastName;
        public String firstName;
        public String phone;
        public String company;
        public String companySpecialty;  //The Account Topic from the account related to the call
        public String market; //The market for the account related to the call
        public String leadOwnerId;
        public id discussionID;
        public String leadsource;
   } 
    
    public CreateLeadFromCall(Map<Id,Call__c> calls) {
        System.debug('Initiating CreateLeadFromCall ===> ' + calls);
        this.callsMap = calls;
    }
    
    /**
     * @description worker method to gather data and create the leads
     * @param discussionName The name of the discussion.  Initial build only supports "diagnostic equipment lead" 
     * but this was abstracted out from this class to support other use cases
     */
    public void processCallDiscussions(String discussionName){
        filterAttendeeDiscussions(discussionName);
        System.Debug(Logginglevel.WARN,'LeadData after filtered Attendee Discussions:  >>>  ' + this.callToLeadDataMap);
        if(this.callToLeadDataMap.values().size() > 0){
            getAccountDataForLeads(this.callToLeadDataMap);
        }
        System.debug('Attempting processCallDiscussions: ' + callToLeadDataMap);
     //   System.Debug(Logginglevel.WARN,'LeadData after Account Data:  >>>  ' + this.callToLeadDataMap);
        List<Lead> leadsToInsert = createLeadsFromData(this.callToLeadDataMap);

        if(leadsToInsert.size() > 0){
            insertLeads(leadsToInsert);
		}
        
        ErrorLogUtil.commitLogs();
    }

    /**
     * @description worker method to gather data and create the leads
     * @param discussionName The name of the discussion to process
     */
    public void filterAttendeeDiscussions(String discussionName){
        Set<leadData> leadsToCreate;
        Set<Id> callIds  = new Set<Id>();
        System.Debug(Logginglevel.WARN,'Number of Calls to Process for ===> ' + discussionName + ' discussions: ' +  callsMap.values().size());
        for(Call__c call : this.callsMap.values()){            
            callIds.add(call.Id);            
        } 

        //query attendee data from calls that have attendees.
        List<Attendee__c> attendees = new List<Attendee__c>();
        attendees = getCallAttendees(callIds);        
        System.Debug(Logginglevel.WARN,' ====> Attendees ' + attendees);
        //Loop attendees and child discussion items to find relevant calls to create a lead from
        if (attendees.size() > 0){
            for(Attendee__c attendee : attendees){
                for(ZTS_EU_Discussion__c discussion : attendee.Discussions__r){
                    discussionName = discussion.Name;
                       //If the correct discussion name (initially built for "Diagnostic Equipment Lead") exists, add the call to a list for lead creation
                      System.Debug('discussion.Name ===> ' + discussion.Name);
                    if(discussion.Name == 'Diagnostics Equipment Lead' || discussion.Name == 'Reference Lab Lead'  ){                        
                        //Check if the map already contains the call Id as a value before creating a new entry for the same one.
                        System.Debug('LeadData already contains attendee call ? ' + callToLeadDataMap.containsKey(attendee.ZTS_EU_call__c));
                        if(!callToLeadDataMap.containsKey(attendee.ZTS_EU_call__c)){    
                            LeadData ldata = new LeadData();
                            ldata.attendees = new List<Attendee__c>();
                            if(callsMap.containsKey(attendee.ZTS_EU_call__c)){
                                ldata.call = callsMap.get(attendee.ZTS_EU_call__c); 
                            }
                            
                            ldata.firstName = attendee.ZTS_EU_Contact__r.FirstName;
                            ldata.lastName = attendee.ZTS_EU_Contact__r.LastName;
                            ldata.phone = attendee.ZTS_EU_Contact__r.Phone;
                            If (discussion.Name == 'Reference Lab Lead'){ //mi
                                dname = 'Reference Lab Lead';
                            }else {
                                dname = 'Diagnostics Equipment Lead';
                            }
                            
                            ldata.leadsource = 'Sales Call';
                            ldata.discussionID = discussion.id;   //mi
                            ldata.attendees.add(attendee);        //mi
                            this.callToLeadDataMap.put(attendee.ZTS_EU_call__c,ldata); //mi
                            System.debug('Attendee Data was put in map' + ldata);     
                        } 
                    }                       
                }
            }
        }
    }

     /**
     * @description get the account data to assign leads that are being created
     * @param leadData The lead data created from calls that have the correct discussion name
     */
    public void getAccountDataForLeads(Map<Id,LeadData> leadData){
       Set<Id> accountIds = new Set<Id>();
       for(LeadData ldata : this.callToLeadDataMap.Values()){
           if(ldata.call != null){
               accountIds.add(ldata.call.ZTS_EU_Account__c);
           }
       }
        Map<Id,Account> accountMap = LeadAssignmentBatchHelper.getAccountsWithTeam(accountIds);
        Map<String, Group> leadAssignmentQueueMap = LeadAssignmentBatchHelper.getLeadAssignmentQueues();

        for(LeadData ldata2 : this.callToLeadDataMap.Values()){
            if(ldata2.call != null && ldata2.call.ZTS_EU_Account__c != null){
                if(accountMap.containsKey(ldata2.call.ZTS_EU_Account__c)){
                    Account acct = accountMap.get(ldata2.call.ZTS_EU_Account__c);
                    //CPQATG-1057 use new team logic to determine owner or queue
                    String ownerId = '';
                    ZTS_EU_Account_Position__c owner = LeadAssignmentBatchHelper.determineLeadAssignment(acct.Id);
                    system.debug('after LeadAssignmentBatchHelper.determineLeadAssignmen === 136 owner '+ owner);
                    //ZTS_EU_Account_Position__c
                    //If no direct owner was found determin the queue to use based on the account data given
                    if(owner == null){
                        ownerId = LeadAssignmentBatchHelper.getQueueAssignment(leadAssignmentQueueMap, acct.ZTS_EU_Market__c);
                    } else {
                        ownerId = owner.ZTS_Employee_ID__c;
                    }
                    ldata2.company = acct.Name;
                    ldata2.companySpecialty = acct.Company_Specialty__c;
                    ldata2.leadOwnerId = ownerId;
                    ldata2.market = acct.ZTS_EU_Market__c;
                    ldata2.account = acct;
                }
            }
       }
    }  

    /**
     * @description Process the gathered data and transform it into lead records
     * @param leadData The lead data created from calls that have the correct discussion name
     */
    public List<Lead> createLeadsFromData(Map<Id,LeadData> leadData){
        List<Lead> leadsToInsert = new List<Lead>();
        for(LeadData data : leadData.values()) {
                      
            String recordTypeDeveloperName = 'Zoetis_Reference_Labs_Lead'; 
            String recordTypeDeveloperName1 = 'International_Leads';
           // String recordTypeDeveloperName = data.market == 'United States' ? 'Generic' : 'International_Leads';
            system.debug('method createLeads data.market ===>' + data.market);
            system.debug('about to create a lead from call data line 170');
            Lead newLead = new Lead(
                FirstName = data.firstName,
                LastName = data.lastName,
                Company = data.company,
                Account_ID__c = data.account.Id,
                Street = data.account.BillingStreet,
                City = data.account.BillingCity,
                State = data.account.BillingState,
                Country = data.account.BillingCountry,
                PostalCode = data.account.BillingPostalCode,
                Phone = data.phone,
                Company_Specialty__c = data.companySpecialty,
                OwnerId = data.leadOwnerId,
                Market__c = data.market,
                Lead_Assignment_Processed__c = true,
                Source_Call_Id__c = data.call.Id,
                call__c = data.call.Id, //mi
                Discussion__c = data.discussionID //mi
                
            );
   
            if  (dname == 'Reference Lab Lead'){          //mi
                newLead.Reference_Lab_Lead__c = true;    //mi
                newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
            }else if (dname == 'Diagnostics Equipment Lead'){ 
                newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName1).getRecordTypeId();
            }   
            newLead.leadSource = 'Sales Call';
            newLead.Lead_Assignment_Status__c = 'Auto Created from call via discussion: ' + newLead.leadSource; //mi
            leadsToInsert.add(newLead);           
        }
        return leadsToInsert;
    }  

    /**
     * @description Insert the generated leads and wrtie a CPQ error log if there were any failures
     * @param leads The lead records to insert
     */
    public void insertLeads(List<Lead> leads){
        System.debug('Attempting to insert leads: ' + leads);
        Database.SaveResult[] leadInsert = Database.insert(leads,false);
        
        ErrorLogUtil.handleSaveResults('Create Leads from Calls:  Failed to insert Leads', leadInsert);               
    }
    
    /**
     * @description query attendees from the call to determine if a discussion on "Diagnostic Equipment Lead" has occurred.  
     * @param callIds The calls to get related data from
     */
    public static List<Attendee__c> getCallAttendees(Set<Id> callIds){
          List<Attendee__c> listAtnd = [
            SELECT 
                Id, Name, ZTS_EU_of_Discussion_items__c, ZTS_EU_Attendee_Count__c, ZTS_EU_Attendee_Count_Vet__c, ZTS_EU_call__c, ZTS_EU_Contact__r.Phone,
	            ZTS_EU_Call_Date__c, ZTS_EU_Contact__c, ZTS_EU_Represents_Account__c, ZTS_EU_Uniqueness_Key__c,ZTS_EU_Contact__r.FirstName, ZTS_EU_Contact__r.LastName, 
	            (
		            SELECT 
                        Id, Name, ZTS_EU_Account__c, ZTS_EU_Call_Attendee__c, ZTS_EU_Campaign__c, ZTS_EU_Discussion_Items__c, 
                        ZTS_EU_Discussion_Topic__c, ZTS_EU_Product__c, ZTS_EU_Uniqueness_Key__c
		            FROM Discussions__r
	            ) 
            FROM Attendee__c 
            WHERE ZTS_EU_call__c IN :callIds 
                  and ZTS_EU_call__c not in (select Call__c from Lead where Call__c in :callIds)
            ORDER BY CreatedDate];
          
        System.Debug(' getCallAttendees ===> ' + listAtnd);
        return listAtnd;
    }
}