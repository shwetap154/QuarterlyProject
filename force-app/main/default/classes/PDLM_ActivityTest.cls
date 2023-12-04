@isTest
private class PDLM_ActivityTest {

    static testmethod void checkInsert() {
        // Enable all Change Data Capture entities for notifications.
        Test.enableChangeDataCapture();
        PDLM__Project__c proj = new PDLM__Project__c(Name = 'Test proj');
        insert proj;
        PDLM__Deliverable__c del = new PDLM__Deliverable__c();
        del.Name = 'Test Deliverable';
        del.PDLM__Project__c = proj.Id;
        insert del;
        Test.getEventBus().deliver();
        
        //verify insert for changeevent 
        System.assert(del.Id != null);
    }
}