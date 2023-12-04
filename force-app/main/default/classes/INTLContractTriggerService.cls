/****************************************************************************************************************************************** 
* Class Name   : INTLContractTriggerService
* Description  : Logic for all INTL Contract triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 10 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/10/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public class INTLContractTriggerService 
{
    public static void beforeInsert(List<Contract> triggerNew) 
    {
        ZTS_EU_ContractTriggerHandler.defaultValuesOnContract(triggerNew);
    }
    public static void afterInsert(List<Contract> triggerNew, Map<Id, Contract> triggerNewMap) 
    {
        ZTS_EU_ContractTriggerHandler.copyProductsOnInsert(triggerNew); 
        if(UtilityService.AffUpdateRun)
        {
            ZTS_EU_ContractTriggerHandler.copyContractsOnInsertUpdate(triggerNew);
        }
    }
    public static void afterUpdate(List<Contract> triggerOld, Map<Id, Contract> triggerOldMap, List<Contract> triggerNew, Map<Id, Contract> triggerNewMap) 
    {
        ZTS_EU_ContractTriggerHandler.AddErrorOnUpdateOfContractTemplate(triggerNew, triggerOldMap);
        if(UtilityService.AffUpdateRun)
        {
            ZTS_EU_ContractTriggerHandler.copyContractsOnInsertUpdate(triggerNew);
        }
    }
}