/****************************************************************************************************************************************** 
 * Class Name   : AssessmentTrigger
 * Description  : This trigger will handle all CaseContactTrigger logic
 * Created By   : Slalom Consulting/Neil Kapoor
 * Created Date : September 14th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                			Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Neil Kapoor(Slalom)     			   09/14/2021          Created
 * Venkat Joginapally(Slalom)		   10/27/2021		   Modified to call handler using Dispatch Trigger Handler
*****************************************************************************************************************************************/

trigger AssessmentTrigger on ZTS_US_Assessment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CSE_AssessmentTriggerHandler(), Bypass_Triggers__mdt.Assessment_Bypass__c);
}