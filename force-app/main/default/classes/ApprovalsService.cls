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
public with sharing class ApprovalsService {
  @InvocableMethod(
    label='Recall Approval Request'
    description='Given a Set of IDs, recalls any active approval process for those record(s).'
  )
  public static void recallApprovalsInvocable(List<Id> recordIds) {
    List<Approval.ProcessResult> results = recallApprovals(new Set<Id>(recordIds));
  }

  public static List<Approval.ProcessResult> recallApprovals(
    Set<Id> recordIds
  ) {
    List<ProcessInstanceWorkItem> workItems = ProcessInstanceWorkItemsSelector.selectByTargetRecordIds(
      recordIds
    );
    List<Approval.ProcessWorkItemRequest> listPWR = new List<Approval.ProcessWorkitemRequest>();
    for (ProcessInstanceWorkItem piwi : workItems) {
      Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
      pwr.setAction('Removed');
      pwr.setWorkitemId(piwi.Id);
      listPWR.add(pwr);
    }
    List<Approval.ProcessResult> results = Approval.process(listPWR);
    return results;
  }
}