/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Schedulable_SampleForProducts
* Description   :  This is a schedulable class that runs the batch class  ZTS_EU_Batch_SampleHandlerForProducts. The batch is supposed to run every night.                        

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     21st-Nov-14   Shreyas             Created the class.

********************************************************************************************************************************************/
public class ZTS_EU_Schedulable_SampleForProducts implements Schedulable{

    public void execute(SchedulableContext sc) {
        ZTS_EU_Batch_SampleHandlerForProducts bUpdate = new ZTS_EU_Batch_SampleHandlerForProducts(); 
        Integer batchSize = Integer.valueOf(System.label.ZTS_EU_BatchSizeForSamplesBatch);
        database.executebatch(bUpdate,batchSize);
    }

}