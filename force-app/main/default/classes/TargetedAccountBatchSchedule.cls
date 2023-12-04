public class TargetedAccountBatchSchedule implements Schedulable 
{
    public void execute (SchedulableContext sc)
    {
        TargetedAccountBatch batch = new TargetedAccountBatch ();
        Database.executebatch(batch);
    }
}