/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Batch_SampleHandler_NewYear_Sch 
* Description   :  Schdedulable class that will update the samples on every 1st Jan on change of year at 1AM                       

* @author       :   CloudSense (Sohil Shah)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     12th-Feb-16   Sohil Shah             Created the class.

********************************************************************************************************************************************/

global class  ZTS_EU_Batch_SampleHandler_NewYear_Sch implements Schedulable{
   
  global void execute(SchedulableContext sc) 
    { 
        ZTS_EU_Batch_SampleHandler_NewYear contractBatch = new ZTS_EU_Batch_SampleHandler_NewYear(); 
        database.executebatch(contractBatch ); 
  } 
}

/*
If any one edit this class or it's related batch class(ZTS_EU_Batch_SampleHandler_NewYear) then just run this much of code annonymously(In Developer console editor)
It will schdedule it for you;

For new year(on 30th Dec of every year) please change the custom label value to the current year
[ZTS_EU_Batch_SampleHandler_NewYear_Sch pa= new ZTS_EU_Batch_SampleHandler_NewYear_Sch();
String cronStr = '0 0 1 1 1 ? *';
System.schedule('Process Accs Job', cronStr, pa);]

*/