/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_PositionTrigger
 * Description  : All Trigger Logic for ZTS_EU_Position__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 14th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sunil Kumar             04/17/2014          Created
 * CloudSense(Bimba)       03/12/2014          Updated : added the check to bypass trigger
 * CloudSense(Shreyas)     03/18/2015          Added the method 'populateDaySinceLastCalled_FromCollegue' to populate the 'Days since last called' on account position
 * Mohamed Seliman           02/12/2020        Refactored to use Trigger framework 
*****************************************************************************************************************************************/
trigger ZTS_EU_PositionTrigger on ZTS_EU_Position__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_PositionTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Position_Bypass__c);
}