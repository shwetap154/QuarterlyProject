/****************************************************************************************************************************************** 
* Class Name   : INTLOrdersTriggerService
* Description  : Logic for INTL Orders triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 06 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     05/19/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public with sharing class INTLOrdersTriggerService 
{    
    public static void beforeInsert(List<Orders__c> triggerNew) 
    {
        ZTS_EU_OrderUtility.updateCurrencyIsoCode(triggerNew);
    }
    public static void beforeDelete(List<Orders__c> triggerOld, Map<Id, Orders__c> triggerOldMap) 
    {
        //ZTS_EU_OrderUtility.restrictOrderDelete(trigger.old);
    }
    public static void afterInsert(List<Orders__c> triggerNew, Map<Id, Orders__c> triggerNewMap) 
    {
        ZTS_EU_OrderUtility.deleteCallRecordForOrder(triggerNew);
        ZTS_EU_OrderUtility.createorderdetails(triggerNew);
    }
}