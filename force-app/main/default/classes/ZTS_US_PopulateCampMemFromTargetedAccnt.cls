/*************************************************************************************************************************
  Class Name     : ZTS_US_PopulateCampMemFromTargetedAccnt
  Description    : This class is called from trigger on Targeted Account for creation of Campaign Member records.
  Created By     : Mayank
  Created On     : 05/19/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Mayank Agarwal                      05/19/2014              Created
  
***************************************************************************************************************************/
public class ZTS_US_PopulateCampMemFromTargetedAccnt
{
   public static void insertCampMem(List<ZTS_EU_Campaign_Account__c> listCampAcc){
    Set<Id> campaignIDSet=new Set<Id>();
    Set<Id> accIDSet=new Set<Id>();
    for(ZTS_EU_Campaign_Account__c campgn_acc:listCampAcc){
        if(campgn_acc.No_Batch__c==true){
            System.debug('campgn_acc.No_Batch__c' + campgn_acc.No_Batch__c);
        	campaignIDSet.add(campgn_acc.ZTS_EU_Campaign__c);
        	accIDSet.add(campgn_acc.ZTS_EU_Account__c);
        }
    }
    
    system.debug('----------accIDSet: '+ accIDSet);
     //Get Campaigns for inserted records
     
     
     Map<Id,Campaign> campaignMap=new Map<Id,Campaign>([SELECT Id, IsActive, ZTS_EU_External_ID__c, Name, ZTS_EU_Field_Targeting__c,Type 
                                                       FROM Campaign WHERE ID IN :campaignIDSet AND ZTS_EU_Market__c = 'United States']
                                                      );
     /*Map<Id,Account> acc_map=new Map<Id,Account>([SELECT Id, Name, (SELECT AccountId,Id,Name,Interface_Email_Opt_Out__c,HasOptedOutOfFax,DoNotCall,ZTS_US_Phone_Opt_out__c,
                                                 ZTS_EU_Contact_Status__c,ZTS_US_NARC_ID__c,Email FROM Contacts WHERE ZTS_EU_Contact_Status__c!=:ZTS_EU_GlobalConstants.INACTIVE_CONTACT ) 
                                                 FROM Account WHERE ID IN :accIDSet AND ZTS_EU_Market__c = 'United States']);*/
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
     system.debug('test >>>>>>>> list size'+ acc_map.size());                                            
     List<CampaignMember> campaignMembersListToInsert=new List<CampaignMember>();
     List<CampaignMember> campaignMembersListToInsertNew=new List<CampaignMember>();                                          
      for(ZTS_EU_Campaign_Account__c new_campgn_acc:listCampAcc){
        
        if(campaignMap.containsKey(new_campgn_acc.ZTS_EU_Campaign__c) && acc_map.containsKey(new_campgn_acc.ZTS_EU_Account__c)){
            
            //List<Contact> contactList=acc_map.get(new_campgn_acc.ZTS_EU_Account__c).Contacts;
            boolean IS_EMAIL_CAMPAIGN=campaignMap.get(new_campgn_acc.ZTS_EU_Campaign__c).Type==ZTS_EU_GlobalConstants.CAMPAIGN_TYPE_EMAIL?TRUE:FALSE;
            boolean IS_TELEMARKETING_CAMPAIGN=campaignMap.get(new_campgn_acc.ZTS_EU_Campaign__c).Type==ZTS_EU_GlobalConstants.TELEMARKET_TYPE_EMAIL?TRUE:FALSE;
            
         for(ZTS_EU_Affiliations__c oAccConAff : acc_map.get(new_campgn_acc.ZTS_EU_Account__c))
         {
            //CHECK FOR EMAIL OPT OUTS CONTANCTS FOR EMAIL MARKETING CAMPAIGNS
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
                system.debug('test >>>>>>>> campaignMembersListToInsert 1'+ campaignMembersListToInsert.size());    
            }
        }
            /*if(contactList!=null && !contactList.isEmpty() ){
                Set<String> campaign_con_uniq_keySet=new Set<String>();

                
                for(Contact con:contactList){
                    
                   //CHECK FOR EMAIL OPT OUTS CONTANCTS FOR EMAIL MARKETING CAMPAIGNS
                    if(IS_EMAIL_CAMPAIGN && !con.HasOptedOutOfEmail){ 
                        campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=con.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));
                            
                        }
                        
                        //CHECK FOR PHONE OR DONOT CALL CONTACTS FOR TELEMARKETING CAMPAIGNS
                        else if(IS_TELEMARKETING_CAMPAIGN && ! (con.ZTS_US_Phone_Opt_out__c || con.DoNotCall)){
                        campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=con.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));
                                                
                        }
                        
                        //OTHER CAMPAIGN TYPES
                        else if(!IS_EMAIL_CAMPAIGN && !IS_TELEMARKETING_CAMPAIGN){
                        campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=con.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));
                            
                        }
                   //}        

                }
                
            }*/ 
        }
          
   
  }
     //system.debug('test >>>>>>>> campaignMembersListToInsert '+ campaignMembersListToInsert.size()); 
     if(!campaignMembersListToInsert.isEmpty())
     {
        system.debug('test >>>>>>>> campaignMembersListToInsert '+ campaignMembersListToInsert.size()+'------------'+campaignMembersListToInsertNew.size()); 
       List<Database.Saveresult> results=Database.insert(campaignMembersListToInsert,false);
       //insertSobj(Json.serialize(campaignMembersListToInsert));
        /**I gnore below error message as when existing Campaign members are inserted again will receive error
          !!!!!!!! campaign;getStatusCode=DUPLICATE_VALUE;] This entity is already a member of error !!!!!!!!!!
         **/
        //ZTS_EU_Logger.error(results,'ZTS_US_PopulateCampMemFromTargetedAccnt-insertCampMem');
     }
     
     
 }
   
   public static void updCampMem(List<ZTS_EU_Campaign_Account__c> listCampAcc, Map<ID,ZTS_EU_Campaign_Account__c> triggerOldMap){
                  Boolean statusRemoved = false;
                  List<Id> campaignIDList=new List<Id>();
                  List<Id> accIDList=new List<Id>();
                  Set<Id> campaign_acc_WithRemovedStatus_Set=new Set<Id>();
                  Set<Id> contactIdSet=new Set<Id>();
                for(ZTS_EU_Campaign_Account__c  updatedCampAcc:listCampAcc){
                    if(triggerOldMap.get(updatedCampAcc.id).ZTS_EU_Member_Status__c!=updatedCampAcc.ZTS_EU_Member_Status__c && updatedCampAcc.ZTS_EU_Member_Status__c=='Removed'){
                        system.debug('inside update loop >>>>>>>>>>>>>');
                        statusRemoved = true;
                        campaignIDList.add(updatedCampAcc.ZTS_EU_Campaign__c);
                        accIDList.add(updatedCampAcc.ZTS_EU_Account__c);
                        campaign_acc_WithRemovedStatus_Set.add(updatedCampAcc.Id);
                    }else if(triggerOldMap.get(updatedCampAcc.id).ZTS_EU_Member_Status__c!=updatedCampAcc.ZTS_EU_Member_Status__c && updatedCampAcc.ZTS_EU_Member_Status__c=='Added'){
                        statusRemoved = false;
                    }
                }
                        if(statusRemoved){
                        //get  contacts associated with campaigns accounts/target accounts
                       Map<Id,Account> accMap=new Map<Id,Account>([SELECT Id,Name,(SELECT Id from Contacts) FROM Account WHERE Id IN :accIDList AND ZTS_EU_Market__c = 'United States']);
                       Map<Id,Set<Id>>accContactIdMap=new Map<Id,Set<Id>>();
                       for(Id accId:accMap.keySet()){
                        if(!accContactIdMap.containsKey(accId)){
                            accContactIdMap.put(accId,new Set<Id>());
                        }
                        
                         for(List<Contact> conList:accMap.get(accId).Contacts){
                            for(Contact con:conList){
                            accContactIdMap.get(accId).add(con.id);
                            }
                         }
                       }
                       
                        Map<Id,Campaign> campaignMap=new Map<Id,Campaign>();
                        campaignMap.putAll(ZTS_US_CampaignManager.getCampaignsWithMembersForTargetAccounts(listCampAcc,accContactIdMap));
                        
                        
                        List<Id> campMemIdToRemove=new List<Id>();
                        //delete contacts for associated campaign 
                        for(ZTS_EU_Campaign_Account__c updatedCamAcc:listCampAcc){
                            if(campaign_acc_WithRemovedStatus_Set.contains(updatedCamAcc.id)){
                                if(accContactIdMap.containsKey(updatedCamAcc.ZTS_EU_Account__c)){
                                    contactIdSet=accContactIdMap.get(updatedCamAcc.ZTS_EU_Account__c);
                                for(CampaignMember cmpgnMember:campaignMap.get(updatedCamAcc.ZTS_EU_Campaign__c).CampaignMembers){
                                    if(contactIdSet.contains(cmpgnMember.ContactId)){
                                        campMemIdToRemove.add(cmpgnMember.id);
                                    }
                                  }
                                }
                            }
                        }
                        
                     if(!campMemIdToRemove.isEmpty()){
                        System.debug('## campMemIdToRemove : '+campMemIdToRemove.size());
                       List<Database.Deleteresult> results= Database.delete(campMemIdToRemove,false);
                       ZTS_EU_Logger.error(results, 'ZTS_US_PopulateCampMemFromTargetedAccnt-delCampMem');
                     }
                    }
                   /* else {
                       system.debug('kist size >>>>>>>>>>>>>>>'+listCampAcc.size());
                       insertCampMem(listCampAcc);
                    }*/
   }
   public static void delCampMem(List<ZTS_EU_Campaign_Account__c> listCampAcc){
   	set<string> accids = new set<string>();
   	Boolean accfound = false;
   	Set<Id> campaignIDSet=new Set<Id>();
    Set<Id> accIDSet=new Set<Id>();
    Set<string> targetNARCIds = new set<string>();
   	for(ZTS_EU_Campaign_Account__c tar_acc : listCampAcc){
   		campaignIDSet.add(tar_acc.ZTS_EU_Campaign__c);
    }
    
    system.debug('----------accIDSet: '+ accIDSet);
     //Get Campaigns for deleted records
     
     
     Map<Id,Campaign> campaignMap=new Map<Id,Campaign>([SELECT Id, IsActive, ZTS_EU_External_ID__c, Name, ZTS_EU_Field_Targeting__c,Type 
                                                       FROM Campaign WHERE ID IN :campaignIDSet AND ZTS_EU_Market__c = 'United States']);
      for(ZTS_EU_Campaign_Account__c all_tar_acc : [select id,ZTS_EU_Account__c from ZTS_EU_Campaign_Account__c where ZTS_EU_Campaign__c IN:campaignIDSet AND ZTS_EU_Market_From_Parent__c = 'United States']){
      	accids.add(all_tar_acc.ZTS_EU_Account__c);
      }
      for(ZTS_EU_Campaign_Account__c tar_acc1 : listCampAcc){
      	if(accIds.contains(tar_acc1.ZTS_EU_Account__c)){
      		accfound = true;
      		return;
      	}
      	else
      	targetNARCIds.add(tar_acc1.ZTS_US_NARC_ID__c);
      }
      List<CampaignMember> camMemDel = new List<CampaignMember>([select id,ZTS_US_NARC_ID__c,campaignId from CampaignMember where ZTS_US_NARC_ID__c IN:targetNARCIds and campaignId IN:campaignMap.keyset() AND ZTS_EU_Market__c = 'United States']);
      
            if(accfound==false){
            	try{
            		Delete camMemDel;
            	}
            	catch(Exception e){
            		System.debug('exception Occurred on delete'+e);
            	}
            }                    
   
   }
   
}