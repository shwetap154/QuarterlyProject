public with sharing class INTZTS_EU_ProductAdoptionProfileService {

    public static void beforeInsert(List<ZTS_EU_Product_Adoption_Profile__c> triggerNew){
        ZTS_EU_ProdAdoptionHistory.updatePrimaryAccount(triggerNew);
    }

    public static void beforeUpdate(List<ZTS_EU_Product_Adoption_Profile__c> triggerNew){
        ZTS_EU_ProdAdoptionHistory.updatePrimaryAccount(triggerNew);
    }

    public static void afterInsert(List<ZTS_EU_Product_Adoption_Profile__c> triggerNew){
        ZTS_EU_ProdAdoptionHistory.createProdAdoptHistory(triggerNew);
    }

    public static void afterUpdate(List<ZTS_EU_Product_Adoption_Profile__c> triggerNew){
        ZTS_EU_ProdAdoptionHistory.createProdAdoptHistory(triggerNew);
    }

}