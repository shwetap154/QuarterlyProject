/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_Batch_callUpdateforActivities 
 * Description  : This is Batch class to update all exisitng calls fields DEF-001251.     
 * Created By   : CloudSense(Sohil Shah) 
 * Created Date : 4th June, 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sohil Shah           06/04/2015          Created 
*****************************************************************************************************************************************/

global class ZTS_EU_Batch_callUpdateforActivities implements Database.Batchable<SObject>
{   
    global String Market = 'France';
   /* global String querys;
    global ZTS_EU_Batch_callUpdateforActivities(querys)
    {
       Market = 'France';
       querys = 'Select Id, Name, ZTS_EU_Account__c, Contact_Employee__c, Discussion_Item__c from Call__c where ZTS_EU_Account__r.ZTS_EU_Market__c =:Market';
    }*/

    global Database.queryLocator start(Database.BatchableContext bc) { 
            
       
        String query = 'Select Id, Name, ZTS_EU_Account__c, Contact_Employee__c, Discussion_Item__c from Call__c where ZTS_EU_Account__r.ZTS_EU_Market__c =:Market';
        return Database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext bc, List<Call__C> scope) {    
        
           List<Call__c> allCallList = new List<Call__c>();
            allCallList = [Select Id, Name, ZTS_EU_Account__c,Discussion_Item_Count__c,Contact_Employee_Count__c, Contact_Employee__c, Discussion_Item__c,(Select Id, Name, ZTS_EU_call__c from Attendees__r) from Call__c where id IN: scope AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            List<Call__c> CallListToUpdate = new List<Call__c>();           
            System.debug('allCallList-----'+allCallList);
            System.debug('allCallList-Size----'+allCallList.Size());
            String contactName = '';
            String DIName = '';
            Map<Id,String> callVsContactMap = new Map<Id,String>();
            Map<ID,String> callVsDIMap = new Map<ID,String>();
            Map<ID,Call__c> callVsCall = new Map<ID,Call__C>();
            Map<Id,Integer> callVsDiCountMap = new Map<Id,Integer>();
            List<Attendee__c> allAttendeeList = new List<Attendee__c>();
            
            Set<Id> attendeeId = new Set<Id>();
            for(Call__c call : allCallList)
            {
            //  callId.add(call.id);
                integer i = 1;
                
                for(Attendee__c att: call.Attendees__r)
                {
                    if(i != call.Attendees__r.Size())
                    {
                        contactName = contactName + att.Name + ';';
                    }
                    if(i ==  call.Attendees__r.Size())
                    {
                        contactName = contactName + att.Name;
                    }
                    i++;
                    attendeeId.add(att.id);
                    
                }               
                callVsContactMap.put(call.id,contactName);                  
                callVsCall.put(call.id,call);
                contactName = '';
            }
            allAttendeeList = [Select Id, Name, ZTS_EU_call__c,(Select Id, Name from Discussions__r) from Attendee__c where id IN : attendeeId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            System.debug('allAttendeeList-----'+allAttendeeList);
            System.debug('allAttendeeList-Size----'+allAttendeeList.Size());
            for(Attendee__c att : allAttendeeList)
            {
                integer j = 1;
                for(ZTS_EU_Discussion__c discussion : att.Discussions__r)
                    {
                        if(j != att.Discussions__r.Size())
                        {
                            DIName = DIName + discussion.Name + ';';
                        }
                        if(j ==  att.Discussions__r.Size())
                        {
                            DIName = DIName + discussion.Name;
                        }
                        j++;
                    }
                    callVsDIMap.PUT(att.ZTS_EU_call__c,DIName);
                    System.debug('DIName---'+DIName);
                    System.debug('count---'+DIName.split(';').Size());
                    if(DIName == '')
                    {
                        callVsDiCountMap.put(att.ZTS_EU_call__c,0);
                    }
                    else if(DIName != '')
                    {
                        callVsDiCountMap.put(att.ZTS_EU_call__c,DIName.split(';').Size());
                    }
                    
                    DIName = '';    
            }
            System.debug('callVsDiCountMap-----'+callVsDiCountMap);
            System.debug('callVsDiCountMap-Size----'+callVsDiCountMap.Size());
            for(Id callId : callVsDIMap.keySet())
            {
                callVsCall.get(callId).Contact_Employee__c = callVsContactMap.get(callId);
                callVsCall.get(callId).Discussion_Item__c = callVsDIMap.get(callId);
                callVsCall.get(callId).Discussion_Item_Count__c = callVsDiCountMap.get(callId);
                CallListToUpdate.add(callVsCall.get(callId));
            }

            System.debug('callVsContactMap-----'+callVsContactMap);
            System.debug('callVsContactMap--Size---'+callVsContactMap.Size());
            System.debug('callVsDIMap-----'+callVsDIMap);
            System.debug('callVsDIMap--Size---'+callVsDIMap.Size());

            System.debug('CallListToUpdate-----'+CallListToUpdate);
            System.debug('CallListToUpdate--Size---'+CallListToUpdate.Size());
            Database.update(CallListToUpdate,false);
       }     
     global void finish(Database.BatchableContext bc) {
     }  
}