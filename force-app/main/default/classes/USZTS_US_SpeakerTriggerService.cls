/****************************************************************************************************************************************** 
 * Trigger Name : USZTS_US_SpeakerTriggerService
 * Description  : Service class to handle ZTS_US_Speaker__c trigger logic  
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman			02/12/2020		Moved from Triggers into service class per framework
 * Triggers added below:
 -----------------------------------------------------------------------------------------------------------------------------------------
 * Trigger Name   : ZTS_US_Trigger_Create_Expense_Record
 * Description    : This trigger is used to create an expense record whenever a speaker record is created/updated with a fee
 * Created By   : Deloitte Consulting
 * Created Date : May 4th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sameep Agrawal           05/04/2014          Created 
 * Saibal Mondal            10/24/2016          Ref US SC-002011 : Added 'after delete' condition on trigger and added call to UpdateSpeakerContactIDsOnEvent() for stamping Speaker Contact IDs on Event
*****************************************************************************************************************************************/
public class USZTS_US_SpeakerTriggerService 
{
    public static void beforeUpdate(List<ZTS_US_Speaker__c> triggerOld, Map<Id, ZTS_US_Speaker__c> triggerOldMap, List<ZTS_US_Speaker__c> triggerNew, Map<Id, ZTS_US_Speaker__c> triggerNewMap)
    {
        USZTS_US_Class_Speaker_Check_Helper.checkSpeakerRecord(triggerNew,triggerOldMap);
    }
    public static void beforeInsert(List<ZTS_US_Speaker__c> triggerNew)
    {
        map<id,ZTS_US_Speaker__c> mapSpeaker=new map<id,ZTS_US_Speaker__c>();
        USZTS_US_Class_Speaker_Check_Helper.checkSpeakerRecord(triggerNew,mapSpeaker);    
    }
    public static void beforeDelete(List<ZTS_US_Speaker__c> triggerOld, Map<Id, ZTS_US_Speaker__c> triggerOldMap) 
    {
        List<ID> listSpeakerId = new List<ID>();
        
        for(ZTS_US_Speaker__c speaker: triggerOld){
            listSpeakerId.add(speaker.Id);
        }
        USZTS_US_Class_Expense_Trigger_Helper.deleteSpeakerExpense(listSpeakerId); //using this in the Trigger handler
    }
    public static void afterUpdate(List<ZTS_US_Speaker__c> triggerOld, Map<Id, ZTS_US_Speaker__c> triggerOldMap, List<ZTS_US_Speaker__c> triggerNew, Map<Id, ZTS_US_Speaker__c> triggerNewMap)
    {
        USZTS_US_Class_Expense_Trigger_Helper.updateExpenseRecord(triggerNew); //using this in the Trigger handler
    }
    
    public static void afterInsert(List<ZTS_US_Speaker__c> triggerNew, Map<Id, ZTS_US_Speaker__c> triggerNewMap)
    {
        USZTS_US_Class_Expense_Trigger_Helper.createExpenseRecord(triggerNew);  //using this in the Trigger handler
        USZTS_US_Class_Speaker_Check_Helper.UpdateSpeakerContactIDsOnEvent(triggerNew);
	}
    public static void afterDelete(List<ZTS_US_Speaker__c> triggerOld, Map<Id, ZTS_US_Speaker__c> triggerOldMap)
    {
        USZTS_US_Class_Speaker_Check_Helper.UpdateSpeakerContactIDsOnEvent(triggerOld);                            
    }
}