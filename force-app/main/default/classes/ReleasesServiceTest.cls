@isTest
private class ReleasesServiceTest {
  @testSetup
  static void setup() {
    // Create a Copado Release Record that is Frozen for Frozen Release Test
    copado__Release__c release = new copado__Release__c();
    release.Name = 'Frozen Release Test';
    release.Metadata_Freeze_Start_Date__c = System.today().addDays(-5);
    release.Metadata_Freeze_End_Date__c = System.today().addDays(20);
    insert release;

    // Create User Story linked to the Frozen Release for Frozen Release Test
    copado__User_Story__c freezeStory = new copado__User_Story__c();
    freezeStory.copado__User_Story_Title__c = 'Copado Frozen Release Story';
    freezeStory.copado__Release__c = release.Id;

    insert freezeStory;

    // Add Freeze Story to existing DML for User Stories
    List<copado__User_Story_Metadata__c> lstUserStoryMetadata = new List<copado__User_Story_Metadata__c>();
    // Create User Story Metadata related to Frozen Release Record
    for (Integer i = 0; i < 5; i++) {
      copado__User_Story_Metadata__c metadataRecord = new copado__User_Story_Metadata__c();
      metadataRecord.Name = freezeStory.Name + ' StoryMetadataTestRecord ' + i;
      //metadataRecord.copado__Unique_Id__c = freezeStory.Name + ' StoryMetadataTestRecord ' + i;
      metadataRecord.copado__User_Story__c = freezeStory.Id;
      metadataRecord.copado__Metadata_API_Name__c =
        'ApexClass.StoryMetadataTestRecord' + i;
      lstUserStoryMetadata.add(metadataRecord);
    }

    insert lstUserStoryMetadata;
  }
  static testMethod void getFrozenReleaseMap_Test() {
    List<copado__Release__c> releases = [
      SELECT Id
      FROM copado__Release__c
      WHERE Name = 'Frozen Release Test'
    ];

    Map<Id, Set<String>> frozenReleaseMap = ReleasesService.getFrozenReleaseMap();
    System.assertNotEquals(null, frozenReleaseMap.get(releases[0].Id),'Release Should be found in Map');
  }
}