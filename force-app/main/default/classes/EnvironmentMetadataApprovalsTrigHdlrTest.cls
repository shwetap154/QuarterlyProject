@IsTest
private class EnvironmentMetadataApprovalsTrigHdlrTest {
  @TestSetup
  static void makeData() {
    copado__Environment__c env = new copado__Environment__c();
    env.Name = 'TestEnv';
    insert env;
    List<Environment_Metadata_Approval__c> preApprovalList = [
      SELECT Id
      FROM Environment_Metadata_Approval__c
    ];
    delete preApprovalList;
  }

  @IsTest
  private static void insert_Test() {
    List<copado__Environment__c> env = [SELECT Id FROM copado__Environment__c];
    Environment_Metadata_Approval__c metadata = new Environment_Metadata_Approval__c();
    metadata.Environment__c = env[0].Id;
    metadata.Metadata_Type__c = 'ApexClass';
    insert metadata;
  }

  @IsTest
  private static void update_Test() {
    List<copado__Environment__c> env = [SELECT Id FROM copado__Environment__c];
    Environment_Metadata_Approval__c metadata = new Environment_Metadata_Approval__c();
    metadata.Environment__c = env[0].Id;
    metadata.Metadata_Type__c = 'ApexClass';
    insert metadata;
    update metadata;
  }

  @IsTest
  private static void delete_Test() {
    List<copado__Environment__c> env = [SELECT Id FROM copado__Environment__c];
    Environment_Metadata_Approval__c metadata = new Environment_Metadata_Approval__c();
    metadata.Environment__c = env[0].Id;
    metadata.Metadata_Type__c = 'ApexClass';
    insert metadata;
    delete metadata;
  }

  @IsTest
  private static void undelete_Test() {
    List<copado__Environment__c> env = [SELECT Id FROM copado__Environment__c];
    Environment_Metadata_Approval__c metadata = new Environment_Metadata_Approval__c();
    metadata.Environment__c = env[0].Id;
    metadata.Metadata_Type__c = 'ApexClass';
    insert metadata;
    delete metadata;
    undelete metadata;
  }
}