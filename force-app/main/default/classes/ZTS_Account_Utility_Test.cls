/* ZTS_Account_Utility test class */
@isTest
public class ZTS_Account_Utility_Test 
{
    @testSetup
    public static void setup()
    {
        MarketGeoMapping__c mcs = new MarketGeoMapping__c(Geo__c='CLAR',Name = 'Brazil');
        insert mcs;
    }
    @isTest
	public static void checkTerrAlignment()
    {
        User usr = new User();
		usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		usr.FirstName = 'intlUser';
		usr.zts_eu_market__c = 'Brazil';
		insert usr;
		
		System.runAs(usr)
        {
            Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            acc.ZTS_EU_Market__c = 'Brazil';
            insert acc;
            
            ZTS_Account_Utility.checkTerrAlignment(new List<Account>{acc});
            
            System.assertEquals([SELECT Id, ZTS_EU_Excludezipbrickterralignment__c FROM Account WHERE ZTS_EU_Market__c = 'Brazil'].ZTS_EU_Excludezipbrickterralignment__c, true);
        }
    }
    @isTest
    public static void populateCity()
    {        
        User usr = new User();
		usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		usr.FirstName = 'intlUser';
		usr.zts_eu_market__c = 'Brazil';
		insert usr;
		
		System.runAs(usr)
        {
            State_Country__c country = new State_Country__c(Name = 'Test Country', ZTS_EU_Country__c = 'Brazil');
            insert country;
            
            City_State__c city = new City_State__c(Name = 'Test City', ZTS_EU_State_County__c = country.Id);
            insert city;
            
            Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            acc.ZTS_EU_Market__c = 'Brazil';
            acc.ZTS_EU_State_County__c = country.Id;
            insert acc;
            
            acc.ZTS_EU_City_Country__c = city.Id;
            update acc;
            
            ZTS_Account_Utility.populateCity(new List<Account>{acc});
            System.assertEquals([SELECT Id, ZTS_EU_City__c FROM Account WHERE ZTS_EU_Market__c = 'Brazil'].ZTS_EU_City__c, city.Name);
        }
    }
}