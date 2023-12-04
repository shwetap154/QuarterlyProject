/****************************************************************************************************************************************** 
 * Trigger Name : USCampaignMemberTriggerService
 * Description  : Trigger on Campaign Members.
 *                -If campaign is isInactive, user shdn't be able to add/remove campaign members.
                  -Adding a contact type campaignmember for open field target  and active campaign should create Target Account 
                   or update existing ones status to Added.
 * Created Date : April 16, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Akanksha Gupta    `     April 16, 2014      Created
 * Raghu                   June  11, 2014      Added/Modified for active campaigns and target accounts
 * Art Smorodin           02/07/2020           Moved to Service Class
 * Aritra(Cognizant)       March 9, 2021       Turned off the bypass logic, changed code to create campaign accounts for contact's account (SC-008159)
*****************************************************************************************************************************************/
public class USCampaignMemberTriggerService 
{      
    public static void afterInsert(List<CampaignMember> triggerNew, Map<Id, CampaignMember> triggerNewMap)
    {
        //if(!(CustomSettingService.checkIfTriggerActive('CampaignMemberTrigger'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        //Aritra Commented the above bypass logic (SC-008159)
        Map<ID, Contact> parentOpps = new Map<ID, Contact>();
        List<contact> cnts = new List<Contact>();
        Map<Id,String> usercontactmap = new Map<Id,String>();
        Map<Id,String> usercontactemailmap = new Map<Id,String>();
        List<CampaignMember> members = new List<CampaignMember>();
        Map<Id,Campaign> campMap = new Map<Id,Campaign>(); 
        List<CampaignMember> camMembers = new List<CampaignMember>();
        //This part updates the Campaign_Member_Created_by__c, Campaign_Member_Created_by_Email__c fields on contacts with campaign member creating user. 
        /*members=[select id,contactId,createdBy.name,createdBy.email,createdBy.profile.name from CampaignMember where id IN:triggerNew AND ZTS_EU_Market__c = 'United States'];
        for (CampaignMember childObj : members) {
            if(childObj.createdBy.profile.name!='US Home Office Profile'&&childObj.createdBy.profile.name!='System Administrator'){
                usercontactmap.put(childObj.contactId,childObj.createdBy.name);
                System.debug('campaign member contact ids'+usercontactmap.keyset());
                System.debug('campaign member name'+usercontactmap.values());
                usercontactemailmap.put(childObj.contactId,childObj.createdBy.email);
            }
        }*/
        //SC-008729 - Commented the above section and written updated code below
       
        members=[select id,contactId,createdBy.name,createdBy.email,createdBy.profile.name from CampaignMember where id IN:triggerNew AND ZTS_EU_Market__c = 'United States' 
                 and createdBy.profile.name not in ('US Home Office Profile','System Administrator') ];//changed by Aritra
        
        if(members.size()>0){
            for (CampaignMember childObj : members) {
                usercontactmap.put(childObj.contactId,childObj.createdBy.name);
                System.debug('campaign member contact ids'+usercontactmap.keyset());
                System.debug('campaign member name'+usercontactmap.values());
                usercontactemailmap.put(childObj.contactId,childObj.createdBy.email);
            }
        }
        
        if(!usercontactemailmap.isEmpty()){
            for(Contact con : [select id,Campaign_Member_Created_by__c,Campaign_Member_Created_by_Email__c,email from contact where id IN:usercontactmap.keyset() AND ZTS_EU_Market__c = 'United States'])
            {
                con.Campaign_Member_Created_by__c = usercontactmap.get(con.id);
                con.Campaign_Member_Created_by_Email__c = usercontactemailmap.get(con.id);
                cnts.add(con);
            }
            // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 			Database.DMLOptions dml = new Database.DMLOptions(); 
 			dml.DuplicateRuleHeader.allowSave = true;
 			dml.DuplicateRuleHeader.runAsCurrentUser = true;
 			List<Database.SaveResult> sr = Database.update(cnts,dml);
            //update cnts;---- commented for SC-008149
        }
        //If the contact's account is not already added in campaigns targeted account, it creates the targeted account for the associated account
        if(controlTriggers.execute_CampaignMember_Trigger)
        {
            Set<Id> conIdset = new Set<Id>();
            controlTriggers.execute_ZTS_US_Campaign_Account_Trigger = false;
            Map<ID,List<CampaignMember>> cammemmap = new Map<Id,List<CampaignMember>>{};
            
            system.debug('*********executing the campaign trigger'+trigger.size);
            camMembers = triggerNew;
            
            for(CampaignMember cm : camMembers){
                if(cammemmap.containskey(cm.CampaignId)){
                    cammemmap.get(cm.CampaignId).add(cm);
                } 
                else cammemmap.put(cm.CampaignId,new List<CampaignMember>{cm});
            }
            List<Campaign> cList =  [Select Id,ZTS_EU_Field_Targeting__c,IsActive from Campaign where Id in :cammemmap.keySet() AND ZTS_EU_Market__c = 'United States'];
            for(Campaign c: cList){
                campMap.put(c.Id,c);
            }
    
            for(CampaignMember cam : camMembers )
            {
                String fieldVal = campMap.get(cam.CAmpaignId).ZTS_EU_Field_Targeting__c;
                boolean inActiveCampaign=!campMap.get(cam.CAmpaignId).IsActive;
                if (inActiveCampaign){
                    //TODO create custom label for error message
                    cam.addError('You cannot add or delete campaign members for Inactive Campaigns.');
                    // cam.addError('You cannot add or delete campaign members if Field Targeting is Closed on associated Campaign.');
                }
                //Below part is added by Aritra for SC-008159(Add contact's associated account in targeted account )
                else
                {
                    
                    if(cam.ContactId!=null){conIdset.add(cam.ContactId);}
                }
            }
            //get the associated accounts for campaignmember contacts
        Map<Id,Contact> contactMap=new Map<Id,Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :conIdset AND AccountId!=null AND ZTS_EU_Market__c = 'United States']);
        Set<Id> accIds=new Set<Id>();
        for(Contact con:contactMap.values()){
            accIds.add(con.AccountId);
        }
        List<ZTS_EU_Campaign_Account__c> campgnAccList = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c,ZTS_EU_Targeted_Account_Unique__c FROM ZTS_EU_Campaign_Account__c 
                                                        WHERE ZTS_EU_Campaign__c IN :campMap.keySet() AND ZTS_EU_Account__c IN :accIds AND ZTS_EU_Market_From_Parent__c = 'United States'];
        Map<String,List<ZTS_EU_Campaign_Account__c>> cmpAccMap = new Map<String,List<ZTS_EU_Campaign_Account__c>>();                                       
        for(ZTS_EU_Campaign_Account__c cmp_acc:campgnAccList){
            String cmp_acc_key=cmp_acc.ZTS_EU_Campaign__c+'-'+cmp_acc.ZTS_EU_Account__c;
            if(!cmpAccMap.containsKey(cmp_acc_key)){
                cmpAccMap.put(cmp_acc_key,new List<ZTS_EU_Campaign_Account__c>());
            }
            cmpAccMap.get(cmp_acc_key).add(cmp_acc);
        }   
        
        List<ZTS_EU_Campaign_Account__c> campAccList=new List<ZTS_EU_Campaign_Account__c>();
        Set<ZTS_EU_Campaign_Account__c> campAccSet=new Set<ZTS_EU_Campaign_Account__c>();
        String STATUS_ADDED='Added';
        for(CampaignMember cam : camMembers ){
            String fieldTarget = campMap.get(cam.CampaignId).ZTS_EU_Field_Targeting__c;
            boolean activeCampaign=campMap.get(cam.CampaignId).IsActive;
            if(fieldTarget=='Open' && activeCampaign){                                       
                //check for existing target accounts associated with campaign member or create new target accounts
                if(cam.contactId!=null && contactMap.containsKey(cam.contactId)){
                    String camp_acc_key=cam.CampaignId+'-'+contactMap.get(cam.contactId).AccountId;
                    if(!cmpAccMap.containsKey(camp_acc_key)){
                        //create a new target account
                        campAccSet.add(new ZTS_EU_Campaign_Account__c(ZTS_EU_Campaign__c=cam.CampaignId,ZTS_EU_Account__c=contactMap.get(cam.contactId).AccountId,
                                   ZTS_EU_Member_Status__c=STATUS_ADDED));
                    }
                    else{
                        for(ZTS_EU_Campaign_Account__c ca:cmpAccMap.get(camp_acc_key)){
                            if(ca.ZTS_EU_Member_Status__c!=STATUS_ADDED){
                                campAccSet.add(new ZTS_EU_Campaign_Account__c(id=ca.id,ZTS_EU_Member_Status__c=STATUS_ADDED));
                            }
                        }
                    }
                }
            }
        }
        if(!campAccSet.isEmpty()){
            System.debug('### campAccSet : '+campAccSet);
            campAccList.addAll(campAccSet);
            System.debug('### campAccList : '+campAccList);
            //TODO exception handling
            Database.upsert(campAccList,true);
            campAccList.clear();
        }
            
        }
    }

    public static void beforeDelete(List<CampaignMember> triggerOld, Map<Id, CampaignMember> triggerOldMap)
    {
        //if(!(CustomSettingService.checkIfTriggerActive('CampaignMemberTrigger'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        //Aritra Commented the above bypass logic (SC-008159)
        if(controlTriggers.execute_CampaignMember_Trigger)
        {
            controlTriggers.execute_ZTS_US_Campaign_Account_Trigger = false;
            Map<ID,List<CampaignMember>> cammemmap = new Map<Id,List<CampaignMember>>{};
            List<CampaignMember> camMembers;
            system.debug('*********executing the campaign trigger'+trigger.size);
            camMembers = triggerOld;
            Map<Id,Campaign> campMap = new Map<Id,Campaign>(); 
            for(CampaignMember cm : camMembers){
                if(cammemmap.containskey(cm.CampaignId)){
                    cammemmap.get(cm.CampaignId).add(cm);
                } 
                else cammemmap.put(cm.CampaignId,new List<CampaignMember>{cm});
            }
            List<Campaign> cList =  [Select Id,ZTS_EU_Field_Targeting__c,IsActive from Campaign where Id in :cammemmap.keySet() AND ZTS_EU_Market__c = 'United States'];
            for(Campaign c: cList){
                campMap.put(c.Id,c);
            }
    
            for(CampaignMember cam : camMembers )
            {
                String fieldVal = campMap.get(cam.CAmpaignId).ZTS_EU_Field_Targeting__c;
                boolean inActiveCampaign=!campMap.get(cam.CAmpaignId).IsActive;
                if (inActiveCampaign){
                    //TODO create custom label for error message
                    cam.addError('You cannot add or delete campaign members for Inactive Campaigns.');
                    // cam.addError('You cannot add or delete campaign members if Field Targeting is Closed on associated Campaign.');
                }
            }
        }
    }
}