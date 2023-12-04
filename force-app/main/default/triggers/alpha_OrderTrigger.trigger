/**
 * @description       : 
 * @author            : Cognizant
 * @group             : 
 * @last modified on  : 08-28-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
trigger alpha_OrderTrigger on Order (before insert,before update,after insert,after update,before delete, after delete) {
    TriggerFactory.createAndExecuteHandler(OrderHandler.class);
}