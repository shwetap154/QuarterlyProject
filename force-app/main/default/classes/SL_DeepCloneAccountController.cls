/**
* @ClassName    : SL_DeepCloneAccountController
* @JIRATicket   : LIGHTNI-160
* @CreatedOn    : 15th May 2019
* @CreatedBy    : Premraj K K
* @ModifiedBy   : 
* @Description  : This is the controller for the Lightning button in a detail page of an Account record.
				  On click of button, clones the Account record and either clone/re-parent few related records.
				  Related Records:
					- Contacts - Re-parent
					- Account Contact Affilliations (ZTS_EU_Affiliations__c) - Clone and Reparent
					- Account Species Potential (Animals) - Clone and Re-parent
					- Address Record - Clone and Reparent
					- Account Positions - Clone and Reparent
*/
public without sharing class SL_DeepCloneAccountController {

    @AuraEnabled
    public static String deepCloneAccountAndRelatedRecords(Id accountId) {
        
        Account account = [Select ZTS_EU_Market__c, Name
                           From Account
                           Where Id =: accountId
                           AND ZTS_EU_Market__c != 'United States'];

        
        /*List<User> lstUsers = [Select Id, Name
                               From User
                               Where IsActive = true 
                               AND Profile.Name Like '%Business Admin%'
                               AND ZTS_EU_Market__c = :account.ZTS_EU_Market__c];
        
        if(lstUsers.isEmpty() || String.isBlank(account.ZTS_EU_Market__c))
            return null;*/
        
        try {
            //Cloning existing Account to a new record
            Account newAccount = ((List<Account>)cloneRecords(new List<Id> { accountId }, 
                                                              new map<String, String>{'ZTS_EU_Primary_Address__c' => null,
                                                                  'Name' => (account.Name + ' - CLONED')} ))[0];
            //Inactivating existing Account record
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update new Account(Id = accountId, ZTS_EU_Account_Status__c = 'Inactive', ZTS_EU_Reason__c = 'Inactive', ZTS_EU_Cloned__c = false);
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            /*Reparenting all the related Contact Records to new Account*/
            List<Contact> lstContactsToReparent = new List<Contact>();
            for(Contact c : [Select Id, AccountId
                             From Contact
                             Where AccountId =: accountId]) {
                c.AccountId = newAccount.Id;
                lstContactsToReparent.add(c);
            }
            
            if(! lstContactsToReparent.isEmpty())
                update lstContactsToReparent;
            
            /*Cloning and reparenting all the related Account Contact Affiliation Records to new Account*/        
            List<Id> lstAccountContAffiliationsToClone = new List<Id>();
            for(ZTS_EU_Affiliations__c a : [Select Id
                                            From ZTS_EU_Affiliations__c
                                            Where ZTS_EU_Account__c =: accountId AND ZTS_EU_Market_from_Parent__c != 'United States']) {
                lstAccountContAffiliationsToClone.add(a.Id);
            }
            
            cloneRecords(lstAccountContAffiliationsToClone, 
                         new map<String, String>{'ZTS_EU_Account__c' => newAccount.Id}
                        );
            
            
            /*Cloning and Reparenting all the related Account_Species_Potential (Animal) Records to new Account*/
            List<Id> lstAccountSpeciesToClone = new List<Id>();
            for(ZTS_EU_Account_Species_Potential__c a : [Select Id
                                                         From ZTS_EU_Account_Species_Potential__c
                                                         Where Account__c =: accountId]) {
                lstAccountSpeciesToClone.add(a.Id);
            }
            
            cloneRecords(lstAccountSpeciesToClone, 
                         new map<String, String>{'Account__c' => newAccount.Id}
                        );
            
            
            /*Cloning and reparenting all the Address records to new Account*/
            List<Id> lstAddressIdsToClone = new List<Id>();
            for(Address__c a : [Select Id
                                From Address__c
                                Where ZTS_EU_Account__c =: accountId AND ZTS_EU_Market_from_Parent__c != 'United States']) {
                lstAddressIdsToClone.add(a.Id);
            }
            
            cloneRecords(lstAddressIdsToClone, 
                         new map<String, String>{'ZTS_EU_Account__c' => newAccount.Id}
                        );
            
            // marking account position active and bring offline field as false for LIGHTNI-1561
            SL_AccountPositionManager.markAccountPositionInactive(new List<Id> { accountId });

            /*Cloning and reparenting all the Account_Position to new Account*/
            List<Id> lstAccountPositionIdsToClone = new List<Id>();
            for(ZTS_EU_Account_Position__c ap : [Select Id
                                                 From ZTS_EU_Account_Position__c
                                                 Where ZTS_EU_Account__c =: accountId
                                                 AND ZTS_EU_Market__c != 'United States']) {
                lstAccountPositionIdsToClone.add(ap.Id);
            }
        
            cloneRecords(lstAccountPositionIdsToClone,
                         new map<String, String>{'ZTS_EU_Account__c' => newAccount.Id}
                        );
            
            //Inactivating existing Account record
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update new Account(Id = accountId, ZTS_EU_Account_Status__c = 'Inactive', ZTS_EU_Reason__c = 'Inactive', ZTS_EU_Cloned__c = false);
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            return newAccount.Id;
        }
        catch(Exception e) {
            System.assert(false, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static List<SObject> cloneRecords(List<Id> lstRecordIds, map<String, String> mapNewFieldValues) {
        
        if(lstRecordIds.isEmpty())
            return null;
        List<SObject> lstClonedRecords = new List<SObject>();
        String sobjName = lstRecordIds[0].getSObjectType().getDescribe().getName();
        List<String> sObjectFields = fetchAllFields(sobjName);
        String strQuery = 'SELECT ' + String.join(sObjectFields, ',') +
            ' FROM ' + sobjName + ' WHERE Id IN :lstRecordIds';
        
        system.debug('Query::'+strQuery);
        for(SObject o : Database.query(strQuery)) {
            SObject clonedRecord = o.clone(false, true, false, false);
            for(String fieldName : mapNewFieldValues.keyset())
                clonedRecord.put(fieldName, mapNewFieldValues.get(fieldName));
            
            lstClonedRecords.add(clonedRecord);
        }
        try
        {
            if(! lstClonedRecords.isEmpty())
            {
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true; 
                List<Database.SaveResult> srs = Database.insert(lstClonedRecords, dml); 
            }
        }
        catch(Exception ex)
        {
            System.assert(false, ex.getMessage());
        }
        return lstClonedRecords;
    }
    
    private static List<String> fetchAllFields(String sObjectName) {
        set<String> setFields = new set<String>();
        map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        for(Schema.SObjectField sField : fieldMap.values()) {
            Schema.describefieldresult descField = sField.getDescribe();
            if(! descField.isUnique())
                setFields.add(descField.getName());
        }
        return new List<String>(setFields);
    }
    
    
    /*Reparenting all the related Contact Records to new Account*/
    @future
    @TestVisible private static void reparentContacts(Id oldAccountId, Id accountId) {
        List<Contact> lstContactsToReparent = new List<Contact>();
        for(Contact c : [Select Id, AccountId
                         From Contact
                         Where AccountId =: oldAccountId
                         AND ZTS_EU_Market__c != 'United States']) {
                             c.AccountId = accountId;
                             lstContactsToReparent.add(c);
                         }
        
        if(! lstContactsToReparent.isEmpty())
            update lstContactsToReparent;
    }
    
    /*Cloning and Reparenting all the related Account-Contact Affilliation Records to new Account*/
    @future
    @TestVisible private static void cloneAndReparentAccntContAffilliations(Id oldAccountId, Id accountId) {
        List<Id> lstAccountContAffiliationsToClone = new List<Id>();
        for(ZTS_EU_Affiliations__c a : [Select Id
                                        From ZTS_EU_Affiliations__c
                                        Where ZTS_EU_Account__c =: oldAccountId AND ZTS_EU_Market_from_Parent__c != 'United States']) {
                                            lstAccountContAffiliationsToClone.add(a.Id);
                                        }
        
        cloneRecords(lstAccountContAffiliationsToClone, 
                     new map<String, String>{'ZTS_EU_Account__c' => accountId}
                    );
    }
    
    /*Cloning and Reparenting all the related Account_Species_Potential (Animal) Records to new Account*/
    @future
    @TestVisible private static void cloneAndReparentAccntSpeciesPotential(Id oldAccountId, Id accountId) {
        List<Id> lstAccountSpeciesToClone = new List<Id>();
        for(ZTS_EU_Account_Species_Potential__c a : [Select Id
                                                     From ZTS_EU_Account_Species_Potential__c
                                                     Where Account__c =: oldAccountId]) {
                                                         lstAccountSpeciesToClone.add(a.Id);
                                                     }
        
        cloneRecords(lstAccountSpeciesToClone, 
                     new map<String, String>{'Account__c' => accountId}
                    );
    }
    
    /*Cloning and reparenting all the Address records to new Account*/
    @future
    @TestVisible private static void cloneAndReparentAddress(Id oldAccountId, Id accountId) {
        List<Id> lstAddressIdsToClone = new List<Id>();
        for(Address__c a : [Select Id
                            From Address__c
                            Where ZTS_EU_Account__c =: oldAccountId]) {
                                lstAddressIdsToClone.add(a.Id);
                            }
        
        cloneRecords(lstAddressIdsToClone, 
                     new map<String, String>{'ZTS_EU_Account__c' => accountId}
                    );
    }
    
    /*Cloning and reparenting all the Account_Position to new Account*/
    @future
    @TestVisible private static void cloneAndReparentAccountPosition(Id oldAccountId, Id accountId) {
        
        List<Id> lstAccountPositionIdsToClone = new List<Id>();
        for(ZTS_EU_Account_Position__c ap : [Select Id
                                             From ZTS_EU_Account_Position__c
                                             Where ZTS_EU_Account__c =: oldAccountId
                                               AND ZTS_EU_Market__c != 'United States']) {
                                                 lstAccountPositionIdsToClone.add(ap.Id);
                                             }
        
        cloneRecords(lstAccountPositionIdsToClone,
                     new map<String, String>{'ZTS_EU_Account__c' => accountId}
                    );
    }
}