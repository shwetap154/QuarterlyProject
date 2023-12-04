trigger EnvironmentMetadataApprovalTrigger on Environment_Metadata_Approval__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  EnvironmentMetadataApprovalsTrigHdlr handler = new EnvironmentMetadataApprovalsTrigHdlr();
  DispatchTriggerHandler.dispatchHandlerToFire(handler);
}