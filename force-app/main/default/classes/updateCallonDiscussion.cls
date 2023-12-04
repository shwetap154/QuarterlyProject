/****************************************************************************************************************************************** 
 * Class Name   : updateCallonDiscussion
 * Description  : This is class for Trigger discussion to update call fields on Di insert and delete DEF-001251.     
 * Created By   : CloudSense(Sohil Shah) 
 * Created Date : 4th June, 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sohil Shah           06/04/2015          Created 
 * Deepshikha Tyagi(Cognizant)  01/09/2023  Modified for inserting/deleting Campaign Members whenever Campaign discussions are added to call 
*****************************************************************************************************************************************/
public class updateCallonDiscussion
{
    public static void callUpdateOnDiscussionInsert(List<ZTS_EU_Discussion__c> insertedDiscussion)
    {
        List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
        String Action = '';
        discussionList = [select id, Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Call_Attendee__r.ZTS_EU_call__c,ZTS_EU_Campaign__c,ZTS_EU_Call_Attendee__r.ZTS_EU_Contact__c,ZTS_EU_Campaign__r.ZTS_EU_Field_Targeting__c,ZTS_EU_Campaign__r.IsActive from ZTS_EU_Discussion__c where id IN:insertedDiscussion AND ZTS_EU_Market__c != 'United States']; 
        System.debug('discussionList------'+discussionList);
        Set<Id> callId = new Set<Id>();
        Set<Id> attendeeId = new Set<Id>();
        String DIName = '';
        Integer Dicount = 0;
        for(ZTS_EU_Discussion__c discussion : discussionList)
        {
            callId.add(discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_call__c);
            DIName = DIName + discussion.Name;
            attendeeId.add(discussion.ZTS_EU_Call_Attendee__c);
        }
       //Added for TPDEV-360 -Start
        if(discussionList.size()>0){
                Action = 'Insert';
                DiscussionsService.createDeleteCampaignMembers(discussionList,Action);  
        }
       //Added for TPDEV-360 -End
        System.debug('callId------'+callId);
        System.debug('DIName------'+DIName);            
        List<Call__c> callList = new List<Call__c>();
        List<Call__c> callListToUpodate = new List<Call__c>();
        callList = [Select Id, Name,Discussion_Item__c,Discussion_Item_Count__c from Call__c where id=:callId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        
        List<ZTS_EU_Discussion__c> existingDIList = new List<ZTS_EU_Discussion__c>();
        List<ZTS_EU_Discussion__c> existingDIList2 = new List<ZTS_EU_Discussion__c>();
        existingDIList = [select id, Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Call_Attendee__r.ZTS_EU_call__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c=:attendeeId AND ZTS_EU_Market__c != 'United States'];
        System.debug('existingDIList--1----'+existingDIList);
        System.debug('existingDIList--Size--1--'+existingDIList.Size());
        Map<String,ZTS_EU_Discussion__c> myMap = new Map<String,ZTS_EU_Discussion__c>();    
        for(ZTS_EU_Discussion__c dis : existingDIList)
        {           
            myMap.put(dis.Name,dis);
        }
        System.debug('myMap------'+myMap);
        System.debug('myMap--Size----'+myMap.Size());       
        String allDIName = '';
        
        integer i=1;
        for(ZTS_EU_Discussion__c DI : myMap.values())
        {              
                if(i != myMap.Size())
                {
                    allDIName = allDIName + DI.Name + ';';
                }
                if(i == myMap.Size() )
                {
                    allDIName = allDIName + DI.Name;
                }                                   
          i++; 
        }
        System.debug('allDIName------'+allDIName);  
        for(Call__c call: callList)
        {
            call.Discussion_Item__c = allDIName ; 
            if(allDIName == '')
            {
                call.Discussion_Item_Count__c = 0;   
            }
            else if(allDIName != '')
            {
               call.Discussion_Item_Count__c = allDIName.split(';').Size();   
            }   
            System.debug('allDIName.split.Siz------'+allDIName.split(';').Size());  
            
            callListToUpodate.add(call);
        }
        System.debug('callListToUpodate------'+callListToUpodate);
        System.debug('callListToUpodate--Size----'+callListToUpodate.Size());
        
        update callListToUpodate;               
    }
    public static void callUpdateOnDiscussionDelete(List<ZTS_EU_Discussion__c> deletedDiscussion)
    { 
        String Action = '';
        boolean myflag = false;
        if(myflag == false)
        {
            List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
            System.debug('deletedDiscussion------'+deletedDiscussion);
            System.debug('deletedDiscussion--Size----'+deletedDiscussion.Size());
            discussionList = [select id, Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Call_Attendee__r.ZTS_EU_call__c,ZTS_EU_Campaign__c,ZTS_EU_Call_Attendee__r.ZTS_EU_Contact__c,ZTS_EU_Campaign__r.ZTS_EU_Field_Targeting__c,ZTS_EU_Campaign__r.IsActive from ZTS_EU_Discussion__c where id IN:deletedDiscussion AND ZTS_EU_Market__c != 'United States'];
            System.debug('discussionList------'+discussionList);
            System.debug('discussionList--Size----'+discussionList.Size());
            Set<Id> callId = new Set<Id>();
            Set<Id> attendeeId = new Set<Id>();
            String DIName = '';
            Map<String,ZTS_EU_Discussion__c> myMap = new Map<String,ZTS_EU_Discussion__c>();    
            for(ZTS_EU_Discussion__c dis : discussionList)
            {           
                myMap.put(dis.Name,dis);
            }
           //Added for TPDEV-360 -Start
            if(discussionList.size()>0){
                Action = 'Delete';
                DiscussionsService.createDeleteCampaignMembers(discussionList,Action);
            }
           //Added for TPDEV-360 -End
            System.debug('myMap------'+myMap);
            System.debug('myMap--Size----'+myMap.Size());   
            for(ZTS_EU_Discussion__c discussion : myMap.values())
            {
                callId.add(discussion.ZTS_EU_Call_Attendee__r.ZTS_EU_call__c);
                DIName = DIName + discussion.Name;
                attendeeId.add(discussion.ZTS_EU_Call_Attendee__c);
            }
            System.debug('callId------'+callId);
            System.debug('DIName------'+DIName);            
            List<Call__c> callList = new List<Call__c>();
            List<Call__c> callListToUpodate = new List<Call__c>();
            callList = [Select Id, Name,Discussion_Item__c,Discussion_Item_Count__c from Call__c where id=:callId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];      
            
            String callDI = ''; 
            List<String> stringList = new List<String>();   
            List<String> stringList2 = new List<String>();
            List<String> stringList3 = new List<String>();
            
            for(Call__c call: callList)
            {   
                
                callDI = call.Discussion_Item__c;
                System.debug('callDI-1---'+callDI);
                if(callDI != null)
                {
                    stringList = callDI.split(';');
                    stringList2.addAll(stringList);
                    System.debug('stringList--2-------'+stringList2);
                    System.debug('stringList2--size-------'+stringList2.Size());
                    for(integer j=0;j<stringList2.Size();j++)
                    {
                        System.debug('j------'+j);
                        System.debug('stringList[j]------'+stringList2[j]);
                        /*if(stringList2[j] == DIName)
                        {
                             System.debug('matched--------');
                             stringList.remove(j);                                              
                        }*/
                        if(stringList2[j] != DIName)
                        {
                            System.debug('not matched--------');
                            stringList3.add(stringList2[j]);
                        }           
                    }
                    
                    integer i=1;
                    callDI = '';
                    System.debug('stringList--3-------'+stringList3);
                    for(String str: stringList3)
                    {
                        if(i != stringList3.Size())
                        {
                            callDI = callDI + str + ';';
                        }
                        if(i == stringList3.Size())
                        {
                            callDI = callDI + str;
                        }
                        i++;
                    }
                    System.debug('callDI-2---'+callDI);
                    call.Discussion_Item__c = callDI;
                    //call.Discussion_Item_Count__c = 0;
                    if(callDI == '')
                    {
                        call.Discussion_Item_Count__c = 0;   
                    }
                    else if(callDI != '')
                    {
                       call.Discussion_Item_Count__c = callDI.split(';').Size();   
                    }
                                
                    callListToUpodate.add(call);
                }
                
            }
            System.debug('callListToUpodate------'+callListToUpodate);
            System.debug('callListToUpodate--Size----'+callListToUpodate.Size());
               myflag = true; 
               
               
            update callListToUpodate;
           
       }     
    }
}