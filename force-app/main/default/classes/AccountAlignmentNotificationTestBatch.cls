/*************************************************************************************
* Name          :    AccountAlignmentNotificationTestBatch.
* Description   :    Schecdule the Batch Test class(AccountAlignmentNotification)daily to notify the user on alignment of an Account.
* Author        :    Sohil Shah(CloudSense)

Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
01/19/2015       Sohil Shah(CloudSense)            Created
11/30/2020       Alex Carstairs (Slalom)           Added assertions
**************************************************************************************/

@isTest
private class AccountAlignmentNotificationTestBatch {
    
    @TestSetup
    static void dataSetup(){
        
        /*ZTS_US_Account_Position__c accntPos = new ZTS_US_Account_Position__c(ZTS_US_Account__c = '001i000000zfVKk', ZTS_US_UserTerritory__c='a1ri00000003La4',ZTS_NotificationUser__c='005i0000004XH4I');
        insert accntPos;
        ZTS_US_Account_Position__c accntPos1 = new ZTS_US_Account_Position__c(ZTS_US_Account__c = '001i000000zfndm', ZTS_US_UserTerritory__c='a1ri00000003La4',ZTS_NotificationUser__c='005i0000004XH4I');
        insert accntPos1;*/
        
        //Art Smorodin Slalom 07/20/20 Unit Test coverage fixes 
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            List<Account> acc = ZTS_DataUtilityTest.createAccountRecord(2);
            for(Account ac : acc){
                ac.BillingCountry = 'India';
                ac.BillingState = 'West Bengal';
                ac.BillingPostalCode = '700114';
            }
            insert acc;
        }
        
        List<Account> acc = [SELECT id, ZTS_EU_Zoetis_SFDC_ID__c FROM Account WHERE BillingCountry = 'India' AND BillingState = 'West Bengal' AND BillingPostalCode = '700114'];
        
        List<User> testCoacherUsers = ZTS_DataUtilityTest.createcoacherUser();
        testCoacherUsers.addAll(ZTS_DataUtilityTest.createcoacherUser());
        for(User testUser : testCoacherUsers){
            testUser.PIT_Coaching_Group__c = 'TBM';
            testUser.ZTS_EU_Market__c = 'United States';
        }
        testCoacherUsers[1].username = 'deneme2@deneme2.com';
        insert testCoacherUsers;
        
        List<ZTS_EU_Territory__c> testTerritories = ZTS_DataUtilityTest.createCustomTerritory(2);
        for(ZTS_EU_Territory__c territory : testTerritories){
            territory.ZTS_TerritoryRole__c = 'NBM';
            territory.ZTS_EU_Market__c = 'United States';
        }
        insert testTerritories;
        
        List<ZTS_EU_Position__c> testUserTerritory = ZTS_DataUtilityTest.createUserTerritory(testTerritories);
        for(Integer i=0; i<testUserTerritory.size(); i++) {
            testUserTerritory[i].ZTS_EU_Employee__c = testCoacherUsers[i].Id;
        }
        insert testUserTerritory;
        
        List<ZTS_AccountTerritory__c> testAccountTerritory = ZTS_DataUtilityTest.createAccountTerritory(acc,testTerritories);
        for(ZTS_AccountTerritory__c accountTerritory : testAccountTerritory){
            accountTerritory.ZTS_SIB_Flag__c = true;
            accountTerritory.ZTS_Exception_Alignment__c = false;
        }
        insert testAccountTerritory;
        
        
        
        ZTS_EU_Account_Position__c testAccountPosition1 = new ZTS_EU_Account_Position__c();
        
        testAccountPosition1.ZTS_EU_Account__c = acc[0].Id;
        testAccountPosition1.ZTS_AccountTerritory__c = testAccountTerritory[0].Id;
        testAccountPosition1.ZTS_NotificationUser__c = testCoacherUsers[0].Id;
        //testAccountPosition1.ZTS_EU_Position__c = testUserTerritory[0].Id;
        
        
        //insert testAccountPosition1;
        
        ZTS_EU_Account_Position__c testAccountPosition2 = new ZTS_EU_Account_Position__c();
        
        testAccountPosition2.ZTS_EU_Account__c = acc[1].Id;
        testAccountPosition2.ZTS_AccountTerritory__c = testAccountTerritory[1].Id;
        testAccountPosition2.ZTS_NotificationUser__c = testCoacherUsers[1].Id;
        //testAccountPosition2.ZTS_EU_Position__c = testUserTerritory[1].Id;
        
        //insert testAccountPosition2;
        
        Date todaysDate = Date.today();

        ZTS_EU_Account_PositionTriggerHandler apHandler = new ZTS_EU_Account_PositionTriggerHandler();
        apHandler.disableTrigger = true;
        insert new List<ZTS_EU_Account_Position__c>{testAccountPosition1, testAccountPosition2};

        Test.setCreatedDate(testAccountPosition1.Id, todaysDate.addDays(1));
        Test.setCreatedDate(testAccountPosition2.Id, todaysDate.addDays(1));
        
    }
    
    @isTest static void testAllignBatch() {       
        
        Test.startTest();
            AccountAlignmentNotification aan = new AccountAlignmentNotification();
            Id myBatchJobID = Database.executebatch(aan);
        Test.stopTest();
        
        // System.assert(AccountAlignmentNotification.sendEmailIsSuccess, 'The batch should successfully send email. This should fail in sandboxes with email deliverability not set to "All Email"');
        
    }

    @isTest static void testAlignSchedule() {
        
        Integer numberOfJobsBefore = [SELECT count() FROM CronJobDetail WHERE JobType = '7'];
        Test.startTest();
            AccountAlignmentNotificationSchedulable accntAlign = new AccountAlignmentNotificationSchedulable();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Alignment', sch, accntAlign); 
        Test.stopTest();

        Integer numberOfJobsAfter = [SELECT count() FROM CronJobDetail WHERE JobType = '7'];

        System.assertEquals(1, numberOfJobsAfter-numberOfJobsBefore, 'The batch should be scheduled');
    }
}