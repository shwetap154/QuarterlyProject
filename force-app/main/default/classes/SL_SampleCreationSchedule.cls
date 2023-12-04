/**
* @ClassName    : SL_SampleCreationSchedule
* @JIRATicket   : LIGHTNI-1682
* @CreatedOn    : 13th Oct 2019
* @CreatedBy    : Premraj K K
* @ModifiedBy   : 
* @Description  : Scheduler class for creating Sample from both Contact and Product Hierarchy
*/
public class SL_SampleCreationSchedule implements Schedulable {
    
	public void execute(SchedulableContext ctx) {
        
        SL_SampleFromProductsBatch batch = new SL_SampleFromProductsBatch(''); 
        Database.executeBatch(batch);
    }
}