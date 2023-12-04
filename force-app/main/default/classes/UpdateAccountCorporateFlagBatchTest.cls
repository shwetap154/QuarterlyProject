/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 05-12-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   05-9-2023    Padma Nerella @ Zoetis Inc  Added test caes to test the corporate flag on child accounts from parent account TPDEV-109
**/
@isTest
private class UpdateAccountCorporateFlagBatchTest {
    @TestSetup
    static void dataSetup(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
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
            parentAccList[0].ZTS_EU_Corporate_Flag__c = true;
            parentAccList[1].ZTS_EU_Parent_Id__c = parentAccList[1].Id;
            parentAccList[1].ZTS_EU_Corporate_Flag__c = true;
            parentAccList[2].ZTS_EU_Parent_Id__c = parentAccList[2].Id;
            parentAccList[2].ZTS_EU_Corporate_Flag__c = true;
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update parentAccList;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            
            List<Account> testChildAccList = ZTS_DataUtilityTest.createAccountRecord(4);
            testChildAccList[0].ZTS_EU_Market__c = 'United Kingdom';
            testChildAccList[0].Name = 'ChildAcc1';
            testChildAccList[0].ZTS_EU_Account_Status__c='Active';
            testChildAccList[0].ZTS_EU_Parent_Id__c = parentAccList[0].Id;
            testChildAccList[0].ParentId =parentAccList[0].Id;
            testChildAccList[1].ZTS_EU_Market__c = 'United Kingdom';
            testChildAccList[1].Name = 'ChildAcc2';
            testChildAccList[1].ZTS_EU_Account_Status__c='Active';
            testChildAccList[1].ZTS_EU_Parent_Id__c = parentAccList[0].Id;
            testChildAccList[1].ParentId =parentAccList[0].Id;
            testChildAccList[2].ZTS_EU_Market__c = 'United Kingdom';
            testChildAccList[2].ParentId =parentAccList[1].Id;
            testChildAccList[2].ZTS_EU_Account_Status__c='Active';
            testChildAccList[2].ZTS_EU_Parent_Id__c = parentAccList[1].Id;
            testChildAccList[3].ZTS_EU_Market__c = 'United Kingdom';
            testChildAccList[3].ZTS_EU_Account_Status__c='Active';
            testChildAccList[3].ZTS_EU_Parent_Id__c = parentAccList[2].Id;
            testChildAccList[3].ParentId =parentAccList[2].Id;
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            Insert testChildAccList;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
    @isTest
    static void updateZTSEUCorporateFlagFromINTLParentAccTest1(){
        List<String> accNames = new List<String>{'ParentAcc1','ChildAcc1','ChildAcc2'};
        Set<Id> parentAccIds = new Set<Id>();
        List<Account> accList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c from Account where ZTS_EU_Market__c!='United States' AND Name IN:accNames];
        for(Account acc : accList){
            parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
        }        
        Test.startTest();
        UpdateAccountCorporateFlagBatch.forceMapContainsParent = false;
        UpdateAccountCorporateFlagBatch updateBatchjob = new UpdateAccountCorporateFlagBatch();
        updateBatchjob.parentAccIds = parentAccIds;
        updateBatchjob.parentAccs=accList;
        Database.QueryLocator ql = updateBatchjob.start(null);
        updateBatchjob.Execute(null,accList);
        updateBatchjob.Finish(null);
        Test.stopTest();
        UpdateAccountCorporateFlagBatch.forceMapContainsParent = true;
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,ParentId,ZTS_EU_Corporate_Flag__c From Account where ParentId IN:parentAccIds];
        Integer flagCount =0;
        for(Account acc :childAccUpdateList){
            System.assertEquals(true, acc.ZTS_EU_Corporate_Flag__c, 'Child Accounts Corporate flag updated to true when parent account flag updated true');
            flagCount++;
        }
        System.assertEquals(2,flagCount, '2 child accounts flag updated');
        
        
    }
    
    @isTest
    static void updateZTSEUCorporateFlagFromINTLParentAccHierarchyTest(){
        List<Account> parent1List = ZTS_DataUtilityTest.createAccountRecord(1);
        parent1List[0].ZTS_EU_Market__c = 'United Kingdom';
        parent1List[0].Name = 'HierarchyParent';
        parent1List[0].ZTS_EU_Account_Status__c='Active';
        insert parent1List;
        parent1List[0].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        update parent1List[0];
        List<Account> parent2List = ZTS_DataUtilityTest.createAccountRecord(1);
        parent2List[0].ZTS_EU_Market__c = 'United Kingdom';
        parent2List[0].ZTS_EU_Account_Status__c='Active';
        parent2List[0].Name='Parent1';
        parent2List[0].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        parent2List[0].ParentId =parent1List[0].Id;
        insert parent2List;
        
        List<Account> parent3List = ZTS_DataUtilityTest.createAccountRecord(1);
        parent3List[0].ZTS_EU_Market__c = 'United Kingdom';
        parent3List[0].ZTS_EU_Account_Status__c='Active';
        parent3List[0].Name='Parent3';
        parent3List[0].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        parent3List[0].ParentId =parent2List[0].Id;
        insert parent3List[0];
        List<Account> parent4List = ZTS_DataUtilityTest.createAccountRecord(1);
        parent4List[0].ZTS_EU_Market__c = 'United Kingdom';
        parent4List[0].Name = 'Parent4';
        parent4List[0].ZTS_EU_Account_Status__c='Active';
        parent4List[0].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        parent4List[0].ParentId =parent3List[0].Id;
        insert parent4List[0];
        
        List<Account> childAccList = ZTS_DataUtilityTest.createAccountRecord(2);
        childAccList[0].ZTS_EU_Market__c = 'United Kingdom';
        childAccList[0].ZTS_EU_Account_Status__c='Active';
        childAccList[0].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        childAccList[0].ParentId =parent4List[0].Id;
        childAccList[1].ZTS_EU_Market__c = 'United Kingdom';
        childAccList[1].ZTS_EU_Account_Status__c='Active';
        childAccList[1].ZTS_EU_Parent_Id__c =parent1List[0].Id;
        childAccList[1].ParentId =parent4List[0].Id;
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert childAccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        parent1List[0].ZTS_EU_Corporate_Flag__c = true;
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update parent1List[0];
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        Set<Id> parentAccIds = new Set<Id>();
        for(Account acc : parent1List){
            parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
        }
        Test.startTest();
        UpdateAccountCorporateFlagBatch updateBatchjob = new UpdateAccountCorporateFlagBatch();
        updateBatchjob.parentAccIds = parentAccIds;
        database.executeBatch(updateBatchjob);
        Test.stopTest();
        Integer flagCount =0;
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,Name From Account where ZTS_EU_Parent_Id__c IN:parentAccIds];
        for(Account acc :childAccUpdateList){
            System.assertEquals(true, acc.ZTS_EU_Corporate_Flag__c, 'Child Accounts Corporate flag updated to true when parent account flag updated true');
            flagCount++;
        }
        System.assertEquals(6,flagCount, '1 parent account and 5 child account records got updated Corporate flag to true when hierarchyParent flag update to true');
    }
    
    @isTest
    static void updateZTSEUCorporateFlagFromINTLParentAccBulkTest(){
        List<Account> parentAcc2List = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c from Account where ZTS_EU_Market__c!='United States' AND Name = 'ParentAcc2'];
        List<Account> updateparentAcc2List = new List<Account>();
        for(Account acc : parentAcc2List){
            acc.ZTS_EU_Corporate_Flag__c = false;
            updateparentAcc2List.add(acc);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update updateparentAcc2List;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Set<Id> parentAccIds = new Set<Id>();
        List<Account> accList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c from Account where ZTS_EU_Market__c!='United States' AND Name LIKE 'ParentAcc%'];
        for(Account acc : accList){
            parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
        }
        Test.startTest();
        UpdateAccountCorporateFlagBatch updateBatchjob = new UpdateAccountCorporateFlagBatch();
        updateBatchjob.parentAccIds = parentAccIds;
        database.executeBatch(updateBatchjob);
        Test.stopTest();
        Integer flagTrueCount =0;
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,Parent.Name From Account where ParentId IN:parentAccIds];
        for(Account acc :childAccUpdateList){
            if((acc.Parent.Name == 'ParentAcc1')||(acc.Parent.Name == 'ParentAcc3')){
                System.assertEquals(true, acc.ZTS_EU_Corporate_Flag__c, 'ParentAcc1 and ParentAcc3 Child Accounts Corporate flag updated to true when parent account flag updated true');
                flagTrueCount++;
            } else{
                System.assertEquals(false, acc.ZTS_EU_Corporate_Flag__c, 'Child Accounts Corporate flag did not updated to true since parentAcc2 account oldMap and newMap corporate flag value is same');
            }
        }
        System.assertEquals(3, flagTrueCount, 'Total 3 ChildAccount records ZTS_EU_Corporate_Flag__c updated to true');
    }
    
    
    @isTest
    static void updateZTSEUCorporateFlagONChildAcc(){
        Set<Id> parentAccIds = new Set<Id>();
        List<Account> accList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c from Account where ZTS_EU_Market__c!='United States' And Name ='ChildAcc1'];
        List<Account> childList = new List<Account> ();
        for(Account acc :accList){
            acc.ZTS_EU_Corporate_Flag__c = False;
            childList.add(acc);
            parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update childList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Test.startTest();
        UpdateAccountCorporateFlagBatch updateBatchjob = new UpdateAccountCorporateFlagBatch();
        updateBatchjob.parentAccIds = parentAccIds;
        database.executeBatch(updateBatchjob);
        Test.stopTest();
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c From Account where ZTS_EU_Parent_Id__c IN:parentAccIds];
        for(Account acc :childAccUpdateList){
            System.assertEquals(true, acc.ZTS_EU_Corporate_Flag__c, 'Child Accounts Corporate flag did not updated to false since parent Corporate flag is still true');
        }
    }
    @isTest
    static void updateZTSEUCorporateFlagFalseOnParent(){
        Set<Id> parentAccIds = new Set<Id>();
        List<Account> accList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c from Account where ZTS_EU_Market__c!='United States' AND Name ='ParentAcc1' And ZTS_EU_Corporate_Flag__c = true];
        List<Account> updateParentList = new List<Account>();
        for(Account acc : accList){
            acc.ZTS_EU_Corporate_Flag__c = false;
            updateParentList.add(acc);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update updateParentList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Account> updateParentAcc1 = [Select Id, Name,ZTS_EU_Parent_Id__c,ParentId,ZTS_EU_Corporate_Flag__c from Account where Id IN: updateParentList];
        
        for(Account acc :updateParentAcc1){
            parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
        }
        Test.startTest();
        UpdateAccountCorporateFlagBatch updateBatchjob = new UpdateAccountCorporateFlagBatch();
        updateBatchjob.parentAccIds = parentAccIds;
        database.executeBatch(updateBatchjob);
        Test.stopTest();
        List<Account> childAccUpdateList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c From Account where ParentId IN:parentAccIds];
        for(Account acc :childAccUpdateList){
            System.assertEquals(false, acc.ZTS_EU_Corporate_Flag__c, 'Child Accounts Corporate flag updated to false when parent account flag updated false');
        }
        
    }
    
    @isTest
    static void updateZTSEUCorporateFlagFromUSParentAccTest(){
        List<Account> parentAcc = ZTS_DataUtilityTest.createAccountRecord(1);
        parentAcc[0].Name='USParent';
        parentAcc[0].ZTS_EU_Market__c ='United States';
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert parentAcc;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        parentAcc[0].ZTS_EU_Parent_Id__c =parentAcc[0].Id;
        parentAcc[0].ZTS_EU_Corporate_Flag__c=true;
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update parentAcc;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        List<Account> childAcc = ZTS_DataUtilityTest.createAccountRecord(1);
        childAcc[0].Name = 'USParentChildRecord';
        childAcc[0].ZTS_EU_Parent_Id__c=parentAcc[0].Id;
        childAcc[0].ParentId=parentAcc[0].Id;
        childAcc[0].ZTS_EU_Market__c ='United States';
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert childAcc;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Set<Id> parentAccIds = new Set<Id>();
        List<Account> accList = [Select Id, Name,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c from Account where Id IN:parentAcc and ZTS_EU_Market__c='United States'];
        for(Account acc : accList){
            parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
        }
        Test.startTest();
        UpdateAccountCorporateFlagBatch updateBatchjob = new UpdateAccountCorporateFlagBatch();
        updateBatchjob.parentAccIds = parentAccIds;
        database.executeBatch(updateBatchjob);
        Test.stopTest();
        List<Account> childAccUpdateList = [Select Id,Name,ZTS_EU_Parent_Id__c,Parent.ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c,Parent.Name,ZTS_EU_Corporate_Flag__c From Account where ZTS_EU_Parent_Id__c IN:parentAccIds];
        for(Account acc :childAccUpdateList){
            if(acc.Parent.Name=='USParent'){
                System.assertEquals(true, acc.Parent.ZTS_EU_Corporate_Flag__c, 'USParent flag is true');
            }else if(acc.Name=='USParentChildRecord'){
                System.assertEquals(false, acc.ZTS_EU_Corporate_Flag__c, 'Child Accounts Corporate flag did not updated to true when parent account flag updated true since market is United States');
            }
            
        }
    }
    
}