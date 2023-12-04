/**
* @ClassName    : SL_SampleCreationHelper
* @JIRATicket   : LIGHTNI-1682
* @CreatedOn    : 10th Oct 2019
* @CreatedBy    : Premraj K K
* @ModifiedBy   : 
* @Description  : Helper logic that creates Sample records for Contacts based on Product-Hierarchy
*/
public class SL_SampleCreationHelper {
	
    public static void createSampleRecords(List<Contact> lstContacts, List<Id> productIds) {
        
        Integer currentYear = Date.today().year();
        List<ZTS_EU_Sample__c> newSamplesToCreate = new List<ZTS_EU_Sample__c>();
        
        String strQuery = 'Select Id From ZTS_EU_Species_Product__c ' +
            'Where Year__c =: currentYear AND ZTS_EU_Market__c = \'Italy\' AND ZTS_EU_is_Samplable__c = true ';
        
        if(!productIds.isEmpty())
            strQuery += 'AND Id IN :productIds';
        
        Map <Id, ZTS_EU_Species_Product__c> mapProducts = new Map<Id, ZTS_EU_Species_Product__c>(
            (List<ZTS_EU_Species_Product__c>)Database.query(strQuery)
        );
        
        if(mapProducts.isEmpty())
            return;
        
        for(Contact c : [Select AccountId,
                         (Select ZTS_EU_Product__c, ZTS_EU_Year__c
                          From Samples__r
                          Where ZTS_EU_Year__c =: String.valueOf(currentYear)
                         )
                         From Contact
                         Where Id IN :lstContacts]){
            
            set<Id> productIdsHavingSample = new set<Id>();
            Boolean isNullProductSampleExist = false;
            for(ZTS_EU_Sample__c s : c.Samples__r) {
                productIdsHavingSample.add(s.ZTS_EU_Product__c);
                
                if(!isNullProductSampleExist && s.ZTS_EU_Product__c == null)
                    isNullProductSampleExist = true;
            }
            
            set<Id> setProdIdsForSample = new set<Id>();
            for(Id prodId : mapProducts.keyset()) {
                if(!productIdsHavingSample.contains(prodId))
                	setProdIdsForSample.add(prodId);
            }
            
            for(Id prodId : setProdIdsForSample) {
                ZTS_EU_Species_Product__c prod = mapProducts.get(prodId);
                newSamplesToCreate.add(new ZTS_EU_Sample__c(ZTS_EU_Product__c = prod.Id,
                                                           	ZTS_EU_Account__c = c.AccountId,
                                                            ZTS_EU_Contact__c = c.Id,
                                                            ZTS_EU_Year__c = String.valueOf(currentYear),
                                                            ZTS_EU_Start_Quantity__c = 10,
                                                            ZTS_EU_Is_Active__c = true
                                                           ));
            }
            
            if(!isNullProductSampleExist) {
                newSamplesToCreate.add(new ZTS_EU_Sample__c(ZTS_EU_Product__c = null,
                                                            ZTS_EU_Account__c = c.AccountId,
                                                            ZTS_EU_Contact__c = c.Id,
                                                            ZTS_EU_Year__c = String.valueOf(currentYear),
                                                            ZTS_EU_Start_Quantity__c = 10,
                                                            ZTS_EU_Is_Active__c = true,
                                                            ZTS_EU_Is_used_for_old_SKUs__c = true
                                                           ));
            }
        }
        
        if(! newSamplesToCreate.isEmpty())
             Database.insert(newSamplesToCreate, false);
    }
}