/*******************************************************************************************
 * Class Name   : ZTS_US_BatchPopulateAccountTSF_test
 * Description  : This is a test class to cover "ZTS_US_BatchPopulateAccountTSF"
 *      
 * Created By   : Cognizant / Aritra
 * Edited By   : Slalom / David
********************************************************************************************/
@IsTest
public class ZTS_US_BatchPopulateAccountTSF_test 
{
    static testMethod void testAccountTSF()
    {
        //*************************** create test data **********************
        Account acc1 = new Account(Name = 'Test_Account1', 
                                   ZTS_US_NARC_ID__c = '912276', 
                                   ZTS_US_Business_Class__c = 'Sub-Class 1',
                                   ZTS_EU_Country__c = 'United States',
                                   BillingStreet = 'test_st1', 
                                   BillingCity = 'test_city',
                                   BillingCountry = 'United States',
                                   BillingState = 'TX',
                                   BillingPostalCode = 'ert',
                                   ZTS_EU_Account_Status__c = 'Active',
                                   ZTS_EU_Zip_Postal_Code__c = '11111',
                                   ZTS_EU_Market__c = 'United States'
                                  );
        insert acc1;
        
        List<Account> acclist = new List<Account>{acc1};
            List<ZTS_EU_Territory__c> custTerrlist = ZTS_DataUtilityTest.createCustomTerritory(3);
        insert custTerrlist;
        
        List<ZTS_EU_Position__c> userTerrlist = ZTS_DataUtilityTest.createUserTerritory(custTerrlist);
        insert userTerrlist;
        
        List<ZTS_AccountTerritory__c> accTerrlist = ZTS_DataUtilityTest.createAccountTerritory(acclist,custTerrlist);
        for(ZTS_AccountTerritory__c at:accTerrlist)
        {
            at.ZTS_SIB_Flag__c = True;
        }
        insert accTerrlist;
        
        //*************************** execute batch *******************
        Test.startTest();
        	String batchid = ZTS_US_BatchPopulateAccountTSF.executeBatch(200);
        	System.assert(batchid != null, 'ZTS_US_BatchPopulateAccountTSF failed to execute batch');
        Test.stopTest();
        
        Account testAcct = [
            SELECT Id, ZTS_US_TSF__c
            FROM Account
            LIMIT 1
        ];
        
        System.assertNotEquals(acc1.ZTS_US_TSF__c, testAcct.ZTS_US_TSF__c, 'United States Account TSF should have been changed.');
    }
    
    static testMethod void testNonUSAccountFails()
    {
        //*************************** create test data **********************
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        Account acc1 = new Account(Name = 'Test_Account1', 
                                   ZTS_US_NARC_ID__c = '912276', 
                                   ZTS_US_Business_Class__c = 'Sub-Class 1',
                                   ZTS_EU_Country__c = 'Italy',
                                   BillingStreet = 'test_st1', 
                                   BillingCity = 'test_city',
                                   BillingCountry = 'Italy',
                                   BillingState = 'TX',
                                   BillingPostalCode = 'ert',
                                   ZTS_EU_Account_Status__c = 'Active',
                                   ZTS_EU_Zip_Postal_Code__c = '11111',
                                   ZTS_EU_Market__c = 'Italy'
                                  );
        System.runAs(usr)
        {
            insert acc1;
        }
        
        List<Account> acclist = new List<Account>{acc1};
            List<ZTS_EU_Territory__c> custTerrlist = ZTS_DataUtilityTest.createCustomTerritory(3);
        insert custTerrlist;
        
        List<ZTS_EU_Position__c> userTerrlist = ZTS_DataUtilityTest.createUserTerritory(custTerrlist);
        insert userTerrlist;
        
        List<ZTS_AccountTerritory__c> accTerrlist = ZTS_DataUtilityTest.createAccountTerritory(acclist,custTerrlist);
        for(ZTS_AccountTerritory__c at:accTerrlist)
        {
            at.ZTS_SIB_Flag__c = True;
        }
        insert accTerrlist;
        
        //*************************** execute batch *******************
        Test.startTest();
        System.runAs(usr)
        {
            String batchid = ZTS_US_BatchPopulateAccountTSF.executeBatch(200);
            System.assert(batchid != null, 'ZTS_US_BatchPopulateAccountTSF failed to execute batch');
        }
        	        
        Test.stopTest();
        
        Account testAcct = [
            SELECT Id, ZTS_US_TSF__c
            FROM Account
            LIMIT 1
        ];
        
        System.assertEquals(acc1.ZTS_US_TSF__c, testAcct.ZTS_US_TSF__c, 'United States Account TSF should not have been changed.');
    }   
}