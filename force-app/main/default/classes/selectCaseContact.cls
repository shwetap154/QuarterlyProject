public class selectCaseContact {
    @AuraEnabled(cacheable=true)
    public static Case getCaseDetail(Id caseId) {
        return [Select Id, ContactId, No_Contact__c from Case Where Id =:caseId LIMIT 1];
    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByCaseId(Id caseId) {
        return [SELECT Id, Name, AccountId, LastName ,Account_Name__c, Title,Phone, Email, ZTS_EU_Contact_Status__c  
                FROM Contact 
                WHERE AccountId IN (Select AccountId from Case Where Id = :caseId)
                Order By Name ASC];
    }
}