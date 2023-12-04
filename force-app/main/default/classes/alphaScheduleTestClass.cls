@isTest
public class alphaScheduleTestClass {
static testMethod void myTestMethod() {        
         test.starttest();
         AlphascheduledBatchable_Weekly myClass = new AlphascheduledBatchable_Weekly ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
    
    AlphascheduledBatchable_Monthly myClass1 = new AlphascheduledBatchable_Monthly ();   
         String chro1n = '0 0 23 * * ?';        
         system.schedule('Test Sched123', chro1n, myClass1);
         test.stopTest();
    }
}