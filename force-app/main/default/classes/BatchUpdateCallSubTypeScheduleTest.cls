@isTest
private class BatchUpdateCallSubTypeScheduleTest {
    static testmethod void test() {        
        Test.startTest();
        BatchUpdateCallSubTypeSchedule sh1 = new BatchUpdateCallSubTypeSchedule();      
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();
    }
    
}