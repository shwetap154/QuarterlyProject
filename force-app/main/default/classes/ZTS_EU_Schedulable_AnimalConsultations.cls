/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Schedulable_AnimalConsultations
* Description   :  This is a schedulable class that runs the batch class  ZTS_EU_Batch_AnimalConsultations. The batch is supposed to run on the 1st of every month.                        

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     10th-Sep-14   Shreyas             Created the class.

********************************************************************************************************************************************/
public class ZTS_EU_Schedulable_AnimalConsultations implements Schedulable{

    public void execute(SchedulableContext sc) {
        ZTS_EU_Batch_AnimalConsultations bUpdate = new ZTS_EU_Batch_AnimalConsultations(); 
        database.executebatch(bUpdate,200);
    }

}