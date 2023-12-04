/****************************************************************************************************************************************** 
* Trigger Name : INTLZTS_EventsTriggerService
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
* @CloudSense(Bimba) 					03/12/2014 				Updated : added the check to bypass trigger
* Art Smorodin			  				02/12/2020	      		Moved to Service Class
*****************************************************************************************************************************************/
public class INTLZTS_EventsTriggerService 
{      
    
    public static void afterInsert(List<ZTS_Events__c> triggerNew, Map<Id, ZTS_Events__c> triggerNewMap)
    {
        /*** Added by Bimba-03/12/2014 ***/
        ZTS_US_CustomEvents_Utils.createInternalAttendeeOnEventInsert(triggerNew);
        ZTS_US_CustomEvents_Utils.createEntitySubscription(triggerNew);
    }
    
    public static void afterUpdate(List<ZTS_Events__c> triggerOld, Map<Id, ZTS_Events__c> triggerOldMap, List<ZTS_Events__c> triggerNew, Map<Id, ZTS_Events__c> triggerNewMap)
    {
        /*** Added by Bimba-03/12/2014 ***/
        
        
        System.debug('Update:::');
        ZTS_US_CustomEvents_Utils.processUpdatedRecords(triggerNew);
        ZTS_US_CustomEvents_Utils.updateEntitySubscription(triggerNew, triggerOldMap);
        
    }
}