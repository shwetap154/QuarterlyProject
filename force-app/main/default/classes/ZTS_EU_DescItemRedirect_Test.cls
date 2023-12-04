@isTest (SeeAlldata = False)
public class ZTS_EU_DescItemRedirect_Test{
    
    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            PageReference pageRef = Page.ZTS_EU_DiscItemRedirect;
            Test.setCurrentPageReference(pageRef);
            
            //create Time out of Territory
            ZTS_EU_Discussion_Item__c descitemObj = new ZTS_EU_Discussion_Item__c(ZTS_EU_Discussion_Item_Title__c = 'Test Class', ZTS_EU_Market__C = 'Italy');
            insert descitemObj;
            
            ZTS_EU_Discussion_Item__c getdescitemObj = [select id from ZTS_EU_Discussion_Item__c WHERE ZTS_EU_Market__C != 'United States' limit 1];
            
            Apexpages.currentPage().getParameters().put('retURL','/a0s/o');
            Apexpages.currentPage().getParameters().put('nooverride','1');
            Apexpages.currentPage().getParameters().put('00NL00000037B9G','United Kingdom');
            
            ApexPages.StandardController controller = new ApexPages.StandardController(getdescitemObj);
            ZTS_EU_DescItemRedirect appRedirect = new ZTS_EU_DescItemRedirect(controller);
            appRedirect.descitemRedirect();   
        }
    }
}