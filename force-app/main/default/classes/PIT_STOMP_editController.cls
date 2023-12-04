public with sharing class PIT_STOMP_editController {

    public PIT_STOMP__c stomp {get;set;}
    public List<PIT_STOMP_product__c> stompProducts {get;set;}
    public PIT_STOMP_product__c newProduct {get;set;}
        
    public String productToRemove {get;set;}
    private List<PIT_STOMP_product__c> stompProductsToRemove;
    
    
    public PIT_STOMP_editController(ApexPages.StandardController controller) {
        if(!Test.isRunningTest()) {
            controller.addFields(new List<string>{
                        'PIT_Status__c',
                        'PIT_Owner_Manager__c',
                        'PIT_Account__c',
                        'PIT_Approving_Vet__c',
                        'PIT_Site__c',
                        'PIT_Consulting_Vet__c',
                        'PIT_Diagnostic_Lab__c',
                        'PIT_What_Question_Needs_to_be_Answered__c',
                        'PIT_Describe_Problem_On_Farm__c',
                        'Reason_for_STOMP__c',
                        'Follow_Up_Notes__c',
                        'Date_Follow_Up_Completed__c',
                        'Outcome__c'
                    });
        }
        stomp = (PIT_STOMP__c)controller.getRecord();
        if(stomp.PIT_Account__c == null) {
            String accId = ApexPages.currentPage().getParameters().get('accId');
            if(accId != null) {
                stomp.PIT_Account__c = accId;
            }
        }
        //System.debug('stomp.Date_Follow_Up_Completed__c--------'+stomp.Date_Follow_Up_Completed__c);
        stomp.PIT_Owner_Manager__c = [SELECT ManagerId FROM User WHERE id = :UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'].ManagerId;
        
        stompProducts = new List<PIT_STOMP_product__c>();
        if(stomp.id != null && stompProducts.isEmpty()) {
            stompProducts = [SELECT id, PIT_STOMP__c, PIT_Product__c FROM PIT_STOMP_product__c WHERE PIT_STOMP__c = :controller.getRecord().id];
        }
        newProduct = new PIT_STOMP_product__c();
        productToRemove ='';
        stompProductsToRemove = new List<PIT_STOMP_product__c>();
        System.debug('stomp ::: '+stomp);

    }

    public PageReference customCancel() {
        return new ApexPages.Action('{!List}').invoke();
    }
    
    public PageReference customSave() {
        try {
            delete stompProductsToRemove;
            upsert stomp;
            
            for(PIT_STOMP_product__c prod :stompProducts) {
                prod.PIT_STOMP__c = stomp.id;
            }
            
            upsert stompProducts;
            
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        return new PageReference('/' + stomp.id);
    }
    
    public PageReference addProduct() {
        if(newProduct.PIT_Product__c != null && !isProductInTheList(newProduct.PIT_Product__c)) {
            stompProducts.add(newProduct);
        }
        newProduct = new PIT_STOMP_product__c();
        return null;
    }
    
    private Boolean isProductInTheList(id productId) {
        Set<Id> productListIds = new Set<Id>();
        for(PIT_STOMP_Product__c stompProduct : stompProducts) {
            productListIds.add(stompProduct.PIT_Product__c);
        }
        
        if(productListIds.contains(productId)) {
            return true;
        } else {
            return false;
        }
    }
    
    public PageReference removeProduct() {
        Integer indexToRemove;

        for(Integer i=0 ; i < stompProducts.size(); i++) {

            if(String.valueOf(stompProducts[i].PIT_Product__c).substring(0,15) == productToRemove.substring(0,15)) {
                indexToRemove = i;

                break;
            }
            
        }
        
        if(indexToRemove != null) {
            if(stompProducts[indexToRemove].id != null) {
                stompProductsToRemove.add(stompProducts[indexToRemove]);    
            }
            stompProducts.remove(indexToRemove);

        }
        productToRemove = '';
        return null;
    }

}