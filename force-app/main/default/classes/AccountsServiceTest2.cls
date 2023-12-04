/**
* @description       : Created new AccountServiceTest2 class for AccountService class
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 05-12-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
*  Modifications Log
* Ver   Date         Author                      Modification
* 1.0   04-4-2023    Padma Nerella @ Zoetis Inc  Added test case to update account certification status
* 1.1   05-9-2023    Padma Nerella @ Zoetis Inc  Added test caes to test the corporate flag on child accounts from parent TPDEV-109
**/
@isTest
private class AccountsServiceTest2 {
    
    @TestSetup
    private static void setup(){
        
        List<Account> parentAccList = ZTS_DataUtilityTest.createAccountRecord(3);
        parentAccList[0].ZTS_EU_Market__c = 'United Kingdom';
        parentAccList[0].ZTS_EU_Account_Status__c='Active';
        parentAccList[0].Name='ParentAcc1';
        parentAccList[0].ZTS_EU_Parent_Id__c=null;
        parentAccList[1].ZTS_EU_Market__c = 'United Kingdom';
        parentAccList[1].ZTS_EU_Account_Status__c='Active';
        parentAccList[1].Name='ParentAcc2';
        parentAccList[1].ZTS_EU_Parent_Id__c=null;
        parentAccList[2].ZTS_EU_Market__c = 'United Kingdom';
        parentAccList[2].ZTS_EU_Account_Status__c='Active';
        parentAccList[2].Name='ParentAcc3';
        parentAccList[2].ZTS_EU_Parent_Id__c=null;
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert parentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        parentAccList[0].ZTS_EU_Parent_Id__c = parentAccList[0].Id;
        parentAccList[1].ZTS_EU_Parent_Id__c = parentAccList[1].Id;
        parentAccList[2].ZTS_EU_Parent_Id__c = parentAccList[2].Id;
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update parentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Account> insertTestaccList = new List<Account>();
        List<Account> testaccList = ZTS_DataUtilityTest.createAccountRecord(4);
        testaccList[0].ZTS_EU_Parent_Id__c = parentAccList[0].Id;
        testaccList[0].ParentId =parentAccList[0].Id;
        testaccList[0].Name = 'ChildAcc1';
        testaccList[0].ZTS_EU_Market__c = 'United Kingdom';
        testaccList[0].ZTS_EU_Account_Status__c='Active';
        testaccList[1].ZTS_EU_Parent_Id__c = parentAccList[0].Id;
        testaccList[1].ParentId =parentAccList[0].Id;
        testaccList[1].ZTS_EU_Market__c = 'United Kingdom';
        testaccList[1].ZTS_EU_Account_Status__c='Active';
        testaccList[2].ZTS_EU_Parent_Id__c = parentAccList[1].Id;
        testaccList[2].ParentId =parentAccList[1].Id;
        testaccList[2].ZTS_EU_Market__c = 'Canada';
        testaccList[2].ZTS_EU_Account_Status__c='Active';
        testaccList[3].ZTS_EU_Parent_Id__c = parentAccList[2].Id;
        testaccList[3].ParentId =parentAccList[2].Id;
        testaccList[3].ZTS_EU_Market__c = 'Australia';
        testaccList[3].ZTS_EU_Account_Status__c='Active';
        insertTestaccList.addall(testaccList);
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert insertTestaccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Contact> insertConList = new List<Contact>();
        List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(5);
        conList[0].AccountId = insertTestaccList[0].Id;
        conList[0].ZTS_EU_Contact_type__c = 'Farmer';
        conList[0].ZTS_EU_Contact_Status__c ='Active';
        conList[0].Certification_Status__c = true;
        conList[0].Email = 'test@Zoetis.com';
        conList[1].AccountId = insertTestaccList[1].Id;
        conList[1].ZTS_EU_Contact_type__c = 'Veterinarian';
        conList[1].ZTS_EU_Contact_Status__c ='Active';
        conList[1].Email = 'test12@Zoetis.com';
        conList[1].Certification_Status__c = true;
        conList[2].AccountId = insertTestaccList[2].Id;
        conList[2].ZTS_EU_Contact_type__c = 'Academic';
        conList[2].ZTS_EU_Contact_Status__c ='Active';
        conList[2].Email = 'test12@Zoetis.com';
        conList[2].Certification_Status__c = true;
        insert conList;
    }
    
    @isTest
    private static void getAccounttoUpdatecertificationStatusTest(){
        
        List<Contact> contactList = [Select Id,Email,ZTS_EU_Contact_type__c,Account.Certification_Status__c,Certification_Status__c,AccountId from Contact where Certification_Status__c = true AND (ZTS_EU_Contact_type__c = 'Farmer' OR ZTS_EU_Contact_type__c = 'Veterinarian')];
        
        Set<Id> accIdSet =  new Set<Id>();
        For(Contact con :contactList){
            accIdSet.add(con.AccountId);
        }
        Test.startTest();
        AccountsService.updateAccountcertificationStatus(accIdSet);
        Test.stopTest();
        List<Account> getAccountUpadteList =[Select Id,Certification_Status__c from Account where Id =:accIdSet];
        for(Account acc:getAccountUpadteList){
            System.assertEquals(true,acc.Certification_Status__c,'Account record Certification Status should be true');
        }
    }
    @isTest
    private static void getAccounttoUpdatecertificationStatusFalseTest(){
        List<Contact> contactList = [Select Id,Email,ZTS_EU_Contact_type__c,Certification_Status__c,AccountId,Account.Certification_Status__c from Contact where ZTS_EU_Contact_type__c= 'Farmer'];
        
        contactList[0].Certification_Status__c = false;
        
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        update contactList[0];
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        Set<Id> accIdSet = New Set<Id> ();
        for(Contact con:contactList){
            accIdSet.add(con.AccountId);
        }
        Test.startTest();
        AccountsService.updateAccountcertificationStatus(accIdSet);
        Test.stopTest();
        List<Account> getAccountUpadteList =[Select Id,Certification_Status__c from Account where Id =:accIdSet];
        System.assertEquals(false,getAccountUpadteList[0].Certification_Status__c, 'Account record Certification Status should be false');
    }
    
    @isTest
    private static void updateZTSEUCorporateFlagFromINTLParentAccSynchronousTest1(){
        Set<Id> parentIdSet = new Set<Id>();
        List<Account> accList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c,ParentId from Account where ZTS_EU_Market__c!='United States' AND Name ='ParentAcc1'];
        List<Account> oldListCopy = accList.deepClone(true, false, false);
        Map<Id, Account> oldMap = new Map<Id,Account>(oldListCopy);
        List<Account> updatedParentAccList = new List<Account>();
        for(Account acc1 :accList){
            acc1.ZTS_EU_Corporate_Flag__c=true;
            updatedParentAccList.add(acc1);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update updatedParentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Map<Id, Account> newMap = new Map<Id,Account>([Select Id,ZTS_EU_Corporate_Flag__c,ZTS_EU_Parent_Id__c,ZTS_EU_Market__c from Account where Id IN: updatedParentAccList]);
        Test.startTest();
        AccountsService.updateZTSEUCorporateFlagFromINTLParentAcc(newMap, oldMap);
        Test.stopTest();
        Integer flagCount =0;
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c From Account where ParentId IN:updatedParentAccList];
        for(Account acc :childAccUpdateList){
            System.assertEquals(true, acc.ZTS_EU_Corporate_Flag__c, 'Child Account Corporate flag updated to true when parent account flag updated true');
            flagCount++;
        }
        System.assertEquals(2, flagCount, '2 child account records corporate flag updated to true when parent account updated to true');
    }
    
    @isTest
    private static void updateZTSEUCorporateFlagFromINTLParentAccHierarchyAndAsyncTest(){
        List<Account> parent1List = ZTS_DataUtilityTest.createAccountRecord(1);
        parent1List[0].ZTS_EU_Market__c = 'United Kingdom';
        parent1List[0].Name = 'Parentparent';
        parent1List[0].ZTS_EU_Account_Status__c='Active';
        insert parent1List;
        
        parent1List[0].ZTS_EU_Parent_Id__c = parent1List[0].Id;
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update parent1List[0];
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Account> parent2List = ZTS_DataUtilityTest.createAccountRecord(1);
        parent2List[0].ZTS_EU_Market__c = 'United Kingdom';
        parent2List[0].Name = 'Parent2';
        parent2List[0].ZTS_EU_Account_Status__c='Active';
        parent2List[0].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        parent2List[0].ParentId =parent1List[0].Id;
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert parent2List[0];
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        
        List<Account> childAccList = ZTS_DataUtilityTest.createAccountRecord(2);
        childAccList[0].ZTS_EU_Market__c = 'United Kingdom';
        childAccList[0].Name = 'Child1';
        childAccList[0].ZTS_EU_Account_Status__c='Active';
        childAccList[0].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        childAccList[0].ParentId =parent2List[0].Id;
        childAccList[1].ZTS_EU_Market__c = 'United Kingdom';
        childAccList[1].Name = 'Child2';
        childAccList[1].ZTS_EU_Account_Status__c='Active';
        childAccList[1].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        childAccList[1].ParentId =parent2List[0].Id;
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert childAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Account> oldListCopy = parent1List.deepClone(true, false, false);
        Map<Id, Account> OldmapFromList = new Map<Id, Account>(oldListCopy);
        
        List<Account> updatedParentAccList = new List<Account>();
        for(Account acc1 :parent1List){
            acc1.ZTS_EU_Corporate_Flag__c=true;
            updatedParentAccList.add(acc1);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update updatedParentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Set<Id> customParentIdSet = new Set<Id>();
        for(Account acc:updatedParentAccList){
            customParentIdSet.add(acc.ZTS_EU_Parent_Id__c);
        } 
        Map<Id, Account> newMap = new Map<Id,Account>(updatedParentAccList);
        Test.startTest();
        AccountsService.forcerunBatchToUpdateCorporateFlag = true;
        
        AccountsService.updateZTSEUCorporateFlagFromINTLParentAcc(newMap, OldmapFromList);
        Test.stopTest();
        AccountsService.forcerunBatchToUpdateCorporateFlag = false;
        Integer flagCount =0;
        List<Account> childAccUpdateList = [Select Id,Name,ZTS_EU_Parent_Id__c,parentId,ZTS_EU_Corporate_Flag__c From Account where ZTS_EU_Parent_Id__c IN:customParentIdSet];
        for(Account acc :childAccUpdateList){
            System.assertEquals(true, acc.ZTS_EU_Corporate_Flag__c, 'Child Accounts Corporate flag updated to true when parent account flag updated true');
            flagCount++;
        }
        System.assertEquals(4,flagCount , '1 Parent account and 3 child account records updated to true when parent parent account updated to true');
    }
    
    @isTest
    private static void updateZTSEUCorporateFlagFromUSParentAccTest(){
        List<Account> parentAccList = ZTS_DataUtilityTest.createAccountRecord(1);
        parentAccList[0].Name='USParent1';
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert parentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        parentAccList[0].ZTS_EU_Parent_Id__c =parentAccList[0].Id;
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update parentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        List<Account> childAcc = ZTS_DataUtilityTest.createAccountRecord(1);
        childAcc[0].ZTS_EU_Parent_Id__c=parentAccList[0].Id;
        childAcc[0].ParentId=parentAccList[0].Id;
        childAcc[0].Name='USParentChild';
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert childAcc;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Set<Id> parentIdSet = new Set<Id>();
        
        Map<Id, Account> oldMap = new Map<Id,Account>(parentAccList);
        List<Account> updatedParentAccList = new List<Account>();
        for(Account acc1 :parentAccList){
            acc1.ZTS_EU_Corporate_Flag__c=true;
            updatedParentAccList.add(acc1);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update updatedParentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Map<Id, Account> newMap = new Map<Id,Account>(updatedParentAccList);
        Set<Id> accIds=new Set<Id>();
        for(Account acc:updatedParentAccList){
            accIds.add(acc.ZTS_EU_Parent_Id__c);
        }
        Test.startTest();
        AccountsService.updateZTSEUCorporateFlagFromINTLParentAcc(newMap, oldMap);
        Test.stopTest();
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,Name,ZTS_EU_Corporate_Flag__c From Account where ZTS_EU_Parent_Id__c IN:accIds];
        for(Account acc :childAccUpdateList){
            if(acc.Name=='USParentChild'){
                System.assertEquals(false, acc.ZTS_EU_Corporate_Flag__c, 'Child Account Corporate flag did not updated to true when parent account flag updated true since Account market is United States');
            }
        }
    }
    
    @isTest
    static void updateZTSEUCorporateFlagONChildAcc(){
        Set<Id> parentIdSet = new Set<Id>();
        List<String> accNames = new List<String>{'ChildAcc1','ParentAcc1'};
            List<Account> accList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c from Account where ZTS_EU_Market__c!='United States' And Name IN:accNames];
        List<Account> oldListCopy = accList.deepClone(true, false, false);
        Map<Id, Account> oldMap = new Map<Id,Account>(oldListCopy);
        List<Account> childList = New List<Account>();
        for(Account acc :accList){
            if(acc.Name=='ChildAcc1'){
                acc.ZTS_EU_Corporate_Flag__c = False;
                childList.add(acc);
            }else{
                acc.ZTS_EU_Corporate_Flag__c = true;
                childList.add(acc);
            }
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update childList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        List<Account> newAccList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c from Account where ZTS_EU_Market__c!='United States' and Id IN:childList];
        Map<Id, Account> newMap = new Map<Id,Account>(newAccList);
        Test.startTest();
        AccountsService.updateZTSEUCorporateFlagFromINTLParentAcc(newMap, oldMap);
        Test.stopTest();
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,Name From Account where Id IN:childList];
        for(Account acc :childAccUpdateList){
            System.assertEquals(true, acc.ZTS_EU_Corporate_Flag__c, 'Child Account Corporate flag did not updated to false since parent account flag status is true');
        }
    }
    
    @isTest
    private static void updateZTSEUCorporateFlagFromINTLParentAccBulk(){
        Set<Id> parentIdSet = new Set<Id>();
        List<Account> accListToUpdate = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c from Account where ZTS_EU_Market__c!='United States' And Name Like 'ParentAcc%'];
        List<Account> parent2updateList = new List<Account>();
        for(Account acc: accListToUpdate){
            if(acc.Name =='ParentAcc2'){
                acc.ZTS_EU_Corporate_Flag__c=true;
                parent2updateList.add(acc);
            }
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update parent2updateList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        List<Account> oldListCopy = accListToUpdate.deepClone(true, false, false);
        Map<Id, Account> oldMap = new Map<Id,Account>(oldListCopy);
        List<Account> updatedParentAccList = new List<Account>();
        for(Account acc1 :accListToUpdate){
            if((acc1.Name =='ParentAcc1')||(acc1.Name =='ParentAcc3')){
                acc1.ZTS_EU_Corporate_Flag__c=true;
                updatedParentAccList.add(acc1);
            } else if(acc1.Name =='ParentAcc2'){
                acc1.ZTS_EU_Corporate_Flag__c=false;
                updatedParentAccList.add(acc1);
            }
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update updatedParentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Map<Id, Account> newMap = new Map<Id,Account>(updatedParentAccList);
        Set<Id> newParentIdSet =  new Set<Id>();
        for(Account acc:updatedParentAccList){
            newParentIdSet.add(acc.ZTS_EU_Parent_Id__c);
        }
        Test.startTest();
        AccountsService.updateZTSEUCorporateFlagFromINTLParentAcc(newMap, oldMap);
        Test.stopTest();
        Integer flagCount =0;
        List<Account> childAccUpdateList = [Select Id,Name,ZTS_EU_Parent_Id__c,Parent.Name,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c From Account where ZTS_EU_Parent_Id__c IN:newParentIdSet];
        for(Account acc :childAccUpdateList){
            if((acc.Parent.Name =='ParentAcc1')||(acc.Parent.Name =='ParentAcc3')){
                System.assertEquals(true, acc.ZTS_EU_Corporate_Flag__c, 'From 3 parent accounts only 2 parent account Child Account Corporate flag updated to true when parent account flag updated true,since 3rd parent oldmap and newmap corporatefalg values are same');
                flagCount++;
            } else if(acc.Parent.Name=='ParentAcc2'){
                System.assertEquals(false, acc.ZTS_EU_Corporate_Flag__c, '3rd parent Child account falg did not updated to true since parent account old map new map having same value');
            }
        }
        System.assertEquals(3, flagCount, '3 child account records corporate flag updated to true when parent account updated to true');
    }
    
    @isTest
    private static void updateZTSEUCorporateFlagFromINTLParentAccTest2(){
        Set<Id> parentIdSet = new Set<Id>();
        List<Account> accList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c,ParentId from Account where ZTS_EU_Market__c!='United States' AND Name ='ParentAcc1'];
        
        Map<Id, Account> oldMap = new Map<Id,Account>(accList);
        List<Account> updatedParentAccList = new List<Account>();
        for(Account acc1 :accList){
            acc1.ZTS_EU_Corporate_Flag__c=true;
            updatedParentAccList.add(acc1);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update updatedParentAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        List<Account> falseAccList = new List<Account>();
        for(Account acc:updatedParentAccList){
            acc.ZTS_EU_Corporate_Flag__c=false;
            falseAccList.add(acc);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update falseAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Map<Id, Account> newMap = new Map<Id,Account>([Select Id,ZTS_EU_Corporate_Flag__c,ZTS_EU_Parent_Id__c,ZTS_EU_Market__c from Account where Id IN: falseAccList]);
        test.startTest();
        AccountsService.updateZTSEUCorporateFlagFromINTLParentAcc(newMap, oldMap);
        Test.stopTest();
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c From Account where ParentId IN:falseAccList];
        for(Account acc :childAccUpdateList){
            System.assertEquals(false, acc.ZTS_EU_Corporate_Flag__c, 'updateZTSEUCorporateFlagFromINTLParentAcc did not kick off since the old map and new map corporate flag is having same value');
        }
    }
    
}