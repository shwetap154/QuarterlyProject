@isTest
public class NewCaseFromAddressOverride_Test {
    @TestSetup
    static void setup(){
        Id adminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1].Id;
        User u1 = TestDataFactory.createUser(adminProfileId, null, null, false);
        u1.FirstName = 'User1';
        u1.ZTS_EU_Market__c = 'United States';
        u1.ManagerId = Userinfo.getUserId();
        u1.IsActive = true;
        u1.Territory__c = 'TestTerritory';
        INSERT u1;
        
        system.runAs(u1){
            INSERT new account(name='test123',
                               ZTS_EU_Market__c='United States',
                               Practice_Management_Software__c = 'Other',
                               Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                               ZTS_EU_Zip_Postal_Code__c = '00000',
                               ZTS_US_NARC_ID__c='0001',
                               Phone='9748694980',
                               Type='Diagnostic',
                               BillingStreet='123 Main St',
                               BillingCity='abc city',
                               BillingCountry='United States',
                               BillingState='California',
                               BillingPostalCode='12345',
                               ZTS_EU_City__c='abc town',
                               ZTS_EU_Country__c='United States',
                               ZTS_US_State_Province__c='CA',
                               ZTS_US_Business_Class__c='Business Class',
                               ZTS_US_Sub_Class_1__c='Sub Class 1',
                               Email__c='abc@xyz.com',
                               ZTS_EU_Account_Status__c='Active');
            
            Contact con = new Contact();
            con.LastName = 'User Contact11';
            con.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
            con.ZTS_US_Account_influence__c = 'Decision Maker';
            con.ZTS_US_Profession__c = 'Distributor';
            con.ZTS_US_Job_Function__c = 'Owner';
            
            INSERT con;
        }
    }
    
    
    
    @isTest
    static void testGetRecordTypes() {
        List<NewCaseFromAddressOverride.RecordTypeInfoWrapper> recordTypes = NewCaseFromAddressOverride.getRecordTypes('Case');
        System.assertNotEquals(null, recordTypes);
        System.assertNotEquals(0, recordTypes.size());
    }
    
    @isTest
    static void testConAccMethod() {
        Id conId = NewCaseFromAddressOverride.getAccountIdFromContact([SELECT Id FROM Contact].Id);
        system.assertEquals(conId != null, true, 'Contact Has An Account Id');
    }
    
}