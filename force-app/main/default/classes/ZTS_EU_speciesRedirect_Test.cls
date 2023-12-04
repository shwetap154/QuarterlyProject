@isTest (Seealldata = false)
public class ZTS_EU_speciesRedirect_Test{

    static testMethod void myTest(){
        PageReference pageRef = Page.ZTS_EU_speciesRedirect;
        Test.setCurrentPageReference(pageRef);
        ZTS_EU_Species_Product__c speObj1 = new ZTS_EU_Species_Product__c(Name = 'Test Territory', ZTS_EU_Type__c = 'Business Unit', ZTS_EU_Market__c = 'United Kingdom');
        insert speObj1;
        
        ZTS_EU_Species__c speObj = new ZTS_EU_Species__c(Name = 'Test Territory', ZTS_EU_Species__c = 'Pigs', ZTS_EU_Business_Unit__c = speObj1.id,  ZTS_EU_Market__c = 'United Kingdom');
        insert speObj;
        
        ZTS_EU_Species__c getztbObj = [select id from ZTS_EU_Species__c limit 1];
        Schema.DescribeSObjectResult r = ZTS_EU_Species__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        Apexpages.currentPage().getParameters().put('retURL','/'+keyPrefix+'/e');
        Apexpages.currentPage().getParameters().put('nooverride','1');
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.ZTS_EU_Market__c = 'United Kingdom';
        insert usr;

        Test.startTest();
            System.runAs(usr){            
        ApexPages.StandardController controller = new ApexPages.StandardController(getztbObj);
        ZTS_EU_speciesRedirect appRedirect = new ZTS_EU_speciesRedirect(controller);


                appRedirect.speciesRedirect();
            }
        Test.stopTest();        
    }
}