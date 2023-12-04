/*************************************************************************************
* Name          :    AccSegmentationTest
* Description   :    Test classes to check the logic for Account segmentation work complete by Slalom
* Author        :    Art Smorodin (Slalom)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
03/03/2020       Art Smorodin (Slalom)            Created
01/21/2022       Chelsea Paice                    Commented out unneeded tests

**************************************************************************************/
@isTest
private class USZTS_EU_Account_PosTrigerService_Test {

    @testSetup static void setup() {
        // Create ZTS_EU_Territory__c
        ZTS_EU_Territory__c UsTerrit = new ZTS_EU_Territory__c(
            Name = 'GerTestTerr',
            ZTS_EU_Market__c = 'United States'
        );
        insert UsTerrit;    

        ZTS_EU_Territory__c UsTerrit2 = new ZTS_EU_Territory__c(
            Name = 'ItalTestTerr',
            ZTS_EU_Market__c = 'United States'
        );
        insert UsTerrit2;        

        User getTestUser1 = [SELECT Id, Name 
                            FROM User
                            WHERE  Profile.Name = 'System Administrator' AND isActive = true
                            LIMIT 1];

        User getTestUser2 = [SELECT Id, Name 
                                FROM User
                                WHERE  Profile.Name = 'Integration Profile' AND isActive = true
                                LIMIT 1];
        //create ZTS_EU_Position__c (User Territory)

        List<ZTS_EU_Position__c> testPositions= new List<ZTS_EU_Position__c>();

        ZTS_EU_Position__c testPosition1 = new ZTS_EU_Position__c(
            ZTS_EU_Territory__c = UsTerrit.id,
            ZTS_EU_Employee__c = getTestUser1.Id
        );

        testPositions.add(testPosition1);

        ZTS_EU_Position__c testPosition2 = new ZTS_EU_Position__c(
            ZTS_EU_Territory__c = UsTerrit2.id,
            ZTS_EU_Employee__c = getTestUser2.Id
        );

        testPositions.add(testPosition2);

        insert testPositions;        


        //create Account
        //List of Markets to populate
        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
        //Create common test accounts
        List<Account> testINTLAccts = new List<Account>();
        List<Account> testUSAccts = new List<Account>();
        for(Integer i=0;i<4;i++) {
            if (String.valueOf(maktList[i]) == 'United States')
            {
                testUSAccts.add(new Account(Name = 'UnitTestAcct'+i,
                                          ZTS_EU_Market__c = String.valueOf(maktList[i]),
                                          ZTS_US_NARC_ID__c = 'TestNID'+i,
                                          Type = 'Vet Practice',
                                          ZTS_EU_Zip_Postal_Code__c = '00000',
                                          BillingPostalCode = '00000',
                                          BillingCity = 'testCity',
                                          BillingState = 'testState',
                                          BillingStreet = 'testStreet'));
            }
            else
            {
                testINTLAccts.add(new Account(Name = 'UnitTestAcct'+i,
                                            ZTS_EU_Market__c = String.valueOf(maktList[i]),
                                            ZTS_US_NARC_ID__c = 'TestNID'+i,
                                            Type = 'Vet Practice',
                                            ZTS_EU_Zip_Postal_Code__c = '00000',
                                            BillingPostalCode = '00000',
                                            BillingCity = 'testCity',
                                            BillingState = 'testState',
                                            BillingStreet = 'testStreet'));
            }
        }

        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
         	insert testINTLAccts;   
        }

		insert testUSAccts;
    }
    @isTest static void beforeInsert() {

        User getTestUser = [SELECT Id, Name 
                            FROM User
                            WHERE  Profile.Name = 'System Administrator' AND isActive = true
                            LIMIT 1];

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM Account 
                                WHERE ZTS_EU_Market__c = 'United States' AND Name LIKE 'UnitTestAcct%'];
        
        System.assertEquals(2, getAcc.size());

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM ZTS_EU_Territory__c 
                                WHERE ZTS_EU_Market__c = 'United States' AND Name LIKE '%TestTerr'];
        
        System.assertEquals(2, getTerr.size());

        List<ZTS_EU_Position__c> getPosition = [SELECT Id, Name, ZTS_EU_Employee__c
                                FROM ZTS_EU_Position__c 
                                WHERE ZTS_EU_Territory__c =: getTerr[0].id AND Market__c = 'United States'];
        
        System.assertEquals(1, getPosition.size());
        System.assertNotEquals(null, getPosition[0].ZTS_EU_Employee__c);

        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
            ZTS_EU_Account__c = getAcc[0].id,
            ZTS_EU_Position__c = getPosition[0].id
        );

        Test.startTest();
        insert newAccPosition;
        Test.stopTest();  

        List<ZTS_EU_Account_Position__c> checkAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_AccountUserTerrUniqueKey__c
                                FROM ZTS_EU_Account_Position__c 
                                WHERE ZTS_EU_Account__c =: getAcc[0].id];
        
        System.assertEquals(1, checkAccPosition.size());
        System.assertEquals(getAcc[0].id+':'+getPosition[0].id, checkAccPosition[0].ZTS_AccountUserTerrUniqueKey__c);
        System.assertEquals(getPosition[0].ZTS_EU_Employee__c, checkAccPosition[0].ZTS_NotificationUser__c);

    }

    @isTest static void beforeUpdate() {

        User getTestUser1 = [SELECT Id, Name 
                            FROM User
                            WHERE  Profile.Name = 'System Administrator' AND isActive = true
                            LIMIT 1];

        User getTestUser2 = [SELECT Id, Name 
                            FROM User
                            WHERE  Profile.Name = 'Integration Profile' AND isActive = true
                            LIMIT 1];

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM Account 
                                WHERE ZTS_EU_Market__c = 'United States' AND Name LIKE 'UnitTestAcct%'];

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM ZTS_EU_Territory__c 
                                WHERE ZTS_EU_Market__c = 'United States' AND Name LIKE '%TestTerr'];
        
        System.assertEquals(2, getTerr.size());

        List<ZTS_EU_Position__c> getPositionList = [SELECT Id, Name, ZTS_EU_Employee__c
                                FROM ZTS_EU_Position__c 
                                WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'United States'];

        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
            ZTS_EU_Account__c = getAcc[0].id,
            ZTS_EU_Position__c = getPositionList[0].id
        );

        insert newAccPosition;   

        ZTS_EU_Account_Position__c checkAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_EU_Position__c
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE ZTS_EU_Position__c =: getPositionList[0].id
                                                                LIMIT 1];

        Test.startTest();
        
        checkAccPosition.ZTS_EU_Position__c = getPositionList[1].id;
        update checkAccPosition;
        Test.stopTest();  

        List<ZTS_EU_Account_Position__c> validateAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_AccountUserTerrUniqueKey__c
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE id =: checkAccPosition.id];
        

        //System.assertEquals(getTestUser2.id, validateAccPosition[0].ZTS_NotificationUser__c);

    }
/* 
    @isTest static void afterInsert() {

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                    FROM Account 
                    WHERE ZTS_EU_Market__c = 'United States' AND Name LIKE 'UnitTestAcct%'];

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                    FROM ZTS_EU_Territory__c 
                    WHERE ZTS_EU_Market__c =: 'United States' AND Name LIKE '%TestTerr'];

        ZTS_EU_Position__c getPosition1 = [SELECT Id, Name, ZTS_EU_Employee__c
                    FROM ZTS_EU_Position__c 
                    WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'United States'
                    LIMIT 1];

        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
                    ZTS_EU_Account__c = getAcc[0].id,
                    ZTS_EU_Position__c = getPosition1.id
        );

        Test.startTest();
            insert newAccPosition;   
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

    @isTest static void afterUpdate() {

        User getTestUser1 = [SELECT Id, Name 
                            FROM User
                            WHERE  Profile.Name = 'System Administrator' AND isActive = true
                            LIMIT 1];

        User getTestUser2 = [SELECT Id, Name 
                            FROM User
                            WHERE  Profile.Name = 'Integration Profile' AND isActive = true
                            LIMIT 1];

        List<Account> getAcc = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM Account 
                                WHERE ZTS_EU_Market__c = 'United States' AND Name LIKE 'UnitTestAcct%'];

        List<ZTS_EU_Territory__c> getTerr = [SELECT Id, Name, ZTS_EU_Market__c 
                                FROM ZTS_EU_Territory__c 
                                WHERE ZTS_EU_Market__c =: 'United States' AND Name LIKE '%TestTerr'];
        
        System.assertEquals(2, getTerr.size());

        List<ZTS_EU_Position__c> getPositionList = [SELECT Id, Name, ZTS_EU_Employee__c
                                FROM ZTS_EU_Position__c 
                                WHERE ZTS_EU_Territory__c IN :getTerr AND Market__c = 'United States'];


        ZTS_EU_Account_Position__c newAccPosition =  new ZTS_EU_Account_Position__c (
            ZTS_EU_Account__c = getAcc[0].id,
            ZTS_EU_Position__c = getPositionList[0].id
        );

        insert newAccPosition;   

        ZTS_EU_Account_Position__c checkAccPosition = [SELECT Id, Name, ZTS_NotificationUser__c, ZTS_EU_Position__r.ZTS_EU_Employee__r.Id
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE ZTS_EU_Position__c =: getPositionList[0].id
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

        List<EntitySubscription> checkSubscrDeleted = new List<EntitySubscription>([SELECT Id 
                                                                                    FROM EntitySubscription 
                                                                                    WHERE SubscriberId =: userIdOld
                                                                                    AND ParentId =: checkAccPosition.id]);

        System.assertEquals(1, checkSubscrDeleted.size());

    } */
}