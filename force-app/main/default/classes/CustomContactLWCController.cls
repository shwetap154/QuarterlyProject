public with sharing class CustomContactLWCController {
    @AuraEnabled(cacheable=true)
    public static Contact getSingleRecord(String recordId) {
        System.debug('Here '+recordId);
        return [
            SELECT Id, ZTS_EU_Contact_Status__c, Name
            FROM Contact
            WHERE Id =: recordId
            LIMIT 1
        ];
    }
}