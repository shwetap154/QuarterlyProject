/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Schedulable_HolidayToT
* Description   :  This is a schedulable class that runs the batch class  ZTS_EU_Batch_HolidayToT.                       

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     22nd-Sep-14   Shreyas             Created the class.

********************************************************************************************************************************************/
public class ZTS_EU_Schedulable_HolidayToT implements Schedulable{

    public void execute(SchedulableContext sc) {
        ZTS_EU_Batch_HolidayToT bUpdate = new ZTS_EU_Batch_HolidayToT(); 
        database.executebatch(bUpdate,200);
    }

}