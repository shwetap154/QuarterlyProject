/*******************************************************************************************************************************************
* File Name     :  ZTS_Scheduler_ConDeactbyAffiliations
* Description   :  This is a schedulable class that runs the batch class ZTS_DeactiveContOnAffltnDeactivation.                        
* Created By    : Aritra(Cognizant)
* Created Date  : 01-Apr-2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra (Cognizant)      01-Apr-2021      Created this class (SC-008471)
********************************************************************************************************************************************/
public class ZTS_Scheduler_ConDeactbyAffiliations implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        ZTS_DeactiveContOnAffltnDeactivation bUpdate = new ZTS_DeactiveContOnAffltnDeactivation(); 
        database.executebatch(bUpdate,5);
    } 

}