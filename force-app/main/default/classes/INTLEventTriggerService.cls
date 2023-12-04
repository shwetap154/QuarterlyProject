/****************************************************************************************************************************************** 
 * Class Name   : IntlEventTriggerService
 * Description  : Logic for all Event triggers housed here.
 * Created By   : Slalom/David Stern 
 * Created Date : 06 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     02/06/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/

public class INTLEventTriggerService 
{
    public static void afterInsert(List<Event> triggerNew, Map<Id, Event> triggerNewMap)
    {
        if(UserInfo.getLanguage() == 'Fr')
        {
            eventUpdate.updatEventOnInsert(triggerNew); 
        }
        ZTS_EU_UpdateEventSubjectOnIsertUdate.updateEventSubject(triggerNew); 
    }
	public static void afterUpdate(List<Event> triggerOld, Map<Id, Event> triggerOldMap, List<Event> triggerNew, Map<Id, Event> triggerNewMap)
    {
            
        if(!GlobalVariablesService.isCallUpdatingEvent)
        {
            GlobalVariablesService.isEventUpdatingCall = true;
            EventService.updateAndSyncCallsFromEvents(triggerNewMap, triggerOldMap);
        }
        for(Id eve : triggerNewMap.keySet())
        {
            if(UserInfo.getLanguage() == 'Fr' && triggerOldMap.get(eve).Sub_Type__c != triggerNewMap.get(eve).Sub_Type__c)
            {
                eventUpdate.updatEventOnInsert(triggerNew); 
            }
        } 
    }	
    public static void beforeDelete(List<Event> triggerOld, Map<Id, Event> triggerOldMap)
    {
        if(!GlobalVariablesService.isCallDeletingEvent && !ZTS_EU_TOT_Utils.IsTotDelete)
        {
            GlobalVariablesService.isEventDeletingCall = true;
            EventService.deleteRelatedCalls(triggerOldMap);
        }
    }		
    public static void afterDelete(List<Event> triggerOld, Map<Id, Event> triggerOldMap)
    {
        if(ZTS_EU_TOT_Utils.IsTotDelete == false)
        {
            EventService.deleteParentTOT(triggerOldMap);
        }
    }
}