public with sharing class AccountUtility {
 
   
    public static void syncOptOutField(List<string> emailList, Set<Id> accountIDs, Map<string,boolean> emailMap){
        
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactQueryLst = new List<Contact>([SELECT Id,AccountId,Account.Email__c,Email,ZTS_EU_Opt_Out_Email__c,ZTS_EU_Country__c,ZTS_EU_Market__c FROM Contact WHERE (ZTS_EU_Country__c = 'Germany' OR ZTS_EU_Market__c = 'Germany') AND AccountId IN :accountIDs and Email IN:emailList]);
        Set<Contact> contactQuerySet = new Set<Contact>();
        contactQuerySet.addAll(contactQueryLst);
        for(Contact c: contactQuerySet){
            if(c.Email==c.Account.Email__c){
            c.ZTS_EU_Opt_Out_Email__c = emailMap.get(c.Email);
            contactsToUpdate.add(c);
            }
        }
        try {
                update contactsToUpdate;   } catch (DmlException e) {
                // Process exception here
                system.debug('Failed to update Contact in AccountUtility.syncOptOutField');
            }
        return;
    }
}