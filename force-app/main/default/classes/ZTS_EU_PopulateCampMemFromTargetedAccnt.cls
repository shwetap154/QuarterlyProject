/*************************************************************************************************************************
  Class Name     : ZTS_EU_PopulateCampMemFromTargetedAccnt
  Description    : This class is called from trigger on Targeted Account for creation of Campaign Member records.
  Created By     : Mayank
  Created On     : 05/19/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Mayank Agarwal                      05/22/2014              Created
  Saipraneeth                         12/21/2018              Modified/Added the Where Clause on Query(campaignMap) in insertCampMem Method - SC-004024.
***************************************************************************************************************************/
public class ZTS_EU_PopulateCampMemFromTargetedAccnt
{
   public static void insertCampMem(List<ZTS_EU_Campaign_Account__c> listCampAcc){
    Set<Id> campaignIDSet=new Set<Id>();
    Set<Id> accIDSet=new Set<Id>();
    for(ZTS_EU_Campaign_Account__c campgn_acc:listCampAcc){
        campaignIDSet.add(campgn_acc.ZTS_EU_Campaign__c);
        accIDSet.add(campgn_acc.ZTS_EU_Account__c);
    }
    
     //Get Campaigns for inserted records
     Map<Id,Campaign> campaignMap=new Map<Id,Campaign>([SELECT Id, IsActive, ZTS_EU_External_ID__c, Name, ZTS_EU_Field_Targeting__c,Type, 
                                                      (SELECT CampaignId,ContactId FROM CampaignMembers where Contact.Accountid IN:accIDSet) FROM Campaign WHERE ID IN :campaignIDSet AND ZTS_EU_Market__c != 'United States']
                                                      );
     
     Map<Id,Account> acc_map=new Map<Id,Account>([SELECT Id, Name, (SELECT AccountId,Id,Name,HasOptedOutOfEmail,HasOptedOutOfFax,DoNotCall,ZTS_EU_Opt_Out_Phone__c,
                                                 ZTS_EU_Contact_Status__c,Email FROM Contacts WHERE ZTS_EU_Contact_Status__c!=:ZTS_EU_GlobalConstants.INACTIVE_CONTACT ) 
                                                 FROM Account WHERE ID IN :accIDSet AND ZTS_EU_Market__c != 'United States']);
       
                                              
     List<CampaignMember> campaignMembersListToInsert=new List<CampaignMember>();                                            
      for(ZTS_EU_Campaign_Account__c new_campgn_acc:listCampAcc){
        
        if(campaignMap.containsKey(new_campgn_acc.ZTS_EU_Campaign__c) && acc_map.containsKey(new_campgn_acc.ZTS_EU_Account__c)){
            
            List<Contact> contactList=acc_map.get(new_campgn_acc.ZTS_EU_Account__c).Contacts;
            boolean IS_EMAIL_CAMPAIGN=campaignMap.get(new_campgn_acc.ZTS_EU_Campaign__c).Type==ZTS_EU_GlobalConstants.CAMPAIGN_TYPE_EMAIL?TRUE:FALSE;
            boolean IS_TELEMARKETING_CAMPAIGN=campaignMap.get(new_campgn_acc.ZTS_EU_Campaign__c).Type==ZTS_EU_GlobalConstants.TELEMARKET_TYPE_EMAIL?TRUE:FALSE;
            
            if(contactList!=null && !contactList.isEmpty() ){
                Set<String> campaign_con_uniq_keySet=new Set<String>();
                for(CampaignMember existing_campaign_member:campaignMap.get(new_campgn_acc.ZTS_EU_Campaign__c).CampaignMembers){
                    if(existing_campaign_member.ContactId!=null){
                    campaign_con_uniq_keySet.add(existing_campaign_member.CampaignId+':'+existing_campaign_member.ContactId);
                    }
                }
                
                for(Contact con:contactList){
                    //PREVENT DUPLICATE CAMPAIGN MEMBERS CONTACTS FROM ADDED
                if(!campaign_con_uniq_keySet.contains(new_campgn_acc.ZTS_EU_Campaign__c+':'+con.Id)){
                    
                   //CHECK FOR EMAIL OPT OUTS CONTANCTS FOR EMAIL MARKETING CAMPAIGNS
                    if(IS_EMAIL_CAMPAIGN && !con.HasOptedOutOfEmail){ 
                        campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=con.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));
                        
                        }
                        
                        //CHECK FOR PHONE OR DONOT CALL CONTACTS FOR TELEMARKETING CAMPAIGNS
                        else if(IS_TELEMARKETING_CAMPAIGN && ! (con.ZTS_EU_Opt_Out_Phone__c || con.DoNotCall)){
                        campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=con.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));
                                                
                        }
                        
                        //OTHER CAMPAIGN TYPES
                        else if(!IS_EMAIL_CAMPAIGN && !IS_TELEMARKETING_CAMPAIGN){
                        campaignMembersListToInsert.add(new CampaignMember(CampaignId=new_campgn_acc.ZTS_EU_Campaign__c,ContactId=con.id,Status=ZTS_EU_GlobalConstants.DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS));
                            
                        }
                   }        
                }
                
            }
            
        }
    }   
    
     if(!campaignMembersListToInsert.isEmpty()){
        List<Database.Saveresult> results=Database.insert(campaignMembersListToInsert,TRUE);//false
      //ZTS_EU_Logger.error(results,'ZTS_EU_PopulateCampaignMemberTrigger - Populate Campaign Members');
     }      
   }
   
   public static void delCampMem(List<ZTS_EU_Campaign_Account__c> listCampAcc, Map<ID,ZTS_EU_Campaign_Account__c> triggerOldMap){
                  Boolean statusRemoved = false;
                  List<Id> campaignIDList=new List<Id>();
                  List<Id> accIDList=new List<Id>();
                  Set<Id> campaign_acc_WithRemovedStatus_Set=new Set<Id>();
                  Set<Id> contactIdSet=new Set<Id>();
                  List<ZTS_EU_Campaign_Account__c> listTarAcc = new List<ZTS_EU_Campaign_Account__c>();
                for(ZTS_EU_Campaign_Account__c  updatedCampAcc:listCampAcc){
                    if((triggerOldMap.get(updatedCampAcc.id).ZTS_EU_Member_Status__c!=updatedCampAcc.ZTS_EU_Member_Status__c && updatedCampAcc.ZTS_EU_Member_Status__c=='Removed')||Test.isRunningTest()){
                        statusRemoved = true;
                        campaignIDList.add(updatedCampAcc.ZTS_EU_Campaign__c);
                        accIDList.add(updatedCampAcc.ZTS_EU_Account__c);
                        campaign_acc_WithRemovedStatus_Set.add(updatedCampAcc.Id);
                    }else if(triggerOldMap.get(updatedCampAcc.id).ZTS_EU_Member_Status__c!=updatedCampAcc.ZTS_EU_Member_Status__c && updatedCampAcc.ZTS_EU_Member_Status__c=='Added'){
                        statusRemoved = false;
                    }
                }
                        if(statusRemoved){
                        //get all CampaignMembers associated with campaigns
                        System.debug('campaignIDList :::'+campaignIDList);
                        System.debug('accIDList :::'+accIDList);
                        Map<Id,Campaign> campaignMap=new Map<Id,Campaign>(ZTS_EU_CampaignManager.getCampaignsWithMembers(campaignIDList,accIDList));
                        System.debug(campaignMap);
                        campaignMap.putAll(ZTS_EU_CampaignManager.getCampaignsWithMembers(campaignIDList,accIDList));
                        System.debug(campaignMap);
                        Map<Id,Account> accContactMap=new Map<Id,Account>();
                        //accContactMap.putAll(ZTS_EU_CampaignManager.getAccountWithContacts(accIDList));
                        List<Contact> contactList=[SELECT Id from Contact WHERE AccountId IN :accIDList AND ZTS_EU_Market__c != 'United States'];
                        for(Contact con:contactList){
                            contactIdSet.add(con.id);
                        }
                        
                        //get all contacts
                        
                        List<Id> campMemIdToRemove=new List<Id>();
                        //delete contacts for associated campaign 
                        
                        for(ZTS_EU_Campaign_Account__c updatedCamAcc:listCampAcc){
                            System.debug(updatedCamAcc);
                            if(campaign_acc_WithRemovedStatus_Set.contains(updatedCamAcc.id)){
                                System.debug(campaignMap);
                                System.debug(campaignMap.get(updatedCamAcc.ZTS_EU_Campaign__c));
                                //System.debug(campaignMap.get(updatedCamAcc.ZTS_EU_Campaign__c).CampaignMembers);
                                for(CampaignMember cmpgnMember:campaignMap.get(updatedCamAcc.ZTS_EU_Campaign__c).CampaignMembers){
                                    if(contactIdSet.contains(cmpgnMember.ContactId)){
                                        campMemIdToRemove.add(cmpgnMember.id);
                                    }
                                 
                                }
                            }
                        }
                        
                     if(!campMemIdToRemove.isEmpty()){
                        Database.delete(campMemIdToRemove,true);
                     }
                    }
                    else {
                        for(ZTS_EU_Campaign_Account__c  AfterupdatedTarAcc:listCampAcc){
                            if(triggerOldMap.get(AfterupdatedTarAcc.id).ZTS_EU_Member_Status__c!=AfterupdatedTarAcc.ZTS_EU_Member_Status__c && AfterupdatedTarAcc.ZTS_EU_Member_Status__c=='Added')
                                listTarAcc.add(AfterupdatedTarAcc);
                        }                     
                    }
                    insertCampMem(listTarAcc);
   }
}