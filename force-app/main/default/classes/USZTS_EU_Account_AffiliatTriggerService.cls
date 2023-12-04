/****************************************************************************************************************************************** 
 * Trigger Name : USZTS_EU_Account_AffiliatTriggerService
 * Description  : Trigger on ZTS_EU_Account_Affiliations.
 *              	
 * @date Created:Jan 29, 2014
 * @author:      Ninad
 *                                                         
 * Modification Log    :
 * ---------------------------------------------------------------------------------------------------------------------
 * Developer                             Date                   Description
 * ---------                             ----                   -----------
 * Ninad     				            01//29/2014             Created   
 * Art Smorodin			  				02/13/2020	      		Moved to Service Class
*****************************************************************************************************************************************/



public with sharing class USZTS_EU_Account_AffiliatTriggerService {

    public static void afterInsert(List<ZTS_EU_Account_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Account_Affiliations__c> triggerNewMap){
        if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_Account_Affi_InsertDupliRec'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        ZTS_GL_Affiliation_ReverseRecordCreation forInsert = new ZTS_GL_Affiliation_ReverseRecordCreation();
        forInsert.insertRecord(triggerNew,triggerNewMap);
    }

    public static void afterUpdate(List<ZTS_EU_Account_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Account_Affiliations__c> triggerOldMap, List<ZTS_EU_Account_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Account_Affiliations__c> triggerNewMap){
        if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_Account_Affi_InsertDupliRec'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        ZTS_GL_Affiliation_ReverseRecordCreation forUpdate = new ZTS_GL_Affiliation_ReverseRecordCreation();
        forUpdate.updateAccountRecord(triggerNew, triggerOld,triggerNewMap,triggerOldMap);
    }

    public static void afterDelete(List<ZTS_EU_Account_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Account_Affiliations__c> triggerOldMap){
        if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_Account_Affi_InsertDupliRec'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        ZTS_GL_Affiliation_ReverseRecordCreation forDelete = new ZTS_GL_Affiliation_ReverseRecordCreation();
        //forDelete.DeleteRecord(triggerOld,triggerOldMap,triggerNew);
    }

    public static void afterUndelete(List<ZTS_EU_Account_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Account_Affiliations__c> triggerNewMap){
        if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_Account_Affi_InsertDupliRec'))) return; // by pass trigger logic according to isActive checkbox in custom setting
        ZTS_GL_Affiliation_ReverseRecordCreation forUndelete = new ZTS_GL_Affiliation_ReverseRecordCreation();
        forUndelete.unDeleteAccountRecord(triggerNew);
    }
}