/****************************************************************************************************************************************** 
 * Class Name   : CaseProductTrigger
 * Description  : This trigger will handle all CaseProductTrigger logic
 * Created By   : Slalom Consulting/Venkat Joginapally
 * Created Date : September 13th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Venkat Joginapally(Slalom)     09/13/2021          Created
 * Ethan Hirsch (Zoetis Inc)      07/18/2022          Removed calls to CSE_CaseProductTriggerHandler.batchDetailFromCaseProduct
 *                                                    and CSE_ValidateAssessmentProducts.afterUpdate. 
 *                                                    This has moved to CaseProductService.upsertBatchDetailFromCaseProduct
 *                                                    with recursion prevention using DispatchTriggerHandler.
 * Ethan Hirsch (Zoetis Inc)      07/25/2022          Remove references to CSE_ValidateAssessmentProducts as it was not
 *                                                    performing any logic.
*****************************************************************************************************************************************/

trigger CaseProductTrigger on ZTS_US_Case_Product__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CSE_CaseProductTriggerHandler(), Bypass_Triggers__mdt.CaseProduct_Bypass__c);
}