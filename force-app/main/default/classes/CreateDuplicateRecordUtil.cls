/*************************************************************************************
* Name          :    CreateDuplicateRecordUtil.
* Description   :    This is a utility class which will allow duplicate record creation (SC-008149)
* Author        :    Aritra Chakraborty
 
Modification Log
----------------
Date             Developer              Comments
---------------------------------------------------------------------------------------
April,2022      Aritra Chakraborty      Created
April,2023 		Prasun Dubey			TPDEV-320 Modified the code to handle duplicate contact selection according to new duplicate rule (FirstName+LastName+Colleague Entered Email)
**************************************************************************************/
public with sharing class CreateDuplicateRecordUtil {
    
    @AuraEnabled 
    public static String createDuplicateRecord(String sObjectRecord, String objectName){
        String returnVal = 'ERROR';
        SObject recToInsert;
        switch on objectName {
            when 'Contact'
            {
                recToInsert= (Contact)JSON.deserialize(sObjectRecord, Contact.class);
            }
            when 'Call__c'
            {
                recToInsert= (Call__c)JSON.deserialize(sObjectRecord, Call__c.class);
            }
        }
        Database.saveResult sr2;
        Database.DMLOptions dml =  new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        try{
            sr2 = Database.insert(recToInsert, dml);
            
        }
        catch (Exception ex) {
          System.debug('Error Message '+ ex.getMessage()); 
            ex.setMessage('Exception occurred');
          throw new AuraHandledException(ex.getMessage());
            
        }
        if(sr2.isSuccess())
        {
            returnVal = recToInsert.Id;
        }
        return returnVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getDupContactDetails(String selectedIdsJson) {
        List<String> selectedIds = (List<String>)JSON.deserialize(selectedIdsJson,List<String>.class);
        List<Contact> lstCon = [Select Id, Name, Account_Name__c, Full_Contact_Name__c, Interface_Email__c, Phone,ZTS_US_Profession__c,ZTS_US_Job_Function__c,ZTS_EU_Contact_Status__c from Contact where id in :selectedIds];
        return lstCon;
    }
    
    // TPDEV-320 added method to create affiliation if one is not already exist
    @AuraEnabled
    public static void createAffiliation(Id contactId,Id accountId) {
        Contact createdContact = [SELECT Id, 
                                        Name,
                                        ZTS_US_Profession__c,
                                        ZTS_US_Job_Function__c,
                                        ZTS_US_Account_influence__c,
                                        Title,
                                        MailingCity,
                                        MailingState,
                                        Account.Name,
                                        AccountId,
                                        OwnerId,
                                        Account_Name__c
                                        FROM Contact 
                                        WHERE Id = :contactId limit 1];
        
        ZTS_EU_Affiliations__c affiliation = new ZTS_EU_Affiliations__c();
        List<ZTS_EU_Affiliations__c> existingAffiliation = [SELECT Id
                                                            FROM ZTS_EU_Affiliations__c 
                                                            WHERE ZTS_EU_Account__c = :accountId
                                                            AND ZTS_EU_Contact__c = :createdContact.Id];
        if(existingAffiliation.size() > 0) {
            affiliation = existingAffiliation[0];
            affiliation.ZTS_US_Profession__c = createdContact.ZTS_US_Profession__c; 
            affiliation.ZTS_EU_Job_Function__c = createdContact.ZTS_US_Job_Function__c; 
            affiliation.ZTS_EU_Account_influence__c = createdContact.ZTS_US_Account_influence__c; 
            affiliation.ZTS_US_Job_Function__c = createdContact.ZTS_US_Job_Function__c; 
        }
        else {
            affiliation.ZTS_EU_Account__c = accountId;
            affiliation.ZTS_EU_Contact__c = createdContact.Id;
            affiliation.ZTS_US_Profession__c = createdContact.ZTS_US_Profession__c; 
            affiliation.ZTS_EU_Job_Function__c = createdContact.ZTS_US_Job_Function__c; 
            affiliation.ZTS_EU_Account_influence__c = createdContact.ZTS_US_Account_influence__c; 
            affiliation.ZTS_US_Job_Function__c = createdContact.ZTS_US_Job_Function__c; 
        }
        
        try {
            upsert affiliation;
        }
        catch(DmlException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        
    }

    @AuraEnabled
    public static List<Contact> checkDuplicateRecords(Contact contactRecord){
        boolean hasDuplicateResult = false;
        List<sObject> duplicateRecords; 
        
        Database.SaveResult saveResult = Database.insert(contactRecord, false);
        
        if (!saveResult.isSuccess()) {
            for (Database.Error error : saveResult.getErrors()){ 
                if (error instanceof Database.DuplicateError) {
                    Database.DuplicateError duplicateError = 
                        (Database.DuplicateError)error;
                    Datacloud.DuplicateResult duplicateResult = 
                        duplicateError.getDuplicateResult();
                    
                    // Get duplicate records
                    duplicateRecords = new List<sObject>();
                    
                    //  find duplicate records
                    Datacloud.MatchResult[] matchResults = 
                        duplicateResult.getMatchResults();
                    
                    Datacloud.MatchResult matchResult = matchResults[0];
                    
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    
                    // Add matched record to the duplicate records variable
                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        duplicateRecords.add(matchRecord.getRecord());
                    }
                    hasDuplicateResult = !duplicateRecords.isEmpty();
                }
            }
        }
        
        if(hasDuplicateResult){
            Set<Id> contactIds = new Set<Id>();
            List<Contact> duplicateContacts = new List<Contact>();
            List<List<Contact>> returnWrapper = new List<List<Contact>>();
            for(Object dupContact :duplicateRecords ){
                contactIds.add(((Contact)dupContact).Id);
            }
            return getDupContactDetails(JSON.serialize(contactIds));
        }else{
            return null; 
        }
    }
}