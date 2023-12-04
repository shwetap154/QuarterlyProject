/****************************************************************************************************************************************** 
 * Class Name   : CaseAnimalTrigger
 * Description  : This trigger will handle all CaseAnimalTrigger logic
 * Created By   : Slalom Consulting/Venkat Joginapally
 * Created Date : September 13th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                         Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Venkat Joginapally(Slalom)     09/13/2021              Created
*****************************************************************************************************************************************/

trigger CaseAnimalTrigger on ZTS_US_Case_Animal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CSE_CaseAnimalTriggerHandler(), Bypass_Triggers__mdt.CaseAnimal_Bypass__c);
}