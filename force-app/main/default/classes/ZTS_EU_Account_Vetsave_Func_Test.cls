/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 01-21-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   01-21-2021   Morgan Marchese @ Zoetis Inc   Initial Version
**/
@isTest
private class ZTS_EU_Account_Vetsave_Func_Test {
    
    @testSetup
    static void setup(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<State_Country__c> stateCountryList = new List<State_Country__c>();
            List<Account> parentAccountList = new List<Account>();    
            List<Account> childAccountList = new List<Account>();            
            TestDataFactory.createVetSaveMarket('Ireland',true);
            TestDataFactory.createVetSaveMarket_UK('United Kingdom',true);
            
            State_Country__c stateCountryUK = TestDataFactory.createStateCountry('United Kingdom','County Down',false);
            State_Country__c stateCountryIreland = TestDataFactory.createStateCountry('Ireland','Ireland',false);
            stateCountryList.add(stateCountryUK);
            stateCountryList.add(stateCountryIreland);
            insert stateCountryList;

            System.debug('State Country UK ID: ' + stateCountryUK.Id);
            
            // Create and Insert Home Office/Parent Accounts
            Account ukParentAccount = TestDataFactory.createAccount_EU('UK Home Office Account',stateCountryUK.Id,false);
            parentAccountList.add(ukParentAccount);
            Account irelandParentAcct = TestDataFactory.createAccount_EU('Ireland Home Office Account',stateCountryIreland.Id,false);
            irelandParentAcct.ZTS_EU_Market__c = 'Ireland';
            irelandParentAcct.ZTS_EU_Country__c = 'Ireland';
            irelandParentAcct.ZTS_EU_Vetsave_ID__c = '';
            irelandParentAcct.ZTS_EU_Vetsave_HO_ID__c = '';
            irelandParentAcct.ZTS_EU_Ref_ID1_Value__c = '300';
            irelandParentAcct.ZTS_EU_Ref_ID2_Value__c = '300';
            parentAccountList.add(irelandParentAcct);
            insert parentAccountList;

            // Create and Insert Child Accounts
            Account childAcct1 = TestDataFactory.createAccount_EU('UK Unlinked Child Account 1',stateCountryUK.Id,false);
            childAcct1.ZTS_EU_Vetsave_ID__c = '3001';
            childAcct1.ZTS_EU_Vetsave_HO_ID__c = '200';
            childAccountList.add(childAcct1);
            Account childAcct2 = TestDataFactory.createAccount_EU('UK Linked Child Account 1',stateCountryUK.Id,false);
            childAcct2.ZTS_EU_Vetsave_ID__c = '3002';
            childAcct2.ZTS_EU_Vetsave_HO_ID__c = '300';
            childAcct2.ParentId = ukParentAccount.Id;
            childAccountList.add(childAcct2);
            Account childAcct3 = TestDataFactory.createAccount_EU('Ireland Unlinked Child Account 1',stateCountryIreland.Id,false);
            childAcct3.ZTS_EU_Market__c = 'Ireland';
            childAcct3.ZTS_EU_Country__c = 'Ireland';
            childAcct3.ZTS_EU_Vetsave_ID__c = '';
            childAcct3.ZTS_EU_Vetsave_HO_ID__c = '';
            childAcct3.ZTS_EU_Ref_ID1_Value__c = '3001';
            childAcct3.ZTS_EU_Ref_ID2_Value__c = '200';
            childAccountList.add(childAcct3);
            Account childAcct4 = TestDataFactory.createAccount_EU('Ireland Linked Child Account 1',stateCountryIreland.Id,false);
            childAcct4.ZTS_EU_Market__c = 'Ireland';
            childAcct4.ZTS_EU_Country__c = 'Ireland';
            childAcct4.ZTS_EU_Vetsave_ID__c = '';
            childAcct4.ZTS_EU_Vetsave_HO_ID__c = '';
            childAcct4.ZTS_EU_Ref_ID1_Value__c = '3002';
            childAcct4.ZTS_EU_Ref_ID2_Value__c = '300';
            childAcct4.ParentId = irelandParentAcct.Id;
            childAccountList.add(childAcct4);
            for(Account a : childAccountList){
                System.debug('State County: ' + a.ZTS_EU_State_County__c);
            }
            insert childAccountList;
        }
    }

    public static testMethod void add_UKChild_Test(){
        User intlUsr = [SELECT Id 
                        FROM User 
                        WHERE FirstName = 'IntUser'];
        System.runAs(intlUsr){
            Account childAccount;
            Account homeOfficeAccount;
            List<Account> accounts = [SELECT Id, ZTS_EU_HO_Flag__c,
                                    Name, ZTS_EU_Vetsave_ID__c,
                                    ZTS_EU_VetSave_HO_ID__c,
                                    ParentId
                                    FROM Account];
            for(Account a : accounts){
                if(a.Name == 'UK Home Office Account'){
                    System.assertEquals(true, a.ZTS_EU_HO_Flag__c,'Home Office Account should be flagged as true');
                    homeOfficeAccount = a;
                }else if(a.Name == 'UK Unlinked Child Account 1'){
                    System.assertEquals(false, a.ZTS_EU_HO_Flag__c,'Child Account should never be flagged as Home Office');
                    System.assertEquals(null, a.ParentId,'Child Account Parent ID should start as null');
                    childAccount = a;
                }
            }
            Test.startTest();
            childAccount.ZTS_EU_VetSave_HO_ID__c = '300';
            update childAccount;
            Test.stopTest();

            Account acctAfter = [SELECT Id,ParentID,
                                ZTS_EU_VetSave_HO_ID__c 
                                FROM Account 
                                WHERE Name = 'UK Unlinked Child Account 1'];
            System.assertEquals('300',acctAfter.ZTS_EU_VetSave_HO_ID__c,'VetSave HO Id should be 300');
            System.assertEquals(homeOfficeAccount.Id,acctAfter.ParentId,'Parent ID should match Home Office ID');
        }
    }

    public static testMethod void remove_UKChild_Test(){
        User intlUsr = [SELECT Id 
                        FROM User 
                        WHERE FirstName = 'IntUser'];
        System.runAs(intlUsr){
            Account childAccount;
            Account homeOfficeAccount;
            List<Account> accounts = [SELECT Id, ZTS_EU_HO_Flag__c,
                                    Name, ZTS_EU_Vetsave_ID__c,
                                    ZTS_EU_VetSave_HO_ID__c,
                                    ParentId
                                    FROM Account];
            for(Account a : accounts){
                if(a.Name == 'UK Home Office Account'){
                    System.assertEquals(true, a.ZTS_EU_HO_Flag__c,'Home Office Account should be flagged as true');
                    homeOfficeAccount = a;
                }else if(a.Name == 'UK Linked Child Account 1'){
                    System.assertEquals(false, a.ZTS_EU_HO_Flag__c,'Child Account should never be flagged as Home Office');
                    System.assertEquals(homeOfficeAccount.Id, a.ParentId,'Linked Child Account should start with Parent ID set to Home Office');
                    childAccount = a;
                }
            }
            Test.startTest();
            childAccount.ZTS_EU_VetSave_HO_ID__c = '1';
            update childAccount;
            Test.stopTest();

            Account acctAfter = [SELECT Id,ParentID,
                                ZTS_EU_VetSave_HO_ID__c 
                                FROM Account 
                                WHERE Name = 'UK Linked Child Account 1'];
            System.assertEquals('1',acctAfter.ZTS_EU_VetSave_HO_ID__c,'VetSave HO Id should now be 1');
            System.assertEquals(null,acctAfter.ParentId,'Parent ID should be null after VetSave HO Id is changed');
        }
    }

    public static testMethod void add_IrelandChild_Test(){
        User intlUsr = [SELECT Id 
                        FROM User 
                        WHERE FirstName = 'IntUser'];
        System.runAs(intlUsr){
            Account childAccount;
            Account homeOfficeAccount;
            List<Account> accounts = [SELECT Id, ZTS_EU_HO_Flag__c,
                                    Name, ZTS_EU_Vetsave_ID__c,
                                    ZTS_EU_VetSave_HO_ID__c,
                                    ParentId
                                    FROM Account];
            for(Account a : accounts){
                if(a.Name == 'Ireland Home Office Account'){
                    System.assertEquals(true, a.ZTS_EU_HO_Flag__c,'Home Office Account should be flagged as true');
                    homeOfficeAccount = a;
                }else if(a.Name == 'Ireland Unlinked Child Account 1'){
                    System.assertEquals(false, a.ZTS_EU_HO_Flag__c,'Child Account should never be flagged as Home Office');
                    System.assertEquals(null, a.ParentId,'Unlinked Child Account should start without Parent ID');
                    childAccount = a;
                }
            }
            Test.startTest();
            childAccount.ZTS_EU_Ref_ID2_Value__c = '300';
            update childAccount;
            Test.stopTest();

            Account acctAfter = [SELECT Id,ParentID,
                                ZTS_EU_Ref_ID2_Value__c 
                                FROM Account 
                                WHERE Name = 'Ireland Unlinked Child Account 1'];
            System.assertEquals('300',acctAfter.ZTS_EU_Ref_ID2_Value__c,'Ref ID 2 should be 300');
            System.assertEquals(homeOfficeAccount.Id,acctAfter.ParentId,'Parent ID should match Home Office');
        }
    }

    public static testMethod void remove_IrelandChild_Test(){
        User intlUsr = [SELECT Id 
                        FROM User 
                        WHERE FirstName = 'IntUser'];
        System.runAs(intlUsr){
            Account childAccount;
            Account homeOfficeAccount;
            List<Account> accounts = [SELECT Id, ZTS_EU_HO_Flag__c,
                                    Name, ZTS_EU_Vetsave_ID__c,
                                    ZTS_EU_VetSave_HO_ID__c,
                                    ParentId
                                    FROM Account];
            for(Account a : accounts){
                if(a.Name == 'Ireland Home Office Account'){
                    System.assertEquals(true, a.ZTS_EU_HO_Flag__c,'Home Office Account should be flagged as true');
                    homeOfficeAccount = a;
                }else if(a.Name == 'Ireland Linked Child Account 1'){
                    System.assertEquals(false, a.ZTS_EU_HO_Flag__c,'Child Account should never be flagged as Home Office');
                    System.assertEquals(homeOfficeAccount.Id, a.ParentId,'Linked Child Account should start with Parent ID set to Home Office');
                    childAccount = a;
                }
            }
            Test.startTest();
            childAccount.ZTS_EU_Ref_ID2_Value__c = '1';
            update childAccount;
            Test.stopTest();

            Account acctAfter = [SELECT Id,ParentID,
                                ZTS_EU_Ref_ID2_Value__c 
                                FROM Account 
                                WHERE Name = 'Ireland Linked Child Account 1'];
            System.assertEquals('1',acctAfter.ZTS_EU_Ref_ID2_Value__c,'Ref ID 2 should now be 2');
            System.assertEquals(null,acctAfter.ParentId,'Parent ID should be null after changing Ref ID 2');
        }
    }

    public static testMethod void multiMarket_Update_Test(){
        User intlUsr = [SELECT Id 
                        FROM User 
                        WHERE FirstName = 'IntUser'];
        System.runAs(intlUsr){
            Account ukChild;
            Account irelandChild;
            Account ukHomeOffice;
            Account irelandHomeOffice;
            List<Account> accounts = [SELECT Id, ZTS_EU_HO_Flag__c,
                                    Name, ZTS_EU_Vetsave_ID__c,
                                    ZTS_EU_VetSave_HO_ID__c,
                                    ParentId
                                    FROM Account];
            for(Account a : accounts){
                if(a.Name == 'Ireland Home Office Account'){
                    System.assertEquals(true, a.ZTS_EU_HO_Flag__c,'Home Office Account should be flagged as true');
                    irelandHomeOffice = a;
                }else if(a.Name == 'UK Home Office Account'){
                    System.assertEquals(true, a.ZTS_EU_HO_Flag__c,'Home Office Account should be flagged as true');
                    ukHomeOffice = a;
                }else if(a.Name == 'Ireland Unlinked Child Account 1'){
                    System.assertEquals(false, a.ZTS_EU_HO_Flag__c,'Child Account should never be flagged as Home Office');
                    System.assertEquals(null, a.ParentId,'Child Account Parent ID should start as null');
                    irelandChild = a;
                }else if(a.Name == 'UK Unlinked Child Account 1'){
                    System.assertEquals(false, a.ZTS_EU_HO_Flag__c,'Child Account should never be flagged as Home Office');
                    System.assertEquals(null, a.ParentId,'Child Account Parent ID should start as null');
                    ukChild = a;
                }
            }
            Test.startTest();
            List<Account> testAccounts = new List<Account>();
            ukChild.ZTS_EU_VetSave_HO_ID__c = '300';
            irelandChild.ZTS_EU_Ref_ID2_Value__c = '300';
            testAccounts.add(ukChild);
            testAccounts.add(irelandChild);
            update testAccounts;
            Test.stopTest();

            
            List<Account> acctsAfter = [SELECT Id,ParentID,Name,
                                ZTS_EU_VetSave_HO_ID__c,
                                ZTS_EU_Ref_ID2_Value__c 
                                FROM Account 
                                WHERE Name LIKE '%Unlinked Child Account 1'];
            for(Account a : acctsAfter){
                if(a.Name == 'UK Unlinked Child Account 1'){
                    System.assertEquals('300',a.ZTS_EU_VetSave_HO_ID__c,'VetSave HO ID should be 300');
                    System.assertEquals(ukHomeOffice.Id,a.ParentId,'Parent ID should match UK Home Office');
                }else if(a.Name == 'Ireland Unlinked Child Account 1'){
                    System.assertEquals('300',a.ZTS_EU_Ref_ID2_Value__c,'Ref ID2 should be 300');
                    System.assertEquals(irelandHomeOffice.Id,a.ParentId,'Parent ID should match Ireland Home Office');
                }
            }
        }
    }
}