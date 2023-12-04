/****************************************************************************************************************************************** 
* Class Name   : ZTS_DeactiveContOnAffltnDeactivation
* Description  : This batch job is used to deactivate associated Contacts if an affiliation's "Contact Affiliation Deactivated Date" is more than 24 hours old.
               : This job will be scheduled
* Created By   : Aritra(Cognizant)
* Created Date : 01-Apr-2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra (Cognizant)      01-Apr-2021      Created this class (SC-008471)
*****************************************************************************************************************************************/
global class ZTS_DeactiveContOnAffltnDeactivation implements Database.Batchable<sObject>  {
    global Database.queryLocator start(Database.BatchableContext BC){
        datetime myDateTime = datetime.now().addHours(-24);
        system.debug('Inside batch class'+myDateTime);
            return Database.getQueryLocator([Select Id,ZTS_EU_Contact__c,ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c,Contact_Affiliation_Deactivation_Date__c
                         from ZTS_EU_Affiliations__c where Contact_Affiliation_Deactivation_Date__c<:myDateTime and Contact_Deactivation_Processed__c = FALSE]);
    }
    global void execute(Database.BatchableContext BC, List<ZTS_EU_Affiliations__c> affList){
        List<Contact> contactUpdateLst = new List<Contact>();
        List<ZTS_EU_Affiliations__c> affltnUpdateLst = new List<ZTS_EU_Affiliations__c>();
 		Set <Id> setConIds = new Set <Id> ();
        Map <Id,List<Id>> mapConIdtoAffId = new Map <Id,List<Id>>();
        //This part will create ContactId-To-AffiliationId map for all fetched Affiliations
        for(ZTS_EU_Affiliations__c af: affList)
        {
             	setConIds.add(af.ZTS_EU_Contact__c);
                if(!mapConIdtoAffId.containsKey(af.ZTS_EU_Contact__c))
                {
                    mapConIdtoAffId.put(af.ZTS_EU_Contact__c, new List<Id>{af.Id});
                }
                else{
                    mapConIdtoAffId.get(af.ZTS_EU_Contact__c).add(af.Id);
                }
        }
        //This query will check if the Aff's contact currently has any Active affiliation
        List< ZTS_EU_Affiliations__c> lstActiveAff = [Select Id,ZTS_EU_Contact__c from ZTS_EU_Affiliations__c 
                                                    where ZTS_EU_Contact__c in :setConIds  
                                                    and ZTS_EU_Affiliation_Status__c = 'Active'];
        //If aff's contact has active affiliation in an Exclusion contact set
        if (lstActiveAff.size()>0)
        {
            Set <Id> setExcludeContact = new Set <Id>();
            for(ZTS_EU_Affiliations__c aff: lstActiveAff)
            {
                setExcludeContact.add(aff.ZTS_EU_Contact__c);
            }
            //Update the other contacts which are not present in the set
            for(Id i: mapConIdtoAffId.keyset()) 
            {
                //If the contact is not present in the exclusion Contact set(i.e. contact has no Active Affs), then deactivate the contact
                //And mark the "Contact_Deactivation_Processed__c" flag on Aff record as TRUE, so that it is not fetched in next job run
                if(!setExcludeContact.contains(i))
                {
                    contactUpdateLst.add(new Contact (Id = i,ZTS_EU_Contact_Status__c = 'Inactive',ZTS_EU_Rep_Contact_Status__c= 'Inactive',
                                                      ZTS_EU_Reason_for_Inactivation__c  = 'No Longer in Practice'));
                    
                    for(Id j: mapConIdtoAffId.get(i)){
                        affltnUpdateLst.add(new ZTS_EU_Affiliations__c(Id = j, Contact_Deactivation_Processed__c = TRUE));
                    }
                }
                
                //If the contact is present in the exclusion set (i.e. Contact has active affiliation currently) then do nothing on contact
                //and mark the affiliation record "Processed" flag as TRUE,
                else
                {
                    for(Id index : mapConIdtoAffId.get(i))
                    {
                        affltnUpdateLst.add(new ZTS_EU_Affiliations__c (Id = index,Contact_Deactivation_Processed__c= TRUE));
                    }
                }
            }
        }
        //If all aff's contacts don't have any active affiliation then mark associated contacts inactive
        //And also mark all the affiliation record's "Processed" flag as TRUE,
        else
        {
            for (Id index2 : setConIds)
            {
                contactUpdateLst.add(new Contact (Id = index2,ZTS_EU_Contact_Status__c = 'Inactive',ZTS_EU_Rep_Contact_Status__c= 'Inactive',
                                                      ZTS_EU_Reason_for_Inactivation__c  = 'No Longer in Practice'));
            }
            for(ZTS_EU_Affiliations__c affRecord: affList){
                affRecord.Contact_Deactivation_Processed__c = TRUE;
                affltnUpdateLst.add(affRecord);
            }
        }
        
        
        // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 		Database.DMLOptions dml = new Database.DMLOptions(); 
 		dml.DuplicateRuleHeader.allowSave = true;
 		dml.DuplicateRuleHeader.runAsCurrentUser = true;
        dml.OptAllOrNone = false;
 		List <Database.Saveresult> SaveResultList = Database.update(contactUpdateLst,dml);
        //List <Database.Saveresult> SaveResultList = Database.update(contactUpdateLst,false);-- commented for SC-008149
        List <Database.Saveresult> SaveResultList2 = Database.update(affltnUpdateLst,false);
        ErrorLogUtil.handleSaveResults('ZTS_DeactiveContOnAffltnDeactivation: Failed to deactivate contacts', SaveResultList);
        ErrorLogUtil.handleSaveResults('ZTS_DeactiveContOnAffltnDeactivation: Failed to update deactivate date on affiliations', SaveResultList2);
       
    }
     global void finish(Database.BatchableContext BC){    
    }
}