@IsTest
private class EnvironmentsServiceTest {
  @IsTest
  private static void createDefaultApprovalMetadata_Test() {
    copado__Environment__c env = new copado__Environment__c();
    env.Name = 'TestEnv';
    Test.startTest();
    insert env;
    Test.stopTest();

    Set<String> picklistVals = PicklistsService.getActivePicklistValues(
      'Environment_Metadata_Approval__c',
      'Metadata_Type__c'
    );

    List<Environment_Metadata_Approval__c> metadataList = [
      SELECT Id
      FROM Environment_Metadata_Approval__c
    ];

    System.assertEquals(
      picklistVals.size(),
      metadataList.size(),
      'Record Size should match available picklist options'
    );
  }
}