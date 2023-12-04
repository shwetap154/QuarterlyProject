@isTest (Seealldata = false)
public class ZTS_EU_SpeciesProducRedirect_Test{

    static testMethod void myTest(){
        PageReference pageRef = Page.ZTS_EU_SpeciesProducRedirect;
        Test.setCurrentPageReference(pageRef);
        
        ZTS_EU_Species_Product__c spObj = new ZTS_EU_Species_Product__c(Name = 'Test Territory', ZTS_EU_Market__c = 'United Kingdom');
        insert spObj;
        
        ZTS_EU_Species_Product__c getspObj = [select id from ZTS_EU_Species_Product__c limit 1];
        Schema.DescribeSObjectResult r = ZTS_EU_Species_Product__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        Apexpages.currentPage().getParameters().put('retURL','/'+keyPrefix+'/e');
        Apexpages.currentPage().getParameters().put('nooverride','1');
                
        ApexPages.StandardController controller = new ApexPages.StandardController(getspObj);
        ZTS_EU_SpeciesProducRedirect appRedirect = new ZTS_EU_SpeciesProducRedirect(controller);
        Test.startTest();
        appRedirect.spRedirect();
        Test.stopTest();      
        
    }
}