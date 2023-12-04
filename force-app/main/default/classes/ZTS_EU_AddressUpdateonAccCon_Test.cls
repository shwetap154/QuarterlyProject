@isTest
public class ZTS_EU_AddressUpdateonAccCon_Test {
    
    public static testMethod void ZTS_EU_AddressUpdateonAccountContact() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            
            List < sObject > ls = Test.loadData(ZTS_GL_Account_Affiliation_Reverse_Roles__c.sObjectType, 'AccountReverseRoles');
            // List < TriggerActivation__c > triggerActiveList = new List < TriggerActivation__c > ();
            // TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_AddressUpdateonAccountContact',ZTS_EU_Bypass__c = true);
            // triggerActiveList.add(tr);
            
            List<Account> accountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            Insert accountRecord;
            List<Contact> contactRecord=ZTS_EU_DataUtilityTest.createContactRecord(1);
            Insert contactRecord;
            
            List<Address__c>AddressRecord=ZTS_EU_DataUtilityTest.createAddressRecord(1);
            List<Address__c> addrupd = new List<Address__c>();
            Map<Id,Address__c> triggerOldMap = new Map<Id,Address__c>();
            Map<Id,Address__c> triggerNewMap = new Map<Id,Address__c>();
            
            for(Address__c addr : AddressRecord){
                triggerOldMap.put(addr.id, addr);
                triggerNewMap.put(addr.id, addr);
                addr.ZTS_EU_Account__c = accountRecord[0].id;
                addr.ZTS_EU_Phone__c = '900test';
                //addr.ZTS_EU_Contact__c = contactRecord[0].id;
                addrupd.add(addr);
            }
            
            insert addrupd;
            
            List<Address__c> addrupd1 = new List<Address__c>();
            triggerOldMap = new Map<Id,Address__c>();
            triggerNewMap = new Map<Id,Address__c>();
            
            for(Address__c addr : ZTS_EU_DataUtilityTest.createAddressRecord(1))
            {
                triggerOldMap.put(addr.id, addr);
                triggerNewMap.put(addr.id, addr);
                addr.ZTS_EU_Contact__c = contactRecord[0].id;
                addr.ZTS_EU_City__c = 'Test';
                addr.ZTS_EU_Phone__c = 'test200';
                addrupd1.add(addr);
            }
            
            UtilityService.addressTriggerRun = true;   
            insert addrupd1;
            
            UtilityService.addressTriggerRun = true;
            addrupd1[0].ZTS_EU_City__c = 'Test12';
            addrupd1[0].ZTS_EU_Contact__c = contactRecord[0].id;
            update addrupd1;
            
            contactRecord[0].ZTS_EU_Primary_Address__c = addrupd1[0].Id;
            update contactRecord[0];
            
            List<Account> accupd = new List<Account>();
            for(Account acc : accountRecord){
                acc.ZTS_EU_Primary_Address__c = addrupd[0].id;
                acc.ZTS_EU_Parent_Id__c = addrupd[0].id;
                
            }
            update accountRecord;
            
            map<id,account> mapAcc = new map<id,account>([SELECT ZTS_EU_Primary_Address__c, ZTS_EU_Address_Line_1__c, 
                                                          ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c, ZTS_EU_Address_Line_4__c, 
                                                          ZTS_EU_District__c, ZTS_EU_City__c, ZTS_EU_Zip_Postal_Code__c, ZTS_EU_Country__c, 
                                                          ZTS_EU_Main_Phone__c, ZTS_EU_Commune_Lookup__c, ZTS_EU_State_County__c, ZTS_EU_City_Country__c
                                                          FROM Account 
                                                          WHERE Id = :accountRecord[0].id
                                                          AND ZTS_EU_Market__c != 'United States']);
            
            for(Account acc : accountRecord){
                acc.ZTS_EU_Main_Phone__c = '12345678';
                accupd.add(acc);
            }
            
            update accupd;
            UtilityService.addressTriggerRun = true;
            // insert triggerActiveList;
            
            
            Address__c add1 = [select id,ZTS_EU_Primary_Address__c,ZTS_EU_District__c from Address__c where id =:addrupd[0].id];
            
            UtilityService.addressTriggerRun=true;
            system.assertEquals(true, UtilityService.isAddressTriggerRun());
            
            add1.ZTS_EU_City__c = 'test';
            add1.ZTS_EU_Phone__c = '1238';
            update add1;
            
            List<Contact> lstCon = new List<Contact>();
            //List<Contact> lstCon1 = new List<Contact>();
            
            contact con = new contact();
            con.lastname = 'testCon';
            con.firstname = 'test';
            con.ZTS_EU_Private_Phone__c = 'test12345';
            con.ZTS_EU_Primary_Address__c = addrupd1[0].id;
            lstCon.add(con);
            
            insert lstCon;
            
            lstCon[0].ZTS_EU_Private_Phone__c = 'test123456';
            update lstcon[0];
            
            UtilityService.contactTriggerRun = true;
            Test.StartTest();
            ZTS_EU_Update_Address.updateAccountContactAddress(addrupd1,triggerOldMap,triggerNewMap,true,true);
            ZTS_Account_Utility.populateCity(addrupd1);
            ZTS_Account_Utility.populateCity(addrupd);
            Test.StopTest();
        }
    }
    public static testMethod void ZTS_EU_AddressUpdateonAccountContact1() { 
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Address__c> addList1 = new List<Address__c>();
            
            State_Country__c sc1 = new State_Country__c();
            sc1.name = 'ABERCONWY';
            sc1.ZTS_EU_Country__c = 'United Kingdom';
            insert sc1;
            
            Account acc1 = new Account();         
            acc1.name = 'Test Account New';
            acc1.Type = 'Farm';
            acc1.ZTS_EU_Sub_Type__c = 'Beef';
            acc1.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc1.ZTS_EU_City__c = 'Test City';
            acc1.ZTS_EU_Zip_Postal_Code__c = 'LD';                
            // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc1.ZTS_EU_Main_Phone__c='9876789876';
            acc1.CurrencyIsoCode='EUR';
            acc1.ZTS_EU_Market__c='United Kingdom';
            acc1.Practice_Management_Software__c = 'Other';
            acc1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc1.ZTS_EU_Vetsave_ID__c='200';
            acc1.ZTS_EU_Vetsave_HO_ID__c='56';
            insert acc1;
            
            Address__c add1 = new Address__c();         
            add1.name = 'Test Address New';
            add1.ZTS_EU_Country__c = 'United Kingdom';
            add1.ZTS_EU_State_County__c = sc1.id;
            add1.Zip_Postal_Code__c = '2343'; 
            add1.ZTS_EU_Account__c = acc1.Id;
            addList1.add(add1);
            
            insert addList1;
            
            ZTS_Account_Utility.populateCity(addList1);
        }
    }
}