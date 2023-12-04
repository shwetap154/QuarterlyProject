/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Schedulable_SampleForInactivatedProducts
* Description   :  This is a schedulable class that runs the batch class  ZTS_EU_Batch_SampleHandlerForProducts. The batch is supposed to run every night.                        

* @author       :   CloudSense (Sohil shah)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     17th-April-15   Shreyas             Created the class.

********************************************************************************************************************************************/
public class Schedulable_SampleForInactivatedProduct implements Schedulable{

    public void execute(SchedulableContext sc) {
        ZTS_EU_Batch_SmplHandlrFrInactiveProduct bUpdate = new ZTS_EU_Batch_SmplHandlrFrInactiveProduct(); 
        Integer batchSize = Integer.valueOf(System.label.ZTS_EU_BatchSizeForSamplesBatch);
        database.executebatch(bUpdate,batchSize);
    }

}