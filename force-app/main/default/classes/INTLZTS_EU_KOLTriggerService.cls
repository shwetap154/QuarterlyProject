/****************************************************************************************************************************************** 
 * Trigger Name : INTLZTS_EU_KOLTriggerService
 * Description    : 1. Update KOL and Speaker flag on contact whenever a kol is created.
 *                  2. Update Speaker flag on contact whenever a kol is updated.
 *                  3. Check if a contact has KOL records or not.
 * Created By     : Sunil Kumar
 * Created On     : 02/26/2014
 *                                                         
 * Modification Log    :
 * -----------------------------------------------------------------------------------------------------------------------
 * Developer                             Date                   Description
 * ---------                             ----                   -----------
 * Deloitte Constulting/Sunil Kumar     02/26/2014              Created
 * Deloitte Consulting/Ragh             05/14/2014              TA Class modification    
 * Art Smorodin			  				02/11/2020	      		Moved to Service Class
*****************************************************************************************************************************************/
public class INTLZTS_EU_KOLTriggerService 
{      
	public static void afterInsert(List<ZTS_EU_KOL__c> triggerNew, Map<Id, ZTS_EU_KOL__c> triggerNewMap)
    {
    	if(UtilityService.iskolRun()){
	    	ZTS_EU_KOL_UpdateContact kolObj = new ZTS_EU_KOL_UpdateContact();    
	        kolObj.UpdateKOLandSpeakerFlag(triggerNew);
        }	
        UtilityService.setkolRunFalse(); // Recursion check
    }	

    public static void afterUpdate(List<ZTS_EU_KOL__c> triggerOld, Map<Id, ZTS_EU_KOL__c> triggerOldMap, List<ZTS_EU_KOL__c> triggerNew, Map<Id, ZTS_EU_KOL__c> triggerNewMap)
    {	
    	if(UtilityService.iskolRun()){
	    	ZTS_EU_KOL_UpdateContact kolObj = new ZTS_EU_KOL_UpdateContact();    
        	kolObj.UpdateSpeakerFlag(triggerNew);
        }	
        UtilityService.setkolRunFalse(); // Recursion check
    }	

    public static void afterDelete(List<ZTS_EU_KOL__c> triggerOld, Map<Id, ZTS_EU_KOL__c> triggerOldMap)
    {
    	if(UtilityService.iskolRun()){
	    	ZTS_EU_KOL_UpdateContact kolObj = new ZTS_EU_KOL_UpdateContact();
        	kolObj.checkKOLRecordsOnContact(triggerOld);
        }	
        UtilityService.setkolRunFalse(); // Recursion check
    }	

    public static void afterUndelete(List<ZTS_EU_KOL__c> triggerNew, Map<Id, ZTS_EU_KOL__c> triggerNewMap)
    {
    	if(UtilityService.iskolRun()){
	    	ZTS_EU_KOL_UpdateContact kolObj = new ZTS_EU_KOL_UpdateContact();    
         	kolObj.UpdateKOLandSpeakerFlag(triggerNew);
         	kolObj.UpdateSpeakerFlag(triggerNew);
        }	
        UtilityService.setkolRunFalse(); // Recursion check
    }	

}