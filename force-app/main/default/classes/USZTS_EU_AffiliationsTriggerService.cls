/****************************************************************************************************************************************** 
* Class Name   : USZTS_EU_AffiliationsTriggerService
* Description  : Logic for all US ZTS_EU_Affiliations triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 07 May 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     05/07/2020          Created, Logic from all triggers moved to this class.
* Aritra (Cognizant)      01-Apr-2021         Updated the BeforeUpdate part (SC-008471)
* Pooja (Cognizant)       08-May-2023         Make surviving account contact affiliation the Primary affiliation (TPDEV-733)
*****************************************************************************************************************************************/
public with sharing class USZTS_EU_AffiliationsTriggerService 
{
    public static void beforeInsert(List<ZTS_EU_Affiliations__c> triggerNew) 
    {
        //if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_AccountContactAffiliation'))) return;
        ZTS_GL_accUpdateClass oAcc = new ZTS_GL_accUpdateClass();

        oAcc.UpdateAccOnCont(triggerNew, null, null, null, false, true);
       
    }

    public static void afterInsert(List<ZTS_EU_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Affiliations__c> triggerNewMap) 
    {
        //if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_AccountContactAffiliation'))) return;
        ZTS_GL_accUpdateClass oAcc = new ZTS_GL_accUpdateClass();

        if(CheckRecursiveTrigger.runOnce())
        {     
            Set<Id> contIdSet = new Set<Id>();
            for(ZTS_EU_Affiliations__c acaf : triggerNew)
            { 
                contIdSet.add(acaf.ZTS_EU_Contact__c);
            } 
            
            if(contIdSet.size() > 0)
            {
                oAcc.updateContactsStatus(contIdSet);
            }
        }
        
        
    }

    public static void afterUpdate(List<ZTS_EU_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Affiliations__c> triggerOldMap, List<ZTS_EU_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Affiliations__c> triggerNewMap) 
    {
        //if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_AccountContactAffiliation'))) return;
        ZTS_GL_accUpdateClass oAcc = new ZTS_GL_accUpdateClass();

        if(CheckRecursiveTrigger.runOnce())
        {     
            Set<Id> contIdSet = new Set<Id>();
            for(ZTS_EU_Affiliations__c acaf : triggerNew)
            { 
                contIdSet.add(acaf.ZTS_EU_Contact__c);
            } 
            
            if(contIdSet.size() > 0)
            {
                oAcc.updateContactsStatus(contIdSet);
            }
        }
        
    }
    public static void beforeUpdate(List<ZTS_EU_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Affiliations__c> triggerOldMap, List<ZTS_EU_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Affiliations__c> triggerNewMap) 
    {
        //if(!(CustomSettingService.checkIfTriggerActive('ZTS_US_AccountContactAffiliation'))) return;
        ZTS_GL_accUpdateClass oAcc = new ZTS_GL_accUpdateClass();

        if(CheckRecursiveTrigger.updateconaffonce())
        {
            oAcc.UpdateAccOnCont(triggerNew, triggerOld, triggerNewMap, triggerOldMap, true, false);
        }
        //Aritra added this part to update the Affiliation deactivate date field on affiliation record (SC-008471)
        //This part will populate "Contact Affiliation Deactivation Date" on Aff record with current datetime when the record is made Inactive 
        List<Id> contactIdList = new List<Id>();
        for (ZTS_EU_Affiliations__c oAff: Triggernew) {
            System.debug('OLD STATUS: '+triggerOldMap.get(oAff.id).ZTS_EU_Affiliation_Status__c);
            System.debug('NEW STATUS: '+oAff.ZTS_EU_Affiliation_Status__c);
            if (((triggerOldMap.get(oAff.id).ZTS_EU_Affiliation_Status__c) <> (oAff.ZTS_EU_Affiliation_Status__c)) && (oAff.ZTS_EU_Affiliation_Status__c == 'Inactive')) {
                oAff.Contact_Affiliation_Deactivation_Date__c = system.now();
                oAff.Contact_Deactivation_Processed__c = FALSE;
                
                //TPDEV-733 Pooja added To make surviving account contact affiliation the Primary affiliation
                if(oAff.ZTS_EU_Primary_Account__c == TRUE) {
                    contactIdList.add(oAff.ZTS_EU_Contact__c);
                }                
            }
        }
        
        if(!contactIdList.isEmpty()) {
            updatePrimaryContactAffiliation(contactIdList, triggerNew, triggerNewMap);
        }
    }
    
    // Added as a part of TPDEV-733
    public static void afterDelete(List<ZTS_EU_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Affiliations__c> triggerOldMap) 
    {
        List<Id> contactIdList = new List<Id>();
        for (ZTS_EU_Affiliations__c oAff: triggerOld) {
            if ((oAff.ZTS_EU_Affiliation_Status__c == 'Active') && oAff.ZTS_EU_Primary_Account__c == TRUE) {
                contactIdList.add(oAff.ZTS_EU_Contact__c);              
            }
        }
        
        if(!contactIdList.isEmpty()) {
            updatePrimaryContactAffiliation(contactIdList, triggerOld, null);
        }
    }
    
    public static void updatePrimaryContactAffiliation(List<Id>contactIdList, List<ZTS_EU_Affiliations__c> triggerList, Map<Id, ZTS_EU_Affiliations__c> triggerNewMap) 
    {
        List<Id> invalidContactIdList = new List<Id>();
        List<Contact> contactToUpdateList = new List<Contact>();
        
        List<Contact> contactList = [SELECT Id, AccountId, ZTS_US_Account_influence__c, ZTS_US_LE_Contact__c, ZTS_US_Job_Function__c, ZTS_US_UpdateHappeningFromAff__c,
                                     (SELECT Id, ZTS_EU_Account__c, ZTS_EU_Account_influence__c, ZTS_US_LE_Contact__c, ZTS_US_Job_Function__c FROM Accounts_and_Contacts__r WHERE ZTS_EU_Affiliation_Status__c = 'Active')
                                     FROM Contact WHERE Id IN :contactIdList];
        
        for(Contact con : contactList) {
            if(con.Accounts_and_Contacts__r == null || con.Accounts_and_Contacts__r.isEmpty()) {
                continue;
            }
            else if(con.Accounts_and_Contacts__r.size() > 0 &&  con.Accounts_and_Contacts__r.size() <= 2) {
                ZTS_EU_Affiliations__c aca = new ZTS_EU_Affiliations__c();
                if(con.Accounts_and_Contacts__r.size() == 1 || triggerNewMap == null)
                	aca = con.Accounts_and_Contacts__r[0];
                else{
                    aca = triggerNewMap.containsKey(con.Accounts_and_Contacts__r[0].Id) ? con.Accounts_and_Contacts__r[1] : con.Accounts_and_Contacts__r[0];
                }
                con.AccountId = aca.ZTS_EU_Account__c;
                con.ZTS_US_Account_influence__c = aca.ZTS_EU_Account_influence__c;
                con.ZTS_US_LE_Contact__c = aca.ZTS_US_LE_Contact__c;
                con.ZTS_US_Job_Function__c = aca.ZTS_US_Job_Function__c;
                con.ZTS_US_UpdateHappeningFromAff__c = true;
                contactToUpdateList.add(con);
            }
            else {
                invalidContactIdList.add(con.Id);
            }
        }
        
        if(!invalidContactIdList.isEmpty()) {
            for (ZTS_EU_Affiliations__c oAff: triggerList) {
                if(invalidContactIdList.contains(oAff.ZTS_EU_Contact__c)) {
                    oAff.addError('You cannot inactivate this account contact affiliation without clicking "Make Primary" button on one of the other Account Contact Affiliations for this contact');
                }
            }
        }
        
        if(!contactToUpdateList.isEmpty()) {
            //Added below lines to bypass contact duplicate rule during DML on Contact for US (SC-008149)
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] sr = Database.update(contactToUpdateList,dml);
        }
    }
}