@isTest
private class ZTS_US_ContactAddinsertfromAccount_Test
{
    static testMethod void ZTS_US_ContactAddinsertfromAccount()
    {
        ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            List<Account> Accountrecord = ZTS_DataUtilityTest.createAccountRecord(1);
            AccountRecord[0].BillingCity = 'Boca Raton';
            AccountRecord[0].ZTS_EU_Market__c = 'United States';
            insert Accountrecord;
            Set<Id> accset = new Set<Id>();
            for(Account acc : Accountrecord){
                accset.add(acc.id);
            }

            List<Contact> Contactrecord = ZTS_DataUtilityTest.createContactRecord(1);
            List<Contact> conlst = new List<Contact>();
            for(Contact con: Contactrecord){
                con.AccountId = Accountrecord[0].id;
                conlst.add(con);
            }
            test.startTest();
            insert conlst;
            ZTS_US_ContactAddinsertfromAccount.ContactAddinsertfromAccount(accset,conlst);
            System.assert(conlst[0].MailingCity == Accountrecord[0].BillingCity);
            System.assert(conlst[0].MailingStreet == Accountrecord[0].BillingStreet);
            System.assert(conlst[0].MailingCountry == Accountrecord[0].BillingCountry);
            //System.assert(conlst[0].MailingStateCode == Accountrecord[0].BillingStateCode);
            test.stopTest();
        }
    }

    static testMethod void  testpopulateLISOrgCode()
    {
        ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            List<Account> Accountrecord = ZTS_DataUtilityTest.createAccountRecord(1);
            insert Accountrecord;
/*
            State_Country__c sc = new State_Country__c
            (   Name = 'testName'
            ,   ZTS_EU_Country__c = 'testCountry'
            );
            insert sc;

            Address__c testAddress = new Address__c(Zip_Postal_Code__c = '00000',
                                                    ZTS_EU_Street__c = 'testStreet',
                                                    ZTS_Address_Line_1__c = 'testline1',
                                                    ZTS_EU_Address_Line_2__c = 'testline2',
                                                    State_Province__c = 'testState',
                                                    ZTS_EU_Address_Type__c = 'Ship To',
                                                    ZTS_EU_Primary__c = true,
                                                    ZTS_EU_Country__c = 'testCountry',
                                                    ZTS_EU_City__c = 'testCity',
                                                    ZTS_EU_Account__c = Accountrecord[0].Id,
                                                    Is_Active__c = true ,
                                                    Ship_Indirect__c = 'N',
                                                    ZTS_EU_State_County__c = sc.id,
                                                    ZTS_US_Source_Account_Number__c = '10001'
                                                    );
            insert testAddress;
/**/
            List<Contact> Contactrecord = ZTS_DataUtilityTest.createContactRecord(1);
            for ( Contact con : Contactrecord ) {
                con.AccountId = Accountrecord[0].id;
            }
            insert Contactrecord;

            test.startTest();
            Accountrecord[0].Reference_Lab_Customer__c = true;
            AccountTriggerHandler accTriggerHandler = new AccountTriggerHandler();
            DispatchTriggerHandler.setRecursionContexts(accTriggerHandler);
            update Accountrecord;
            test.stopTest();

            System.assertEquals(null, Accountrecord[0].LIS_Org_Code__c,'LIS org code is not null');
            System.assertEquals(true, Accountrecord[0].Reference_Lab_Customer__c,'Reference_Lab_Customer is true');

            delete Accountrecord; 
        }
    }

    @isTest
    private static void testSendReportingContactsToLIS() {

        ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            List<Account> accountRecordsList = ZTS_DataUtilityTest.createAccountRecord(1);
            accountRecordsList[0].Reference_Lab_Customer__c = true;
            accountRecordsList[0].LIS_Org_Code__c = '123456';
            insert accountRecordsList;

            State_Country__c stc = new State_Country__c();
            stc.name = 'test co';
            stc.ZTS_EU_Country__c = 'Albania';
            insert stc;
        
            Address__c adds = new Address__c();
            adds.name = 'test line';
            adds.ZTS_EU_Account__c = accountRecordsList[0].Id;
            adds.ZTS_EU_Address_Type__c = 'Shipping';
            adds.ZTS_EU_District__c = 'Teast';
            adds.ZTS_EU_Country__c = 'Albania';
            adds.ZTS_EU_State_County__c = stc.id;
            adds.Zip_Postal_Code__c = '738747';
            adds.ZTS_US_Source_Account_Number__c = '908090';
            adds.Is_Active__c = true;
            adds.LIS_Number__c = '99999test';
            adds.Ship_Indirect__c = 'N';
            insert adds;
            
            Address__c adds1 = new Address__c();
            adds1.name = 'test line';
            adds1.ZTS_EU_Account__c = accountRecordsList[0].Id;
            adds1.ZTS_EU_Address_Type__c = 'Shipping';
            adds1.ZTS_EU_District__c = 'Teast';
            adds1.ZTS_EU_Country__c = 'Albania';
            adds1.ZTS_EU_State_County__c = stc.id;
            adds1.Zip_Postal_Code__c = '738747';
            adds1.ZTS_US_Source_Account_Number__c = '908090';
            adds1.Is_Active__c = true;
            adds1.LIS_Number__c = '99999test';
            adds1.Ship_Indirect__c = 'N';
            insert adds1;

            List<Contact> contactRecordList = ZTS_DataUtilityTest.createContactRecord(1);
            for ( Contact con : contactRecordList ) {
                con.AccountId = accountRecordsList[0].id;
                con.Reference_Lab_Contact__c = true;
                con.ZTS_US_Profession__c = 'Veterinarian';
                con.ZTS_US_Job_Function__c = 'Associate';
                con.RefLabs_Email_Default__c = true;
                con.RefLabs_Results_Email__c = 'test@test.com';
            }
            insert contactRecordList;

            contactRecordList[0].Send_To_LIS__c = false;
            update contactRecordList;

            test.startTest();

            AccountTriggerHandler accTriggerHandler = new AccountTriggerHandler();
            DispatchTriggerHandler.setRecursionContexts(accTriggerHandler);
            accountRecordsList[0].LIS_Org_Code__c = '78967671';
            update accountRecordsList;
            
            ContactSendToLISInvocable.sendTOLIS(contactRecordList);
            ContactSendToLISInvocable.sendTOLIS(null);
            test.stopTest();

            List<Contact> relatedReportingContacts =
            [   SELECT  Id, Send_To_LIS__c
                FROM    Contact
                WHERE   AccountId IN :accountRecordsList             
            ];

            System.assertEquals(true, relatedReportingContacts[0].Send_To_LIS__c,'The Contact is marked as RefLabs contact');
            System.assertEquals(true, accountRecordsList[0].Reference_Lab_Customer__c,'Reference_Lab_Customer is true');

        }

    }
}