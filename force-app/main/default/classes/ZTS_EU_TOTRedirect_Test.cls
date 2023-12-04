@isTest (SeeAlldata = False)
public class ZTS_EU_TOTRedirect_Test{
    
    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            PageReference pageRef = Page.ZTS_EU_TOTRedirect;
            Test.setCurrentPageReference(pageRef);
            
            //create Time out of Territory
            Time_Out_of_Territory__c terrObj = new Time_Out_of_Territory__c(ZTS_EU_Status__c ='Planned', 
                                                                            ZTS_EU_Start_Date__c = System.today(), 
                                                                            ZTS_EU_End_Date__c = System.today() + 10,
                                                                            ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM');
            insert terrObj;
            
            Time_Out_of_Territory__c getTerrObj = [SELECT Id
                                                   FROM Time_Out_of_Territory__c 
                                                   limit 1];
            
            Schema.DescribeSObjectResult r = Time_Out_of_Territory__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            
            Apexpages.currentPage().getParameters().put('retURL','/'+keyPrefix+'/e');
            Apexpages.currentPage().getParameters().put('nooverride','1');
            
            ApexPages.StandardController controller = new ApexPages.StandardController(getTerrObj);
            ZTS_EU_TOTRedirect appRedirect = new ZTS_EU_TOTRedirect(controller);
            appRedirect.totRedirect();
            appRedirect.backToView();
        }
    }
}