/****************************************************************************************************************************************** 
 * Trigger Name : USZTS_EU_KOLTriggerService
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
public class USZTS_EU_KOLTriggerService 
{      
	public static void beforeInsert(List<ZTS_EU_KOL__c> triggerNew)
    {
    	//if(!(CustomSettingService.checkIfTriggerActive('ZTS_KOL'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        List<ZTS_EU_KOL__c> kolWithProd=new List<ZTS_EU_KOL__c>();
        Set<Id> prodIds=new Set<Id>();
        for(ZTS_EU_KOL__c kol:triggerNew){
            /** Product set override Therapeutic_Class with _Product_Therapeutic_Class formula value**/
            System.debug('## '+kol.name + ': '+kol.ZTS_US_Product_Therapeutic_Class__c);
            if(kol.ZTS_US_Product__c!=null && kol.ZTS_US_Therapeutic_Class__c!=kol.ZTS_US_Product_Therapeutic_Class__c){
                kol.ZTS_US_Therapeutic_Class__c=kol.ZTS_US_Product_Therapeutic_Class__c;
            }
        }
    }

	public static void beforeUpdate(List<ZTS_EU_KOL__c> triggerOld, Map<Id, ZTS_EU_KOL__c> triggerOldMap, List<ZTS_EU_KOL__c> triggerNew, Map<Id, ZTS_EU_KOL__c> triggerNewMap)
    {
    	//if(!(CustomSettingService.checkIfTriggerActive('ZTS_KOL'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        List<ZTS_EU_KOL__c> kolWithProd=new List<ZTS_EU_KOL__c>();
        Set<Id> prodIds=new Set<Id>();
        for(ZTS_EU_KOL__c kol:triggerNew){
            /** Product set override Therapeutic_Class with _Product_Therapeutic_Class formula value**/
            System.debug('## '+kol.name + ': '+kol.ZTS_US_Product_Therapeutic_Class__c);
            if(kol.ZTS_US_Product__c!=null && kol.ZTS_US_Therapeutic_Class__c!=kol.ZTS_US_Product_Therapeutic_Class__c){
                kol.ZTS_US_Therapeutic_Class__c=kol.ZTS_US_Product_Therapeutic_Class__c;
            }
        }
    }

    public static void afterInsert(List<ZTS_EU_KOL__c> triggerNew, Map<Id, ZTS_EU_KOL__c> triggerNewMap)
    {
    	//if(!(CustomSettingService.checkIfTriggerActive('ZTS_KOL'))) return; // by pass trigger logic according to isActive checkbox in custom setting
    	if(UtilityService.iskolRun()){ // Recursion check
    		ZTS_US_KOL_UpdateContact kolObj = new ZTS_US_KOL_UpdateContact();    
        	kolObj.UpdateKOLandSpeakerFlag(triggerNew);
    	}
    	UtilityService.setkolRunFalse(); // Recursion check
    }

    public static void afterUpdate(List<ZTS_EU_KOL__c> triggerOld, Map<Id, ZTS_EU_KOL__c> triggerOldMap, List<ZTS_EU_KOL__c> triggerNew, Map<Id, ZTS_EU_KOL__c> triggerNewMap)
    {
    	//if(!(CustomSettingService.checkIfTriggerActive('ZTS_KOL'))) return; // by pass trigger logic according to isActive checkbox in custom setting
    	if(UtilityService.iskolRun()){ // Recursion check
    		ZTS_US_KOL_UpdateContact kolObj = new ZTS_US_KOL_UpdateContact();    
        	kolObj.KOLUpdates(triggerNew);
    	}
    	UtilityService.setkolRunFalse(); // Recursion check
    }

    public static void afterDelete(List<ZTS_EU_KOL__c> triggerOld, Map<Id, ZTS_EU_KOL__c> triggerOldMap)
    {
    	//if(!(CustomSettingService.checkIfTriggerActive('ZTS_KOL'))) return; // by pass trigger logic according to isActive checkbox in custom setting
    	if(UtilityService.iskolRun()){ // Recursion check
    		ZTS_US_KOL_UpdateContact kolObj = new ZTS_US_KOL_UpdateContact();
         	kolObj.KOLUpdates(triggerOld);
    	}
    	UtilityService.setkolRunFalse(); // Recursion check
    }

    public static void afterUndelete(List<ZTS_EU_KOL__c> triggerNew, Map<Id, ZTS_EU_KOL__c> triggerNewMap)
    {
    	//if(!(CustomSettingService.checkIfTriggerActive('ZTS_KOL'))) return; // by pass trigger logic according to isActive checkbox in custom setting
    	if(UtilityService.iskolRun()){ // Recursion check
			ZTS_US_KOL_UpdateContact kolObj = new ZTS_US_KOL_UpdateContact();    
         	kolObj.KOLUpdates(triggerNew);
    	}
    	UtilityService.setkolRunFalse(); // Recursion check
    }

}