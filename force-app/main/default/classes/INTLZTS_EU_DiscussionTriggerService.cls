/****************************************************************************************************************************************** 
 * Trigger Name : INTLZTS_EU_DiscussionTriggerService
 * Description  : Service class to handle ZTS_EU_Discussion__c trigger logic  
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman			02/11/2020		Consolidated trigger logic in service class
 * Added below triggers:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Trigger Name   : CallUpdateOnDIInsertandUpdat
 * Description  : This is trigger to update calls fields DEF-001251.     
 * Created By   : CloudSense(Sohil Shah) 
 * Created Date : 4th June, 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sohil Shah           06/04/2015          Created 
*****************************************************************************************************************************************/
public class INTLZTS_EU_DiscussionTriggerService 
{
    public static void beforeDelete(List<ZTS_EU_Discussion__c> triggerOld, Map<Id, ZTS_EU_Discussion__c> triggerOldMap) 
    {
       updateCallonDiscussion.callUpdateOnDiscussionDelete(triggerOld);
    }
    
    public static void afterInsert(List<ZTS_EU_Discussion__c> triggerNew, Map<Id, ZTS_EU_Discussion__c> triggerNewMap)
    {
       updateCallonDiscussion.callUpdateOnDiscussionInsert(triggerNew);
	}
}