@isTest
private class MilestoneCompleteTest 
{
    private static testMethod void testmilestone()
    {
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Items Request').getRecordTypeId();

    	Case ca = new Case(Subject='Test Controller Acct Case', Status = 'Open', RecordTypeId = caseRTId);
    	insert ca;
    }

}