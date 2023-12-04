@isTest
private class PIT_TestTestOrderedNewController {

    static testMethod void testController() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'mrTest';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr){

            String testRid =  [select Id, DeveloperName from RecordType where DeveloperName = 'PIT_Swab'].Id;
            
            Apexpages.currentPage().getParameters().put('RecordType', testRid);
            
            Account acc = new Account();
            acc.Name = 'test account';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            acc.BillingPostalCode = '12345';
            acc.BillingCity = 'Boca Raton';
            acc.BillingState = 'Florida';
            acc.BillingStreet = 'Elm Lane';
            acc.ZTS_EU_Market__c = 'United States';
            insert acc;
            
            PIT_STOMP__c stomp = new PIT_STOMP__c();
            stomp.PIT_Diagnostic_Lab__c = 'University of Iowa';
            stomp.PIT_Account__c = acc.Id;
            insert stomp;
            
            PIT_Test_Ordered__c testOrdered = new PIT_Test_Ordered__c();
            testOrdered.PIT_STOMP__c = stomp.Id;
            
            ApexPages.Standardcontroller stdCtrl = new Apexpages.Standardcontroller(testOrdered);
            
            PIT_TestOrderedNewController testCtrl = new PIT_TestOrderedNewController(stdCtrl);
            
            //no custom settings inserted so only - None - on the list
            System.assertEquals(1, testCtrl.getTests().size());
            
            ApexPages.currentPage().getHeaders().put('Referer', 'test');

            testCtrl.saveAndNew();
            
            test.startTest();
            test.stopTest();
        }
        
    }
    
    static testMethod void testControllerTissue() {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'mrTest';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr){
            String testRid =  [select Id, DeveloperName from RecordType where DeveloperName = 'PIT_Tissue'].Id;
            
            Apexpages.currentPage().getParameters().put('RecordType', testRid);
            
            Account acc = new Account();
            acc.Name = 'test account';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            acc.BillingPostalCode = '12345';
            acc.BillingCity = 'Boca Raton';
            acc.BillingState = 'Florida';
            acc.BillingStreet = 'Elm Lane';
            acc.ZTS_EU_Market__c = 'United States';
            insert acc;
            
            PIT_STOMP__c stomp = new PIT_STOMP__c();
            stomp.PIT_Diagnostic_Lab__c = 'University of Iowa';
            stomp.PIT_Account__c = acc.Id;
            insert stomp;
            
            PIT_Test_Ordered__c testOrdered = new PIT_Test_Ordered__c();
            testOrdered.PIT_STOMP__c = stomp.Id;
            
            ApexPages.Standardcontroller stdCtrl = new Apexpages.Standardcontroller(testOrdered);
            
            PIT_TestOrderedNewController testCtrl = new PIT_TestOrderedNewController(stdCtrl);
            
            //no custom settings inserted so only - None - on the list
            System.assertEquals(1, testCtrl.getTests().size());
            
            ApexPages.currentPage().getHeaders().put('Referer', 'test');

            testCtrl.saveAndNew();
            
            test.startTest();
            
            test.stopTest();
        }
        
    }
    
    static testMethod void testControllerSerology() {
        
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'mrTest';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr){
            
            String testRid =  [select Id, DeveloperName from RecordType where DeveloperName = 'PIT_Pig_Serology'].Id;
            
            Apexpages.currentPage().getParameters().put('RecordType', testRid);
            
            Account acc = new Account();
            acc.Name = 'test account';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            acc.BillingPostalCode = '12345';
            acc.BillingCity = 'Boca Raton';
            acc.BillingState = 'Florida';
            acc.BillingStreet = 'Elm Lane';
            acc.ZTS_EU_Market__c = 'United States';
            insert acc;
            
            PIT_STOMP__c stomp = new PIT_STOMP__c();
            stomp.PIT_Diagnostic_Lab__c = 'University of Iowa';
            stomp.PIT_Account__c = acc.Id;
            insert stomp;
            
            PIT_Test_Ordered__c testOrdered = new PIT_Test_Ordered__c();
            testOrdered.PIT_STOMP__c = stomp.Id;
            
            ApexPages.Standardcontroller stdCtrl = new Apexpages.Standardcontroller(testOrdered);
            
            PIT_TestOrderedNewController testCtrl = new PIT_TestOrderedNewController(stdCtrl);
            
            //no custom settings inserted so only - None - on the list
            System.assertEquals(1, testCtrl.getTests().size());
            
            ApexPages.currentPage().getHeaders().put('Referer', 'test');

            testCtrl.saveAndNew();
            
            test.startTest();
            
            test.stopTest();
        }
        
    }
}