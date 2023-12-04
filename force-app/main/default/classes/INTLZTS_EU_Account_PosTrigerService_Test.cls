/*************************************************************************************
* Name          :    AccSegmentationTest
* Description   :    Test classes to check the logic for Account segmentation work complete by Slalom
* Author        :    Art Smorodin (Slalom)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
03/03/2020       Art Smorodin (Slalom)            Created
12/12/2022       Ethan Hirsch @ Zoetis Inc        Updated the test to setup a User to use instead of querying one.
                                                  This avoids random failures due to SOQL returning different results in setup and tests.
                                                  Also reenabled additional assertions around ZTS_NotificationUser__c to verify it's set properly.

**************************************************************************************/
@isTest
private class INTLZTS_EU_Account_PosTrigerService_Test {
    private static final String testAdminUserEmail = 'testadminuser@zoetis.com.testemail901314';
    private static final String testIntegrationUserEmail = 'testintegration@zoetis.com.testemail901314';

    @testSetup static void setup() {
        // Create ZTS_EU_Territory__c
        ZTS_EU_Territory__c GerIntlTerr = new ZTS_EU_Territory__c(
            Name = 'GerTestTerr',
            ZTS_EU_Market__c = 'Germany'
        );
        insert GerIntlTerr;    

        ZTS_EU_Territory__c ItalIntlTerr = new ZTS_EU_Territory__c(
            Name = 'ItalTestTerr',
            ZTS_EU_Market__c = 'Italy'
        );
        insert ItalIntlTerr;

        Id adminProfileId;
        Id integrationProfileId;
        for (Profile profile : [
            SELECT Id, Name
            FROM Profile
            WHERE Name in ('System Administrator', 'Integration Profile')]) {
            if (profile.Name == 'System Administrator') {
                adminProfileId = profile.Id;
            }
            else {
                integrationProfileId = profile.Id;
            }
        }

        User testAdminUser =  ZTS_EU_DataUtilityTest.createUserWithProfile(adminProfileId, false);
        testAdminUser.Email = testAdminUserEmail;

        User testIntegrationUser = ZTS_EU_DataUtilityTest.createUserWithProfile(integrationProfileId, false);
        testIntegrationUser.Email = testIntegrationUserEmail;

        User adminCreationUser = ZTS_EU_DataUtilityTest.createUserWithProfile(adminProfileId, false);
        adminCreationUser.FirstName = 'davidsUser';
        adminCreationUser.zts_eu_market__c = 'United Kingdom';

        insert new List<User> {testAdminUser, testIntegrationUser, adminCreationUser};

        //create ZTS_EU_Position__c (User Territory)

        List<ZTS_EU_Position__c> testPositions= new List<ZTS_EU_Position__c>();

        ZTS_EU_Position__c testPosition1 = new ZTS_EU_Position__c(
            ZTS_EU_Territory__c = GerIntlTerr.id,
            ZTS_EU_Employee__c = testAdminUser.Id
        );

        testPositions.add(testPosition1);

        ZTS_EU_Position__c testPosition2 = new ZTS_EU_Position__c(
            ZTS_EU_Territory__c = ItalIntlTerr.id,
            ZTS_EU_Employee__c = testIntegrationUser.Id
        );

        testPositions.add(testPosition2);

        insert testPositions;        


        //create Account
        //List of Markets to populate
        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
        //Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<4;i++) {
            testAccts.add(new Account(Name = 'UnitTestAcct'+i,
                                        ZTS_EU_Market__c = String.valueOf(maktList[i]),
                                        ZTS_US_NARC_ID__c = 'TestNID'+i,
                                        Type = 'Vet Practice',
                                        ZTS_EU_Zip_Postal_Code__c = '12345',
                                        BillingPostalCode = '12345',
                                        BillingCity = 'Boca Raton',
                                        BillingState = 'Florida',
                                        BillingStreet = 'Elm Lane'));
        }

        System.runAs(adminCreationUser){
            insert testAccts;
        }

    }
    @isTest static void beforeInsert() {

        User getTestUser = [SELECT Id, Name 
                            FROM User
                            WHERE  Profile.Name = 'System Administrator' AND isActive = true
                            AND Email =: testAdminUserEmail
                            LIMIT 1];

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM Account 
                                WHERE ZTS_EU_Market__c = 'Germany' AND Name LIKE 'UnitTestAcct%'];
        
        System.assertEquals(1, getAcc.size());

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM ZTS_EU_Territory__c 
                                WHERE ZTS_EU_Market__c = 'Germany' AND Name LIKE '%TestTerr'];
        
        System.assertEquals(1, getTerr.size());

        List<ZTS_EU_Position__c> getPosition = [SELECT Id, Name, ZTS_EU_Employee__c
                                FROM ZTS_EU_Position__c 
                                WHERE ZTS_EU_Territory__c =: getTerr[0].id AND Market__c = 'Germany'];
        
        System.assertEquals(1, getPosition.size());
        System.assertNotEquals(null, getPosition[0].ZTS_EU_Employee__c);

        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
            ZTS_EU_Account__c = getAcc[0].id,
            ZTS_EU_Position__c = getPosition[0].id,
            ZTS_EU_Call_Target__c = 1
        );

        Test.startTest();
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert newAccPosition;
            } 
        
        Test.stopTest();  

        List<ZTS_EU_Account_Position__c> checkAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_AccountUserTerrUniqueKey__c
                                FROM ZTS_EU_Account_Position__c 
                                WHERE ZTS_EU_Account__c =: getAcc[0].id];
        
        System.assertEquals(1, checkAccPosition.size());
        System.assertEquals(getAcc[0].id+':'+getPosition[0].id, checkAccPosition[0].ZTS_AccountUserTerrUniqueKey__c);
        System.assertEquals(getTestUser.id, checkAccPosition[0].ZTS_NotificationUser__c);

    }

    @isTest static void beforeUpdate() {
        User getTestUser1;
        User getTestUser2;
        for (User user : 
            [SELECT Id, Name, Email
            FROM User
            WHERE  (Profile.Name = 'System Administrator' AND isActive = true AND Email =: testAdminUserEmail)
            OR (Profile.Name = 'Integration Profile' AND isActive = true AND Email =: testIntegrationUserEmail)
            LIMIT 2]) {
            if (user.Email == testAdminUserEmail) {
                getTestUser1 = user;
            }
            else {
                getTestUser2 = user;
            }
        }

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM Account 
                                WHERE ZTS_EU_Market__c = 'Germany' AND Name LIKE 'UnitTestAcct%'];

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM ZTS_EU_Territory__c 
                                WHERE ZTS_EU_Market__c IN ('Germany','Italy') AND Name LIKE '%TestTerr'];
        
        System.assertEquals(2, getTerr.size());

        ZTS_EU_Position__c getPosition1 = [SELECT Id, Name, ZTS_EU_Employee__c
                                FROM ZTS_EU_Position__c 
                                WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'Germany'
                                LIMIT 1];

        ZTS_EU_Position__c getPosition2 = [SELECT Id, Name, ZTS_EU_Employee__c
                                FROM ZTS_EU_Position__c 
                                WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'Italy'
                                LIMIT 1];

        System.assertNotEquals(getPosition1, getPosition2);

        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
            ZTS_EU_Account__c = getAcc[0].id,
            ZTS_EU_Position__c = getPosition1.id,
            ZTS_EU_Call_Target__c = 1
        );

        User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert newAccPosition;
            } 

        ZTS_EU_Account_Position__c checkAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_EU_Position__c
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE ZTS_EU_Position__c =: getPosition1.id
                                                                LIMIT 1];

        Test.startTest();
        
        checkAccPosition.ZTS_EU_Position__c = getPosition2.id;
        update checkAccPosition;
        Test.stopTest();  

        List<ZTS_EU_Account_Position__c> validateAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_AccountUserTerrUniqueKey__c
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE id =: checkAccPosition.id];
        

        // As Position changed, ZTS_NotificationUser__c should also change to the User on that Position
        System.assertEquals(getTestUser2.id, validateAccPosition[0].ZTS_NotificationUser__c);

    }

    @isTest static void afterInsert() {

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                    FROM Account 
                    WHERE ZTS_EU_Market__c = 'Germany' AND Name LIKE 'UnitTestAcct%'];

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                    FROM ZTS_EU_Territory__c 
                    WHERE ZTS_EU_Market__c IN ('Germany','Italy') AND Name LIKE '%TestTerr'];

        ZTS_EU_Position__c getPosition1 = [SELECT Id, Name, ZTS_EU_Employee__c
                    FROM ZTS_EU_Position__c 
                    WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'Germany'
                    LIMIT 1];

        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
                    ZTS_EU_Account__c = getAcc[0].id,
                    ZTS_EU_Position__c = getPosition1.id,
                    ZTS_EU_Call_Target__c = 1
        );

        Test.startTest();
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert newAccPosition;
            }
               
        Test.stopTest();  

        ZTS_EU_Account_Position__c checkAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_EU_Position__c, ZTS_EU_Position__r.ZTS_EU_Employee__r.Id
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE id =: newAccPosition.id
                                                                LIMIT 1];
        
        String userID = String.valueOf(checkAccPosition.ZTS_EU_Position__r.ZTS_EU_Employee__r.Id);
        List<EntitySubscription> checkSubscr = new List<EntitySubscription>([SELECT Id 
                                            FROM EntitySubscription 
                                            WHERE SubscriberId =: userID
                                            AND ParentId =: checkAccPosition.id]);
        
        System.assertEquals(1, checkSubscr.size());                                    

    }

    @isTest static void afterUndelete() {

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                    FROM Account 
                    WHERE ZTS_EU_Market__c = 'Germany' AND Name LIKE 'UnitTestAcct%'];

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                    FROM ZTS_EU_Territory__c 
                    WHERE ZTS_EU_Market__c IN ('Germany','Italy') AND Name LIKE '%TestTerr'];

        ZTS_EU_Position__c getPosition1 = [SELECT Id, Name, ZTS_EU_Employee__c
                    FROM ZTS_EU_Position__c 
                    WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'Germany'
                    LIMIT 1];

        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
                    ZTS_EU_Account__c = getAcc[0].id,
                    ZTS_EU_Position__c = getPosition1.id,
                    ZTS_EU_Call_Target__c = 1
        );

        User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert newAccPosition;
            }
        

        ZTS_EU_Account_Position__c checkAP = [SELECT Id, Name, AP_Combination__c
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE id =: newAccPosition.id
                                                                LIMIT 1];

        System.assertNotEquals(null, checkAP.AP_Combination__c); 

        String apUniqueKey = String.valueOf(checkAP.AP_Combination__c);

        delete checkAP;

        List<ZTS_EU_Account_Position__c> validateAccPosition = new List<ZTS_EU_Account_Position__c> ([  
                                                SELECT Id, Name, ZTS_NotificationUser__c, ZTS_EU_Position__c, ZTS_EU_Position__r.ZTS_EU_Employee__r.Id
                                                FROM ZTS_EU_Account_Position__c 
                                                WHERE AP_Combination__c =: apUniqueKey]);

        System.assertEquals(0, validateAccPosition.size());   

        Test.startTest();

            ZTS_EU_Account_Position__c[] savedAP = [SELECT Id, Name FROM ZTS_EU_Account_Position__c WHERE AP_Combination__c =: apUniqueKey ALL ROWS]; 
            undelete savedAP;

        Test.stopTest();  

        ZTS_EU_Account_Position__c checkAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_EU_Position__c, ZTS_EU_Position__r.ZTS_EU_Employee__r.Id
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE AP_Combination__c =: apUniqueKey
                                                                LIMIT 1]; 
        
        String userID = String.valueOf(checkAccPosition.ZTS_EU_Position__r.ZTS_EU_Employee__r.Id);
        List<EntitySubscription> checkSubscr = new List<EntitySubscription>([SELECT Id 
                                            FROM EntitySubscription 
                                            WHERE SubscriberId =: userID
                                            AND ParentId =: checkAccPosition.id]);
        
        System.assertEquals(1, checkSubscr.size());                                    

    }

    @isTest static void afterUpdate() {
        User getTestUser1;
        User getTestUser2;
        for (User user : 
            [SELECT Id, Name, Email
            FROM User
            WHERE  (Profile.Name = 'System Administrator' AND isActive = true AND Email =: testAdminUserEmail)
            OR (Profile.Name = 'Integration Profile' AND isActive = true AND Email =: testIntegrationUserEmail)
            LIMIT 2]) {
            if (user.Email == testAdminUserEmail) {
                getTestUser1 = user;
            }
            else {
                getTestUser2 = user;
            }
        }

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM Account 
                                WHERE ZTS_EU_Market__c = 'Germany' AND Name LIKE 'UnitTestAcct%'];

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM ZTS_EU_Territory__c 
                                WHERE ZTS_EU_Market__c IN ('Germany','Italy') AND Name LIKE '%TestTerr'];
        
        System.assertEquals(2, getTerr.size());

        ZTS_EU_Position__c getPosition1 = [SELECT Id, Name, ZTS_EU_Employee__c
                                FROM ZTS_EU_Position__c 
                                WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'Germany'
                                LIMIT 1];

        ZTS_EU_Position__c getPosition2 = [SELECT Id, Name, ZTS_EU_Employee__c
                                FROM ZTS_EU_Position__c 
                                WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'Italy'
                                LIMIT 1];

        System.assertNotEquals(getPosition1, getPosition2);

        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
            ZTS_EU_Account__c = getAcc[0].id,
            ZTS_EU_Position__c = getPosition1.id,
            ZTS_EU_Call_Target__c = 1
        );

        User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert newAccPosition;
            }
          

        ZTS_EU_Account_Position__c checkAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_EU_Position__r.ZTS_EU_Employee__r.Id
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE ZTS_EU_Position__c =: getPosition1.id
                                                                LIMIT 1];

        String userIdOld = String.valueOf(checkAccPosition.ZTS_EU_Position__r.ZTS_EU_Employee__r.Id);
        List<EntitySubscription> checkSubscrOld = new List<EntitySubscription>([SELECT Id 
                                            FROM EntitySubscription 
                                            WHERE SubscriberId =: userIdOld
                                            AND ParentId =: checkAccPosition.id]);
        
        System.assertEquals(1, checkSubscrOld.size());       

        Test.startTest();
        
        checkAccPosition.ZTS_NotificationUser__c = getTestUser2.id;
        update checkAccPosition;
        Test.stopTest();  

        List<ZTS_EU_Account_Position__c> validateAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_AccountUserTerrUniqueKey__c
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE id =: checkAccPosition.id];
        
        // The update to ZTS_NotificationUser__c should revert since Position didn't change.
        System.assertEquals(getTestUser1.id, validateAccPosition[0].ZTS_NotificationUser__c);


        List<EntitySubscription> checkSubscrDeleted = new List<EntitySubscription>([SELECT Id 
                                                                                    FROM EntitySubscription 
                                                                                    WHERE SubscriberId =: userIdOld
                                                                                    AND ParentId =: checkAccPosition.id]);

        System.assertEquals(1, checkSubscrDeleted.size());

    }
}