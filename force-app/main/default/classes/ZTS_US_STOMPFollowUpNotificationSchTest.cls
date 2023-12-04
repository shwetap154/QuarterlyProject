@isTest(seeAllData = true)
public class ZTS_US_STOMPFollowUpNotificationSchTest {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        ZTS_US_STOMPFollowUpNotificationSchedule sh1 = new ZTS_US_STOMPFollowUpNotificationSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Follow Up Check', sch, sh1); 
        Test.stopTest(); 
    }
}