/****************************************************************************************************************************************** 
 * Trigger Name : INTLPIT_Coaching_GuideTriggerService
 * Description  : Trigger to rewrite the comments from approval process; 
 *                  as it is not possible to approve or reject many records within a single transaction, mechanism below is not fully bulk designed
 *                  @since   15/07/2014
 *                  @author  emil.puchalski@directpl.com
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Akanksha Gupta    `     July 07, 2014       Created
 * Srijani Pal (Cognizant) 15-Mar-2018         Updated the uniqueness key creation logic to extract 18 digit id for coach and colleague (updated as per SC-003541)
 * Art Smorodin			   02/010/2020	       Moved to Service Class
 * Aritra (Cognizant)      18-Dec-2020         Changed the code, moved coaching guide share record creation in SharingUtil class (SC-008280)
*****************************************************************************************************************************************/
public class INTLPIT_Coaching_GuideTriggerService 
{      
    
    //TPDEV-1437
    public static List<Market_Setting__mdt> listOfAutoApprovedMarkets = [Select Market__c, Coaching_Guide_Auto_Approved__c  from Market_Setting__mdt where Coaching_Guide_Auto_Approved__c = true];
 
    public static void beforeUpdate(List<PIT_Coaching_Guide__c> triggerOld, Map<Id, PIT_Coaching_Guide__c> triggerOldMap, 
                                    List<PIT_Coaching_Guide__c> triggerNew, Map<Id, PIT_Coaching_Guide__c> triggerNewMap)
    {
        Set<String> autoApproveMarketSet= new Set<String>();

        system.debug('Before Update');
        //TPDEV-1437 
        for(Market_Setting__mdt msm : listOfAutoApprovedMarkets){
            autoApproveMarketSet.add(msm.Market__c);
        }
            
        Map<String,PIT_Coaching_Guide__c> foundMatches = new Map<String,PIT_Coaching_Guide__c>();
        for(PIT_Coaching_Guide__c c1 : triggerNew){
            PIT_Coaching_Guide__c c1old = triggerOldMap.get(c1.Id);	
            //TPDEV-1437 considering 15 digit ID to match PIT_Users_Match__c value, since salesforce by default allows 15 digit ID only in Custom formula field
            String keyId = c1.PIT_Coach__c.to15()+'#'+c1.PIT_Colleague__c.to15();
            System.debug('###### KEY ID' + keyId );
            //TPDEV-1437 If the Coaching Guide's Market is a Market where no approval is necessary, 
            //this trigger will fire multiple times. Allow the trigger to run again to catch subsequent updates.
            if(c1.PIT_Coaching_Status__c == 'Pending Colleague Comments' && autoApproveMarketSet.contains(c1.ZTS_EU_Market__c)){
                 DispatchTriggerHandler.setRecursionContexts(new PIT_Coaching_GuideTriggerHandler());
            }
            if(c1.PIT_Coaching_Status__c == 'Completed' && c1.PIT_Coaching_Status__c != c1old.PIT_Coaching_Status__c){
            //TPDEV-1437 considering 15 digit ID to match PIT_Users_Match__c value, since salesforce by default allows 15 digit ID only in Custom formula field
                KeyId = c1.PIT_Coach__c.to15() + '#' + c1.PIT_Colleague__c.to15();
                if(!foundMatches.containsKey(keyId)){
                   foundMatches.put(keyId, c1);    
                } else {
                   PIT_Coaching_Guide__c temp = foundMatches.get(keyId); 
                    if(temp.createdDate > c1.CreatedDate){
                     foundMatches.put(keyId, c1);
                    }
                    
                }
            }
           
        }
            
            
        if(foundMatches.size() > 0){
			PIT_Coaching_Guide__c[] recs2upd = [select Id, PIT_Coach__c, PIT_Last_Session__c, CreatedDate, PIT_Colleague__c from PIT_Coaching_Guide__c where PIT_Last_Session__c = true AND ZTS_EU_Market__c != 'United States' and PIT_Users_Match__c in :foundMatches.keySet() and Id not in: foundMatches.values()];
           System.debug('recs2upds values '+recs2upd );
            if(recs2upd.size() > 0){
               for(PIT_Coaching_Guide__c c1 : recs2upd){
              //TPDEV-1437 considering 15 digit ID to match PIT_Users_Match__c value, since salesforce by default allows 15 digit ID only in Custom formula field
                   String keyId = c1.PIT_Coach__c.to15() + '#' + c1.PIT_Colleague__c.to15();                       
                       if(c1.CreatedDate < foundMatches.get(keyId).CreatedDate){     
                       c1.PIT_Last_Session__c = false;
                       foundMatches.get(keyId).PIT_Last_Session__c = true;
                    }
                }
                update recs2upd;
            	} else 
             	{
                    for(PIT_Coaching_Guide__c v1 : foundMatches.values()){
                        v1.PIT_Last_Session__c = true;
                    }
            	}
        }
        Map<Id,PIT_Coaching_Guide__c> mColleagueId2CoachingGuide = new Map<Id,PIT_Coaching_Guide__c>(); 

        for(PIT_Coaching_Guide__c c1 : triggerNew){
            PIT_Coaching_Guide__c c1old = triggerOldMap.get(c1.Id);
            if(c1.PIT_Copy_Comments__c && !c1old.PIT_Copy_Comments__c){
                System.debug('XXX step executed!');
                c1.PIT_Copy_Comments__c = false;
                ProcessInstanceStep[] stepRec = [Select SystemModstamp, StepStatus, StepNodeId, ProcessInstanceId, OriginalActorId, Id, CreatedDate, CreatedById, Comments, ActorId From ProcessInstanceStep where actorId = :userInfo.getUserId() order by CreatedDate desc limit 1];
                if(stepRec.size() > 0){ 
                    System.debug('XXX found some steps: ' + stepRec);
                    c1.PIT_Colleague_Comments__c = stepRec[0].Comments;
                    c1.PIT_Send_Notification_Email__c = true;
                } 
            }
            if(c1.PIT_Coach__c != null ){
               c1.OwnerId = c1.PIT_Coach__c;
            }
            if(c1.PIT_Coaching_Status__c == 'Pending Colleague Comments' && (c1old.PIT_Coaching_Status__c == 'New' || c1old.PIT_Coaching_Status__c == 'Saved')){
                mColleagueId2CoachingGuide.put(c1.PIT_Colleague__c,c1);
            }
            if(mColleagueId2CoachingGuide.size() > 0){
                
                Map<Id,User> mIdUsrs = new Map<Id,User>([select Id, ManagerId, Manager.Email,PIT_DirectorEmail__c from User where Id in : mColleagueId2CoachingGuide.keySet() AND ZTS_EU_Market__c != 'United States']);
                for(PIT_Coaching_Guide__c pg1 : mColleagueId2CoachingGuide.values()){
                    if(mIdUsrs.containsKey(pg1.PIT_Colleague__c)){
                        
                        User uTemp = mIdUsrs.get(pg1.PIT_Colleague__c);
                        if(uTemp.ManagerId != null){
                            
                            if(String.isNotEmpty(uTemp.Manager.Email)){
                                
                                pg1.PIT_Colleagues_Manager__c = uTemp.Manager.Email;
                            } 
                        }
                        if(String.isNotEmpty(uTemp.PIT_DirectorEmail__c)){ 
                            
                            pg1.PIT_Colleagues_Director__c = uTemp.PIT_DirectorEmail__c;
                        } 
                                
                    }
                }
                
                c1.PIT_Send_Notification_Email__c = true;
            }
        } 
        
        //Added by Laxmikanth
        List <PIT_Coaching_Guide__Share> cgshareList = new List<PIT_Coaching_Guide__Share>();
        for(PIT_Coaching_Guide__c cg : triggerNew){
            if(cg.PIT_Coaching_Status__c == 'Pending Colleague Comments'){
                PIT_Coaching_Guide__Share cgshare = new PIT_Coaching_Guide__Share();
                cgshare.ParentId = cg.id;
                cgshare.UserOrGroupId = cg.PIT_Colleague__c;
                cgshare.AccessLevel = 'edit';
                cgshare.RowCause = Schema.PIT_Coaching_Guide__Share.RowCause.Share_Coaching_with_Colleague__c;
                cgshareList.add(cgshare);
            }
        }
        if(cgsharelist.size()>0){
            //Insert cgshareList;
            SharingUtil.create(cgshareList); // Commented the above line and Added this line to create Apex Sharing records from SharingUtil class(SC-008280)
        }
    }
    
    public static void afterInsert(List<PIT_Coaching_Guide__c> triggerNew, Map<Id, PIT_Coaching_Guide__c> triggerNewMap){
        PIT_Coaching_Guide__c[] recs2upd = new PIT_Coaching_Guide__c[]{};
        for(PIT_Coaching_Guide__c r1 : triggerNew){
            recs2upd.add(new PIT_Coaching_Guide__c(Id = r1.Id, PIT_Record_ID__c = r1.Id));
        }
        update recs2upd;
        
        //Shefali 20 May 2015 (Added for Defect DEF-001525)
        //Slalom Art Smorodin: Feb 10th, 2020. 
        //Before Delet Logic will not run from inside after insert logic. This was a part of original trigger. Commenting it out. 
        //TODO: check test classes to see if it was ever tested.
        /*if(trigger.isdelete && trigger.isBefore){   
            String profilename=[Select id,name from profile where id=:Userinfo.getProfileId()].name;
       		for(PIT_Coaching_Guide__c cg : trigger.old){
            	System.debug('******status******'+cg.PIT_Coaching_Status__c );
            	if(profilename !='System Administrator' && (cg.PIT_Coaching_Status__c =='Completed'||cg.PIT_Coaching_Status__c=='Pending Colleague Comments')){
               
                	cg.addError(' Submitted and Completed Coaching guides cannot be deleted.');
                }
            }
       	}*/
        //EOC by Shefali 
    }
    
    public static void beforeInsert(List<PIT_Coaching_Guide__c> triggerNew){
        
        String keyId;
        Set<String> foundMatches = new Set<String>(); 
        for(PIT_Coaching_Guide__c r1 : triggerNew){
            if(r1.PIT_Coaching_Status__c == 'Completed'){
              //TPDEV-1437 considering 15 digit ID to match PIT_Users_Match__c value, since salesforce by default allows 15 digit ID only in Custom formula field
                keyId = r1.PIT_Coach__c.to15()+'#'+r1.PIT_Colleague__c.to15();
                if(!foundMatches.contains(keyId)){
                    r1.PIT_Last_Session__c = true;
                    foundMatches.add(keyId);
                }
            }
        }
        if(foundMatches.size() > 0){
          PIT_Coaching_Guide__c[] recs2upd = [select Id, PIT_Last_Session__c from PIT_Coaching_Guide__c where PIT_Last_Session__c = true and PIT_Users_Match__c in :foundMatches AND ZTS_EU_Market__c != 'United States'];
            if(recs2upd.size() > 0){
                for(PIT_Coaching_Guide__c r1 : recs2upd){
                    r1.PIT_Last_Session__c = false;
                }
                update recs2upd;
            }
        }
    }
    
    public static void beforeDelete(List<PIT_Coaching_Guide__c> triggerOld, Map<Id, PIT_Coaching_Guide__c> triggerOldMap){
        //Shefali 20 May 2015 (Added for Defect DEF-001525)
        //Slalom Art Smorodin: Feb 10th, 2020. 
        //Before Delet Logic used to reside inside after insert logic. This was a part of original trigger. Commenting it out. 
        //TODO: check to see if it was ever used and tested.
        /*if(trigger.isdelete && trigger.isBefore){   
            String profilename=[Select id,name from profile where id=:Userinfo.getProfileId()].name;
       		for(PIT_Coaching_Guide__c cg : trigger.old){
            	System.debug('******status******'+cg.PIT_Coaching_Status__c );
            	if(profilename !='System Administrator' && (cg.PIT_Coaching_Status__c =='Completed'||cg.PIT_Coaching_Status__c=='Pending Colleague Comments')){
               
                	cg.addError(' Submitted and Completed Coaching guides cannot be deleted.');
                }
            }
       	}*/
        //EOC by Shefali 
    }
}