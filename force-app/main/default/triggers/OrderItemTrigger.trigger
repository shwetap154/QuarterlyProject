/**
* File Name     :  OrderItemTrigger
* @description  :  Trigger for OrderItem object.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/19/2019		Cesar Sandrigo @ ATG     Created the Class.
*/
trigger OrderItemTrigger on OrderItem (before insert) {

    if (Trigger.isInsert && Trigger.isBefore) {
        
    
        List<OrderItem> listOrderItem = new List<OrderItem>();
        for(OrderItem oItem : Trigger.new)
        {	
 			//oITem.SBQQ__QuoteLine__c condition added to avoid firing this trigger for SAP_Staging OrderItems - TPDEV 1999
            if(!oItem.IsPortalCreated__c && oITem.SBQQ__QuoteLine__c != null)
            {
                listOrderItem.add(oItem);
            }
        }
        //System.debug('list Size==>' + listOrderItem.size());
        if(listOrderItem.size() > 0)
        {
            OrderItemTriggerHandler.handleBeforeInsert(listOrderItem);
        }
    }
}