trigger UserStoryTrigger on copado__User_Story__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  UserStoryTriggerHandler handler = new UserStoryTriggerHandler();
  DispatchTriggerHandler.dispatchHandlerToFire(handler);
}