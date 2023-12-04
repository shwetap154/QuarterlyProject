/****************************************************************************************************************************************** 
 * Class Name   : taskUpdateonCallUpdate
 * Description  : This is Trigger class from Calltrigger After Update, update task fields related to call fields DEF-001251.
 *      
 * Created By   : CloudSense(Sohil Shah) 
 * Created Date : 4th June, 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sohil Shah           06/04/2015          Created 
*****************************************************************************************************************************************/

public class taskUpdateonCallUpdate
{  
    public static void updateTaskOnCallUpdate(List<Call__c> callList)
    {
        List<Task> taskList = new List<Task>();
        List<Task> taskToUpdate = new List<Task>();  
        // Comment out on 10th Sep
        //callList = [Select Id, Name,Discussion_Item__c,Discussion_Item_Count__c,Contact_Employee__c,Contact_Employee_Count__c,ZTS_EU_Sub_Type__c,ZTS_EU_Local_Subtype__c from call__c where id IN:callList AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
		//callList = [Select Id,Discussion_Item__c,Discussion_Item_Count__c,Contact_Employee__c,Contact_Employee_Count__c,ZTS_EU_Sub_Type__c,ZTS_EU_Local_Subtype__c from call__c where id IN:callList AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
 		//System.debug('CallList------'+callList);
        //System.debug('CallList--Size----'+callList.Size());
        taskList = [SELECT Id,WhatID,Discussion_Item__c,Contact_Employee__c,Discussion_Item_Count__c,Contact_Employee_Count__c,Local_sub_type__c,Sub_Type__c from Task where What.Type = 'Call__C' and WhatId IN:callList];
        
        //taskList = [SELECT Id,Discussion_Item__c,Contact_Employee__c,Discussion_Item_Count__c,Contact_Employee_Count__c,Local_sub_type__c,Sub_Type__c from Task where What.Type = 'Call__C' and WhatId IN:callList];
        //System.debug('taskList------'+taskList);
        //System.debug('taskList--Size----'+taskList.Size());
        
        for(Task ts: taskList)
        {
            ts.Contact_Employee__c = callList[0].Contact_Employee__c;
            ts.Discussion_Item__c = callList[0].Discussion_Item__c;
            ts.Contact_Employee_Count__c = callList[0].Contact_Employee_Count__c;
            ts.Discussion_Item_Count__c = callList[0].Discussion_Item_Count__c;
            ts.Sub_Type__c = callList[0].ZTS_EU_Sub_Type__c;
            ts.Local_sub_type__c = callList[0].ZTS_EU_Local_Subtype__c;
            taskToUpdate.add(ts);
        }      
         Database.update(taskToUpdate,false);
    }
    
}