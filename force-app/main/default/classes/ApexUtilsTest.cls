/**
* File Name     :  ApexUtilsTest
* @description  :  Utility class for common operations.
* @author       :  ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/24         Cesar Sandrigo @ ATG     Created the Class.
*
*/
@isTest
private class ApexUtilsTest {

    private static Integer sObjectIdCounter = 1;
    public static String getFakeId(Schema.SobjectType sot) {
        String result = String.valueOf(sObjectIdCounter++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    private static List<Account> createTestAccounts() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = '1', ZTS_EU_Market__c = 'Italy', Practice_Management_Software__c = 'Animana',
                                                                            ZTS_EU_Zip_Postal_Code__c = '12345',
                                                                            BillingPostalCode = '12345',
                                                                            BillingCity = 'Boca Raton',
                                                                            BillingState = 'Florida',
                                                                            BillingStreet = 'Elm Lane'));
        accounts.add(new Account(Name = '2', ZTS_EU_Market__c = 'Italy', Practice_Management_Software__c = 'Animana',
                                                                            ZTS_EU_Zip_Postal_Code__c = '12345',
                                                                            BillingPostalCode = '12345',
                                                                            BillingCity = 'Boca Raton',
                                                                            BillingState = 'Florida',
                                                                            BillingStreet = 'Elm Lane'));
        accounts.add(new Account(Name = '3', ZTS_EU_Market__c = 'Italy', Practice_Management_Software__c = 'Animana',
                                                                            ZTS_EU_Zip_Postal_Code__c = '12345',
                                                                            BillingPostalCode = '12345',
                                                                            BillingCity = 'Boca Raton',
                                                                            BillingState = 'Florida',
                                                                            BillingStreet = 'Elm Lane'));

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert accounts;
        }
        return accounts;
    }

    private static Contact createTestContact(Account account) {
        return new Contact(FirstName = account.Name, LastName = account.name, AccountId = account.Id, ZTS_EU_Market__c = 'Italy');
    }
    private static Contact createTestContact(Account account, Boolean doInsert) {
        Contact c = createTestContact(account);
        if(doInsert) {
            insert c;
        }
        return c;
    }

    private static List<Contact> createTestContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
        for(Account account : accounts) {
            contacts.add(createTestContact(account));
        }
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert contacts;
        }
        return contacts;
    }

    // NOTE: this requires some record types to exist in org, can adjust unit test in client org
    @isTest static void test_getRecordTypeByDeveloperName() {
        RecordType recordType = ApexUtils.getRecordTypeByDeveloperName('SomeRecTypeDevName');
        System.assertEquals(null, recordType);
        // System.assertNotEquals(null, recordType);
    }

    @isTest static void test_pluckIdSet() {
        List<Account> accounts = createTestAccounts();
        Set<Id> accountIds = ApexUtils.pluckIdSet(accounts, Schema.Account.Id);
        System.assertEquals(3, accountIds.size());
    }

    @isTest static void test_pluckIdSetNonMatching() {
        List<Account> accounts = createTestAccounts();
        Set<Id> accountIds = ApexUtils.pluckIdSet(accounts, Schema.Contact.Name);
        System.assertEquals(0, accountIds.size());
    }

    @isTest static void test_pluckIdSetRelationship() {
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = '1', Account = new Account(Name = 'Account 1', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-1'))),
            new Contact(LastName = '2', Account = new Account(Name = 'Account 2', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-2'))),
            new Contact(LastName = '3', Account = new Account(Name = 'Account 3', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-3'))),
            new Contact(LastName = '4', Account = new Account(Name = 'Account 4', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-4'))),
            new Contact(LastName = '5', Account = new Account(Name = 'Account 4')),
            new Contact(LastName = '5')
        };
        Set<Id> userIds = ApexUtils.pluckIdSet(contacts, 'Account.Parent.Id');
        System.assertEquals(4, userIds.size());
        // System.assertEquals(contacts[0].Account.Parent.Id, userIds[0]);
        // System.assertEquals(contacts[1].Account.Parent.Id, userIds[1]);
        // System.assertEquals(contacts[2].Account.Parent.Id, userIds[2]);
        // System.assertEquals(contacts[3].Account.Parent.Id, userIds[3]);
    }

    @isTest static void test_pluckStringSet() {
        List<Account> accounts = createTestAccounts();
        Set<String> accountIds = ApexUtils.pluckStringSet(accounts, Schema.Account.Name);
        System.assertEquals(3, accountIds.size());

        System.assert(accountIds.contains('1'));
        System.assert(accountIds.contains('2'));
        System.assert(accountIds.contains('3'));
    }

    @isTest static void test_pluckStringSetRelationship() {
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = '1', Account = new Account(Name = 'Account 1', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-1'))),
            new Contact(LastName = '2', Account = new Account(Name = 'Account 2', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-2'))),
            new Contact(LastName = '3', Account = new Account(Name = 'Account 3', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-3'))),
            new Contact(LastName = '4', Account = new Account(Name = 'Account 4', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-4'))),
            new Contact(LastName = '5', Account = new Account(Name = 'Account 4')),
            new Contact(LastName = '5')
        };
        Set<String> userNames = ApexUtils.pluckStringSet(contacts, 'Account.Parent.Name');
        System.assertEquals(4, userNames.size());
        // System.assertEquals(userNames[0].Account.Parent.Name, userNames[0]);
        // System.assertEquals(userNames[1].Account.Parent.Name, userNames[1]);
        // System.assertEquals(userNames[2].Account.Parent.Name, userNames[2]);
        // System.assertEquals(userNames[3].Account.Parent.Name, userNames[3]);
    }

    @isTest static void test_pluckMap() {
        List<Account> accounts = createTestAccounts();
        Map<String, String> accountMap = ApexUtils.pluckMap(accounts, Schema.Account.Id, Schema.Account.Name);

        System.assertEquals(accounts[0].Name, accountMap.get(accounts[0].Id));
        System.assertEquals(accounts[1].Name, accountMap.get(accounts[1].Id));
        System.assertEquals(accounts[2].Name, accountMap.get(accounts[2].Id));
    }

    @isTest static void test_groupBy() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Type = 'Franchise';
        accounts[1].Type = 'Franchise';
        accounts[2].Type = 'Client';

        Map<String, List<SObject>> accountMap = ApexUtils.groupBy(accounts, Schema.Account.Type);

        System.assertEquals(2, accountMap.get('Franchise').size());
        System.assertEquals(1, accountMap.get('Client').size());
    }

    @isTest static void test_groupByString() {
        List<Account> accounts = createTestAccounts();
        
        accounts[0].Parent = new Account();
        accounts[0].Parent.Owner = new User(FirstName = 'Bob');
        accounts[1].Parent = new Account();
        accounts[1].Parent.Owner = new User(FirstName = 'Bob');
        accounts[2].Parent = new Account();
        accounts[2].Parent.Owner = new User(FirstName = 'Sally');

        Map<String, List<SObject>> accountMap = ApexUtils.groupBy(accounts, 'Parent.Owner.FirstName');

        System.assertEquals(2, accountMap.get('Bob').size());
        System.assertEquals(1, accountMap.get('Sally').size());
    }

    @isTest static void test_groupByStringMultiLevel() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Parent = new Account();
        accounts[0].Parent.Owner = new User(FirstName = 'Bob');
        accounts[1].Parent = new Account();
        accounts[1].Parent.Owner = new User(FirstName = 'Bob');
        accounts[2].Parent = new Account();
        accounts[2].Parent.Owner = new User(FirstName = 'Sally');

        Map<String, List<SObject>> accountMap = ApexUtils.groupBy(accounts, 'Parent.Owner.FirstName');

        System.assertEquals(2, accountMap.get('Bob').size());
        System.assertEquals(1, accountMap.get('Sally').size());
    }

    @isTest static void test_pluckMapAny() {
        List<Account> accounts = createTestAccounts();
        Map<String, Object> accountMap = ApexUtils.pluckMapAny(accounts, Schema.Account.Id, Schema.Account.Name);

        System.assertEquals(accounts[0].Name, accountMap.get(accounts[0].Id));
        System.assertEquals(accounts[1].Name, accountMap.get(accounts[1].Id));
        System.assertEquals(accounts[2].Name, accountMap.get(accounts[2].Id));
    }

    @isTest static void test_pluckMapAny2() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Type = 'Client';
        accounts[1].Type = 'Partner';
        accounts[2].Type = 'Franchise';

        Map<String, SObject> accountMap = ApexUtils.groupByFlat(accounts, Schema.Account.Type);

        System.assertEquals(accounts[0], accountMap.get('Client'));
        System.assertEquals(accounts[1], accountMap.get('Partner'));
        System.assertEquals(accounts[2], accountMap.get('Franchise'));
    }

    @isTest static void test_findChangedRecs() {
        List<Account> accounts = createTestAccounts();
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);

        accounts[0].Name = 'CHANGED1';
        accounts[2].Name = 'CHANGED3';

        List<SObject> changedAccounts = ApexUtils.findChangedRecs(accounts, accountMap, Schema.Account.Name);

        System.assertEquals(2, changedAccounts.size());
        System.assertEquals(accounts[0], changedAccounts[0]);
        System.assertEquals(accounts[2], changedAccounts[1]);
    }

    @isTest static void test_findChangedRecsWithMatchingVal() {
        List<Account> accounts = createTestAccounts();
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);

        accounts[0].Name = 'CHANGED1';
        accounts[2].Name = 'CHANGED3';


        List<SObject> changedAccounts = ApexUtils.findChangedRecsWithMatchingVal(accounts, accountMap, Schema.Account.Name, 'CHANGED1');

        System.assertEquals(1, changedAccounts.size());
        System.assertEquals(accounts[0], changedAccounts[0]);
    }

    @isTest static void test_findChangedRecsWithMatchingVal2() {
        List<Account> accounts = createTestAccounts();
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);

        accounts[0].Name = 'CHANGED1';
        accounts[2].Name = 'CHANGED1';


        List<SObject> changedAccounts = ApexUtils.findChangedRecsWithMatchingVal(accounts, accountMap, Schema.Account.Name, '1', 'CHANGED1');

        System.assertEquals(1, changedAccounts.size());
        System.assertEquals(accounts[0], changedAccounts[0]);
    }

    @isTest static void test_findRecsWithMatchingValue() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Type = 'Franchise';
        accounts[1].Type = 'Franchise';
        accounts[2].Type = 'Client';

        List<SObject> foundObjects1 = ApexUtils.findRecsWithMatchingValue(accounts, Schema.Account.Type, 'Franchise');
        List<SObject> foundObjects2 = ApexUtils.findRecsWithMatchingValue(accounts, Schema.Account.Type, 'Client');
        List<SObject> foundObjects3 = ApexUtils.findRecsWithMatchingValue(accounts, Schema.Account.Type, 'foo-bar');

        System.assertEquals(accounts[0], foundObjects1[0]);
        System.assertEquals(accounts[1], foundObjects1[1]);
        System.assertEquals(2, foundObjects1.size());
        System.assertEquals(1, foundObjects2.size());
        System.assertEquals(0, foundObjects3.size());
    }

    @isTest static void test_findRecsWithNonMatchingValue() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Type = 'Franchise';
        accounts[1].Type = 'Franchise';
        accounts[2].Type = 'Client';

        List<SObject> foundObjects1 = ApexUtils.findRecsWithNonMatchingValue(accounts, Schema.Account.Type, 'Franchise');
        List<SObject> foundObjects2 = ApexUtils.findRecsWithNonMatchingValue(accounts, Schema.Account.Type, 'Client');
        List<SObject> foundObjects3 = ApexUtils.findRecsWithNonMatchingValue(accounts, Schema.Account.Type, 'foo-bar');

        System.assertEquals(accounts[2], foundObjects1[0]);
        System.assertEquals(accounts[0], foundObjects2[0]);
        System.assertEquals(accounts[1], foundObjects2[1]);
        System.assertEquals(1, foundObjects1.size());
        System.assertEquals(2, foundObjects2.size());
        System.assertEquals(3, foundObjects3.size());
    }
    
    @isTest static void test_getEarliestAndLatestDate() {
        List<Contact> contacts = new List<Contact>{
            new Contact(Birthdate = Date.today().addDays(10)),
            new Contact(Birthdate = Date.today().addDays(-10)),
            new Contact(Birthdate = Date.today().addDays(20))
        };

        Date earliestDate = ApexUtils.getEarliestDate(contacts, Schema.Contact.Birthdate);
        Date latestDate = ApexUtils.getLatestDate(contacts, Schema.Contact.Birthdate);

        System.assertEquals(contacts[1].Birthdate, earliestDate);
        System.assertEquals(contacts[2].Birthdate, latestDate);
    }

    @isTest static void test_findRecWithDateBetween() {
        List<Asset> assets = new List<Asset>{
            new Asset(Id = ApexUtilsTest.getFakeId(Asset.getSObjectType()), InstallDate = Date.today().addDays(0), UsageEndDate = Date.Today().addDays(29)), // 0
            new Asset(Id = ApexUtilsTest.getFakeId(Asset.getSObjectType()), InstallDate = Date.today().addDays(30), UsageEndDate = Date.Today().addDays(39)), // 1
            new Asset(Id = ApexUtilsTest.getFakeId(Asset.getSObjectType()), InstallDate = Date.today().addDays(40), UsageEndDate = Date.Today().addDays(49)), // 2
            new Asset(Id = ApexUtilsTest.getFakeId(Asset.getSObjectType()), InstallDate = Date.today().addDays(50), UsageEndDate = Date.Today().addDays(59)), // 3
            new Asset(Id = ApexUtilsTest.getFakeId(Asset.getSObjectType()), InstallDate = Date.today().addDays(60), UsageEndDate = Date.Today().addDays(69)), // 4
            new Asset(Id = ApexUtilsTest.getFakeId(Asset.getSObjectType()), InstallDate = Date.today().addDays(70), UsageEndDate = Date.Today().addDays(79))  // 5
        };

        System.assertEquals(assets[0], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(0), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(assets[0], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(29), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(assets[1], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(30), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(assets[1], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(35), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(assets[2], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(45), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(assets[3], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(55), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(assets[4], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(60), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(assets[4], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(69), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(assets[5], ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(75), Asset.InstallDate, Asset.UsageEndDate));

        System.assertEquals(null, ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(-1), Asset.InstallDate, Asset.UsageEndDate));
        System.assertEquals(null, ApexUtils.findRecWithDateBetween(assets, Date.today(), Asset.InstallDate, Asset.UsageEndDate, false));
        System.assertEquals(null, ApexUtils.findRecWithDateBetween(assets, Date.today().addDays(29), Asset.InstallDate, Asset.UsageEndDate, false));
    }


    @isTest static void test_findRecWithDecimalBetween() {
        List<Account> accounts = new List<Account>{
            new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), BillingLatitude = 1, BillingLongitude = 15),
            new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), BillingLatitude = 16, BillingLongitude = 30),
            new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), BillingLatitude = 31, BillingLongitude = null)
        };

        // startIsInclusive = true
        //      endIsInclusive = true
        System.assertEquals(accounts[0], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 1, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude));
        System.assertEquals(accounts[0], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 1, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, true));
        System.assertEquals(accounts[0], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 15, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, true));
        System.assertEquals(accounts[1], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 16, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, true));
        System.assertEquals(accounts[1], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 30, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, true));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 99, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, true));

        // startIsInclusive = true
        //      endIsInclusive = false
        System.assertEquals(accounts[0], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 1, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, false));
        System.assertEquals(accounts[1], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 16, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, false));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 15, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, false));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 30, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, false));

        // startIsInclusive = false
        //      endIsInclusive = true
        System.assertEquals(accounts[0], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 2, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, true));
        System.assertEquals(accounts[1], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 17, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, true));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 1, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, true));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 16, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, true));

        // startIsInclusive = false
        //      endIsInclusive = false
        System.assertEquals(accounts[0], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 10, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, false));
        System.assertEquals(accounts[1], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 20, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, false));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 1, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, false));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 15, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, false));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 16, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, false));
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 30, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, false));

        // includeEndIsNullRule = true
        // ( startIsInclusive and endIsInclusive defaults to true )
        System.assertEquals(accounts[2], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 45, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, false, true));
        System.assertEquals(accounts[2], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 45, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, false, true, true));
        System.assertEquals(accounts[2], (Account) ApexUtils.findRecWithDecimalBetween(accounts, 45, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, true, true));
        // includeEndIsNullRule = false
        // ( startIsInclusive and endIsInclusive defaults to true )
        System.assertEquals(null, (Account) ApexUtils.findRecWithDecimalBetween(accounts, 45, Schema.Account.BillingLatitude, Schema.Account.BillingLongitude, true, true, false));
    }

    @isTest static void test_groupByTopLevelBundle() {
        List<Account> accounts = new List<Account>{
            new Account(Id = getFakeId(Account.getSObjectType())), // 0
            new Account(Id = getFakeId(Account.getSObjectType())), // 1
            new Account(Id = getFakeId(Account.getSObjectType())), // 2
            new Account(Id = getFakeId(Account.getSObjectType())), // 3
            new Account(Id = getFakeId(Account.getSObjectType())), // 4
            new Account(Id = getFakeId(Account.getSObjectType()))  // 5
        };

        // line 1 is a child of line 0
        accounts[1].ParentId = accounts[0].Id;
        // line 2 is a child of line 0
        accounts[2].ParentId = accounts[0].Id;
        // line 3 is a child of line 2
        accounts[3].ParentId = accounts[2].Id;
        // line 4 is a child of line 5
        accounts[4].ParentId = accounts[5].Id;


        Map<Id, List<Account>> bundleByTopLevelRecord = (Map<Id, List<Account>>) ApexUtils.groupByTopLevelBundle(accounts, Schema.Account.ParentId);
        System.debug('bundleByTopLevelRecord: ' + bundleByTopLevelRecord);

        // Example log output
//        bundleByTopLevelRecord: {
//            802000000000001AAA=(
//              Account:{Id=802000000000001AAA},
//              Account:{Id=802000000000002AAA, ParentId=802000000000001AAA},
//              Account:{Id=802000000000003AAA, ParentId=802000000000001AAA},
//              Account:{Id=802000000000004AAA, ParentId=802000000000003AAA}
//            ),
//            802000000000006AAA=(
//              ParentId:{Id=802000000000006AAA},
//              ParentId:{Id=802000000000005AAA, ParentId=802000000000006AAA}
//            )
//        }

        System.assert(bundleByTopLevelRecord.containsKey(accounts[0].Id));
        System.assertEquals(accounts[0], bundleByTopLevelRecord.get(accounts[0].Id)[0]);
        System.assertEquals(accounts[1], bundleByTopLevelRecord.get(accounts[0].Id)[1]);
        System.assertEquals(accounts[2], bundleByTopLevelRecord.get(accounts[0].Id)[2]);
        System.assertEquals(accounts[3], bundleByTopLevelRecord.get(accounts[0].Id)[3]);

        System.assert(bundleByTopLevelRecord.containsKey(accounts[5].Id));
        System.assertEquals(accounts[5], bundleByTopLevelRecord.get(accounts[5].Id)[0]);
        System.assertEquals(accounts[4], bundleByTopLevelRecord.get(accounts[5].Id)[1]);

    }

    @isTest static void test_groupByTopLevelBundleWhenNoParent() {
        List<Account> accounts = new List<Account>{
            new Account(Id = getFakeId(Account.getSObjectType())), // 0
            new Account(Id = getFakeId(Account.getSObjectType())), // 1
            new Account(Id = getFakeId(Account.getSObjectType())), // 2
            new Account(Id = getFakeId(Account.getSObjectType())), // 3
            new Account(Id = getFakeId(Account.getSObjectType())), // 4
            new Account(Id = getFakeId(Account.getSObjectType()))  // 5
        };

        // line 1 has a parent not included in the dataset - this makes sure that there is not an infinite loop
        accounts[1].ParentId = ApexUtilsTest.getFakeId(Account.getSObjectType());
        // line 2 is a child of line 0
        accounts[2].ParentId = accounts[0].Id;
        // line 3 is a child of line 2
        accounts[3].ParentId = accounts[2].Id;
        // line 4 is a child of line 5
        accounts[4].ParentId = accounts[5].Id;


        try {
            Map<Id, List<Account>> bundleByTopLevelRecord = (Map<Id, List<Account>>) ApexUtils.groupByTopLevelBundle(accounts, Schema.Account.ParentId);
        } catch(ApexUtils.NoParentRecordIncludedException ex) {
            System.assert(true);
        } catch(Exception ex) {
            System.assert(false, 'Exception ApexUtils.NoParentRecordIncludedException was expected, received ' + ex);
        }
    }

    @isTest static void test_DynamicQueryMethods() {
        List<Account> existingAccounts = createTestAccounts();
        List<Contact> existingContacts = createTestContacts(existingAccounts);
        System.assertEquals(existingAccounts.size(), ApexUtils.dynamicQuery('Account').size());
        System.assertEquals(existingContacts.size(), ApexUtils.dynamicQuery('Contact').size());

        List<Account> accounts = (List<Account>) ApexUtils.dynamicQueryWithSubquery('Account', 'Contact', 'Contacts');
        System.assertEquals(existingAccounts.size(), accounts.size());
        System.assertEquals(1, accounts[0].Contacts.size());
    }

    @isTest static void test_GetFieldsMethods() {

        System.assert(ApexUtils.getAllFieldsForSobj('Account').size() > 0);
        System.assert(ApexUtils.getCreatableFields('Account').size() > 0);
        //System.assertEquals(false, ApexUtils.getCreatableFields('Account').contains('CreatedById'));
        System.assertEquals(true, ApexUtils.getCreatableFields('Account').contains('Name'));

        System.assertEquals(false, ApexUtils.getAllFieldsExceptBlacklist('Account', new List<String>{'Name'}).contains('name'));
        System.assertEquals(true,  ApexUtils.getAllFieldsExceptBlacklist('Account', new List<String>{'Name'}).contains('type'));

        System.assert(ApexUtils.getAllFieldsForSObjAsStr('Account').length() > 0);

        //System.assertEquals(false, ApexUtils.getAllFieldsExceptBlacklistAsStr('Account', new List<String>{'Name'}).contains('name,'));
        System.assertEquals(true, ApexUtils.getAllFieldsExceptBlacklistAsStr('Account', new List<String>{'Name'}).contains('type,'));

        System.assert(ApexUtils.getCreatableFieldsAsStr('Account').length() > 0);
        System.assertEquals(true, ApexUtils.getCreatableFieldsAsStr('Account').contains('Name'));
        //System.assertEquals(false, ApexUtils.getCreatableFieldsAsStr('Account').contains('CreatedById'));
    }

    @isTest static void test_randomString() {
        System.assertNotEquals(null, ApexUtils.randomString(15));
        System.assertEquals(15, ApexUtils.randomString(15).length());
    }

    @isTest static void test_validateId() {
        System.assertEquals('0011800000dSq2KAAS', ApexUtils.validateId('0011800000dSq2KAAS'));
        System.assertEquals('0011800000dSq2K', ApexUtils.validateId('0011800000dSq2K'));
        System.assertEquals(null, ApexUtils.validateId('0011800000dSq2KAA#'));
        System.assertEquals(null, ApexUtils.validateId('0011800000dSq2#'));
        System.assertEquals(null, ApexUtils.validateId('!!!FOO!!!'));
    }

    @isTest static void formatDate() {
        String dateStr = ApexUtils.formatDate(Date.newInstance(2000, 1, 1), 'yyyy-MM-dd');
        System.assertEquals(10, dateStr.length());
        System.assertEquals('2000-01-01', dateStr);
    }

    @isTest static void test_getEnvironmentName() {
        String subDomainWithProtocol1 = 'https://foo--sfbill';
        String subDomainWithProtocol2 = 'https://foo-steelbrick-dev-ed';
        
        ApexUtils.subDomainWithProtocol = subDomainWithProtocol1;
        System.assertEquals('foo--sfbill', ApexUtils.getEnvironmentName());
        System.assertEquals('sfbill', ApexUtils.getEnvironmentName('--'));

        ApexUtils.subDomainWithProtocol = subDomainWithProtocol2;
        System.assertEquals('foo-steelbrick-dev-ed', ApexUtils.getEnvironmentName());
    }

    @isTest static void test_MapSorter_and_mapSorterByObjType() {
        List<Account> acctList = createTestAccounts();
        List<Contact> contactList = new List<Contact>();
        contactList.add(createTestContact(acctList[0]));
        contactList.add(createTestContact(acctList[0]));
        contactList.add(createTestContact(acctList[0]));
        contactList.add(createTestContact(acctList[2]));
        contactList.add(createTestContact(acctList[2]));
        contactList.add(createTestContact(acctList[1]));

        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert contactList;
        }
        

        Map<Id, sObject> sObjectMap = new Map<Id, sObject>();
        // put sObjects in the map in a way that incurs 6 chunks (A, C, A, C, A, C):
        sObjectMap.put(acctList[0].Id, acctList[0]); 
        sObjectMap.put(contactList[0].Id, contactList[0]);
        sObjectMap.put(acctList[1].Id, acctList[1]);
        sObjectMap.put(contactList[1].Id, contactList[1]);
        sObjectMap.put(acctList[2].Id, acctList[2]);
        sObjectMap.put(contactList[2].Id, contactList[2]);

        Integer counter = 0;
        Integer numberOfChunks = 0;
        Integer numberOfChunksV2 = 0;
        String objectNameVar;
        // Since we have 2 object types in the map (Account and Contact) we should only have 1 switch (2 chunks) in the sorted version:
        for(Id sObjId : sObjectMap.keySet()) {
            String sObjName = sObjId.getSObjectType().getDescribe().getName();
            if(sObjName != objectNameVar) {
                numberOfChunks += 1;
            }
            objectNameVar = sObjName;
        }

        // before sorting, the number of chunks in the sObjectMap should be 6:
        System.assertEquals(numberOfChunks, 6);

        Map<Id, sObject> sObjectMapV2 = sObjectMap;
        for(Id sObjId : sObjectMapV2.keySet()) {
            String sObjName = sObjId.getSObjectType().getDescribe().getName();
            if(sObjName != objectNameVar) {
                numberOfChunksV2 += 1;
            }
            objectNameVar = sObjName;
        }

        System.assertEquals(numberOfChunksV2, 6);

        // sort the sObjects by Id to consolidate the chunks:
        sObjectMap = ApexUtils.mapSorter(sObjectMap);
        sObjectMapV2 = APexUtils.mapSorterByObjType(sObjectMap);

        counter = 0;
        numberOfChunks = 0;
        numberOfChunksV2 = 0;
        objectNameVar = null;
        // Since we have 2 object types in the map (Account and Contact) we should only have 1 switch (2 chunks) in the sorted version:
        for(Id sObjId : sObjectMap.keySet()) {
            String sObjName = sObjId.getSObjectType().getDescribe().getName();
            if(sObjName != objectNameVar) {
                numberOfChunks += 1;
            }
            objectNameVar = sObjName;
        }
        // same thing for sObjectMapV2, which was sorted using the mapSorterByObjType method:
        for(Id sObjId : sObjectMapV2.keySet()) {
            String sObjName = sObjId.getSObjectType().getDescribe().getName();
            if(sObjName != objectNameVar) {
                numberOfChunksV2 += 1;
            }
            objectNameVar = sObjName;
        }

        // after the mapSorter method sorted the sObjectMap, the number of chunks should be 2:
        System.assertEquals(numberOfChunks, 2);
        // after the mapSorterByObjType method sorted the sObjectMapV2, the number of chunks should be 2:
        System.assertEquals(numberOfChunksV2, 2);
    }


    @isTest static void test_MapSorterByNumOfChildren() {
        List<Account> acctList = createTestAccounts();
        List<Contact> contactList = new List<Contact>();
        contactList.add(createTestContact(acctList[0]));
        contactList.add(createTestContact(acctList[0]));
        contactList.add(createTestContact(acctList[0]));
        contactList.add(createTestContact(acctList[2]));
        contactList.add(createTestContact(acctList[2]));
        contactList.add(createTestContact(acctList[1]));

        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert contactList;
        }

        Schema.sObjectField contactField = Contact.AccountId.getDescribe().getSObjectField();
        Map<String, List<sObject>> accountIdToContactsMap = ApexUtils.groupBy(contactList, contactField);
        accountIdToContactsMap = ApexUtils.mapSorterByNumOfChildren(accountIdToContactsMap); // sort accounts by number of contacts ascending

        List<Integer> numOfContactsList = new List<Integer>();
        for(String accountId : accountIdToContactsMap.keySet()) {
            Integer numOfContacts = accountIdToContactsMap.get(accountId).size();
            numOfContactsList.add(numOfContacts);
        }

        // Verify the map got sorted by number of contacts ascending:
        System.assertEquals(numOfContactsList[0], 1);
        System.assertEquals(numOfContactsList[1], 2);
        System.assertEquals(numOfContactsList[2], 3);

    }

    @isTest static void test_ScheduleBuilder() {
        ApexUtils.ScheduleBuilder scheduleUsingSeconds = new ApexUtils.ScheduleBuilder(
            5,                                                              // Integer secondsToAdd
            'Test Schedule that will execute the apex 5 seconds from now'   // String jobName
        );
        System.assertNotEquals(scheduleUsingSeconds.pointInFuture, null);
        System.assertNotEquals(scheduleUsingSeconds.strSchedule, null);
        System.assertNotEquals(scheduleUsingSeconds.strJobName, null);

        ApexUtils.ScheduleBuilder scheduleUsingSecondsV2 = new ApexUtils.ScheduleBuilder(
            5,                  // Integer timeToAdd
            'seconds',          // String timeUnitOfMeasure
            'Test Schedule that will execute the apex 5 seconds from now V2' // String jobName
        );
        System.assertNotEquals(scheduleUsingSecondsV2.pointInFuture, null);
        System.assertNotEquals(scheduleUsingSecondsV2.strSchedule, null);
        System.assertNotEquals(scheduleUsingSecondsV2.strJobName, null);

        ApexUtils.ScheduleBuilder scheduleUsingMinutes = new ApexUtils.ScheduleBuilder(
            5,                  // Integer timeToAdd
            'minutes',          // String timeUnitOfMeasure
            'Test Schedule that will execute the apex 5 minutes from now'   // String jobName
        );
        System.assertNotEquals(scheduleUsingMinutes.pointInFuture, null);
        System.assertNotEquals(scheduleUsingMinutes.strSchedule, null);
        System.assertNotEquals(scheduleUsingMinutes.strJobName, null);

        ApexUtils.ScheduleBuilder scheduleUsingHours = new ApexUtils.ScheduleBuilder(
            5,                  // Integer timeToAdd
            'hours',            // String timeUnitOfMeasure
            'Test Schedule that will execute the apex 5 hours from now'     // String jobName
        );
        System.assertNotEquals(scheduleUsingHours.pointInFuture, null);
        System.assertNotEquals(scheduleUsingHours.strSchedule, null);
        System.assertNotEquals(scheduleUsingHours.strJobName, null);

        ApexUtils.ScheduleBuilder scheduleUsingDays = new ApexUtils.ScheduleBuilder(
            5,                  // Integer timeToAdd
            'days',             // String timeUnitOfMeasure
            'Test Schedule that will execute the apex 5 days from now'     // String jobName
        );
        System.assertNotEquals(scheduleUsingDays.pointInFuture, null);
        System.assertNotEquals(scheduleUsingDays.strSchedule, null);
        System.assertNotEquals(scheduleUsingDays.strJobName, null);
    }
}