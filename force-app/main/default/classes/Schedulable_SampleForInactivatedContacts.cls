/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Schedulable_SampleForInactivatedContacts
* Description   :  This is a schedulable class that runs the batch class  ZTS_EU_Batch_SmplHandlrFrInactiveContact. The batch is supposed to run every night.                        

* @author       :   CloudSense (Sohil shah)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     17th-April-15   Shreyas             Created the class.

********************************************************************************************************************************************/
public class Schedulable_SampleForInactivatedContacts implements Schedulable{

    public void execute(SchedulableContext sc) {
        ZTS_EU_Batch_SmplHandlrFrInactiveContact bUpdate = new ZTS_EU_Batch_SmplHandlrFrInactiveContact(); 
        Integer batchSize = Integer.valueOf(System.label.ZTS_EU_BatchSizeForSamplesBatch);
        database.executebatch(bUpdate,batchSize);
    }

}