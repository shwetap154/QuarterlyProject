/****************************************************************************************************************************************** 
 * Class Name   : AnimalTrigger
 * Description  : This trigger will handle all AnimalTrigger logic
 * Created By   : Slalom Consulting/ Christian Kildal-Brandt
 * Created Date : September 20th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				  Date                Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Christian Kildal-Brandt(Slalom)      09/20/2021              Created
 * Neil Kapoor							10/12/2021				Modified
 * Venkat Joginapally					10/27/2021				Updated to Dispatch Trigger Framework
*****************************************************************************************************************************************/

trigger AnimalTrigger on ZTS_US_Animal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CSE_AnimalTriggerHandler(), Bypass_Triggers__mdt.Animal_Bypass__c);
}