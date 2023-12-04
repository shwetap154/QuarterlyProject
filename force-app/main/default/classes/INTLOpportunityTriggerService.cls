/****************************************************************************************************************************************** 
* Class Name   : INTLOpportunityTriggerService
* Description  : Logic for all INTL Opportunity triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 26 June 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     06/26/2020          Created, Logic from all triggers moved to this class.
* Mohamed Seliman(Slalom) 07/26/2020          Commented out ATG Trigger Handler code per ATG email on 07/26/2020.

*****************************************************************************************************************************************/
public class INTLOpportunityTriggerService 
{
    public static void afterInsert(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerNewMap)
    {
        //ATGOpportunityTriggerHandler.updateTerritory(triggerNewMap);
    }
}