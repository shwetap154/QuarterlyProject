/**
 * @description       : Logic for all US Campaign triggers housed here.
 * @author            : David Stern @ Slalom
 * @group             : 
 * @last modified on  : 04-01-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   02-06-2020   David Stern @ Slalom          Created, Logic from all triggers moved to this class.
 * 1.1   04-01-2021   Morgan Marchese @ Zoetis Inc  Complete refactor to fix bad logic
**/

public without sharing class USCampaignTriggerService {
  public static void afterUpdate(
    List<Campaign> oldList,
    Map<Id, Campaign> oldMap,
    List<Campaign> newList,
    Map<Id, Campaign> newMap
  ) {
    List<Campaign> campaignList = new List<Campaign>();
    Campaign oldRecord;
    for (Campaign record : newList) {
      oldRecord = oldMap.get(record.Id);
      if (
        record.Key_Initiative__c != oldRecord.Key_Initiative__c ||
        record.IsActive != oldRecord.IsActive ||
        record.Description != oldRecord.Description
      ) {
        campaignList.add(record);
      }
    }

    if (!campaignList.isEmpty()) {
      Database.executeBatch(new TargetedAccountFlagUpdate(campaignList));
    }
  }
}