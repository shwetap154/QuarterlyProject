/****************************************************************************************************************************************** 
* Class Name   : INTLZTS_EU_RequestService
* Description  : Logic for all INTL ZTS_EU_Request__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 12 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/12/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public class INTLZTS_EU_RequestTriggerService 
{
    public static void beforeUpdate(List<ZTS_EU_Request__c> triggerOld, Map<Id, ZTS_EU_Request__c> triggerOldMap, List<ZTS_EU_Request__c> triggerNew, Map<Id, ZTS_EU_Request__c> triggerNewMap) 
    {
        ZTS_EU_submit_CR_record.updateCRRecord(triggerNew, triggerNewMap, triggerOldMap);
    }    
}