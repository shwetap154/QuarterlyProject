@isTest
public with sharing class ZTS_EU_Species_Product_Test{

    static testMethod void ZTS_EU_Species_Product()
    {
        List <TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
        TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_Species_Product', ZTS_EU_Bypass__c = true);
        triggerActiveList.add(tr);
        insert triggerActiveList;
        MarketGeoMapping__c marketGeoMappingObj = new MarketGeoMapping__c();
        marketGeoMappingObj.Geo__c = 'CLAR';
        marketGeoMappingObj.Name = 'United Kingdom';
        marketGeoMappingObj.Product_Potential_Level__c = 'SKU';
        insert marketGeoMappingObj;
        
        Test.startTest();
        
        ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
        prodSpecies.Name='Test Product';
        prodSpecies.ZTS_EU_Market__c='United Kingdom';
        prodSpecies.ZTS_EU_Type__c='Brand';
        prodSpecies.CurrencyIsoCode = 'EUR';
        prodSpecies.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpecies.ZTS_EU_Is_Active__c=true;
        
        insert prodSpecies;
        
        System.assertEquals(	marketGeoMappingObj.Product_Potential_Level__c
                            , 	[	SELECT ZTS_EU_Product_Potential_Level__c 
                                 	FROM ZTS_EU_Species_Product__c 
                                 	WHERE Id = :prodSpecies.Id
                                ].ZTS_EU_Product_Potential_Level__c
                            ,	'Trigger did not set right value');
        
        ZTS_EU_Product_Gift_Limit__c prodGiftList = new ZTS_EU_Product_Gift_Limit__c();
        
        prodGiftList.CurrencyIsoCode = 'EUR';
        prodGiftList.ZTS_EU_Product__c=prodSpecies.id;
        
        insert prodGiftList;
        
        try
        {
            delete prodSpecies;
            System.assert(false);
            
        }
        catch(DMLException e)
        {
            System.assert(e.getMessage().contains('Delete failed. First exception on'));
            
        }
        
        Test.stopTest();
    }   
}