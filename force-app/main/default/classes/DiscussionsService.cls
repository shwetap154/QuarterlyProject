/**
* @description       : Logic for Insering/Deleting Campaign Member records on Insertion/Deletion of Discussions and delete Campaign Member on removal of Attendees from the call .
* @author            : Deepshikha Tyagi @ Cognizant
**/
public with sharing class DiscussionsService {
    @testVisible private static Boolean forceExceptionInsertCampaignMemberRecord = false;

    /***********
    * Method name  : createDeleteCampaignMembers
    * Description  : This will create and delete Campaign member records on creation/deletion of Discussion and Attendee.
    * Return Type  : None.
    * Parameters   : List<Sobject> and event action(insert/delete).
    * 
    ***********/ 
    public static void createDeleteCampaignMembers(List<ZTS_EU_Discussion__c> disccussionsList, String Mode){
        Map<Id,List<ZTS_EU_Discussion__c>> AttendeeContactMap = new Map<Id,List<ZTS_EU_Discussion__c>>();
        Set<String> campaignDiscussSet = new Set<String>();
        Set<String> AttendeeCallSet = new Set<String>();
        String Action = mode;
        for(ZTS_EU_Discussion__c discussion : disccussionsList)
        {
            if(discussion.ZTS_EU_Campaign__c != null && discussion.ZTS_EU_Campaign__r.IsActive && discussion.ZTS_EU_Campaign__r.ZTS_EU_Field_Targeting__c == 'Open'){
                if(!AttendeeContactMap.containsKey(discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_Contact__c)){
                    AttendeeContactMap.put(discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_Contact__c,new List<ZTS_EU_Discussion__c>{discussion});
                }
                else{
                    AttendeeContactMap.get(discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_Contact__c).add(discussion);
                }
                campaignDiscussSet.add(discussion.ZTS_EU_Campaign__c);
                AttendeeCallSet.add(discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_call__c);
            }
        }
        if(AttendeeContactMap.size()>0){
            CampaignMemberQueueable  CampMemberQueuable = new CampaignMemberQueueable(campaignDiscussSet,AttendeeContactMap,AttendeeCallSet,Action);
            ID jobID = System.enqueueJob(CampMemberQueuable);
        }
    }
    public class CampaignMemberQueueable implements Queueable {
        Set<String> campDiscussionSet = new Set<String>();
        Map<Id,List<SObject>> AttendeeContactMap = new Map<Id,List<SObject>>();
        set<String> AttendeesCallSet = new set<String>();
        String action ='';
        public CampaignMemberQueueable(Set<String> campaignDiscussionSet,Map<Id,List<SObject>> AttendeeConMap,Set<String> AttendeeCallSet,String mode)
        {
            campDiscussionSet = campaignDiscussionSet;
            AttendeeContactMap = AttendeeConMap;
            AttendeesCallSet = AttendeeCallSet;
            action = mode;  
        }
        
        public void execute(QueueableContext context) {
            List<CampaignMember> existingcampMemberList = new List<CampaignMember>();
            Map<String,CampaignMember> existingcampMemberMap = new Map<String,CampaignMember>();
            List<CampaignMember> campMemberToInsert = new List<CampaignMember>();
            List<ZTS_EU_Discussion__c> DiscussionsList = new List<ZTS_EU_Discussion__c>(); 
            if(action == 'Insert'){
                existingcampMemberList = [SELECT Id, CampaignId, ContactId 
                                          FROM CampaignMember
                                          WHERE CampaignId IN :campDiscussionSet
                                          AND  ContactId IN :AttendeeContactMap.keyset()];
                for(CampaignMember campMember : existingcampMemberList){
                    String CampaignContactKey = campMember.CampaignId + '' + campMember.ContactId;
                    if(!existingcampMemberMap.containsKey(CampaignContactKey)){
                        existingcampMemberMap.put(CampaignContactKey,campMember);
                    }
                }
                for(List<ZTS_EU_Discussion__c> discussionList : (List<List<ZTS_EU_Discussion__c>>)AttendeeContactMap.values()){
                    if(!discussionList.isEmpty()){ 
                        for(ZTS_EU_Discussion__c discussion : discussionList){
                            String dissCampaignContactKey = discussion.ZTS_EU_Campaign__c + '' + discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_Contact__c;
                            if(!existingcampMemberMap.containsKey(dissCampaignContactKey)){
                                CampaignMember campMember = new CampaignMember();
                                campMember.CampaignId = discussion.ZTS_EU_Campaign__c;
                                campMember.ContactId =  discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_Contact__c;
                                campMember.Call__c = discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_call__c;
                                campMemberToInsert.add(campMember);
                                DiscussionsList.add(discussion);
                            }
                        }
                    }
                }
                if(campMemberToInsert.size()>0){
                    try {
                        if (forceExceptionInsertCampaignMemberRecord) {
                           integer y = 1 / 0;
            		    }
                    List<Database.SaveResult> results=Database.insert(campMemberToInsert,false);
                    LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                        'Failed to create Campaign Member for the added Discussion. Please review the following Discussion(s): {0} ', 
                              DiscussionsList);
				    Logger_Extension.errorLogIfSaveError(logMessage, campMemberToInsert, results);
                    }
                    catch(Exception e){
                        LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                             'Failed to create Campaign Member for the added Discussion. Please review the following Discussion(s): {0} ', 
                              DiscussionsList);
                        Logger.error(logMessage, campMemberToInsert, e);  
                    }
                } 
            }
            
            if(action == 'Delete'){
                existingcampMemberList = [SELECT Id, CampaignId, ContactId 
                                          FROM CampaignMember
                                          WHERE CampaignId IN :campDiscussionSet
                                          AND ContactId IN :AttendeeContactMap.keyset()
                                          AND Call__c IN :AttendeesCallSet];
                if(existingcampMemberList.size()>0){
                    try {
                         delete existingcampMemberList;
                    }
                    catch(Exception e){
                        LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                             'Failed to delete Campaign Member for the deleted Discussion. Please review the following Campaign Member(s): {0}', 
                              existingcampMemberList);
                        Logger.error(logMessage, existingcampMemberList, e);  
                    }
                }
            }
        }
    }   
    
}