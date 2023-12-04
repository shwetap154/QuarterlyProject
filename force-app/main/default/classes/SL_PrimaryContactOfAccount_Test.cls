@isTest
private class SL_PrimaryContactOfAccount_Test 
{
    @testSetup static void test_setUp() 
    { 

        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            Contact objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
                                            ZTS_EU_Species_Specialty__c='Cattle', Select_Consent_for_eSign__c ='Privacy', ZTS_EU_District__c='UK', ZTS_EU_Market__c='United Kingdom');
            insert objContact;
        }
        
    }
    
	private static testMethod void test_SL_PrimaryContactOfAccount() 
	{
        ZTS_EU_Affiliations__c objAffiliation = [Select Id, ZTS_EU_Contact__c, ZTS_EU_Account__c 
                                                   From ZTS_EU_Affiliations__c where ZTS_EU_Market_from_Parent__c != 'United States' Limit 1];
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            SL_PrimaryContactOfAccount objCntl = new SL_PrimaryContactOfAccount();
            SL_PrimaryContactOfAccount.updateAccount(objAffiliation.Id);
        }
        system.assertNotEquals([Select ZTS_EU_Primary_Contact__c From Account WHERE ZTS_EU_Market__c != 'United States' Limit 1].ZTS_EU_Primary_Contact__c, null); 
	}

}