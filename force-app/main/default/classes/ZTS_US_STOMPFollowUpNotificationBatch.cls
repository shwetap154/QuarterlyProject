public class ZTS_US_STOMPFollowUpNotificationBatch implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
      return Database.getQueryLocator([Select ID, Name, CreatedDate,Mail_Sent__c,PIT_Account__c,PIT_Account__r.Name,Days_Since_Record_Created__c,PIT_STOMP_Initiation_Number__c,PIT_Approving_Vet__c, PIT_Diagnostic_Lab__c,PIT_Status__c from PIT_STOMP__c where ( Days_Since_Record_Created__c = 14 and PIT_Status__c = 'Approved' and Mail_Sent__c = false )]  );
      //return Database.getQueryLocator([Select ID, Name, CreatedDate,Mail_Sent__c,PIT_Account__c,PIT_Account__r.Name,Days_Since_Record_Created__c,PIT_STOMP_Initiation_Number__c,PIT_Approving_Vet__c, PIT_Diagnostic_Lab__c,PIT_Status__c from PIT_STOMP__c where createdDate >=2015-08-07T00:00:00Z and createdDate <=2015-08-08T00:00:00Z  and PIT_Status__c = 'Approved' and Mail_Sent__c = false]  );
    }
    public void execute(Database.BatchableContext BC, List<PIT_STOMP__c> scope)
    {
        ZTS_US_STOMPFollowUpNotification.sendEmail(scope);
    }
    public void finish(Database.BatchableContext BC)
    {
        
    }
}