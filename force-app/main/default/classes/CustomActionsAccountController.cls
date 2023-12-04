public with sharing class CustomActionsAccountController {
    // @AuraEnabled
    // public static void  updateAccountStatus (Id accountId) {
    //     Account account = [SELECT ZTS_EU_Account_Status__c, Name
    //                        FROM Account
    //                        WHERE Id =: accountId];

    //     try {
    //         account.ZTS_EU_Account_Status__c = 'Pending';
    //         update account;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    @AuraEnabled(cacheable=true)
    public static Account getSingleAccount(String recordId) {
        System.debug(':::::::  '+recordId);
        return [
            SELECT Id, ZTS_EU_Account_Status__c, Name
            FROM Account
            WHERE Id =: recordId
            LIMIT 1
        ];
    }
}