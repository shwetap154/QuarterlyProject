@isTest
private class SL_TerritorySync_Test 
{
	static List<User> usrs=new List<User>();
	public static void createTestUser(){
    
    Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='testem11@deneme.com';
        newuser.username='testem11@deneme1.com';
        newuser.lastname='testem11';
        newuser.alias='testem11';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';  
        newuser.EmailEncodingKey='ISO-8859-1';
		newuser.PIT_Coaching_Group__c='TBM';
		newuser.zts_eu_market__c = 'United States';
        usrs.add(newuser);
        insert usrs;
    }

	@isTest static void test_SL_TerritorySync_Test() 
	{
		createTestUser();
		List<ZTS_EU_Territory__c> lstTerritory = new List<ZTS_EU_Territory__c>();
		for(Integer i = 0; i<1000; i++)
		{
			ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrTBM'+i,
																ZTS_Field_Force_Name__c='FieldForceName-',
																ZTS_EU_Description__c='Terr Desc-',
																ZTS_EU_Type__c='Area',ZTS_Species__c='Small Animal',
																ZTS_EU_Market__c = 'Italy');
        	lstTerritory.add(cterr);	
		}
		
		insert lstTerritory;

		system.assertEquals(lstTerritory.size(), 1000);

		system.runAs(usrs[0])
		{	
			ZTS_US_TerritoryConsoleController objTCC = new ZTS_US_TerritoryConsoleController();
			objTCC.createStdTerrFromCustomTerritory();
		}

		//system.assertEquals([Select Count() From Territory2 WHERE ZTS_EU_Market__c = 'United States'], 1000);
	}
}