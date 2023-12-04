@isTest
private class PIT_TestSTOMP_editController {
    
    static testMethod void testController() {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr){
            
            Account acc = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            acc.Name = 'testAcc';        
            insert acc;        
            
            PageReference pageRef = Page.PIT_STOMPAccountSelect;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('accId', acc.id);
            
            PIT_STOMP__c stomp = new PIT_STOMP__c();
            PIT_STOMP_editController controller = new PIT_STOMP_editController(new ApexPages.StandardController(stomp));
            
            ZTS_EU_Species_Product__c product = new ZTS_EU_Species_Product__c();
            product.Name = 'testProduct';
            insert product;
            
            PIT_STOMP_product__c stompProduct = new PIT_STOMP_product__c();
            stompProduct.PIT_Product__c = product.id;
            
            controller.newProduct = stompProduct;
            
            controller.addProduct();
            
            System.assertEquals(1, controller.stompProducts.size());
            System.assertEquals(product.id, controller.stompProducts[0].PIT_Product__c);
            
            PIT_STOMP_product__c stompProductDuplicate = new PIT_STOMP_product__c();
            stompProductDuplicate.PIT_Product__c = product.id;
            
            controller.newProduct = stompProductDuplicate;
            
            controller.addProduct();
            
            System.assertEquals(1, controller.stompProducts.size());
            
            controller.productToRemove = product.id;        
            controller.removeProduct();
            System.assertEquals(0, controller.stompProducts.size());
            
            controller.newProduct = stompProduct;        
            controller.addProduct();
            
            controller.CustomSave();
            
            System.assert(stomp.id != null);
        }
        
    }
    
}