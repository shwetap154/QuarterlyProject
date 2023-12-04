@isTest
private class SL_NewRequest_Test 
{
    private static testMethod void test_SL_NewRequest() 
    {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        Account objAccount = new Account();
        Contact objContact = new Contact();
        ApexPages.StandardSetController setCon;
        SL_NewRequest objCntl;
        SL_NewRequest objCntl1;
        SL_NewRequest objCntl2;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            
            objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
            ZTS_EU_Species_Specialty__c='Cattle', ZTS_EU_District__c='UK', ZTS_EU_Market__c = 'Italy');
            insert objContact;
            
            
            ZTS_EU_Affiliations__c objAff = [SELECT Id, Name FROM ZTS_EU_Affiliations__c 
                                             WHERE ZTS_EU_Account__c = :objAccount.Id
                                               AND ZTS_EU_Contact__c = :objContact.Id];
            
            PageReference pageRef = Page.SL_New_Request;      
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', objAccount.Id);
            
            setCon = new ApexPages.StandardSetController(new List<ZTS_EU_Request__c>());
            objCntl = new SL_NewRequest(setCon);
            objCntl.fetchNewTemplate();

            ApexPages.currentPage().getParameters().put('id', objContact.Id);
            objCntl1 = new SL_NewRequest(setCon);
            objCntl1.fetchNewTemplate();

            ApexPages.currentPage().getParameters().put('id', objAff.Id);
            objCntl2 = new SL_NewRequest(setCon);
            objCntl2.fetchNewTemplate();
        }
        system.assertNotEquals(objCntl.strURLLocation, null);
        
        system.assertNotEquals(objCntl1.strURLLocation, null);
        
        system.assertNotEquals(objCntl2.strURLLocation, null);
    }
}