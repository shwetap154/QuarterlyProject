/****************************************************************************************************************************************** 
* Class Name   : USSampleDropTriggerService
* Description  : Logic for all ZTS_US_Sample_Drop__c triggers housed here.
* Created By   : Slalom/Alex Carstairs 
* Created Date : 26th May 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Alex Carstairs(Slalom)     05/26/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public with sharing class USSampleDropTriggerService {
    public static void beforeInsert(List<ZTS_US_Sample_Drop__c> triggerNew) 
    {
    }
    
    public static void beforeDelete(List<ZTS_US_Sample_Drop__c> triggerOld, Map<Id, ZTS_US_Sample_Drop__c> triggerOldMap)
    {
        ZTS_US_Account_Sample_Drop_Controller.deleteAccounSampleDrop(triggerOld);
        checkForCallSubmittedMoreThanTenDays(triggerOld, triggerOldMap);
    }
    
    public static void afterInsert(List<ZTS_US_Sample_Drop__c> triggerNew, Map<Id, ZTS_US_Sample_Drop__c> triggerNewMap)
    {
        ZTS_US_Account_Sample_Drop_Controller.createAccounSampleDrop(triggerNew);
    }
    
    static void checkForCallSubmittedMoreThanTenDays(List<ZTS_US_Sample_Drop__c> triggerOld, Map<Id, ZTS_US_Sample_Drop__c> triggerOldMap) 
    {
        List<ZTS_US_Sample_Drop__c> samdrops = [Select Id, ZTS_US_Call__r.ZTS_EU_Status__c,ZTS_US_Call__r.ZTS_EU_Submitted_Date__c from ZTS_US_Sample_Drop__c where Id IN:triggerOld];
        for(ZTS_US_Sample_Drop__c drop : triggerOld){
            
            for(ZTS_US_Sample_Drop__c drops :samdrops){
                if(drops.ZTS_US_Call__r.ZTS_EU_Status__c =='Submitted'&&(drops.ZTS_US_Call__r.ZTS_EU_Submitted_Date__c.addDays(10)<(System.Today()))){
                    drop.addError('Cannot delete the sample drop for the submitted calls ');
                }
            }
        }
    }
}