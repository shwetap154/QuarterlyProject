/************************************************************************************* 
* Name: hierarchyComponentControllerTest
* Description: Test class for hierarchyComponentController (SC-009096/SC-008493)
* Created By: Aritra (Cognizant)
* Created: January 18 2022
**************************************************************************************/ 
@isTest
public class hierarchyComponentControllerTest {
    static List<Account> testAccounts = new List<Account>();
    static final Integer NUM_ACCOUNTS = 10;
    static void dataSetup() {
        
        AccountTriggerHandler accountHandler = new AccountTriggerHandler();
        accountHandler.disableTrigger = true;
        
        
        testAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(NUM_ACCOUNTS));
        for(Integer i=0;i<NUM_ACCOUNTS;i++)
        {
        	testAccounts[i].ZTS_EU_Market__c='United States';
        }
        insert testAccounts;
        
        for(Integer i=0;i<NUM_ACCOUNTS-1;i++)
        {
            testAccounts[i].parentId = testAccounts[i+1].Id;
        }
        
        update testAccounts;
        
    }
    
    @isTest
    static void generateHierarchyTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'LastName';
        usr.Email = 'temp@temp.com';
        usr.zts_eu_market__c = 'United States';
        insert usr;
                
        System.runAs(usr)
        {
            
            dataSetup();
            
            PageReference pgRef = Page.Account_Hierarchy_Page;
            Test.setCurrentPageReference (pgRef);
            ApexPages.currentPage().getParameters().put('id',testAccounts[0].id); 
            
            hierarchyComponentController  Target = new hierarchyComponentController ();
            Target.generateQueryString();
            
            String ultimateParentId = Target.GetUltimateParentId(Target.queryStringForUltimateParent);
            system.assertEquals(String.valueOf(testAccounts[NUM_ACCOUNTS-1].Id), ultimateParentId);
            
            Target.generateHierarchyData();
            Integer size  = Target.sortedHierarchyData.size();
			system.assertEquals(String.valueOf(testAccounts[0].Id), Target.sortedHierarchyData[size-1].recordId);            
            
        }
    }
    
    @isTest
    static void generateHierarchyExcelTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'LastName';
        usr.Email = 'temp@temp.com';
        usr.zts_eu_market__c = 'United States';
        insert usr;
                
        System.runAs(usr)
        {
            
            dataSetup();
            
            PageReference pgRef = Page.Account_Hierarchy_Page_DownloadExcel;
            Test.setCurrentPageReference (pgRef);
            ApexPages.currentPage().getParameters().put('id',testAccounts[0].id); 
            ApexPages.currentPage().getParameters().put('type','excel'); 
            hierarchyComponentController  Target = new hierarchyComponentController ();
            Target.generateQueryString();
            
            String ultimateParentId = Target.GetUltimateParentId(Target.queryStringForUltimateParent);
            system.assertEquals(String.valueOf(testAccounts[NUM_ACCOUNTS-1].Id), ultimateParentId);
            
            Target.generateHierarchyData();
            Integer size  = Target.sortedHierarchyData.size();
			system.assertEquals(String.valueOf(testAccounts[0].Id), Target.sortedHierarchyData[size-1].recordId);            
            
        }
    }

}