/**
* @description       : Main Query class for Contact
* @author            : Ethan Hirsch @ Zoetis Inc
* @group             : 
* @last modified on  : 04-18-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   03-17-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
* 1.1   05-03-2022   Ethan Hirsch @ Zoetis Inc   Add selectById Method
* 1.2   08-24-2022   Chelsea Paice @ Zoetis Inc  Added RecordTypeId to field list in getSObjectFieldList
* 1.3   01-24-2023   Padma Nerella @zoetis Inc   Added selectContactsToUpdateEmail method to conatcts from associated account
* 1.4   04-11-2023   Padma Nerella @ Zoetis Inc  Added selectInternationalContactsByIdwithAffiliations to get contacts from associated AccountContact Affiliations
* 1.5   10-31-2023   Dephney Dsouza              Added getContactsByCaseId to get contacts from account associated to case- TPDEV-661
**/
public inherited sharing class ContactSelector extends fflib_SObjectSelector implements IContactSelector {
    public static IContactSelector newInstance() {
        return (IContactSelector)Application.Selector.newInstance(
            Contact.SObjectType
        );
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Contact.Id,
                Contact.Email,
                Contact.AccountId,
                Contact.RecordTypeId
                };
                    }
    
    public Schema.SObjectType getSObjectType() {
        return Contact.sObjectType;
    }
    
    public List<Contact> selectPetOwnerContactsById(List<Id> contactIds) {
        return (List<Contact>)Database.query(
            newQueryFactory().
            selectField(Contact.ZTS_US_Atlas_Id__c).
            setCondition('Id in: contactIds').
            toSOQL()
        );
    }
    
    public List<Contact> selectById(Set<Id> ids) {
        return selectSObjectsById(ids);
    }
    
    
    public List<Contact> selectContactsToUpdateEmail(List<Account> accountIds) {
        List<Contact> contactList = new List<Contact>();
        Id accountContactId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId();
        
        contactList = [Select Id, Name,Interface_Email__c, Interface_Email_Opt_Out__c,ZTS_Invalid_Email__c,AccountId from Contact where AccountId IN : accountIds AND ZTS_EU_Contact_Status__c = 'Active' AND
                       ((ZTS_EU_Profession__c = 'Account Contact') OR (ZTS_Job_Function__c = 'Account Contact') OR (RecordTypeId =:accountContactId))];
        
        return contactList;    
    }
    
    public List<Contact> selectInternationalContactsByIdwithAffiliations(Set<Id> conIdSet){
        
        List<Contact> contactListToUpdate = [Select Id, Name, ZTS_EU_Contact_Status__c,AccountId,ZTS_EU_Rep_Contact_Status__c, (Select Id, Name, ZTS_EU_Affiliation_Status__c from Accounts_and_Contacts__r) from Contact where id IN : conIdSet AND ZTS_EU_Market__c != 'United States'];
        
        return contactListToUpdate;
        
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByCaseId(Id caseId) {
        return [SELECT Id, Name, AccountId, LastName ,Account_Name__c, Title,Phone, Email, ZTS_EU_Contact_Status__c  
                FROM Contact WHERE AccountId IN (Select AccountId from Case Where Id = :caseId)
                Order By Name ASC];
    }
}