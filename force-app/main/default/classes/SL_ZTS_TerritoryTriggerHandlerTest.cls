@isTest
private class SL_ZTS_TerritoryTriggerHandlerTest 
{
	static List<User> usrs=new List<User>();
	public static void createTestUser()
	{
	    Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='testem456@deneme.com';
        newuser.username='testem563@deneme1.com';
        newuser.lastname='testem456';
        newuser.alias='testem';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';  
        newuser.EmailEncodingKey='ISO-8859-1';
        newuser.ZTS_EU_Market__c = 'India';
        //newuser.PIT_Coaching_Group__c='TBM';
        usrs.add(newuser);
        insert usrs;
    }
	


	@isTest static void test_SL_ZTS_TerritoryTriggerHandler() 
	{
		try
		{
			createTestuser();
	        
	        ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrTBM',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Territory', ZTS_EU_Market__c = 'India');
	        insert cterr;

	        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
	        insert usrTerr;  
	        
	        ZTS_EU_Territory__c cterrChild=new ZTS_EU_Territory__c(Name='TerrRBD11',ZTS_Field_Force_Name__c='FieldForceName1-',
	        														ZTS_EU_Description__c='Terr Desc1-',ZTS_EU_Type__c='Region',
	        														ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterr.Id, ZTS_EU_Market__c = 'India');
	        insert cterrChild;
	        
	        ZTS_EU_Territory__c cterrChild2=new ZTS_EU_Territory__c(Name='TerrRBD2',ZTS_Field_Force_Name__c='FieldForceName2-',
	        														ZTS_EU_Description__c='Terr Desc2-',ZTS_EU_Type__c='Region',
	        														ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterrChild.Id, ZTS_EU_Market__c = 'India');
	        insert cterrChild2;
	        
	        ZTS_EU_Position__c usrTerr2=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterrChild.id,ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
			insert usrTerr2; 

			User usrs = [SELECT Id, Username FROM User WHERE username = 'testem563@deneme1.com' LIMIT 1];

			System.runAs(usrs)
			{

	        Account objAcc = new Account(Name='Test Acc 1', ZTS_EU_Market__c = 'India', ZTS_EU_Zip_Postal_Code__c = '12345');
	        insert objAcc;

	        ZTS_AccountTerritory__c objAT = new ZTS_AccountTerritory__c(ZTS_Zoetis_SFDC_ID__c=objAcc.ZTS_EU_Zoetis_SFDC_ID__c, ZTS_EU_Territory__c = cterr.Id, ZTS_EU_Account__c = objAcc.Id, ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT,ZTS_NARC_ID__c='test');
			objAt.ZTS_EU_Market__c = 'India';
			insert objAT;
			}

	        Delete cterr;

		} catch(DmlException ex) {
			Boolean expectedExceptionThrown =  ex.getMessage().contains('This record still has related Position, Account and/or Child Territories. Please delete all related records before deleting this Territory.') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true, 'Expected specific exception message but instead got: ' + ex.getMessage());
		}
	}
}