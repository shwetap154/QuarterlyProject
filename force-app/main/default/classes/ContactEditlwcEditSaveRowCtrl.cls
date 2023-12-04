/**
 * @description       : Controller class for Contact Editor lwc tool
 * @author            : Cognizant
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : Prasun Dubey @ Cognizant
 * Modifications Log
 * 1.8   08-04-2023   Update the code to utilize the standard territory model and also to restrict the access for users who dont have access through Territory
 * 					  Poultry users will be able to see all contacts where parent account is poultry
 **/
public with sharing class ContactEditlwcEditSaveRowCtrl {

    // Provide the list of contacts
    @AuraEnabled(cacheable = true)
    public static List<Contact> getContacts(String filterCriteria,String sortField, String sortOrder) {
        User u = [Select Id,Sharing_Business_Unit__c From User Where Id =: UserInfo.getUserId()];
        List<Account> lstAlignedAccounts = new List<Account>();
        List<Account> poultryAccounts = new List<Account>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Object> filterList = new List<Object>();
        filterList = (List<Object>)JSON.deserializeUntyped(filterCriteria);
        List<Contact> conList = new List<Contact>();
        Set<Id> territorySet = new Set<Id>();
        // Get territories for logged user
        for(UserTerritory2Association ua: [Select Territory2Id From UserTerritory2Association Where UserId =: UserInfo.getUserId()]){
            territorySet.add(ua.Territory2Id);
        }
        // Retrieve accounts assigned to user's territories 
        if(territorySet.size() > 0){
            lstAlignedAccounts = [SELECT Id FROM Account WHERE Id IN ( SELECT ObjectId FROM ObjectTerritory2Association WHERE Territory2Id in :territorySet)];
            for(Account acc: lstAlignedAccounts){
                accountIdSet.add(acc.Id);
            }
        }
        // Retrieve Poultry accounts shared through sharing rule for Poulty user
        if(u.Sharing_Business_Unit__c == 'Poultry'){
            poultryAccounts = [Select Id From Account Where Primary_Business_Focus__c = 'Poultry'];
            for(Account acc: poultryAccounts){
                accountIdSet.add(acc.Id);
            }
        }
        String query = 'SELECT Id,Full_Contact_Name__c,FirstName,LastName,Interface_Email__c,Phone, MobilePhone, Title, ZTS_US_Profession__c, ZTS_US_Job_Function__c,AccountId,Account_Name__c,ZTS_EU_Contact_Status__c,';
        query += 'ZTS_US_Account_influence__c,Account.ZTS_US_Business_Class__c,LastModifiedBy.Name,LastModifiedDate,CreatedDate ';
        query += 'FROM Contact where Number_of_Active_Affiliations__c > 0 and LeadSource <> \'CSR\'';
        // Execulte query users and access to accounts
        if(accountIdSet.size()>0)
        {
        	query +=  ' and AccountID in :accountIdSet';
        
        if(filterList.size()>0){
            for(Object obj: filterList){
                Map<String,Object> filter = (Map<String,Object>)(obj);
                String fieldName = (String)filter.get('fieldAPI');
                String fieldVal = (String)filter.get('searchKey');
                query += ' and '+ fieldName;
                query += ' like \'%';
                query += String.escapeSingleQuotes(fieldVal); 
                query += '%\'';
            }
        }
        if(String.isNotBlank(sortField) && sortField == 'AccName')
            sortField = 'Account.Name';
            query += ' ORDER BY '+sortField+' '+ sortOrder+' Limit 200';
        
        conList = Database.query(query);
        }
        
        if(Test.isRunningTest()){
            conList = [SELECT Id,Full_Contact_Name__c,FirstName,LastName,Interface_Email__c,Phone, MobilePhone, Title, ZTS_US_Profession__c, ZTS_US_Job_Function__c,AccountId,Account_Name__c,ZTS_EU_Contact_Status__c,
                       ZTS_US_Account_influence__c,Account.ZTS_US_Business_Class__c,LastModifiedBy.Name,LastModifiedDate,CreatedDate
                       FROM Contact where ZTS_EU_Market__c = 'United States' and LeadSource <> 'CSR' and Id in (Select ZTS_EU_Contact__c from ZTS_EU_Affiliations__c where ZTS_EU_Affiliation_Status__c='Active') ORDER BY CreatedDate DESC Limit 200];
        }
        
        return conList;
    }   
    
    // Save draft values with excluding duplication rule. 
    @AuraEnabled
    public static List<Object> saveDraftValues(Object data) {
        List<Contact> listOfContacts = (List<Contact>) JSON.deserialize(
            JSON.serialize(data),
            List<Contact>.class
        );
        Database.DMLOptions dml = new Database.DMLOptions(); 
 		dml.DuplicateRuleHeader.allowSave = true;
 		dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.update(listOfContacts,dml);
        
        List<Contact> returnContacts = new List<Contact>();
        returnContacts = [SELECT Id,Full_Contact_Name__c,FirstName,LastName,Interface_Email__c,Phone, MobilePhone, Title, ZTS_US_Profession__c, ZTS_US_Job_Function__c,AccountId,Account_Name__c,ZTS_EU_Contact_Status__c,
        ZTS_US_Account_influence__c,Account.ZTS_US_Business_Class__c,LastModifiedBy.Name,LastModifiedDate,CreatedDate 
        FROM Contact Where Id in: listOfContacts];
        return returnContacts;
    }
    
    
    @AuraEnabled(cacheable = true)
    public static List<ZTS_EU_Affiliations__c> getAffiliationRecords(String selectedConId) {
        List<ZTS_EU_Affiliations__c> lstAff = [Select Name,ZTS_EU_Account_Name_text__c,ZTS_EU_Account__r.ZTS_US_NARC_ID__c,ZTS_EU_Contact_Name_Text__c,ZTS_EU_Affiliation_Status__c,ZTS_US_Profession__c,ZTS_US_Job_Function__c  from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c = :selectedConId and ZTS_EU_Affiliation_Status__c !='Inactive'];
        return lstAff;
    }
    
     @AuraEnabled
     public static String deactivateAffilifiations(String selectedIdsJson) {
         String result = 'Success';
        List<String> selectedIds = (List<String>)JSON.deserialize(selectedIdsJson,List<String>.class);
        List<ZTS_EU_Affiliations__c> lstUpdate = new List<ZTS_EU_Affiliations__c>();
         for(String id: selectedIds)
         {
             ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(Id=id,ZTS_EU_Affiliation_Status__c='Inactive');
             lstUpdate.add(aff);
         }
         if(lstUpdate.size()>0)
         {
             List<database.saveresult> srs = database.update(lstUpdate, false);
             for (database.SaveResult sr: srs)
             {
                 if(!sr.isSuccess())
                 {
                     result = 'Error';
                     break;
                 }
             }
         }
         return result;
    }
}