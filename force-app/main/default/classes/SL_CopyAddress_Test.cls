@isTest
private class SL_CopyAddress_Test 
{
    static void testSetup()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            Contact objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
            ZTS_EU_Species_Specialty__c='Cattle', ZTS_EU_District__c='UK', ZTS_EU_Market__c = 'United Kingdom');
            insert objContact;
            
            // ZTS_EU_Affiliations__c objAff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = objContact.Id, ZTS_EU_Account__c=objAccount.Id);
            // insert objAff;
        }
    }
    private static testMethod void test_SL_CopyAddress() 
    {
        testSetup();
        User intUser = [SELECT Id FROM User WHERE FirstName = 'IntUser'][0];

        Account objAccount = [SELECT Id, ZTS_EU_Address_Line_1__c FROM Account][0];
        ZTS_EU_Affiliations__c objAff = [SELECT Id FROM ZTS_EU_Affiliations__c][0];
        Contact objContact = [SELECT Id FROM Contact][0];
        System.runAs(intUser) {
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('id', objAff.Id);
            
            ApexPages.StandardController setCon = new ApexPages.StandardController(objAff);
            SL_CopyAddress objCntl = new SL_CopyAddress(setCon);
            SL_CopyAddress.updateContactAddress(objAff.Id);
            Test.stopTest();
        }

        
        system.assertEquals([Select Id,ZTS_EU_Address_Line_1__c From Contact Where Id =: objContact.Id AND ZTS_EU_Market__c != 'United States'].ZTS_EU_Address_Line_1__c, objAccount.ZTS_EU_Address_Line_1__c);
    }
}