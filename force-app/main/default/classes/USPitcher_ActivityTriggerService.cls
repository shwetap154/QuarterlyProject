/****************************************************************************************************************************************** 
* Class Name   : USPitcher_ActivityTriggerService
* Description  : Logic for all US Pitcher_Activity__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 29 June 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     06/29/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/

public without sharing class USPitcher_ActivityTriggerService 
{
    public static void afterUpdate(List<Pitcher_Activity__c> triggerOld, Map<Id, Pitcher_Activity__c> triggerOldMap, List<Pitcher_Activity__c> triggerNew, Map<Id, Pitcher_Activity__c> triggerNewMap) 
    {
        for(Pitcher_Activity__c act: triggerNew)
        {
            if(act.Account__c == null)
            { 
               accountPopulateOnPitcherSurvey accntPopObj = new accountPopulateOnPitcherSurvey();
               accntPopObj.populateAccount(triggerNew); 
            }  
          }  
    }

    public static void afterInsert(List<Pitcher_Activity__c> triggerNew, Map<Id, Pitcher_Activity__c> triggerNewMap) 
    {
        for(Pitcher_Activity__c act: triggerNew)
        {
            if(act.Account__c == null)
            { 
               accountPopulateOnPitcherSurvey accntPopObj = new accountPopulateOnPitcherSurvey();
               accntPopObj.populateAccount(triggerNew); 
            }  
          }  
    }
}