/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Schedulable_BringOfflineUniqueKey
* Description   :  This is a schedulable class that runs the batch class  ZTS_EU_Batch_BringOfflineUniquenessKey. The batch will update the uniqueness key of all the 
                   existing Bring Offline records.                         

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0      11th-Dec-14   Shreyas             Created the class.

********************************************************************************************************************************************/
public class ZTS_EU_Schedulable_BringOfflineUniqueKey implements Schedulable{

    public void execute(SchedulableContext sc) {
        ZTS_EU_Batch_BringOfflineUniqueKey bUpdate = new ZTS_EU_Batch_BringOfflineUniqueKey(); 
        database.executebatch(bUpdate,200);
    }

}