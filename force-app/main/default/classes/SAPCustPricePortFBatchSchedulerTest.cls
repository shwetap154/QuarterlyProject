@isTest
public class SAPCustPricePortFBatchSchedulerTest {
    public static testMethod void testschedule() {        
        Test.StartTest();
        Id jobId;        
        SAPCustPricePortFBatchScheduler clsScheduler = new SAPCustPricePortFBatchScheduler();        
        String sch = '0 0 23 * * ?'; 
        jobID = system.schedule('Test Schedule job', sch, clsScheduler);
        System.assert(!String.isEmpty(jobID));
        Test.stopTest();
    }
}