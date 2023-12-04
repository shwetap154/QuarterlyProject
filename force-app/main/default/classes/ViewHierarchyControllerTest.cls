//************************************************************************************* 
// Name: ViewHierarchyControllerTest
// Description: Test class for Customized Account group hierarchy 
// Created By: Sohil Shah (CloudSense)
// Created: September 17 2014 
// 
// ************************Version Updates******************************************** 
// 
// Updated Date Updated By Update Comments 
// 
// ************************************************************************************ 


@isTest
public class ViewHierarchyControllerTest
{
    public static testMethod void fetchAccountHierarchy()
    {
        List<State_Country__c> stateList = new List<State_Country__c>();
        stateList = ZTS_EU_DataUtilityTest.createStateCountryRecord();
        insert stateList;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        Account account1 = new Account(Name = 'Sohil Test Account 1', Type='Farm', ZTS_EU_Address_Line_1__c = 'qq', 
        ZTS_EU_Country__c = 'United Kingdom', ZTS_EU_State_County__c= stateList[0].Id, ZTS_EU_City__c = 'Dundee', ZTS_EU_Market__c='United Kingdom',
        ZTS_EU_Zip_Postal_Code__c= 'DD2 5Sd', Practice_Management_Software__c = 'Other', Other_Practice_Management_Software__c = 'Sample Practice Management Software');
        System.runAs(usr)
        {
        	insert account1;    
        }
        
        Account account2 = new Account(Name = 'Sohil Test Account 2',ParentId = account1.id,Type='Farm', ZTS_EU_Address_Line_1__c = 'qq', 
        ZTS_EU_Country__c = 'United Kingdom', ZTS_EU_State_County__c= stateList[0].Id, ZTS_EU_City__c = 'Dundee', ZTS_EU_Market__c='United Kingdom',
        ZTS_EU_Zip_Postal_Code__c= 'DD2 5Sd', Practice_Management_Software__c = 'Other', Other_Practice_Management_Software__c = 'Sample Practice Management Software');        
        insert account2;
      
        ApexPages.StandardController sc = new ApexPages.StandardController(account1);
        ViewHierarchyController testAccPlan = new ViewHierarchyController(sc);
        ViewHierarchyUtility utilityObj = new ViewHierarchyUtility();
        
        ViewHierarchyUtility.AccountNode wrrprObj = new ViewHierarchyUtility.AccountNode(account1);
        List<ViewHierarchyUtility.AccountNode> tempList = new List<ViewHierarchyUtility.AccountNode>();
        List<ViewHierarchyUtility.AccountNode> accountNodeList = new List<ViewHierarchyUtility.AccountNode>();
        tempList.add(wrrprObj);
        System.debug('tempList-----'+tempList);
        testAccPlan.accountNodeList = tempList;
        
        testAccPlan.SearchAllChildAndParentAccount();
        ID accountId = ApexPages.currentPage().getParameters().put('accountid',account1.id);
        
        utilityObj.getAcxcountHierarchy(account1.Id);
        utilityObj.getRootID(account1.Id);
        
        ViewHierarchyUtility.AccountNode innerClassObj = new ViewHierarchyUtility.AccountNode(account1);
        
        List<ViewHierarchyUtility.AccountNode> listInner = new List<ViewHierarchyUtility.AccountNode>();
        listInner.add(innerClassObj);
        
        utilityObj.addChildNodes(innerClassObj, 1);
        utilityObj.createChildAccountsNodes(listInner);
        utilityObj.createChildrenAccountsNodes(listInner);
        
        
        
       
    }
}