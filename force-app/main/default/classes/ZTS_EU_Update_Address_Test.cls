@isTest
public with sharing class ZTS_EU_Update_Address_Test {
    public static testMethod void ZTS_EU_Update_Address() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List < sObject > ls = Test.loadData(ZTS_GL_Account_Affiliation_Reverse_Roles__c.sObjectType, 'AccountReverseRoles');
            
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
            
            Map<Id,Contact> mapCon = new Map<Id,Contact>([SELECT ZTS_EU_Primary_Address__c, ZTS_EU_Address_Line_1__c, ZTS_EU_Address_Line_2__c, 
                                                          ZTS_EU_Address_Line_3__c, ZTS_EU_City__c, ZTS_EU_District__c, ZTS_EU_Commune_Lookup__c, ZTS_EU_State_County__c, ZTS_EU_Zip_Postal_Code__c, 
                                                          ZTS_EU_Country__c, ZTS_EU_Private_Phone__c, ZTS_EU_City_Country__c 
                                                          FROM Contact 
                                                          WHERE Id = :lstCon[0].Id 
                                                          AND ZTS_EU_Market__c != 'United States'
                                                         ]);
            
            lstCon[0].ZTS_EU_Private_Phone__c = 'test123456';
            update lstcon[0];
            
            UtilityService.contactTriggerRun = true;
            Test.StartTest();
            ZTS_EU_Update_Address.updateAccountContactAddress(addrupd1,triggerOldMap,triggerNewMap,true,true);
            ZTS_EU_Update_Address.updateAddressFieldsOfAccount(accupd,mapAcc);
            ZTS_EU_Update_Address.updateAddressRecordWithAccountFields(accupd,mapAcc);
            ZTS_EU_Update_Address.updateAddressFieldsOfContact(lstCon,mapCon);
            ZTS_EU_Update_Address.updateAddressRecordWithContactFields(lstCon,mapCon);
            Test.StopTest();
        }
    }
    
    static testMethod void validate_ZTS_EU_Update_Address() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            
            List<Account>accountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            Insert accountRecord;
            
            accountRecord[0].ZTS_EU_Parent_Id__c = accountRecord[0].id;
            update accountRecord;
            
            List<Contact>contactRecord=ZTS_EU_DataUtilityTest.createContactRecord(1);
            Insert contactRecord;
            List<Address__c> list_addr_new =  ZTS_EU_DataUtilityTest.createAddressRecord(1);
            for(Address__c newAddr:list_addr_new){
                newAddr.ZTS_EU_Address_Line_2__c = 'Test addr2';
                
                newAddr.ZTS_EU_Account__c = accountRecord[0].Id;
            }
            insert list_addr_new;
            List<Address__c> list_addr_old =  ZTS_EU_DataUtilityTest.createAddressRecord(1);
            for(Address__c oldAddr:list_addr_old){
                oldAddr.ZTS_EU_Address_Line_2__c = 'Test addr1';
                oldAddr.ZTS_EU_Account__c = accountRecord[0].Id;
            }
            insert list_addr_old;
            for(Account acc : accountRecord){
                acc.ZTS_EU_Primary_Address__c = list_addr_new[0].id;    
                
            }
            UtilityService.accountTriggerRun = true;
            update accountRecord;
            
            Map<Id,Address__c> triggerOldMap = new Map<Id,Address__c>();
            Map<Id,Address__c> triggerNewMap = new Map<Id,Address__c>();
            for(Address__c addr: [SELECT ID, name,ZTS_EU_City__c,ZTS_EU_Phone__c,ZTS_EU_Address_Line_3__c,
                                  ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Country__c,ZTS_EU_City_Country__c,ZTS_EU_State_County__c,Zip_Postal_Code__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Primary_Address__c
                                  FROM Address__c WHERE id =: list_addr_old[0].id]){
                                      triggerOldMap.put(list_addr_new[0].id, addr);
                                  }
            for(Address__c addr: [SELECT ID, name,ZTS_EU_City__c,ZTS_EU_Phone__c,ZTS_EU_Address_Line_3__c,
                                  ZTS_EU_Contact__c, ZTS_EU_Account__c,ZTS_EU_Country__c,ZTS_EU_City_Country__c,ZTS_EU_State_County__c,Zip_Postal_Code__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Primary_Address__c
                                  FROM Address__c WHERE id =: list_addr_new[0].id]){
                                      triggerNewMap.put(addr.id, addr);
                                  }
            list_addr_new = [SELECT ID,  name,ZTS_EU_City__c,ZTS_EU_Phone__c,ZTS_EU_Address_Line_3__c,
                             ZTS_EU_Account__c,ZTS_EU_Contact__c,ZTS_EU_Country__c,ZTS_EU_City_Country__c,ZTS_EU_State_County__c,Zip_Postal_Code__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Primary_Address__c
                             FROM Address__c WHERE id =: list_addr_new[0].id];
            
            Test.startTest();
            ZTS_EU_Update_Address.updateAccountContactAddress(list_addr_new,triggerOldMap, triggerNewMap,false, true);
            ZTS_EU_Update_Address.updateAccountContactAddress(list_addr_new,triggerOldMap, triggerNewMap,true, false);
            Test.stopTest();
        }
    }
    /*
    static testMethod void validate_ZTS_EU_Update_Address_Contact() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            TriggerActivation__c ta=new TriggerActivation__c(Name='ZTS_EU_Contact_Trigger',ZTS_EU_Bypass__c=true);insert ta;
            Primary_Contact_Inactive_Profile_List__c pcip = new Primary_Contact_Inactive_Profile_List__c(Name='Profile Names',Profile__c='NA'); insert pcip;
            Primary_Contact_Inactive_Profile_List__c pcip1 = new Primary_Contact_Inactive_Profile_List__c(Name='Profile Names 1',Profile__c='NA'); insert pcip1;
            Primary_Contact_Inactive_Profile_List__c pcip2 = new Primary_Contact_Inactive_Profile_List__c(Name='Profile Names 2',Profile__c='NA'); insert pcip2;
            
            List<Account>accountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            Insert accountRecord;
            List<Contact>contactRecord=ZTS_EU_DataUtilityTest.createContactRecord(1);
            contactRecord[0].accountid =  accountRecord[0].id;
            contactRecord[0].ZTS_EU_Market__c = 'United Kingdom';
            Insert contactRecord;
            List<Address__c> list_addr_new =  ZTS_EU_DataUtilityTest.createAddressRecord(1);
            for(Address__c newAddr:list_addr_new){
                newAddr.ZTS_EU_Address_Line_2__c = 'Test addr2';
                newAddr.ZTS_EU_Contact__c = contactRecord[0].Id;
            }
            insert list_addr_new;
            List<Address__c> list_addr_old =  ZTS_EU_DataUtilityTest.createAddressRecord(1);
            for(Address__c oldAddr:list_addr_old){
                oldAddr.ZTS_EU_Address_Line_2__c = 'Test addr1';
                oldAddr.ZTS_EU_Contact__c = contactRecord[0].Id;
            }
            insert list_addr_old;
            for(Contact con : contactRecord){
                con.ZTS_EU_Primary_Address__c = list_addr_new[0].id;    
                
            }
            Test.startTest();
            UtilityService.contactTriggerRun = true;
            update contactRecord;
            
            UtilityService.contactTriggerRun = true;
            for(Contact con : contactRecord){
                con.ZTS_EU_Primary_Address__c = list_addr_old[0].id;    
                
            }
            update contactRecord;
            
            Map<Id,Address__c> triggerOldMap = new Map<Id,Address__c>();
            Map<Id,Address__c> triggerNewMap = new Map<Id,Address__c>();
            for(Address__c addr: [SELECT ID, name,ZTS_EU_City__c,ZTS_EU_District__c,ZTS_EU_Phone__c,ZTS_EU_Address_Line_3__c,
                                  ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Country__c,ZTS_EU_State_County__c,ZTS_EU_City_Country__c,Zip_Postal_Code__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Primary_Address__c
                                  FROM Address__c WHERE id =: list_addr_old[0].id]){
                                      triggerOldMap.put(list_addr_new[0].id, addr);
                                  }
            for(Address__c addr: [SELECT ID, name,ZTS_EU_City__c,ZTS_EU_Phone__c,  ZTS_EU_Address_Line_3__c,
                                  ZTS_EU_Contact__c, ZTS_EU_Account__c,ZTS_EU_Country__c,ZTS_EU_State_County__c,Zip_Postal_Code__c,ZTS_EU_City_Country__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Primary_Address__c
                                  FROM Address__c WHERE id =: list_addr_new[0].id]){
                                      triggerNewMap.put(addr.id, addr);
                                      system.debug('@@@'+addr.ZTS_EU_Contact__c + addr.ZTS_EU_Primary_Address__c);
                                  }
            list_addr_new = [SELECT ID,  name,ZTS_EU_City__c,ZTS_EU_Phone__c,ZTS_EU_Address_Line_3__c,
                             ZTS_EU_Contact__c, ZTS_EU_Account__c,ZTS_EU_Country__c,ZTS_EU_State_County__c,ZTS_EU_City_Country__c,Zip_Postal_Code__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Primary_Address__c
                             FROM Address__c WHERE id =: list_addr_new[0].id];
            
            ZTS_EU_Update_Address.updateAccountContactAddress(list_addr_new,triggerOldMap, triggerNewMap,true, false);
            ZTS_EU_Update_Address.updateAccountContactAddress(list_addr_new,triggerOldMap, triggerNewMap,false, true);
            Test.stopTest();
        }
    }
    */
    static testmethod void testUpdateContactAddress(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            
            List<Contact> contactRecord=ZTS_EU_DataUtilityTest.createContactRecord(1);
            Insert contactRecord;
            
            List<Account> accountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            Insert accountRecord;
            
            List<Address__c> addrupd1 = new List<Address__c>();
            
            for(Address__c addr : ZTS_EU_DataUtilityTest.createAddressRecord(1)){
                
                addr.ZTS_EU_Contact__c = contactRecord[0].id;
                addr.ZTS_EU_City__c = 'Test';
                addr.ZTS_EU_Phone__c = 'test12';
                addrupd1.add(addr);
            }
            
            UtilityService.addressTriggerRun = true;   
            insert addrupd1;
            
            UtilityService.addressTriggerRun = true;
            addrupd1[0].ZTS_EU_Phone__c = 'Test123';
            update addrupd1;
            
            contactRecord[0].ZTS_EU_Primary_Address__c = addrupd1[0].Id;
            update contactRecord[0];
            
            List<Account> accupd = new List<Account>();
            map<id,account> mapAcc = new map<id,account>();
            Map<Id,Address__c> triggerOldMap = new Map<Id,Address__c>();
            Map<Id,Address__c> triggerNewMap = new Map<Id,Address__c>();
            for(Account acc : accountRecord){
                mapAcc.put(acc.id, acc);
                //acc.ZTS_EU_Primary_Address__c = addrupd1[0].id;
                acc.ZTS_EU_Address_Line_1__c = 'testAddr1';
                accupd.add(acc);
            }
            
            update accupd;
            
            List<Address__c> list_addr_new =  ZTS_EU_DataUtilityTest.createAddressRecord(1);
            for(Address__c newAddr:list_addr_new){
                newAddr.ZTS_EU_Address_Line_2__c = 'Test addr2';
                
                newAddr.ZTS_EU_Account__c = accountRecord[0].Id;
            }
            insert list_addr_new;
            Address__c add1 = [select id,ZTS_EU_Primary_Address__c,ZTS_EU_District__c from Address__c where id =:addrupd1[0].id];
            
            UtilityService.addressTriggerRun=true;
            system.assertEquals(true, UtilityService.isAddressTriggerRun());
            add1.ZTS_EU_City__c = 'Test';
            add1.ZTS_EU_Phone__c = '1238';
            
            update add1;
            
            Test.startTest();
            ZTS_EU_Update_Address.updateAccountContactAddress(list_addr_new,triggerOldMap, triggerNewMap,true, true);
            ZTS_EU_Update_Address.updateAccountContactAddress(list_addr_new,triggerOldMap, triggerNewMap,false, false);
            Test.stopTest();
            
            
            
            /* List<Contact> lstCon = new List<Contact>();
List<Contact> lstCon1 = new List<Contact>();
Map<Id,Contact> mapCon = new Map<Id,Contact>();

contact con = new contact();
con.lastname = 'testCon';
con.firstname = 'test';
con.ZTS_EU_Address_Line_1__c='test1';
con.ZTS_EU_Primary_Address__c = addrupd1[0].id;
lstCon.add(con);

insert lstCon;

mapCon.put(lstCon[0].Id,lstCon[0]);
lstCon[0].ZTS_EU_Primary_Address__c = addrupd1[0].id;


lstCon[0].ZTS_EU_District__c = addrupd1[0].id;
UtilityService.contactTriggerRun = true;
update lstcon[0];*/
        }
    }
}