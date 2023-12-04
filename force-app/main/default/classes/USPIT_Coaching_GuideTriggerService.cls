/****************************************************************************************************************************************** 
 * Trigger Name : USPIT_Coaching_GuideTriggerService
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
* Art Smorodin			   02/010/2020	       Moved to Service Class
*****************************************************************************************************************************************/
public class USPIT_Coaching_GuideTriggerService 
{      
    public static void beforeUpdate(List<PIT_Coaching_Guide__c> triggerOld, Map<Id, PIT_Coaching_Guide__c> triggerOldMap, 
                                    List<PIT_Coaching_Guide__c> triggerNew, Map<Id, PIT_Coaching_Guide__c> triggerNewMap)
    {
        
       // if(!(CustomSettingService.checkIfTriggerActive('PIT_Coaching_Guide'))) return; // by pass trigger logic according to isActive checkbox in custom setting

        Map<String,PIT_Coaching_Guide__c> foundMatches = new Map<String,PIT_Coaching_Guide__c>(); 
        for(PIT_Coaching_Guide__c c1 : triggerNew){
            PIT_Coaching_Guide__c c1old = triggerOldMap.get(c1.Id);
            if(c1.PIT_Coaching_Status__c == 'Completed' && c1.PIT_Coaching_Status__c != c1old.PIT_Coaching_Status__c){
                string keyId = String.valueOf(c1.PIT_Coach__c).substring(0, 15) + '#' + String.valueOf(c1.PIT_Colleague__c).substring(0, 15);
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
            PIT_Coaching_Guide__c[] recs2upd = [select Id, PIT_Coach__c, PIT_Last_Session__c, CreatedDate, PIT_Colleague__c from PIT_Coaching_Guide__c where PIT_Last_Session__c = true and PIT_Users_Match__c in :foundMatches.keySet() and Id not in: foundMatches.values() AND ZTS_EU_Market__c = 'United States'];
            if(recs2upd.size() > 0){
                for(PIT_Coaching_Guide__c c1 : recs2upd){
                    string keyId = String.valueOf(c1.PIT_Coach__c).substring(0, 15) + '#' + String.valueOf(c1.PIT_Colleague__c).substring(0, 15);
                    if(c1.CreatedDate < foundMatches.get(keyId).CreatedDate){
                        c1.PIT_Last_Session__c = false;
                        foundMatches.get(keyId).PIT_Last_Session__c = true;
                    }
                }
                update recs2upd;
            } else {
                for(PIT_Coaching_Guide__c v1 : foundMatches.values()){
                    v1.PIT_Last_Session__c = true;
                }
            }
        }

        Map<Id,PIT_Coaching_Guide__c> mColleagueId2CoachingGuide = new Map<Id,PIT_Coaching_Guide__c>(); 

        ProcessInstanceStep[] stepRec = [SELECT SystemModstamp, StepStatus, StepNodeId, ProcessInstanceId, OriginalActorId, Id, CreatedDate, CreatedById, Comments, ActorId 
                                            FROM ProcessInstanceStep WHERE actorId = :userInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];
    
        for(PIT_Coaching_Guide__c c1 : triggerNew){
            PIT_Coaching_Guide__c c1old = triggerOldMap.get(c1.Id);
            if(c1.PIT_Copy_Comments__c && !c1old.PIT_Copy_Comments__c){
                System.debug('XXX step executed!');
                c1.PIT_Copy_Comments__c = false;
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
                c1.PIT_Send_Notification_Email__c = true;
            }
        } 

        if(mColleagueId2CoachingGuide.size() > 0){
            Map<Id,User> mIdUsrs = new Map<Id,User>([SELECT Id, ManagerId, Manager.Email,PIT_DirectorEmail__c, PIT_BUs__c             
                                                    FROM User where Id in : mColleagueId2CoachingGuide.keySet() AND ZTS_EU_Market__c = 'United States']);
            
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
                    /*try {
                    if(String.isNotEmpty(uTemp.PIT_BUs__c)){
                        PIT_BU_Director__c conf = PIT_BU_Director__c.getInstance(uTemp.PIT_BUs__c);
                        if(conf != null){
                        //pg1.PIT_Colleagues_Director__c = conf.PIT_Directors_Email_Address__c;
                        pg1.PIT_Notification_Extra_Email__c = conf.PIT_Extra_Email_Address__c;
                        }
                    }
                    } 
                    catch(Exception e) {
                    ZTS_US_Logger.errorAsync('coaching error', 'PIT_Coachingguideerror ');
                    */ //}           
                }
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
            // Insert cgshareList;   
            SharingUtil.create(cgshareList); // Commented the above line and Added this line to create Apex Sharing records from SharingUtil class(SC-008280)
        }
    }

    public static void afterInsert(List<PIT_Coaching_Guide__c> triggerNew, Map<Id, PIT_Coaching_Guide__c> triggerNewMap){

       // if(!(CustomSettingService.checkIfTriggerActive('PIT_Coaching_Guide'))) return; // by pass trigger logic according to isActive checkbox in custom setting

        PIT_Coaching_Guide__c[] recs2upd = new PIT_Coaching_Guide__c[]{};
        // List<PIT_Coaching_Guide__c> recs2upd = new List<PIT_Coaching_Guide__c>();
        List<String> colleagueids = new List<String>();
        List<String> coachids = new List<String>();
        for(PIT_Coaching_Guide__c cg : triggerNew){
            string colleague = cg.PIT_Colleague__c;
            string coach = cg.PIT_Coach__c;
            colleagueids.add(colleague);
            coachids.add(coach);
        }
        map<string,string> collterrmap = new map<string,string>();
        map<string,string> coachterrmap = new map<string,string>();
        for(ZTS_EU_Position__c ut: [select id,ZTS_EU_Territory__r.Name,ZTS_EU_Employee__c from ZTS_EU_Position__c where ZTS_EU_Employee__c IN :colleagueids]){
            collterrmap.put(ut.ZTS_EU_Employee__c,ut.ZTS_EU_Territory__r.Name);
        }
        for(ZTS_EU_Position__c ut: [select id,ZTS_EU_Territory__r.Name,ZTS_EU_Employee__c from ZTS_EU_Position__c where ZTS_EU_Employee__c IN :coachids]){
            coachterrmap.put(ut.ZTS_EU_Employee__c,ut.ZTS_EU_Territory__r.Name);
        }
            
        for(PIT_Coaching_Guide__c r1 : triggerNew){
        string colleague = r1.PIT_Colleague__c;
        string coach = r1.PIT_Coach__c;
        if(collterrmap.containskey(colleague)||coachterrmap.containskey(coach))
            recs2upd.add(new PIT_Coaching_Guide__c(Id = r1.Id, PIT_Record_ID__c = r1.Id,PIT_Colleague_Territory__c=collterrmap.get(r1.PIT_Colleague__c),PIT_Coach_Territory__c=coachterrmap.get(r1.PIT_coach__c)));
        }
        update recs2upd;
    }

    public static void beforeInsert(List<PIT_Coaching_Guide__c> triggerNew){

       // if(!(CustomSettingService.checkIfTriggerActive('PIT_Coaching_Guide'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        
        String keyId;
        Set<String> foundMatches = new Set<String>(); 
        for(PIT_Coaching_Guide__c r1 : triggerNew){
            if(r1.PIT_Coaching_Status__c == 'Completed'){
                keyId = String.valueOf(r1.PIT_Coach__c).substring(0, 15) + '#' + String.valueOf(r1.PIT_Colleague__c).substring(0, 15);
                if(!foundMatches.contains(keyId)){
                    r1.PIT_Last_Session__c = true;
                    foundMatches.add(keyId);
                }
            }
        }
        if(foundMatches.size() > 0){
            PIT_Coaching_Guide__c[] recs2upd1 = [select Id, PIT_Last_Session__c from PIT_Coaching_Guide__c where PIT_Last_Session__c = true and PIT_Users_Match__c in :foundMatches AND ZTS_EU_Market__c = 'United States'];
            if(recs2upd1.size() > 0){
                for(PIT_Coaching_Guide__c r1 : recs2upd1){
                r1.PIT_Last_Session__c = false;
                }
                update recs2upd1;
            }
        }
    }

    public static void beforeDelete(List<PIT_Coaching_Guide__c> triggerOld, Map<Id, PIT_Coaching_Guide__c> triggerOldMap){

      //  if(!(CustomSettingService.checkIfTriggerActive('PIT_Coaching_Guide'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        
        String profilename=[Select id,name from profile where id=:Userinfo.getProfileId()].name;
        for(PIT_Coaching_Guide__c cg : triggerOld){
            System.debug('******status******'+cg.PIT_Coaching_Status__c );
            if(profilename !='System Administrator' && (cg.PIT_Coaching_Status__c =='Completed'||cg.PIT_Coaching_Status__c=='Pending Colleague Comments')){
                cg.addError(' Submitted and Completed Coaching guides cannot be deleted.');
            }
        }
    }

}