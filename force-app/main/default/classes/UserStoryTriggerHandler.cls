public with sharing class UserStoryTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {
  public static void beforeInsert(List<SObject> newList) {
  }

  public static void beforeUpdate(
    List<SObject> oldList,
    Map<Id, SObject> oldMap,
    List<SObject> newList,
    Map<Id, SObject> newMap
  ) {
    List<copado__User_Story__c> lstFreezeCheck = new List<copado__User_Story__c>();
    copado__User_Story__c oldRecord;
    Boolean isMetadataCountChanged;
    Boolean isfrozenByChanged;
    Boolean isReleaseChanged;

    for (copado__User_Story__c record : (List<copado__User_Story__c>) newList) {
      oldRecord = (copado__User_Story__c) oldMap.get(record.Id);

      isMetadataCountChanged =
        record.Metadata_Count__c != null &&
        record.Metadata_Count__c != oldRecord.Metadata_Count__c;

      isfrozenByChanged =
        record.Frozen_By__c == null &&
        record.Frozen_By__c != oldRecord.Frozen_By__c;

      isReleaseChanged =
        record.copado__Release__c != oldRecord.copado__Release__c;

      if (isMetadataCountChanged || isfrozenByChanged || isReleaseChanged) {
        lstFreezeCheck.add(record);
      }
    }

    UserStoriesService.setApprovals(newList);
    if (!lstFreezeCheck.isEmpty()) {
      UserStoriesService.setFreezeStatus(lstFreezeCheck);
    }
  }

  public static void beforeDelete(
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
  }

  public static void afterInsert(
    List<SObject> newList,
    Map<Id, SObject> newMap
  ) {
  }

  public static void afterUpdate(
    List<SObject> oldList,
    Map<Id, SObject> oldMap,
    List<SObject> newList,
    Map<Id, SObject> newMap
  ) {
  }

  public static void afterDelete(
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
  }

  public static void afterUndelete(
    List<SObject> newList,
    Map<Id, SObject> newMap
  ) {
  }
}