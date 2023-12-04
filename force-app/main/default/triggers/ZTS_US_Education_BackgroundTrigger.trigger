/*
* @Name: ZTS_US_Education_BackgroundTrigger
* @Desciption: Trigger on ZTS_US_Education_Background__c.
*              Updates Education fields on Contact whenever the fields are modified on the education record.
*              Restricts 1 DVM Education record per Contact.
*/

trigger ZTS_US_Education_BackgroundTrigger on ZTS_US_Education_Background__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_US_Education_BackgroundTrigHandler(), Bypass_Triggers__mdt.ZTS_US_Education_Background_Bypass__c);


}