/****************************************************************************************************************************************** 
 * Class Name   : CaseContactTrigger
 * Description  : This trigger will handle all CaseContactTrigger logic
 * Created By   : Slalom Consulting/Venkat Joginapally
 * Created Date : September 13th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Venkat Joginapally(Slalom)     09/13/2021          Created
*****************************************************************************************************************************************/

trigger CaseContactTrigger on Case_Contact__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CSE_CaseContactTriggerHandler(), Bypass_Triggers__mdt.CaseContact_Bypass__c);
}