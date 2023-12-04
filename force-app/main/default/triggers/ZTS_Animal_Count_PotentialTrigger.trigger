/****************************************************************************************************************************************** 
 * Class Name   : ZTS_Animal_Count_PotentialTrigger
 * Description  : This trigger will handle all ZTS_Animal_Count_Potential__c Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 29 June 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     06/29/2020          Created
*****************************************************************************************************************************************/
trigger ZTS_Animal_Count_PotentialTrigger on ZTS_Animal_Count_Potential__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_Animal_Count_PotentialTriggerHandler(), Bypass_Triggers__mdt.ZTS_Animal_Count_Potential_Bypass__c);
}