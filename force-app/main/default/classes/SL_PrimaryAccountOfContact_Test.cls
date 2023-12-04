@isTest
private class SL_PrimaryAccountOfContact_Test 
{
    @testSetup static void test_setUp() 
    { 
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            Contact objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
            ZTS_EU_Species_Specialty__c='Cattle', Select_Consent_for_eSign__c ='Privacy', ZTS_EU_District__c='UK', ZTS_EU_Market__c = 'Italy');
            insert objContact;
            
            ZTS_EU_Affiliations__c objAff = [SELECT Id, Name FROM ZTS_EU_Affiliations__c 
            WHERE ZTS_EU_Account__c = :objAccount.Id
            AND ZTS_EU_Contact__c = :objContact.Id];
            
            State_Country__c sc = new State_Country__c();
            sc.Name = 'Sachsen';
            sc.ZTS_EU_Country__c = 'Germany';
            insert sc;
            
            Address__c objAdd = new Address__c(ZTS_EU_Account__c = objAccount.Id, Name = 'TEST Add', ZTS_EU_Country__c='Germany', ZTS_EU_State_County__c=sc.Id, Zip_Postal_Code__c ='394857');
            insert objAdd;
            
            objAccount.ZTS_EU_Primary_Address__c = objAdd.Id;
            update objAccount;
        }
    }
    
    private static testMethod void test_SL_PrimaryAccountOfContact() 
    {
        ZTS_EU_Affiliations__c objAffiliation = [Select Id, ZTS_EU_Contact__c, ZTS_EU_Account__c 
        From ZTS_EU_Affiliations__c where ZTS_EU_Market_from_Parent__c != 'United States' Limit 1];
        
        Address__c objAddress = [Select Id,ZTS_EU_Primary_Address__c From Address__c Where ZTS_EU_Primary_Address__c =: true Limit 1];
        
        SL_PrimaryAccountOfContact objCntl = new SL_PrimaryAccountOfContact();
        system.assertNotEquals(SL_PrimaryAccountOfContact.fetchAddress(objAffiliation.Id), null); 
    }
    
}