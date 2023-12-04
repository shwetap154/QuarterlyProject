/**
 * @description       : Main Service Class for all User Story logic
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : ServiceClass
 * @last modified on  : 01-03-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log   
 * Ver   Date         Author                         Modification
 * 1.0   12-15-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   01-03-2023   Padma Nerella @ Zoetis Inc     TPDev-75 Added addtional logic in setApprovals method to copy Additional Approval Required from
 *                                                   the related Environment's Environment Metadata Approval to User Story when the Story's Selected 
 *                                                   Metadata matches the Metadata Type on the Environment Metadata Approval. 
 *                                                   This is done so that additional approvals, such as Architect, can be required based on the Metadata on a Story.
 *                    
 **/

public class UserStoriesService {
  /**
   * @description This will set the Approval for User Stories if any of the Metadata Types selected on the
   * User Story matches any of the Metadata Types present in the Environment objects Metadata Types for
   * Approval List.
   * @author Morgan Marchese @ Zoetis Inc | 12-15-2021
   * @param List<copado__User_Story__c> lstCopadoUserStory
   * @return List<copado__User_Story__c>
   **/
  public static List<copado__User_Story__c> setApprovals(
    List<copado__User_Story__c> lstCopadoUserStory
  ) {
    // If we receive an Empty List, Do Nothing
    if (lstCopadoUserStory.isEmpty()) {
      return lstCopadoUserStory;
    }

    Set<String> allActivePicklistOptions;
    Set<String> userStoryPicklistSelections = new Set<String>();
    Set<String> additionalApprovalsSet = new Set<String>();
    Set<Id> sEnvIds = new Set<Id>();
    String storyMetadata;
    List<copado__User_Story__c> lstUserStoriesToProcess = new List<copado__User_Story__c>();
    Map<String,String> mapEnvironmentMetadataTypeToAdditionalApprovals = new Map<String, String>();
    Map<Id, Map<String, String>> mapEnvIdToEnvironmentMetadataTypeToAdditionalApprovals = new Map<Id, Map<String, String>>();

    // Find Records That Need Processing
    for (copado__User_Story__c objUserStoryRecord : lstCopadoUserStory) {
      storyMetadata = objUserStoryRecord.copado__Metadata_Types_in_Selection__c;
      // If Story Metadata is empty, we can't process approval status
      if (String.isBlank(storyMetadata)) {
        continue;
      }
      sEnvIds.add(objUserStoryRecord.copado__Environment__c);
      lstUserStoriesToProcess.add(objUserStoryRecord);
    }

    // If there are no records to process, return the unmodified list and end early.
    if (lstUserStoriesToProcess.isEmpty()) {
      return lstCopadoUserStory;
    }

    allActivePicklistOptions = PicklistsService.getActivePicklistValues(
      'Environment_Metadata_Approval__c',
      'Metadata_Type__c'
    );

    // Query for Related Environments to get their Approval Requirements
    List<copado__Environment__c> lstEnvironment = [
      SELECT
        Id,
        (SELECT Id, Metadata_Type__c,Additional_Approval_Required__c FROM Environment_Metadata_Approvals__r)
      FROM copado__Environment__c
      WHERE Id = :sEnvIds
    ];

    // Loop through Environments to build Map of Env Id -> Approval Metadata (Set<String>)
    for (copado__Environment__c objEnv : lstEnvironment) {
      mapEnvironmentMetadataTypeToAdditionalApprovals = new Map<String, String>();

      for (
        Environment_Metadata_Approval__c metadata : objEnv.Environment_Metadata_Approvals__r
      ) {
        mapEnvironmentMetadataTypeToAdditionalApprovals.put(metadata.Metadata_Type__c,metadata.Additional_Approval_Required__c);
        
      }
      mapEnvIdToEnvironmentMetadataTypeToAdditionalApprovals.put(objEnv.Id, mapEnvironmentMetadataTypeToAdditionalApprovals);
    }
      
    // Process User Stories for Approvals
    for (copado__User_Story__c objUserStoryRecord : lstUserStoriesToProcess) {
      storyMetadata = objUserStoryRecord.copado__Metadata_Types_in_Selection__c;

      // Build Set<String> of User Story Metadata Selections
      userStoryPicklistSelections.clear();
      userStoryPicklistSelections.addAll(storyMetadata.split(';'));

      // Get Map<String, String> of Related Environment Metadata Selections and the Additional Approvals
      mapEnvironmentMetadataTypeToAdditionalApprovals = mapEnvIdToEnvironmentMetadataTypeToAdditionalApprovals.get(
        objUserStoryRecord.copado__Environment__c
      );

      additionalApprovalsSet = new Set<String>();
      objUserStoryRecord.Metadata_Approval_Required__c = false;

      // Main Comparison Logic
      for (String picklistValue : userStoryPicklistSelections) {
        // If not found in global picklist, require approval and break
        if (!allActivePicklistOptions.contains(picklistValue)) {
          objUserStoryRecord.Metadata_Approval_Required__c = true;
          additionalApprovalsSet.add('Architect');
          
          // Else If Environment Metadata match is found, require approval and break
        } else if (mapEnvironmentMetadataTypeToAdditionalApprovals.containsKey(picklistValue)) {
          objUserStoryRecord.Metadata_Approval_Required__c = true;
          
          String additionalApprovals = mapEnvironmentMetadataTypeToAdditionalApprovals.get(picklistValue);
          if(String.isNotEmpty(additionalApprovals)){
            additionalApprovalsSet.addAll(additionalApprovals.split(';'));
          }
        }
      }

      String approvalSet = String.join((Iterable<String>)additionalApprovalsSet, '; ');
      objUserStoryRecord.Additional_Approval_Required__c = approvalSet;
    }
    return lstCopadoUserStory;
  }

  public static List<copado__User_Story__c> setFreezeStatus(
    List<copado__User_Story__c> lstCopadoUserStory
  ) {
    Boolean isFreezeOverridden;
    List<copado__User_Story__c> lstStories = new List<copado__User_Story__c>();
    Set<Id> userStoryToFreezeIdSet = new Set<Id>();

    // If we receive an Empty List, Do Nothing
    if (lstCopadoUserStory.isEmpty()) {
      return lstCopadoUserStory;
    }

    Map<Id, Set<String>> frozenReleaseMap = ReleasesService.getFrozenReleaseMap();

    // If there are no frozen Releases, Do Nothing
    if (frozenReleaseMap == null) {
      return lstCopadoUserStory;
    }

    for (copado__User_Story__c story : lstCopadoUserStory) {
      if (frozenReleaseMap.containsKey(story.copado__Release__c)) {
        if (story.Frozen_By__c != null) {
          story.Frozen_By__c = null;
        }
      } else {
        userStoryToFreezeIdSet.add(story.Id);
      }
    }

    if (!userStoryToFreezeIdSet.isEmpty()) {
      // Query for Story Data and Metadata
      lstStories = UserStoriesSelector.selectByIdWithRelatedMetadata(
        userStoryToFreezeIdSet
      );
    }

    Map<Id, List<copado__User_Story_Metadata__c>> storyIdToMetadataMap = new Map<Id, List<copado__User_Story_Metadata__c>>();

    // Build a Map so that we can pull back the Story Metadata with the appropriate context record
    for (copado__User_Story__c story : lstStories) {
      storyIdToMetadataMap.put(story.Id, story.copado__User_Story_Metadata__r);
    }

    Boolean isNewlyFrozen;
    Set<String> releaseMetadata;
    List<copado__User_Story_Metadata__c> storyMetadataList;
    // Since this is Before Update, we must loop the original records in context
    // Otherwise updates will not happen as expected if using queried list
    for (copado__User_Story__c story : lstCopadoUserStory) {
      isNewlyFrozen = false;
      storyMetadataList = storyIdToMetadataMap.get(story.Id);

      // If Story Metadata is not Found in Metadata Map, Skip
      if (storyMetadataList == null || storyMetadataList.isEmpty()) {
        continue;
      }

      // If this Record has been Approved to Override Freezing, Skip
      if (story.Approved_Freeze_Override__c) {
        continue;
      }
      for (Id releaseId : frozenReleaseMap.keySet()) {
        // Stop Loop if Just Frozen
        if (isNewlyFrozen) {
          break;
        }
        releaseMetadata = frozenReleaseMap.get(releaseId);
        for (copado__User_Story_Metadata__c storyMetadata : storyMetadataList) {
          if (
            releaseMetadata.contains(storyMetadata.copado__Metadata_API_Name__c)
          ) {
            story.Frozen_By__c = releaseId;
            isNewlyFrozen = true;
            break;
          }
        }
      }
    }

    return lstStories;
  }
}