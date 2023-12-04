public with sharing class EnvironmentMetadataApprovalsService {
  public static void validateNewRecords(
    List<Environment_Metadata_Approval__c> lstMetadata
  ) {
    Set<Id> stEnvIds = new Set<Id>();
    Map<Id, Set<String>> mapEnvIdToMetadataTypes = new Map<Id, Set<String>>();
    Set<String> metadataTypes = new Set<String>();
    for (Environment_Metadata_Approval__c metadata : lstMetadata) {
      stEnvIds.add(metadata.Environment__c);
    }

    List<Environment_Metadata_Approval__c> lstEnvMetadata = [
      SELECT Id, Metadata_Type__c, Environment__c
      FROM Environment_Metadata_Approval__c
      WHERE Environment__c IN :stEnvIds
    ];

    for (Environment_Metadata_Approval__c metadata : lstEnvMetadata) {
      metadataTypes = mapEnvIdToMetadataTypes.get(metadata.Environment__c);
      if (metadataTypes == null) {
        mapEnvIdToMetadataTypes.put(
          metadata.Environment__c,
          new Set<String>{ metadata.Metadata_Type__c }
        );
      } else {
        metadataTypes.add(metadata.Metadata_Type__c);
      }
    }

    for (Environment_Metadata_Approval__c metadata : lstMetadata) {
      metadataTypes = mapEnvIdToMetadataTypes.get(metadata.Environment__c);
      if(metadataTypes == null) continue;
      if (metadataTypes.contains(metadata.Metadata_Type__c)) {
        metadata.addError(
          'The Metadata Type \'' +
          metadata.Metadata_Type__c +
          '\' already exists for this environment.'
        );
      }
    }
  }
}