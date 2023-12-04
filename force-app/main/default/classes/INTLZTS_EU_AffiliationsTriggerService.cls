/****************************************************************************************************************************************** 
* Class Name   : INTLZTS_EU_AffiliationTriggerService
* Description  : Logic for all INTL ZTS_EU_Affiliations triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 07 May 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     05/07/2020          Created, Logic from all triggers moved to this class.
* Aritra (Cognizant)      01-Apr-2021         Updated the BeforeUpdate part (SC-008471)
*****************************************************************************************************************************************/
public with sharing class INTLZTS_EU_AffiliationsTriggerService 
{
    
    public static void afterInsert(List<ZTS_EU_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Affiliations__c> triggerNewMap) 
    {  
        ZTS_EU_UpdateSpeciesSpeciality.UpdateSpeciesSpeciality(triggerNew);
       
    }

    public static void beforeDelete(List<ZTS_EU_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Affiliations__c> triggerOldMap) 
    {
        for(ZTS_EU_Affiliations__c triggerAff : triggerOld)
        {
            if(triggerAff.ZTS_EU_Primary_Contact__c && triggerAff.ZTS_EU_Contact_Active_Status__c)
            {
                triggerAff.addError('<b>The Affiliation for Active Primary Contact of the Account cannot be deleted. Please change the primary contact of the account before deleting this affiliation record. </b>', false);
            }
        }
    }
    public static void beforeUpdate(List<ZTS_EU_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Affiliations__c> triggerOldMap, List<ZTS_EU_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Affiliations__c> triggerNewMap) 
    {
        ZTS_EU_accUpdateClass oAcc=new ZTS_EU_accUpdateClass();
        oAcc.UpdateAccOnCont(triggerNew, triggerOldMap, true, false);
        //Aritra added this part to update the Affiliation deactivate date field on affiliation record (SC-008471)
        //This part will populate "Contact Affiliation Deactivation Date" on Aff record with current datetime when the record is made Inactive 
        for (ZTS_EU_Affiliations__c oAff: Triggernew) {
            if (((triggerOldMap.get(oAff.id).ZTS_EU_Affiliation_Status__c) <> (oAff.ZTS_EU_Affiliation_Status__c)) && (oAff.ZTS_EU_Affiliation_Status__c == 'Inactive')) {
                oAff.Contact_Affiliation_Deactivation_Date__c = system.now();
                oAff.Contact_Deactivation_Processed__c = FALSE;
            }
        }
        
    }
    
}