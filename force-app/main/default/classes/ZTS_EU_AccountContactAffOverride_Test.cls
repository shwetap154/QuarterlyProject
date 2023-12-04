@isTest (SeeAlldata = False)
public class ZTS_EU_AccountContactAffOverride_Test{

    static testMethod void myTest(){
        PageReference pageRef = Page.ZTS_EU_NewAccountContactAffilOverride ;
        Test.setCurrentPageReference(pageRef);
        List<Account> accountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert accountRecord;
        }
        

        List<Contact>contactRecord=ZTS_EU_DataUtilityTest.createContactRecord(1);
        insert contactRecord;

        Account getaccObj = [select id, ZTS_EU_Market__c from Account where Id =: accountRecord[0].id AND ZTS_EU_Market__c != 'United States'];

        Schema.DescribeSObjectResult r = ZTS_EU_Affiliations__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        Apexpages.currentPage().getParameters().put('retURL','/'+keyPrefix+'/e');
        Apexpages.currentPage().getParameters().put('nooverride','1');
        
        Apexpages.currentPage().getParameters().put('nooverride','1');
        Apexpages.currentPage().getParameters().put('accName',accountRecord[0].name);
        Apexpages.currentPage().getParameters().put('accountId',accountRecord[0].id);        
        Apexpages.currentPage().getParameters().put('conName',contactRecord[0].name);
        Apexpages.currentPage().getParameters().put('contactId',contactRecord[0].id);        
        ApexPages.StandardController controller = new ApexPages.StandardController(getaccObj);
        ZTS_EU_AccountContactAffiliationOverride appRedirect = new ZTS_EU_AccountContactAffiliationOverride(controller);
        appRedirect.addRedirect();
        
    }
    static testMethod void myTest1(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        PageReference pageRef = Page.ZTS_EU_NewAccountContactAffilOverride ;
        Test.setCurrentPageReference(pageRef);
        List<Account>accountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert accountRecord;
        }
        List<Contact>contactRecord=ZTS_EU_DataUtilityTest.createContactRecord(1);
        contactRecord[0].ZTS_EU_Market__c = 'Italy';
        System.runAs(usr){
            insert contactRecord;
        }


        Contact getconObj = [select id from Contact where Id =: contactRecord[0].id AND ZTS_EU_Market__c != 'United States'];

        Schema.DescribeSObjectResult r = ZTS_EU_Affiliations__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        Apexpages.currentPage().getParameters().put('retURL','/'+keyPrefix+'/e');
        Apexpages.currentPage().getParameters().put('nooverride','1');
        
        Apexpages.currentPage().getParameters().put('nooverride','1');
        Apexpages.currentPage().getParameters().put('accName',accountRecord[0].name);
        Apexpages.currentPage().getParameters().put('accountId',accountRecord[0].id);        
        Apexpages.currentPage().getParameters().put('conName',contactRecord[0].name);
        Apexpages.currentPage().getParameters().put('contactId',contactRecord[0].id);        
        ApexPages.StandardController controller = new ApexPages.StandardController(getconObj);
        ZTS_EU_AccountContactAffiliationOverride appRedirect = new ZTS_EU_AccountContactAffiliationOverride(controller);
        appRedirect.addRedirect();
        
    }
}