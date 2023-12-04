/**
 * @description       :
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 11-17-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-16-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
public with sharing class ProcessInstanceWorkItemsSelector {
  public static List<ProcessInstanceWorkItem> selectByTargetRecordIds(
    Set<Id> recordIds
  ) {
    List<ProcessInstanceWorkItem> workItems = [
      SELECT Id
      FROM ProcessInstanceWorkItem
      WHERE
        ProcessInstance.TargetObjectId = :recordIds
        AND ProcessInstance.Status = 'Pending'
    ];
    return workItems;
  }
}