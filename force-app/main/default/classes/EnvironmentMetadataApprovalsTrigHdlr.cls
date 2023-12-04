public with sharing class EnvironmentMetadataApprovalsTrigHdlr extends TriggerHandlerExtension implements TriggerHandlerInterface {
  public static void beforeInsert(List<SObject> newList) {
    EnvironmentMetadataApprovalsService.validateNewRecords(newList);
  }

  public static void beforeUpdate(
    List<SObject> oldList,
    Map<Id, SObject> oldMap,
    List<SObject> newList,
    Map<Id, SObject> newMap
  ) {
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