/**
* @ClassName    : SL_ContactNewButtonOverride_Test 
* @JIRATicket   : LIGTHTNI-1111
* @CreatedOn    : 31 July, 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Test class for controller 'SL_ContactNewButtonOverride' class.
*/
@isTest
public class SL_ContactNewButtonOverride_Test {

    @isTest
    public static void testHandler() {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Mosby';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
                
        System.runAs(usr)
        {        
            State_Country__c country = new State_Country__c(Name = 'Test Country', ZTS_EU_Country__c = 'United Kingdom');
            insert country;
    
            City_State__c city = new City_State__c(Name = 'Test City', ZTS_EU_State_County__c = country.Id);
            insert city;
    
            List<Account> objAccounts = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            Account objAccount = objAccounts[0];
            insert objAccount;
    
            Map<String, Object> obj =  SL_ContactNewButtonOverride.getDefaultUserData('Contact', (String)objAccount.Id);
            System.assertNotEquals(null, obj);
        }
    }
}