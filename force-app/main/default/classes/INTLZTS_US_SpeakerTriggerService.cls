/****************************************************************************************************************************************** 
 * Trigger Name : INTLZTS_US_SpeakerTriggerService
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
 * CloudSense(Bimba)        03/12/2014          Updated : added the check to bypass trigger
*****************************************************************************************************************************************/
public class INTLZTS_US_SpeakerTriggerService 
{
    public static void beforeDelete(List<ZTS_US_Speaker__c> triggerOld, Map<Id, ZTS_US_Speaker__c> triggerOldMap) 
    {
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();
        Boolean deActFlag;
        ZTS_EU_Deactivation_Custom_Setting__c deactTrgCS = ZTS_EU_Deactivation_Custom_Setting__c.getInstance(currUsrId);
        //Ilirjana 8/12/14 Added null check
        if(deactTrgCS != null){
            deActFlag = deactTrgCS.ZTS_EU_DeactivateTrigger__c;
        }
        
        if(deActFlag){
            return;
        }
        
        List<ID> listSpeakerId = new List<ID>();
        
        for(ZTS_US_Speaker__c speaker: triggerOld){
            listSpeakerId.add(speaker.Id);
        }
        ZTS_US_Class_Expense_Trigger_Helper.deleteSpeakerExpense(listSpeakerId); 
    }

    public static void afterUpdate(List<ZTS_US_Speaker__c> triggerOld, Map<Id, ZTS_US_Speaker__c> triggerOldMap, List<ZTS_US_Speaker__c> triggerNew, Map<Id, ZTS_US_Speaker__c> triggerNewMap)
    {
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();
        Boolean deActFlag;
        ZTS_EU_Deactivation_Custom_Setting__c deactTrgCS = ZTS_EU_Deactivation_Custom_Setting__c.getInstance(currUsrId);
        //Ilirjana 8/12/14 Added null check
        if(deactTrgCS != null){
            deActFlag = deactTrgCS.ZTS_EU_DeactivateTrigger__c;
        }
        
        if(deActFlag){
            return;
        }
        ZTS_US_Class_Expense_Trigger_Helper.updateExpenseRecord(triggerNew);
    }
    
    public static void afterInsert(List<ZTS_US_Speaker__c> triggerNew, Map<Id, ZTS_US_Speaker__c> triggerNewMap)
    {
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();
        Boolean deActFlag;
        ZTS_EU_Deactivation_Custom_Setting__c deactTrgCS = ZTS_EU_Deactivation_Custom_Setting__c.getInstance(currUsrId);
        //Ilirjana 8/12/14 Added null check
        if(deactTrgCS != null){
            deActFlag = deactTrgCS.ZTS_EU_DeactivateTrigger__c;
        }
        
        if(deActFlag){
            return;
        }
        ZTS_US_Class_Expense_Trigger_Helper.createExpenseRecord(triggerNew);   
	}
}