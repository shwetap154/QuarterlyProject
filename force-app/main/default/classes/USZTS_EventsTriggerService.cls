/****************************************************************************************************************************************** 
 * Trigger Name : USZTS_EventsTriggerService
 * Description    : Trigger on Events.
 *              	1.Creates Internal Attendee record with the Event creator/owner whenever an Event is inserted.
 * @date Created:Mar 07, 2014
 * @author Ketan Prakash Singh
 *                                                         
 * Modification Log    :
 * -----------------------------------------------------------------------------------------------------------------------
 * Developer                             Date                   Description
 * ---------                             ----                   -----------
 * Ketan Prakash Singh     				07/2014              	Created   
 * Art Smorodin			  				02/11/2020	      		Moved to Service Class
*****************************************************************************************************************************************/
public class USZTS_EventsTriggerService 
{      
	public static void beforeInsert(List<ZTS_Events__c> triggerNew)
    {
    	ZTS_US_CustomEvents_Utils.populateUserTerritoryOnEvent(triggerNew,null,true,false);
    	ZTS_US_CustomEvents_Utils.updateOldTotalSumExpenses(triggerNew, null);
    }

	public static void beforeUpdate(List<ZTS_Events__c> triggerOld, Map<Id, ZTS_Events__c> triggerOldMap, List<ZTS_Events__c> triggerNew, Map<Id, ZTS_Events__c> triggerNewMap)
    {
    	ZTS_US_CustomEvents_Utils.populateUserTerritoryOnEvent(triggerNew,triggerOldMap,false,true);
        //if(CheckRecursiveTrigger.runOnce())
        //{
            ZTS_US_CustomEvents_Utils.RequireRejectionComment(triggerNew, triggerOldMap);
      	//}
      	ZTS_US_CustomEvents_Utils.updateOldTotalSumExpenses(triggerNew, triggerOldMap);
    }

    public static void afterInsert(List<ZTS_Events__c> triggerNew, Map<Id, ZTS_Events__c> triggerNewMap)
    {
        CheckRecursiveTrigger.runOnce();
        ZTS_US_CustomEvents_Utils.createInternalAttendeeOnEventInsert(triggerNew);
        ZTS_US_CustomEvents_Utils.createEntitySubscription(triggerNew);
    }

    public static void afterUpdate(List<ZTS_Events__c> triggerOld, Map<Id, ZTS_Events__c> triggerOldMap, List<ZTS_Events__c> triggerNew, Map<Id, ZTS_Events__c> triggerNewMap)
    {
    	for(ZTS_Events__c Eve:triggerNew){
            if(triggerOldMap.get(eve.id).ZTS_US_Number_of_Attendees__c!=eve.ZTS_US_Number_of_Attendees__c && eve.ZTS_US_Number_of_Attendees__c!=null)
            {
               ZTS_US_CustomEvents_Utils.updateExpensesonattendeesupdate(triggerNewMap,triggerOldMap);
            }
        }
        if(CheckRecursiveTrigger.runOnce())
        {
            ZTS_US_CustomEvents_Utils.processUpdatedRecords(triggerNew);
            ZTS_US_CustomEvents_Utils.updateEntitySubscription(triggerNew, triggerOldMap);
        }
    }

    public static void beforeDelete(List<ZTS_Events__c> triggerOld, Map<Id, ZTS_Events__c> triggerOldMap)
    {
    	for (ZTS_Events__c eve :triggerOld)
        {
        	if (eve.ZTS_US_Status__c != 'new')
        	{
            	eve.addError(' Only events with a status of "New" can be deleted. Please update the status to "Cancelled" if this event will no longer take place.');
        	}
     	}
     	ZTS_US_CustomEvents_Utils.updateOldTotalSumExpenses(new List<ZTS_Events__c>(), triggerOldMap);		
    }

}