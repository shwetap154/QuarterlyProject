/****************************************************************************************************************************************** 
 * Trigger Name : INTLCampaignMemberTriggerService
 * Description  : Trigger on Campaign Members.
 *                 If the Field Targetting on a campaign is Closed, user shdn't be able to add/remove campaign members.
 * Created Date : April 16, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Akanksha Gupta    `     April 16, 2014      Created 
 * Art Smorodin			   02/07/2020	       Moved to Service Class
 * Aritra(Cognizant)       10-Mar-2021         Added logic in after insert event to Add contact's associated account in targeted account(SC-008159)
*****************************************************************************************************************************************/
public class INTLCampaignMemberTriggerService 
{      
	public static void afterInsert(List<CampaignMember> triggerNew, Map<Id, CampaignMember> triggerNewMap)
    {
        Map<Id,Campaign> campMap = new Map<Id,Campaign>(); 
        List<CampaignMember> camMember = new List<CampaignMember>();
        boolean flag=false;
 		List<Profile> prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];
 		for(Profile p:prof){
 			if(p.Id == UserInfo.getProfileId()){
    			flag=true;
    		}
    	}

		if(!flag){ 
			Map<ID,List<CampaignMember>> cammemmap = new Map<Id,List<CampaignMember>>{};
			List<CampaignMember> camMembers;
			if(trigger.IsInsert){ 
				camMembers = trigger.new;
			}
            else{
                camMembers = trigger.old;
            }
			Map<Id,Campaign> campList = new Map<Id,Campaign>(); 
            for(CampaignMember cm : camMembers){
                if(cammemmap.containskey(cm.CampaignId)){
                    cammemmap.get(cm.CampaignId).add(cm);
                } 
                else cammemmap.put(cm.CampaignId,new List<CampaignMember>{cm});
            }
		
			List<Campaign> cList =  [Select Id,ZTS_EU_Field_Targeting__c from Campaign where Id in :cammemmap.keySet() AND ZTS_EU_Market__c != 'United States'];
			for(Campaign c: cList){
				campList.put(c.Id,c);
			}
            for(CampaignMember cam : camMembers )
            {
                String fieldVal = campList.get(cam.CAmpaignId).ZTS_EU_Field_Targeting__c;
                system.debug('------------fieldVal--'+ fieldVal);
                if (((trigger.isInsert && trigger.isBefore) || (trigger.isDelete && trigger.isBefore)) &&  fieldVal == 'Closed'){
                    cam.addError('You cannot add or delete campaign members if Field Targeting is Closed on associated Campaign.');
                }
            }
 		}
        //Start - Code added by Aritra for SC-008159(Add contact's associated account in targeted account )
        Set<Id> conIdset = new Set<Id>();
            Map<ID,List<CampaignMember>> cammemmap = new Map<Id,List<CampaignMember>>{};
            
            system.debug('*********executing the campaign trigger'+trigger.size);
            camMember = triggerNew;
            
            for(CampaignMember cm : camMember){
                if(cammemmap.containskey(cm.CampaignId)){
                    cammemmap.get(cm.CampaignId).add(cm);
                } 
                else cammemmap.put(cm.CampaignId,new List<CampaignMember>{cm});
            }
            List<Campaign> cList =  [Select Id,ZTS_EU_Field_Targeting__c,IsActive from Campaign where Id in :cammemmap.keySet() AND ZTS_EU_Market__c != 'United States'];
            for(Campaign c: cList){
                campMap.put(c.Id,c);
            }
    
            for(CampaignMember cam : camMember )
            {
                String fieldVal = campMap.get(cam.CAmpaignId).ZTS_EU_Field_Targeting__c;
                boolean inActiveCampaign=!campMap.get(cam.CAmpaignId).IsActive;
                if (inActiveCampaign){
                    
                    cam.addError('You cannot add or delete campaign members for Inactive Campaigns.');
                    
                }
                
                else
                {
                    if(cam.ContactId!=null){conIdset.add(cam.ContactId);}
                }
            }
            //get the associated accounts for campaignmember contacts
        Map<Id,Contact> contactMap=new Map<Id,Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :conIdset AND AccountId!=null AND ZTS_EU_Market__c != 'United States']);
        Set<Id> accIds=new Set<Id>();
        for(Contact con:contactMap.values()){
            accIds.add(con.AccountId);
        }
        List<ZTS_EU_Campaign_Account__c> campgnAccList = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c,ZTS_EU_Targeted_Account_Unique__c FROM ZTS_EU_Campaign_Account__c 
                                                        WHERE ZTS_EU_Campaign__c IN :campMap.keySet() AND ZTS_EU_Account__c IN :accIds AND ZTS_EU_Market_From_Parent__c != 'United States'];
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
        for(CampaignMember cam : camMember ){
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
        //End - Code added by Aritra for SC-008159(Add contact's associated account in targeted account )
    }
	public static void beforeDelete(List<CampaignMember> triggerOld, Map<Id, CampaignMember> triggerOldMap)
    {
        boolean flag=false;
 		List<Profile> prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];
 		for(Profile p:prof){
 			if(p.Id == UserInfo.getProfileId()){
    			flag=true;
    		}
    	}

		if(!flag){ 
			Map<ID,List<CampaignMember>> cammemmap = new Map<Id,List<CampaignMember>>{};
			List<CampaignMember> camMembers;
			if(trigger.IsInsert){ 
				camMembers = trigger.new;
			}
            else{
                camMembers = trigger.old;
            }
			Map<Id,Campaign> campList = new Map<Id,Campaign>(); 
            for(CampaignMember cm : camMembers){
                if(cammemmap.containskey(cm.CampaignId)){
                    cammemmap.get(cm.CampaignId).add(cm);
                } 
                else cammemmap.put(cm.CampaignId,new List<CampaignMember>{cm});
            }
		
			List<Campaign> cList =  [Select Id,ZTS_EU_Field_Targeting__c from Campaign where Id in :cammemmap.keySet() AND ZTS_EU_Market__c != 'United States'];
			for(Campaign c: cList){
				campList.put(c.Id,c);
			}
            for(CampaignMember cam : camMembers )
            {
                String fieldVal = campList.get(cam.CAmpaignId).ZTS_EU_Field_Targeting__c;
                system.debug('------------fieldVal--'+ fieldVal);
                if (((trigger.isInsert && trigger.isBefore) || (trigger.isDelete && trigger.isBefore)) &&  fieldVal == 'Closed'){
                    cam.addError('You cannot add or delete campaign members if Field Targeting is Closed on associated Campaign.');
                }
            }
 		}
    }
}