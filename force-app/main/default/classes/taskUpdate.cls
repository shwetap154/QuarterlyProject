public class taskUpdate
{
    public static void updateTaskOnInsert(List<Task> newTaskList)
    {
       
            List<Task> taskList = new List<Task>();
            List<Task> taskToUpdate = new List<Task>();
            Set<Id> callId = new Set<Id>();
            Map<Task,Id> taskVsCallMap = new Map<Task,Id>();
            String contactName = '';
            String DIName = '';
            List<Attendee__c> AttendeeList = new List<Attendee__c>();
            Set<Id> attendeeId = new Set<Id>();
            taskList = [SELECT Id,WhatID,Discussion_Item__c,Contact_Employee__c,Discussion_Item_Count__c,Contact_Employee_Count__c,Local_sub_type__c,Sub_Type__c from Task where What.Type = 'Call__C' and Id IN:newTaskList];
            System.debug('taskList------'+taskList);
            System.debug('taskList--Size----'+taskList.Size());
            Map<Id,String> callVsContactMap = new Map<Id,String>();
            Map<ID,String> callVsDIMap = new Map<ID,String>();
            Map<ID,Integer> callVsContactCountMap = new Map<ID,Integer>();
            Map<ID,Integer> callVsDICountMap = new Map<ID,Integer>();
            Map<Id,String> callVsSubTypeCountMap = new Map<Id,String>();
            Map<Id,String> callVsLocalSubTypeCountMap = new Map<Id,String>();
            for(Task ts: taskList)
            {
                callId.add(ts.WhatId);
                taskVsCallMap.put(ts,ts.WhatId);
                //taskVsTask.put(ts.id,ts);
            }
            List<Call__C> callList = new List<Call__C>();
            callList = [Select Id, Name,Discussion_Item__c,Contact_Employee__c,ZTS_EU_Sub_Type__c,ZTS_EU_Local_Subtype__c,(Select Id, Name, ZTS_EU_call__c from Attendees__r) from call__c where id IN:callId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            System.debug('callList------'+callList);
            System.debug('callList--Size----'+callList.Size());
            for(Call__c call : callList)
                {
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
                    if(contactName == '')
                    {
                        callVsContactCountMap.put(call.id,0);
                    }
                    else if(contactName != '')
                    {
                        callVsContactCountMap.put(call.id,contactName.split(';').Size());
                    }
                    callVsSubTypeCountMap.put(call.id,call.ZTS_EU_Sub_Type__c);
                    callVsLocalSubTypeCountMap.put(call.id,call.ZTS_EU_Local_Subtype__c);
                    contactName = '';
                }
                AttendeeList = [Select Id, Name, ZTS_EU_call__c,(Select Id, Name from Discussions__r) from Attendee__c where id IN : attendeeId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];        
                System.debug('AttendeeList-----'+AttendeeList);
                System.debug('AttendeeList-Size----'+AttendeeList.Size());
                System.debug('callVsContactCountMap-----'+callVsContactCountMap);
                System.debug('callVsContactCountMap-Size----'+callVsContactCountMap.Size());
                for(Attendee__c att : AttendeeList)
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
                System.debug('callVsContactMap-----'+callVsContactMap);
                System.debug('callVsContactMap--Size---'+callVsContactMap.Size());
                System.debug('callVsDIMap-----'+callVsDIMap);
                System.debug('callVsDIMap--Size---'+callVsDIMap.Size());
                System.debug('callVsDICountMap-----'+callVsDICountMap);
                System.debug('callVsDICountMap--Size---'+callVsDICountMap.Size());

                for(Task task : taskVsCallMap.keySet())
                {           
                    task.Contact_Employee__c = callVsContactMap.get(task.WhatId);
                    task.Discussion_Item__c = callVsDIMap.get(task.WhatID);
                    task.Discussion_Item_Count__c = callVsDICountMap.get(task.WhatID);
                    task.Contact_Employee_Count__c =callVsContactCountMap.get(task.WhatID);
                    task.Sub_Type__c = callVsSubTypeCountMap.get(task.WhatId);
                    task.Local_sub_type__c = callVsLocalSubTypeCountMap.get(task.WhatId);
                    taskToUpdate.add(task);
                }
                System.debug('taskToUpdate-----'+taskToUpdate);
                System.debug('taskToUpdate--Size---'+taskToUpdate.Size());
                Database.update(taskToUpdate,false);
        
        
    }
}