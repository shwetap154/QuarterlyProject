/**
 * @description       : Test class component controller ZTS_EU_SalesCallOrderController.
 * @author            : Ilirjana @ Unknown
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-10-2014   Ilirjana @ Unknown          Created(T-14040 Order)
 * 1.1   06-07-2022   Ethan Hirsch @ Zoetis Inc   Change the User used in the Unit Test to us a UK Profile instead of the Standard User Profile.
**/
@isTest(SeeAllData=false)
public class ZTS_EU_SalesCallOrderControllerTest 
{   
    //Ilirjana 30/9/2014 T-14040
    static testMethod void runOrderTest(){
        User userIns = ZTS_EU_DataUtilityTest.createUserWithProfile('ZTS UK Field Based Function', true);
        userIns.ZTS_EU_Market__c = 'United Kingdom';
        update userIns;
        
        Call__c call;
        system.runAs(userIns){
            call = ZTS_EU_DataUtilityTest.createCall(true);
            
            Call__c callfetched = new Call__c();
            
            if(call != null){
                callfetched = [Select Id, ZTS_EU_Account__c from Call__c where Id =: call.Id AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];        
            }
            /*ZTS_EU_Species_Product__c productBrand = ZTS_EU_DataUtilityTest.createProduct(ZTS_EU_Constants.productTypeBrand, false);
            productBrand.ZTS_US_Abaxis_Orderable__c = true;
            insert productBrand;
            
            ZTS_EU_Species_Product__c productMPG = ZTS_EU_DataUtilityTest.createProduct(ZTS_EU_Constants.productTypeMPG, false);
            productMPG.ZTS_US_Abaxis_Orderable__c = true;
            productMPG.ZTS_EU_Parent_Species_Product__c = productBrand.Id;
            insert productMPG;
            */
            ZTS_EU_Species_Product__c productSKU = ZTS_EU_DataUtilityTest1.createProductSKURecord(1)[0];
            productSKU.ZTS_US_Abaxis_Orderable__c = true;
            productSKU.ZTS_EU_Is_Active__c = true;
            productSKU.ZTS_EU_Is_Orderable__c = true;
            productSKU.ZTS_EU_Standard_Price__c = 123;
            insert productSKU;
            
            Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            acc.Type = 'Distributor';
            insert acc;
            
            Orders__c order = new Orders__c();
            order.Call__c = call.Id;
            order.ZTS_EU_Dealer_Distributor__c = acc.Id;
            order.Sales_Price__c = Decimal.valueOf(2000);
            order.ZTS_EU_Fulfillment_Date__c = System.today();
            order.Product__r = productSKU;
            order.Product__c = productSKU.Id;
            order.Quantity__c = 10;
            order.ZTS_EU_Account__c = callfetched.ZTS_EU_Account__c ;
            insert order;
             
            //Orders__c order = ZTS_EU_DataUtilityTest.createOrderForCall(call.Id, true);
            ZTS_EU_Species_Product__c product = ZTS_EU_DataUtilityTest1.createProductSKURecord(1)[0];
            product.ZTS_US_Abaxis_Orderable__c = true;
            product.ZTS_EU_Is_Active__c = true;
            product.ZTS_EU_Is_Orderable__c = true;
            product.ZTS_EU_Standard_Price__c = 123;
            insert product;
            
            PageReference pg =new PageReference('/apex/ZTS_EU_ViewSalesCallDetails');
            pg.getParameters().put('id',call.Id);
            Test.SetCurrentPageReference(pg); 
            
            
            ZTS_EU_SalesCallOrderController controller = new ZTS_EU_SalesCallOrderController();
            controller.newOrder = order;
            
            controller.addOrderRow();
            System.assert(controller.addOrderClicked, 'Method addOrderRow should change addOrderClicked flag to true.');
            
            System.assert(controller.listPrice == null || controller.listPrice == Decimal.valueOf(0), 'List price nust be empty or 0 before filling it from order product.');
            controller.getListPriceForProduct();
            System.assert(controller.listPrice != null && controller.listPrice != Decimal.valueOf(0), 'List price nust not be empty nor 0 after filling it from order product.');
            test.startTest();
            controller.addNewOrder();
            List<Orders__c> orders = controller.getOrders();
            System.assert(orders != null && orders.size() > 0, 'There should be at least 1 order in the database.');  
            
            controller.removeOrder();
            System.assert(controller.getOrders() != null && controller.getOrders().size() > 0, 'There should be at least 1 order in the database.'); 
            controller.selectedOrderId = order.Id;
            controller.removeOrder();
            System.assert(controller.getOrders() == null || controller.getOrders().size() == 0, 'After removeOrder() is done, there should be no orders.');
            
            //controller.newOrder = ZTS_EU_DataUtilityTest.createOrderForCall(call.Id, true);
            
            Orders__c order2 = new Orders__c();
            order2.Call__c = call.Id;
            order2.ZTS_EU_Dealer_Distributor__c = acc.Id;
            order2.Sales_Price__c = Decimal.valueOf(2000);
            order2.ZTS_EU_Fulfillment_Date__c = System.today();
            order2.Product__r = productSKU;
            order2.Product__c = productSKU.Id;
            order2.Quantity__c = 10;
            order2.ZTS_EU_Account__c = callfetched.ZTS_EU_Account__c ;
            insert order2;
            
            controller.newOrder = order2;
            
            
            controller.newOrder.Sales_Price__c = Decimal.ValueOf(1234567890);
            
            controller.addOrderClicked = false;
            controller.editOrder();
            System.assert(controller.addOrderClicked, 'Method editOrder() should change addOrderClicked flag to true.');
            
            test.stopTest();
        }
    }
}