@isTest
public class SL_AffiliateNewContactController_Test {
    
    @isTest
    private static void test_SL_NewAddress() {
    
    	User usr = new User();
		usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		usr.FirstName = 'davidsUser';
		usr.zts_eu_market__c = 'United Kingdom';
		insert usr;
		
		System.runAs(usr){

	        State_Country__c country = new State_Country__c(Name = 'Test Country', ZTS_EU_Country__c = 'United Kingdom');
	        insert country;
	
	        City_State__c city = new City_State__c(Name = 'Test City', ZTS_EU_State_County__c = country.Id);
	        insert city;
	
	        Account objAccount = new Account(Name='Test Account Override',
	                                         ZTS_EU_City_Country__c = city.Id,
	                                         ZTS_EU_Country__c = 'United Kingdom',
	                                         ZTS_EU_State_County__c=country.Id,
	                                         ZTS_EU_Zip_Postal_Code__c = '10001',
											 BillingPostalCode = '12345',
											 BillingCity = 'Boca Raton',
											 BillingState = 'Florida',
											 BillingStreet = 'Elm Lane');
	        insert objAccount;
	        
	        PageReference pageRef = Page.SL_AffiliateNewContact;      
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put('id', objAccount.Id);
	        
	        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(new List<ZTS_EU_Affiliations__c>());
	        SL_AffiliateNewContactController objCntl = new SL_AffiliateNewContactController(setCon);
	        objCntl.fetchRecordURL();
	        objCntl.backToView();
        }
    }
}