@IsTest
private class EnvironmentMetadataApprovalsServiceTest {
  @TestSetup
  static void makeData() {
    List<copado__Environment__c> lstEnvironments = new List<copado__Environment__c>();
    for (Integer i = 0; i < 3; i++) {
      copado__Environment__c env = new copado__Environment__c();
      env.Name = 'Test ' + i;
      lstEnvironments.add(env);
    }
    insert lstEnvironments;
    EnvironmentsService.createDefaultApprovalMetadata(lstEnvironments);
  }

  @IsTest
  private static void validateNewRecords_Test() {
    List<Environment_Metadata_Approval__c> lstMetadata = new List<Environment_Metadata_Approval__c>();
    List<copado__Environment__c> environments = [
      SELECT Id
      FROM copado__Environment__c
    ];
    for (copado__Environment__c env : environments) {
      Environment_Metadata_Approval__c metadata = new Environment_Metadata_Approval__c();
      metadata.Environment__c = env.Id;
      metadata.Metadata_Type__c = 'ApexClass';
      lstMetadata.add(metadata);
    }

    Test.startTest();
    try {
      insert lstMetadata;
    } catch (DmlException dml) {
      System.assert(
        dml.getMessage().contains('already exists for this environment'),
        'The duplicate error should be thrown'
      );
    }
    Test.stopTest();
  }
}