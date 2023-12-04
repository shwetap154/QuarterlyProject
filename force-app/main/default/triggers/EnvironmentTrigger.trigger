trigger EnvironmentTrigger on copado__Environment__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  EnvironmentTriggerHandler handler = new EnvironmentTriggerHandler();
  DispatchTriggerHandler.dispatchHandlerToFire(handler);
}