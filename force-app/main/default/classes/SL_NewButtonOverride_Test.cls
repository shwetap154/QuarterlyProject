/**
* @ClassName    : SL_NewButtonOverride_Test 
* @JIRATicket   : LIGTHTNI-1111
* @CreatedOn    : 06 August, 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Test class for SL_NewButtonOverride controller class.
*/
@isTest
public class SL_NewButtonOverride_Test {

    @isTest
    public static void testController() {
        Map<String, Object> obj =  SL_NewButtonOverride.getRecordDetails('Account', '');
        System.assertNotEquals(null, obj);
        obj =  SL_NewButtonOverride.getRecordDetails('Address__c', '');
        System.assertNotEquals(null, obj);
        obj =  SL_NewButtonOverride.getRecordDetails('ZTS_EU_Affiliations__c', '');
        System.assertNotEquals(null, obj);
        obj =  SL_NewButtonOverride.getRecordDetails('ZTS_Events__c', '');
        System.assertNotEquals(null, obj);
    }

    @isTest
    public static void testControllerForContactCase() {
        State_Country__c country = new State_Country__c(Name = 'Test Country', ZTS_EU_Country__c = 'United Kingdom');
        insert country;

        City_State__c city = new City_State__c(Name = 'Test City', ZTS_EU_State_County__c = country.Id);
        insert city;

        Account objAccount = new Account(Name='Test Account Override',
                                         ZTS_EU_City_Country__c = city.Id,
                                         ZTS_EU_Country__c = 'United Kingdom',
                                         ZTS_EU_State_County__c=country.Id,
                                         ZTS_EU_Zip_Postal_Code__c = '10001',
                                         BillingPostalCode = '00000',
                                         BillingCity = 'testCity',
                                         BillingState = 'testState',
                                         BillingStreet = 'testStreet');
        insert objAccount;
        
        Map<String, Object> obj =  SL_NewButtonOverride.getRecordDetails('Contact', objAccount.Id);
        System.assertNotEquals(null, obj);
    }
}