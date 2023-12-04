@isTest (SeeAlldata = False)
public class ZTS_EU_BrickToTerritoryRedirect_Test{

    static testMethod void myTest(){
        PageReference pageRef = Page.ZTS_EU_BrickToTerritoryRedirect;
        Test.setCurrentPageReference(pageRef);

        //create Time out of Territory
        ZTS_GL_BrickToTerr__c bttObj = new ZTS_GL_BrickToTerr__c(ZTS_EU_Market__c = 'United Kingdom');
        insert bttObj;
        
        ZTS_GL_BrickToTerr__c getbttObj = [select id from ZTS_GL_BrickToTerr__c limit 1];
        Schema.DescribeSObjectResult r = ZTS_GL_BrickToTerr__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        Apexpages.currentPage().getParameters().put('retURL','/'+keyPrefix+'/e');
        Apexpages.currentPage().getParameters().put('nooverride','1');

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        { 
            ApexPages.StandardController controller = new ApexPages.StandardController(getbttObj);
            ZTS_EU_BrickToTerritoryRedirect appRedirect = new ZTS_EU_BrickToTerritoryRedirect(controller);
            appRedirect.bttRedirect();
        }
    }
}