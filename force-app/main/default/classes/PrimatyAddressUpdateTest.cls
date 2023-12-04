/* ZTS_Account_Utility test class */
@isTest
public class PrimatyAddressUpdateTest 
{
    @testSetup
    public static void setup()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
    }
    @isTest
    public static void testClass()
    {
        User usr = new User();
		usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		usr.FirstName = 'intlUser';
		usr.zts_eu_market__c = 'Brazil';
		insert usr;
		
		System.runAs(usr)
        {
            State_Country__c sc = new State_Country__c();
            sc.Name = 'Sachsen';
            sc.ZTS_EU_Country__c = 'Brazil';
            insert sc;
            
            Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            acc.ZTS_EU_Market__c = 'Brazil';
            acc.ZTS_EU_State_County__c = sc.Id;
            acc.ZTS_EU_City__c = 'Rio';
            insert acc;
            
            Test.startTest();
            Contact cont = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            cont.ZTS_EU_Market__c = 'Brazil';
            cont.AccountId = acc.Id;
            insert cont;
            
            
            cont.ZTS_EU_Primary_Address__c = [SELECT Id, ZTS_EU_Primary_Address__c FROM Account WHERE Id =: acc.Id].ZTS_EU_Primary_Address__c;
            update cont;
                        
            PrimatyAddressUpdate.ContactsUpdateOnPrimaryAddressUpdate(new List<Account>{acc}); 
            
            System.assert(true == [SELECT Id, Inherited_Address__c FROM Contact WHERE Id =: cont.Id].Inherited_Address__c);
            Test.stopTest();
        }
    }
}