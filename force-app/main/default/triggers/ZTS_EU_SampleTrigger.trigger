/********************************************************************************************************************************************
* Name          :    ZTS_EU_SampleTrigger
* Description   :    Trigger on Sample Object
* Author        :    Cloudsense(Shreyas) 
 
Modification Log
----------------
Date                 Developer                               Comments
---------------------------------------------------------------------------------------
10th-Dec-2014        Cloudsense(Shreyas)                     Created
25th-Nov-2020        Slalom(Allister McKenzie)               Implemented trigger framework
**********************************************************************************************************************************************/
trigger ZTS_EU_SampleTrigger on ZTS_EU_Sample__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new EUSampleTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Sample_Bypass__c);
}