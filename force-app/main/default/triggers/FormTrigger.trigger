/****************************************************************************************************************************************** 
 * Trigger Name : FormTrigger
 * Description  : Trigger for "Form__c" object.
 * Created By   : Aritra (Cognizant)
 * Created Date : 28th Oct, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra Chakraborty      10/28/2021          Created 
******************************************************************************************************************************************/
trigger FormTrigger on Form__c (before insert,before update,after insert,after update,before delete, after delete) {
	DispatchTriggerHandler.dispatchHandlerToFire(new FormTriggerHandler());
}