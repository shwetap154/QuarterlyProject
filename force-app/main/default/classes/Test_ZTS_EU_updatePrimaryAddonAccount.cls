@istest(seeAllData=false)
public class Test_ZTS_EU_updatePrimaryAddonAccount {


    public static address__c Create_PrimaryAddonAccount(){

        Account acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Farm';
        acc.ZTS_EU_Sub_Type__c = 'Beef';
        acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        acc.ZTS_EU_City__c = 'Test City';
        acc.ZTS_EU_Zip_Postal_Code__c = 'LD';
        acc.ZTS_EU_Main_Phone__c='9876789876';
        acc.CurrencyIsoCode='EUR';
        acc.ZTS_EU_Market__c='United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Vetsave_ID__c='200';
        acc.ZTS_EU_Vetsave_HO_ID__c='56';

        Insert acc;


        List<Address__c> addList = new List<Address__c>();

        State_Country__c sc = new State_Country__c();
        sc.name = 'ABERCONWY';
        sc.ZTS_EU_Country__c = 'United Kingdom';
        insert sc;
        Address__c add = new Address__c();
        add.name = 'Test Address';
        add.ZTS_EU_Country__c = 'United Kingdom';
        add.ZTS_EU_State_County__c = sc.id;
        add.Zip_Postal_Code__c = '123456';
        add.ZTS_EU_Account__c = acc.id;
        insert add;
        return add;

    }

    public static address__c Create_PrimaryAddonContact(){
        State_Country__c Cont = new State_Country__c();
        Cont.ZTS_EU_Country__c ='Spain';
        Cont.ZTS_EU_uniqueCOUNTY__c = '!@#ADSFD';
        Insert Cont;


        Contact con = new Contact();
        con.firstname='Test First';
        con.lastname = 'Test Contact';
        con.ZTS_EU_Speaker_Flag__c=true;
        con.ZTS_EU_Market__c= '';
        con.ZTS_EU_Country__c ='Spain';
        con.ZTS_EU_State_County__c = Cont.id;
        insert con;

        List<Address__c> addList = new List<Address__c>();

        State_Country__c sc = new State_Country__c();
        sc.name = 'ABERCONWY';
        sc.ZTS_EU_Country__c = 'United Kingdom';
        insert sc;


        Address__c add = new Address__c();
        add.name = 'Test Address';
        add.ZTS_EU_Country__c = 'United Kingdom';
        add.ZTS_EU_State_County__c = sc.id;
        add.Zip_Postal_Code__c = '123456';

        add.ZTS_EU_Contact__c = con.id;
        insert add;

        return add;

    }

    public static testMethod void Test_ZTS_EU_updatePrimaryAddonAccount ()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            test.starttest();
            Address__c createADD = Create_PrimaryAddonAccount();
            ZTS_EU_updatePrimaryAddonAccount.updatePrimaryaddress(createADD.id);
            test.stoptest();
        }
    }

    public static testMethod void Test_ZTS_EU_update_PrimaryAddonContact  ()
    {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            test.starttest();
            Address__c createADD = Create_PrimaryAddonContact();
            ZTS_EU_updatePrimaryAddonAccount.updatePrimaryaddress(createADD.id);
            test.stoptest();
        }
    }

    public static testMethod void Test_ZTS_US_updatePrimaryAddonAccount ()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        System.runAs(usr)
        {
            List<Account> accs = ZTS_DataUtilityTest.createAccountRecord(1);

            insert accs;
            List<Address__c> originalPrimaryAddress = [SELECT Id FROM Address__c WHERE ZTS_EU_Account__c =: accs[0].Id];
            
            List<Address__c> addList = ZTS_DataUtilityTest.createAddressrec(accs);

            insert addList;

            test.starttest();

            ZTS_EU_updatePrimaryAddonAccount.updatePrimaryaddress(addList[0].Id);
            test.stoptest();

            List<Address__c> actualAddresses = [SELECT Id, ZTS_US_Primary__c, ZTS_EU_Primary__c
                                                FROM Address__c
                                                WHERE Id =: addList[0].Id];

            System.assert(actualAddresses.size() > 0, 'We expect to have an address present.');
            System.assertEquals(true, actualAddresses[0].ZTS_US_Primary__c, 'We expect the addresses Primary flag to be updated.');
            System.assertEquals(actualAddresses[0].ZTS_EU_Primary__c, actualAddresses[0].ZTS_US_Primary__c, 'We expect the addresses Primary flags to be in sync.');

            List<Address__c> actualNonPrimaryAddresses = [SELECT Id, ZTS_US_Primary__c, ZTS_EU_Primary__c
                                                FROM Address__c
                                                WHERE Id =: originalPrimaryAddress[0].Id];

            System.assert(actualNonPrimaryAddresses.size() > 0, 'We expect to have an address present.');
            System.assertEquals(false, actualNonPrimaryAddresses[0].ZTS_US_Primary__c, 'We expect the addresses Primary flag to be updated.');
            System.assertEquals(actualNonPrimaryAddresses[0].ZTS_EU_Primary__c, actualNonPrimaryAddresses[0].ZTS_US_Primary__c, 'We expect the addresses Primary flags to be in sync.');
        }
    }

}