@IsTest
private class UserStoryTriggerHandlerTest {
  @IsTest
  private static void insert_Test() {
    copado__User_Story__c story = new copado__User_Story__c();
    story.copado__User_Story_Title__c = 'Test1';
    insert story;
  }

  @IsTest
  private static void update_Test() {
    copado__User_Story__c story = new copado__User_Story__c();
    story.copado__User_Story_Title__c = 'Test1';
    insert story;
    update story;
  }

  @IsTest
  private static void delete_Test() {
    copado__User_Story__c story = new copado__User_Story__c();
    story.copado__User_Story_Title__c = 'Test1';
    insert story;
    delete story;
  }

  @IsTest
  private static void undelete_Test() {
    copado__User_Story__c story = new copado__User_Story__c();
    story.copado__User_Story_Title__c = 'Test1';
    insert story;
    delete story;
    undelete story;
  }
}