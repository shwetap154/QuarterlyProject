public with sharing class EnvironmentsService {
  public static List<Environment_Metadata_Approval__c> createDefaultApprovalMetadata(
    List<copado__Environment__c> environments
  ) {
    List<Environment_Metadata_Approval__c> lstEnvMetadata = new List<Environment_Metadata_Approval__c>();
    Set<String> metadataPicklistValues = PicklistsService.getActivePicklistValues(
      'Environment_Metadata_Approval__c',
      'Metadata_Type__c'
    );

    for (copado__Environment__c env : environments) {
      for (String metadataValue : metadataPicklistValues) {
        Environment_Metadata_Approval__c metadataRecord = new Environment_Metadata_Approval__c();
        metadataRecord.Environment__c = env.Id;
        metadatarecord.Metadata_Type__c = metadataValue;
        lstEnvMetadata.add(metadataRecord);
      }
    }

    insert lstEnvMetadata;
    return lstEnvMetadata;
  }
}