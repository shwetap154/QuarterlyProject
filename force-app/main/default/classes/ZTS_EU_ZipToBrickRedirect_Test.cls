@isTest (Seealldata = false)
public class ZTS_EU_ZipToBrickRedirect_Test{

    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.ZTS_EU_Market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {  
            PageReference pageRef = Page.ZTS_EU_ZipToBrickRedirect;
            Test.setCurrentPageReference(pageRef);
            
            ZTS_GL_ZipToBrick__c ztbObj = new ZTS_GL_ZipToBrick__c(Name = 'Test Territory', ZTS_EU_Market__c = 'United Kingdom');
            insert ztbObj;
            
            ZTS_GL_ZipToBrick__c getztbObj = [select id from ZTS_GL_ZipToBrick__c limit 1];
            
            Schema.DescribeSObjectResult r = ZTS_GL_ZipToBrick__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            
            
            Apexpages.currentPage().getParameters().put('retURL','/'+keyPrefix+'/e');
            Apexpages.currentPage().getParameters().put('nooverride','1');
                            
            ApexPages.StandardController controller = new ApexPages.StandardController(getztbObj);
            ZTS_EU_ZipToBrickRedirect appRedirect = new ZTS_EU_ZipToBrickRedirect(controller);
            Test.startTest();
            appRedirect.ztbRedirect();
            Test.stopTest();  
        }      
    }
}