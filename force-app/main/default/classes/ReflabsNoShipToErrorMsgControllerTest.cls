@isTest 
private class ReflabsNoShipToErrorMsgControllerTest {
    
    @testSetup
    public static void setupData()
    {
        Test.startTest();
        List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
        TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
        triggerActiveList.add(tr);
        insert triggerActiveList;
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'Canada';
        insert usr;

        System.runAs(usr)
        {
            Account objAcc = (Account) SL_TestDataFactory.createSObject
            (   new Account
                (   Name = 'Test Company for Case'
                ,   ZTS_EU_Market__c = 'Baltics'
                ,   ZTS_EU_VAT_Code__c = '00011'
                ,   ZTS_EU_Account_Status__c = 'Active'
                ,   ZTS_EU_Zip_Postal_Code__c = '07306'
                ,   LIS_Org_Code__c = '1000117840'
                )
            ,   false
            );
           
            insert new List<Account>{ objAcc };

            Contact objCon = (Contact) SL_TestDataFactory.createSObject
            (   new Contact
                (   LastName = 'Test'
                ,   FirstName = 'Name'
                ,   AccountId = objAcc.Id
                ,   ZTS_EU_Contact_type__c = 'Analyst'
                ,   ZTS_EU_Market__c = 'Baltics'
                ,   RefLabs_Contact_Email__c = 'test2@reflabs.com'
                )
            ,   false
            );

            insert new List<Contact>{ objCon };
            
            Case objCase = ( Case ) SL_TestDataFactory.createSObject
            (   new Case
                (   Subject = 'Test Case'
                ,   AccountId = objAcc.Id
                ,   ContactId = objCon.Id
                )
            ,   false
            );

            insert new List<Case>{ objCase };
        }

        Test.stopTest();
    }

    @isTest
    private static void testIsAccountWithNoShipTo() {

        List<Case> caseList = [ SELECT Id, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1 ];

        Test.startTest();
        caseList[0].Has_RefLabs_Multiple_Ship_To__c = true;

        update caseList;
        Test.stopTest();

        System.assertEquals( false, ReflabsNoShipToErrorMessageController.isAccountWithNoShipTo ( caseList[0].Id ), 'The controller should return False' );

    }

    
    @isTest
    private static void testIsAccountWithNoShipToFalse() {

        List<Case> caseList = [ SELECT Id, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1 ];

        Test.startTest();
        caseList[0].Has_RefLabs_Multiple_Ship_To__c = false;

        update caseList;
        Test.stopTest();

        System.assertEquals( true, ReflabsNoShipToErrorMessageController.isAccountWithNoShipTo ( caseList[0].Id ), 'The controller should return true' );
        
    }
}