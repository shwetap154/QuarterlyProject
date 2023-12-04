@isTest
private class UserStoriesSelectorTest {
  @testSetup
  static void setup() {
    // Create User Story not tied to this release
    copado__User_Story__c story = new copado__User_Story__c();
    story.copado__User_Story_Title__c = 'Test Story';
    insert story;

    // Add User Story Metadata to this Story which is linked to the Frozen Release
    copado__User_Story_Metadata__c metadata = new copado__User_Story_Metadata__c();
    metadata.Name = story.Name + ' Metadata Test';
    //metadata.copado__Unique_Id__c = story.Name + ' StoryMetadataTestRecord 0';
    metadata.copado__User_Story__c = story.Id;
    metadata.copado__Metadata_API_Name__c = 'ApexClass.StoryMetadataTestRecord0';
    insert metadata;
  }

  static testMethod void selectByIdWithRelatedMetadata_Test() {
    List<copado__User_Story__c> storyQuery = [SELECT Id FROM copado__User_Story__c];
    Set<Id> storyIds = new Set<Id>();
    for(copado__User_Story__c story : storyQuery){
        storyIds.add(story.Id);
    }
    List<copado__User_Story__c> stories = UserStoriesSelector.selectByIdWithRelatedMetadata(storyIds);
    System.assertEquals(1,stories.size());
  }
}