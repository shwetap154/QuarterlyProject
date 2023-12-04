/*************************************************************************************
* Name          :    ZTS_EU_GiftTrigger.
* Description   :    Trigger on ZTS_EU_Gift__c.
* Author        :    Teresa
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
3/25/2014       Teresa                    Created
10th-Dec-2014   Cloudsense(Shreyas)       Added the logic to populate fields  'ZTS_EU_Year__c' and 'ZTS_EU_Is_Current_Year_Gift__c' 

**************************************************************************************/
trigger ZTS_EU_GiftTrigger on ZTS_EU_Gift__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_GiftTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Gift_Bypass__c);

}