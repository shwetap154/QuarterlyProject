/****************************************************************************************************************************************** 
 * Class Name   : TaskUpdateOnInsert
 * Description  : class to Task Trigger to translate tasks Sub type fields(Trnalsation into French) DEF-001251.     
 * Created By   : CloudSense(Sohil Shah) 
 * Created Date : 4th June, 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sohil Shah           06/04/2015          Created 
*****************************************************************************************************************************************/
public class TaskUpdateOnInsert
{
    public static void updatTaskOnInsert(List<Task> TaskList)
    {
        List<Task> allTaskList = new  List<Task>();
        List<Task> filteredTaskList = new  List<Task>();
        List<Task> filteredListToUpdate = new List<Task>();
        allTaskList = [Select Id, Sub_Type__c,WhatId from Task where id IN:TaskList];
        System.debug('allTaskList-----'+allTaskList);
        System.debug('allTaskList--size---'+allTaskList.Size());
        Set<Id> callId = new Set<Id>();
        Set<Id> filterdCallId = new Set<Id>();
        Map<Id,List<Task>> callVsTaskMap = new Map<Id,List<Task>>();
        for(Task task :allTaskList)
        {
            callId.add(task.WhatId);
            List<Task> tempList = callVsTaskMap.get(task.WhatId);
            if(tempList == null)
            {
                tempList = new List<Task>();
                callVsTaskMap.put(task.WhatId, new List<Task>{task});
            }   
            else
            {
                tempList.add(task);
            }
        }
        List<Call__C> callList = new List<Call__C>();
        callList = [Select Id, Name, ZTS_EU_Sub_Type__c,ZTS_EU_Account__c,ZTS_EU_Account__r.ZTS_EU_Market__c,ZTS_EU_Local_Subtype__c from call__c where id IN:callId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        System.debug('callList-----'+callList);
        System.debug('callList--size---'+callList.Size());
        Map<Id,String> callVsSubtypeMap = new Map<Id,String>();
        for(Call__C call: callList)
        {
            filterdCallId.add(call.id);
            callVsSubtypeMap.put(call.id,call.ZTS_EU_Sub_Type__c);
        }
        filteredTaskList = [Select Id, Sub_Type__c,WhatId from Task where WhatId IN: filterdCallId];
        System.debug('filteredTaskList-----'+filteredTaskList);
        System.debug('filteredTaskList--size---'+filteredTaskList.Size());

            for(Task task :filteredTaskList)
            {
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.Account_Call)
                {
                    task.Sub_Type__c = 'Visite client'; 
                }
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.Account_Call_with_Speaker)
                {
                    task.Sub_Type__c = 'Visite avec KOL'; 
                }
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.Advisory_Diagnostic_visit)
                {
                    task.Sub_Type__c = 'Visite Diagnostic'; 
                }
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.Clinical_Seedings_initial)
                {
                    task.Sub_Type__c = 'Visite élevage'; 
                }
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.Demonstration_PPE)
                {
                    task.Sub_Type__c = 'Démonstration'; 
                }
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.ICP_DMA_visit)
                {
                    task.Sub_Type__c = 'Rev Intra-Cabinet'; 
                }
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.Loyalty_VAS_visit)
                {
                    task.Sub_Type__c = 'Visite PBC - Offre payante'; 
                }
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.PBC_Call)
                {
                    task.Sub_Type__c = 'Visite PBC - Offre non payante'; 
                }
                if(callVsSubtypeMap.get(task.WhatId) == System.Label.Practice_Discussion_Group)
                {
                    task.Sub_Type__c = 'Groupe de discussion'; 
                }
                
                filteredListToUpdate.add(task);
            }   


        System.debug('filteredListToUpdate-----'+filteredListToUpdate);
        System.debug('filteredListToUpdate--size---'+filteredListToUpdate.Size());
        update filteredListToUpdate;
           
    }
}