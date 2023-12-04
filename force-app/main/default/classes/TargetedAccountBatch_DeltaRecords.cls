global class TargetedAccountBatch_DeltaRecords implements Database.Batchable<sObject>
{
    global TargetedAccountBatch_DeltaRecords()
    {
        
        controlTriggers.execute_CampaignMember_Trigger  = false;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
      return Database.getQueryLocator([Select ID, Name, CreatedDate,ZTS_EU_Account__c,ZTS_US_Active__c,ZTS_EU_Campaign__c,ZTS_EU_Campaign__r.No_Batch__c,ZTS_EU_Campaign_Hidden__c from ZTS_EU_Campaign_Account__c where createdDate >=2019-01-03T00:00:00.000Z and ZTS_EU_Campaign__r.No_Batch__c = false AND ZTS_EU_Market_From_Parent__c = 'United States']  );
      
    }
    global void execute(Database.BatchableContext BC, List<ZTS_EU_Campaign_Account__c > listCampAcc)
    {
        
    Set<Id> campaignIDSet=new Set<Id>();
    Set<Id> accIDSet=new Set<Id>();
    for(ZTS_EU_Campaign_Account__c campgn_acc:listCampAcc){
        campaignIDSet.add(campgn_acc.ZTS_EU_Campaign__c);
        accIDSet.add(campgn_acc.ZTS_EU_Account__c);
    }
    
     
     
     Map<Id,Campaign> campaignMap=new Map<Id,Campaign>([SELECT Id, IsActive, ZTS_EU_External_ID__c, Name, ZTS_EU_Field_Targeting__c,Type 
                                                       FROM Campaign WHERE ID IN :campaignIDSet AND ZTS_EU_Market__c = 'United States']
                                                      );
     
     Map<Id,List<ZTS_EU_Affiliations__c>> acc_map=new Map<Id,List<ZTS_EU_Affiliations__c>>();
     for(ZTS_EU_Affiliations__c accCon: [SELECT ZTS_EU_Account__r.Id, ZTS_EU_Account__r.Name, 
     ZTS_EU_Contact__r.AccountId,ZTS_EU_Contact__r.Id,ZTS_EU_Account__c,ZTS_EU_Contact__c,
     ZTS_EU_Contact__r.Name,ZTS_EU_Contact__r.Interface_Email_Opt_Out__c,ZTS_EU_Contact__r.HasOptedOutOfFax,ZTS_EU_Contact__r.DoNotCall,ZTS_EU_Contact__r.ZTS_US_Phone_Opt_out__c,
                                                 ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c,ZTS_EU_Contact__r.ZTS_US_NARC_ID__c,ZTS_EU_Contact__r.Email   
                                                 FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Account__c IN :accIDSet and ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c!=:ZTS_EU_GlobalConstants.INACTIVE_CONTACT and ZTS_US_Primary_Account__c=true AND ZTS_EU_Market_from_Parent__c = 'United States']){
        if(acc_map.containskey(accCon.ZTS_EU_Account__c)){
            acc_map.get(accCon.ZTS_EU_Account__c).add(accCon);
        }else{
            acc_map.put(accCon.ZTS_EU_Account__c,new List<ZTS_EU_Affiliations__c>{accCon});
        }
        
    }                                           
     List<CampaignMember> campaignMembersListToInsert=new List<CampaignMember>();
     List<CampaignMember> campaignMembersListToInsertNew=new List<CampaignMember>();                                          
      for(ZTS_EU_Campaign_Account__c new_campgn_acc:listCampAcc){
        
        if(campaignMap.containsKey(new_campgn_acc.ZTS_EU_Campaign__c) && acc_map.containsKey(new_campgn_acc.ZTS_EU_Account__c)){
            
            //List<Contact> contactList=acc_map.get(new_campgn_acc.ZTS_EU_Account__c).Contacts;
            boolean IS_EMAIL_CAMPAIGN=campaignMap.get(new_campgn_acc.ZTS_EU_Account__c).Type==ZTS_EU_GlobalConstants.CAMPAIGN_TYPE_EMAIL?TRUE:FALSE;
            boolean IS_TELEMARKETING_CAMPAIGN=campaignMap.get(new_campgn_acc.ZTS_EU_Campaign__c).Type==ZTS_EU_GlobalConstants.TELEMARKET_TYPE_EMAIL?TRUE:FALSE;
            
         for(ZTS_EU_Affiliations__c oAccConAff : acc_map.get(new_campgn_acc.ZTS_EU_Account__c))
         {
            
            if(IS_EMAIL_CAMPAIGN && !oAccConAff.ZTS_EU_Contact__r.Interface_Email_Opt_Out__c){
                
                   campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=oAccConAff.ZTS_EU_Contact__r.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));
            }
                
            //CHECK FOR PHONE OR DONOT CALL CONTACTS FOR TELEMARKETING CAMPAIGNS
            else if(IS_TELEMARKETING_CAMPAIGN && ! (oAccConAff.ZTS_EU_Contact__r.ZTS_US_Phone_Opt_out__c || oAccConAff.ZTS_EU_Contact__r.DoNotCall)){
                
                    campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=oAccConAff.ZTS_EU_Contact__r.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));                        
            }
                
            //OTHER CAMPAIGN TYPES
            else if(!IS_EMAIL_CAMPAIGN && !IS_TELEMARKETING_CAMPAIGN)
            {
                
                    campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=oAccConAff.ZTS_EU_Contact__r.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));
                
            }
        }
          
    }
      }
     if(!campaignMembersListToInsert.isEmpty())
     {
        system.debug('test >>>>>>>> campaignMembersListToInsert '+ campaignMembersListToInsert.size()+'------------'+campaignMembersListToInsertNew.size()); 
       List<Database.Saveresult> results=Database.insert(campaignMembersListToInsert,false);
     }
      }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}