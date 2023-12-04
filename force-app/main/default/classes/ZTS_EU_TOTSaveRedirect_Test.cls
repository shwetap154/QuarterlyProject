@isTest (SeeAlldata = False)
public class ZTS_EU_TOTSaveRedirect_Test{
    
    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            PageReference pageRef = Page.ZTS_EU_TOTSaveRedirect;
            Test.setCurrentPageReference(pageRef);
            
            //create Time out of Territory
            Time_Out_of_Territory__c terrObj = new Time_Out_of_Territory__c(ZTS_EU_Status__c ='Planned', ZTS_EU_Start_Date__c = System.today(), ZTS_EU_End_Date__c = System.today() + 10, ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM', ZTS_Market__c = 'United Kingdom');
            insert terrObj;
            
            
            Time_Out_of_Territory__c getTerrObj = [select id from Time_Out_of_Territory__c WHERE ZTS_Market__c != 'United States' limit 1];
            
            //ApexPages.CurrentPage().getparameters().put('pid', getTerrObj[0].id);
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(getTerrObj);
            ZTS_EU_TOTSaveRedirect sic = new ZTS_EU_TOTSaveRedirect (sc);
            sic.save_submit();
            
            ApexPages.StandardController sc1 = new ApexPages.standardController(getTerrObj);
            ZTS_EU_TOTSaveRedirect sic1 = new ZTS_EU_TOTSaveRedirect (sc1);
            sic1.throwTOTSaveRedirectTestException= true;
            sic1.save_submit();
            Test.stopTest();
        }
    }
}