/****************************************************************************************************************************************** 
 * Trigger Name : IntlTaskTriggerService
 * Description  : Trigger to update tasks Sub type fields(Trnalsation into French) DEF-001251.  
                : Update New Fields on Task creation    
 * Created By   : CloudSense(Sohil Shah) 
 * Created Date : 4th June, 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sohil Shah           06/04/2015          	Created 
 * David Stern			02/06/2020				Moved to Service Class
*****************************************************************************************************************************************/
public class INTLTaskTriggerService 
{      
	public static void afterInsert(List<Task> triggerNew, Map<Id, Task> triggerNewMap)
    {   
        taskUpdate.updateTaskOnInsert(triggerNew);
        if(UserInfo.getLanguage() == 'Fr')
        {
            TaskUpdateOnInsert.updatTaskOnInsert(triggerNew); 
        }
    }
	public static void afterUpdate(List<Task> triggerOld, Map<Id, Task> triggerOldMap, List<Task> triggerNew, Map<Id, Task> triggerNewMap)
    {   
        if(UserInfo.getLanguage() == 'Fr')
        {
            TaskUpdateOnInsert.updatTaskOnInsert(triggerNew); 
        }
    }
}