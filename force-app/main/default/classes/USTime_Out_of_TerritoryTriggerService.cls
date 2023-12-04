/****************************************************************************************************************************************** 
 * Trigger Name : USTime_Out_of_TerritoryTriggerService
 * Description  : Service class to handle Time_Out_of_Territory__c trigger logic  
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman			02/12/2020		Moved from Triggers into service class per framework
 * Triggers added below:
 -----------------------------------------------------------------------------------------------------------------------------------------
 * @Name: ZTS_GL_AllTOTTrigger
 * @Desciption: Trigger on TOT.
 *              1.Avoids creation and updation of TOT for the User whenever there is a conflict with DateTime of a call associated with that User.(not in use)'Factored out by US Region'
 *              2.Prevents Deletion of records where the Start Date has past.'Factored in by US Region'
 *              3.Creates Calender Event for the TOT Owner.'Factored in by US Region'
 *              4.Updates Calender Event.'Factored in by US Region'
 *              5.Stamps Start/End DateTime fields of TOT for the Calender Event Start/End DateTime mapping.'Factored in by US Region'
 *              6.Prevents conflicting TOTs for the same User.'Factored in by US Region'
* @date Created:Feb 20, 2014
* @author Ketan Prakash Singh
*****************************************************************************************************************************************/
public class USTime_Out_of_TerritoryTriggerService 
{    
	public static void beforeInsert(List<Time_Out_of_Territory__c> triggerNew)
    {
        // Stamps Start/End DateTime fields of TOT for the Calender Event Start/End DateTime mapping
        ZTS_US_TOT_Utils.dateTimeFill(triggerNew);
        // Prevents conflicting TOTs for the same User    
        ZTS_US_TOT_Utils.preventTOTConflict(triggerNew);
    }
    public static void beforeUpdate(List<Time_Out_of_Territory__c> triggerOld, Map<Id, Time_Out_of_Territory__c> triggerOldMap, List<Time_Out_of_Territory__c> triggerNew, Map<Id, Time_Out_of_Territory__c> triggerNewMap) 
    {
        // Stamps Start/End DateTime fields of TOT for the Calender Event Start/End DateTime mapping
        ZTS_US_TOT_Utils.dateTimeFill(triggerNew);
        // Prevents conflicting TOTs for the same User    
        ZTS_US_TOT_Utils.preventTOTConflict(triggerNew);
    }

    public static void afterUpdate(List<Time_Out_of_Territory__c> triggerOld, Map<Id, Time_Out_of_Territory__c> triggerOldMap, List<Time_Out_of_Territory__c> triggerNew, Map<Id, Time_Out_of_Territory__c> triggerNewMap)
    {
        // Updates Calender Event
        
        ZTS_US_TOT_Utils.updateCalenderEvent(triggerNew,triggerOldMap);    }
    
    public static void afterInsert(List<Time_Out_of_Territory__c> triggerNew, Map<Id, Time_Out_of_Territory__c> triggerNewMap)
    {
        // Creates Calender Event for the TOT Owner
        ZTS_US_TOT_Utils.calenderEventCreation(triggerNew);
	}
    
    public static void beforeDelete(List<Time_Out_of_Territory__c> triggerOld, Map<Id, Time_Out_of_Territory__c> triggerOldMap)
    {
        // Prevents deletion for past Start Date
        ZTS_US_TOT_Utils.preventDeletion(triggerOld);
    }
}