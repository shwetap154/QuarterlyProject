public without sharing class ReleasesSelector {
  public static List<copado__Release__c> selectFrozenWithRelatedStories() {
    return [
      SELECT
        Id,
        Metadata_Freeze_Start_Date__c,
        Metadata_Freeze_End_Date__c,
        (SELECT Id, copado__Status__c FROM copado__User_Stories__r)
      FROM copado__Release__c
      WHERE
        Metadata_Freeze_Start_Date__c != NULL
        AND Metadata_Freeze_End_Date__c != NULL
        AND Metadata_Freeze_Start_Date__c <= :System.Today()
        AND Metadata_Freeze_End_Date__c >= :System.Today()
    ];
  }
}