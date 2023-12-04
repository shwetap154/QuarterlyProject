public with sharing class AccountAlertController {
   @AuraEnabled(cacheable=true)
   public static Map<String,String> getLatestAccountAlerts(Id recordId) {
        String lastModifiedName;
        String accountAlert;
        String concatFieldKey;
        Map<String, String> LastMDateTimeMap = new Map<String, String>();
        List<Account_Alert__c> AccAlertList = [SELECT Name, LastModifiedBy.Name, Expiry_Date__c, LastModifiedDate, Alert__c   FROM Account_Alert__c where Account__r.id = :recordId AND Expiry_Date__c = null  ORDER BY LastModifiedDate DESC]; 
         System.debug('AccAlertList'+AccAlertList);
         for (Account_Alert__c alert : AccAlertList) {
                String lastModifiedTime = alert.LastModifiedDate.format('HH:mm a');
                String lastModifiedDate = alert.LastModifiedDate.format('MM/dd/yyyy');
                String formattedDateTime = lastModifiedTime+' | '+lastModifiedDate;
                LastModifiedName = alert.LastModifiedBy.Name;
                accountAlert=alert.Alert__c;
               concatFieldKey = LastModifiedName+'*'+accountAlert;
             
                System.debug('formattedDateTime '+formattedDateTime);
                lastMDateTimeMap.put(concatFieldKey,formattedDateTime); 
             
        }
        System.debug('LastMDateTimeMap '+LastMDateTimeMap);
        if(!LastMDateTimeMap.isEmpty()){
            return LastMDateTimeMap;
        }
        else{
            return null;
        }
        
    }
 
}