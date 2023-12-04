/****************************************************************************************************************************************** 
* Class Name   : INTLZTS_EU_ColleagueTriggerService
* Description  : Logic for all INTL ZTS_EU_Colleague__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 11 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/11/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public class INTLZTS_EU_ColleagueTriggerService 
{
        
    public static void beforeDelete(List<ZTS_EU_Colleague__c> triggerOld, Map<Id, ZTS_EU_Colleague__c> triggerOldMap)
    {
        Id currUsrId = UserInfo.getUserId();
        
        AccountPositionsService.updateLastCallDateFromColleagues(triggerOld, true);
        
    }
    
    public static void afterInsert(List<ZTS_EU_Colleague__c> triggerNew, Map<Id, ZTS_EU_Colleague__c> triggerNewMap) 
    {
        Id currUsrId = UserInfo.getUserId();
        System.debug('$$$ colleague trigerNew: '+triggerNew);
        ZTS_EU_EmployeeCallCreditCreate.createEmployeeCallCredit(triggerNew);
        ZTS_EU_AttendeeService.createEventRelationsForColleagues(triggerNew);
        AccountPositionsService.updateLastCallDateFromColleagues(triggerNew, false);
    }
    
    public static void afterDelete(List<ZTS_EU_Colleague__c> triggerOld, Map<Id, ZTS_EU_Colleague__c> triggerOldMap) 
    {
        Id currUsrId = UserInfo.getUserId();
        
        ZTS_EU_AttendeeService.deleteEventRelationsForColleague(triggerOldMap);
        
    }
}