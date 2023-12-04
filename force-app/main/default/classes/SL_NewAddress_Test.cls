@isTest
private class SL_NewAddress_Test {
    
    private static testMethod void test_SL_NewAddress() {
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        Account objAccount = new Account();
        Contact objContact = new Contact();
        ApexPages.StandardSetController setCon;
        SL_NewAddress objCntl;
        SL_NewAddress objCntl1;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
            ZTS_EU_Species_Specialty__c='Cattle', ZTS_EU_District__c='UK', ZTS_EU_Market__c = 'Italy');
            insert objContact;
            
            PageReference pageRef = Page.SL_NewAddress;      
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', objAccount.Id);
            
            setCon = new ApexPages.StandardSetController(new List<Address__c>());
            objCntl = new SL_NewAddress(setCon);
            objCntl.fetchRecordURL();

            ApexPages.currentPage().getParameters().put('id', objContact.Id);
            objCntl1 = new SL_NewAddress(setCon);
            objCntl1.fetchRecordURL();
            
        }
        system.assertEquals(objCntl.strFieldAPIName, 'ZTS_EU_Account__c');
        
        
        
        system.assertEquals(objCntl1.strFieldAPIName, 'ZTS_EU_Contact__c');
    }   
}