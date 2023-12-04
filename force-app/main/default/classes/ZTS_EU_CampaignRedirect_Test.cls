@isTest (SeeAlldata = False)
public class ZTS_EU_CampaignRedirect_Test{
    
    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            PageReference pageRef = Page.ZTS_EU_CampaignRedirect ;
            Test.setCurrentPageReference(pageRef);
            
            //create Time out of Territory
            Campaign campObj = new Campaign(Name = 'Test Campaign', Campaign_Name_English__c = 'TestCampaign', ZTS_EU_Market__c = 'United Kingdom');
            insert campObj;
            
            Campaign getcampObj = [select id from Campaign where ZTS_EU_Market__c != 'United States' limit 1];
            Apexpages.currentPage().getParameters().put('nooverride','1');
            ApexPages.StandardController controller = new ApexPages.StandardController(getcampObj);
            ZTS_EU_CampaignRedirect  appRedirect = new ZTS_EU_CampaignRedirect (controller);
            appRedirect.campRedirect();
        }
    }
}