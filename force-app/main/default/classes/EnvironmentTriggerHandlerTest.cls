@IsTest
private class EnvironmentTriggerHandlerTest {
  @IsTest
  private static void insert_Test() {
    copado__Environment__c env = new copado__Environment__c();
    env.Name = 'TestEnv1';
    insert env;
  }

  @IsTest
  private static void update_Test() {
    copado__Environment__c env = new copado__Environment__c();
    env.Name = 'TestEnv1';
    insert env;
    update env;
  }

  @IsTest
  private static void delete_Test() {
    copado__Environment__c env = new copado__Environment__c();
    env.Name = 'TestEnv1';
    insert env;
    delete env;
  }

  @IsTest
  private static void undelete_Test() {
    copado__Environment__c env = new copado__Environment__c();
    env.Name = 'TestEnv1';
    insert env;
    delete env;
    undelete env;
  }
}