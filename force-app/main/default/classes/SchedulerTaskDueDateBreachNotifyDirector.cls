/*******************************************************************************************************************************************
* File Name     :  SchedulerTaskDueDateBreachNotifyDirector
* Description   :  This is a schedulable class that runs the batch class BatchToNotifyTaskDueDateBreachToDirector.                        
* Created By    :  Aritra(Cognizant)
* Created Date  :  24-Mar-2022
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra (Cognizant)      24-Mar-2022      Created this class (SC-009405)
********************************************************************************************************************************************/
public class SchedulerTaskDueDateBreachNotifyDirector implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        BatchToNotifyTaskDueDateBreachToDirector batch = new BatchToNotifyTaskDueDateBreachToDirector(); 
        database.executebatch(batch);
    } 

}