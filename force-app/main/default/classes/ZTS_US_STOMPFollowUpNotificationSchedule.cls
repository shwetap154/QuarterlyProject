public class ZTS_US_STOMPFollowUpNotificationSchedule implements Schedulable 
{
    public void execute (SchedulableContext sc)
    {
        ZTS_US_STOMPFollowUpNotificationBatch batch = new ZTS_US_STOMPFollowUpNotificationBatch();
        Database.executebatch(batch);
    }
}