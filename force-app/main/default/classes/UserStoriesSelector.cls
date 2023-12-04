public without sharing class UserStoriesSelector {
  public static List<copado__User_Story__c> selectByIdWithRelatedMetadata(
    Set<Id> storyIds
  ) {
    // Query for Stories AND Child Metadata Components within those Stories. Need to get Release Id in this query.
    return [
      SELECT
        Id,
        copado__Release__c,
        (SELECT Id, copado__Metadata_API_Name__c FROM copado__User_Story_Metadata__r)
      FROM copado__User_Story__c
      WHERE Id = :storyIds
    ];
  }
}