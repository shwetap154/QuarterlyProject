public with sharing class ReleasesService {
  public static Map<Id, Set<String>> getFrozenReleaseMap() {
    Set<Id> userStoryIds = new Set<Id>();

    // Map of Release Id to All Metadata Strings from Related User Stories
    Map<Id, Set<String>> releaseIdToMetadataMap = new Map<Id, Set<String>>();

    // Query Frozen Releases
    List<copado__Release__c> frozenReleases = ReleasesSelector.selectFrozenWithRelatedStories();

    // If there are no Frozen Release Records, End Early
    if(frozenReleases.isEmpty()){
        return null;
    }

    // Build Set of Story Ids
    for (copado__Release__c release : frozenReleases) {
      for (copado__User_Story__c story : release.copado__User_Stories__r) {
        if (story.copado__Status__c != 'Cancelled') {
          userStoryIds.add(story.Id);
        }
      }
    }

    // Get Stories and their Metadata connected to Frozen Releases
    List<copado__User_Story__c> userStories = UserStoriesSelector.selectByIdWithRelatedMetadata(
      userStoryIds
    );

    releaseIdToMetadataMap = buildReleaseIdToMetadataMap(userStories);

    return releaseIdToMetadataMap;
  }

  private static Map<Id, Set<String>> buildReleaseIdToMetadataMap(
    List<copado__User_Story__c> storyList
  ) {
    // Map of Release Id to its Child User Stories
    Map<Id, Set<String>> releaseIdToMetadataMap = new Map<Id, Set<String>>();

    for (copado__User_Story__c story : storyList) {
      Set<String> relatedMetadata = releaseIdToMetadataMap.get(
        story.copado__Release__c
      );
      for (
        copado__User_Story_Metadata__c metadata : story.copado__User_Story_Metadata__r
      ) {
        if (relatedMetadata == null) {
          relatedMetadata = new Set<String>{
            metadata.copado__Metadata_API_Name__c
          };
        } else {
          relatedMetadata.add(metadata.copado__Metadata_API_Name__c);
        }
      }
      releaseIdToMetadataMap.put(story.copado__Release__c, relatedMetadata);
    }

    return releaseIdToMetadataMap;
  }
}