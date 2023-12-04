/******************************************************//**
@class      USEventTriggerService
@brief      Service class for Event Trigger functionality 

@revision   02-05-2020  Mohamed Seliman
    Created.

@copyright  (c)2020, Zoetis
**********************************************************/

public without sharing class USEventTriggerService 
{

	public static void afterUpdate(List<Event> triggerOld, Map<Id, Event> triggerOldMap, List<Event> triggerNew, Map<Id, Event> triggerNewMap)
	{
		if(!USGlobalVariablesService.isCallUpdatingEvent)
		{
                USGlobalVariablesService.isEventUpdatingCall = true;
                USEventService.updateAndSyncCallsFromEvents(triggerNewMap,triggerOldMap);
		}
	}
	
	public static void beforeDelete(List<Event> triggerOld, Map<Id, Event> triggerOldMap)
	{
		if(!USGlobalVariablesService.isCallDeletingEvent){
			USGlobalVariablesService.isEventDeletingCall = true;
			USEventService.deleteRelatedCalls(triggerOldMap);
		}
	}
	

	// After insert Event Logic goes here

	public static void afterInsert(List<Event> triggerNew, Map<Id, Event> triggerNewMap)
	{
		USEventService.updateEventIdOnTOT(triggerNewMap);
	}	
}