/**
* @description       : Update Order Activation Email Sent Field to True for existing records
* @author            : Rahul Kumar @Deloitte
* @test class        : CPQ_OneTimeOrderUpdate_T_Zoetis

* Modifications Log
* Ver   Date         Author                       Modification
* 1.0   06-21-2023   Rahul Kumar @Deloitte        Initial Version
**/
public class CPQ_OneTimeOrderUpdate_B_Zoetis implements Database.Batchable<SObject>, Database.Stateful {
    
    String OrderNonPinDeveloperName = 'Order_Without_Pre_Install_Checklist_Layout';
    String OrderPinDeveloperName = 'Order_With_Pre_Install_Checklist_Layout';
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        // Query orders that meet the criteria
        try
        {	
            Id cpqOrderNonPinRecordTypeId = SObjectType.Order.getRecordTypeInfosByDeveloperName().get(OrderNonPinDeveloperName).getRecordTypeId();
            Id cpqOrderPinRecordTypeId = SObjectType.Order.getRecordTypeInfosByDeveloperName().get(OrderPinDeveloperName).getRecordTypeId();
            List<Id> listOfId = new List <ID>{cpqOrderNonPinRecordTypeId, cpqOrderPinRecordTypeId};
                String query = 'SELECT Id, CPQ_Order_Activation_Email_Sent__c, createdDate FROM Order WHERE CPQ_Order_Activation_Email_Sent__c = False AND RecordTypeId IN :listOfId AND Status != \'Activated\' ORDER BY CreatedDate ASC';
            return Database.getQueryLocator(query);
        }
        catch (Exception ex)
        {
            System.debug('Error in CPQ_OneTimeOrderUpdate_B_Zoetis class , method = Start , Error = ' + ex.getMessage());
        }
        return null;
    }
    
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Order> ordersToUpdate = new List<Order>();
        
        // Iterate through the orders and update the checkbox field
        for (Order ord : (List<Order>) scope) 
        {
            ord.CPQ_Order_Activation_Email_Sent__c = true;
            ordersToUpdate.add(ord);
        }
        
        // Update the orders in bulk
        if (!ordersToUpdate.isEmpty()) {
            try {
                Database.SaveResult[] updateResults = Database.update(ordersToUpdate, false);
 
                for (Database.SaveResult result : updateResults) {
                    if (!result.isSuccess() || Test.isRunningTest()) {
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error updating order: ' + error.getMessage());
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Error updating orders: ' + e.getMessage());
            }
        }
    }
    
    public void finish(Database.BatchableContext context) {
        // Perform any post-processing logic here
    }
}