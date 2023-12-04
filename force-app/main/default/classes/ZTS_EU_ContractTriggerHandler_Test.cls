/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_BatchAcctSegmentationUpdate_Test.cls
Description: Test Class for Batch Apex ZTS_EU_BatchAcctSegmentationUpdate.cls

Date         Version Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
13-10-2014   1.0     Shefali             Initial Version        
26-11-2014   1.1     Bimba               Modified test class due to the parent class changes 
22-06-2020   1.2     Amanda Doss (Slalom) Fixed test class by adding user with correct market
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public  class ZTS_EU_ContractTriggerHandler_Test{
    
    private static String Brazil = 'Brazil';
    private static String busUnit = 'Business Unit';
    private static String brand = 'Brand';
    private static ZTS_EU_ContractTemplate__c conttemp1;
    private static Product_Contract_Template_Association__c pcta;
    private static List<ZTS_EU_Species_Product__c> prodHierarchyList;
    private static List<ZTS_EU_ContractTemplate__c> contTempList;
    private static List<Contract> contractList;
    private static Account acc1;
    /*******************************************************************
    @Author: Bimba
    Purpose:  Method to set up test data.                                                   
    Parameters: none
    Returns: none
    *******************************************************************/ 
    public static void setUpData(){
        prodHierarchyList = new List<ZTS_EU_Species_Product__c>();
        contTempList = new List<ZTS_EU_ContractTemplate__c>();
        contractList =new List<Contract>();
        String busUnitRecordTypeId = [SELECT Id FROM RecordType 
        WHERE DeveloperName = 'Business_Unit'].Id;
        String brandRecordTypeId = [SELECT Id FROM RecordType 
        WHERE DeveloperName = 'Brand'].Id;  
        
        /* Creating user records*/
        List<Profile> p = [select Id from Profile where Name='System Administrator' limit 1];       
        User u = new User(username='testUser@testabcasdfasdf232323.com',alias='abctest',ProfileId=p[0].Id,email='test@abc.com',CommunityNickname='abc',ZTS_EU_Market__c='United Kingdom',EmailEncodingKey='ISO-8859-1', TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',LocaleSidKey='en_US',CurrencyIsoCode='EUR',LastNAme='testLsatNAme');
        insert u;
        
        System.runAs(u)
        {
            /*** Create Account records ***/
            acc1 = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            acc1.ZTS_EU_Market__c = 'United Kingdom';
            insert acc1;
            
            Account acc2 = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            acc2.ZTS_EU_Market__c = 'United Kingdom';
            insert acc2;
        }
        /*** Create Product Hierarchy records ***/
        ZTS_EU_Species_Product__c prodHierBusUnit = TestUtilities.createNoInsertBusUnit('Companion Animals',busUnit,Brazil,'CA',busUnitRecordTypeId);
        prodHierarchyList.add(prodHierBusUnit);  
        ZTS_EU_Species_Product__c prodHierBrand = TestUtilities.createNoInsertBrand('Draxxin',brand,Brazil,brandRecordTypeId);
        prodHierarchyList.add(prodHierBrand); 
        //Database.insert(prodHierarchyList,false);
        insert prodHierarchyList;
        
        /*** Create Contract Template records ***/
        conttemp1 = new ZTS_EU_ContractTemplate__c();
        conttemp1.Name = 'Test template';
        conttemp1.ZTS_EU_Start_Date__c = Date.today();
        conttemp1.ZTS_EU_End_Date__c = date.today()+10;
        conttemp1.ZTS_EU_Discount__c = 20.00;
        conttemp1.ZTS_EU_Discount_Type__c = 'Fixed Discount';
        conttemp1.ZTS_EU_Fiscal_Year__c = '2014';
        conttemp1.ZTS_EU_Status__c = 'Active';
        conttemp1.ZTS_EU_Type__c = 'Bonus';
        //conttemp1.ZTS_EU_CTBusiness_Unit__c = prodHierarchyList[0].Id;
        //database.insert(conttemp1,false);
        
        insert conttemp1;
        
        /*** Create Product Contract Association Template record ***/
        pcta = new Product_Contract_Template_Association__c();
        pcta.ZTS_EU_Contract_Template__c = conttemp1.Id;
        //pcta.ZTS_EU_Product_Hierarchy__c = prodHierarchyList[1].id;
        pcta.ZTS_EU_ProductContractTemplateMergeField__c = 'test';
        Database.saveResult sr = database.insert(pcta,false);
    } 
    
    /*******************************************************************
    @Author: Bimba
    Purpose:  Method to create contracts and test the insert                                                    
    Parameters: none
    Returns: none
    *******************************************************************/
    public static testMethod void testCreationOfContractAndFieldsCopy(){
        setUpData();
        
        List<Profile> p = [select Id from Profile where Name='System Administrator' limit 1];       
        User u = new User(username='testUser@testabcasdfasdf2323234.com',alias='abctest',ProfileId=p[0].Id,email='test@abc.com',CommunityNickname='abcd',ZTS_EU_Market__c='United Kingdom',EmailEncodingKey='ISO-8859-1', TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',LocaleSidKey='en_US',CurrencyIsoCode='EUR',LastNAme='testLsatNAme');
        insert u;
        
        System.runAs(u)
        {
            Test.StartTest();
            /*** Create contract records ***/
            Contract contract1 =new Contract();
            contract1.Status ='Draft';
            contract1.ZTS_EU_Related_Contract_Template__c= conttemp1.Id;
            contract1.ZTS_EU_Committed_Amount__c = 10000;
            contract1.ZTS_EU_Discount__c = 20.00;
            contract1.AccountId= acc1.Id;
            contract1.Apply_to_Group__c = true;
            database.insert(contract1,false);
            Test.StopTest();
        }
        
        //Check if the Contract is Inserted with the right Contract Template
        List<Contract> insertedContract = [SELECT Id,ZTS_EU_Related_Contract_Template__c,
        
        ZTS_EU_Type__c,ZTS_EU_BusinessUnit__c,
        StartDate,ZTS_EU_End_Date__c,
        ZTS_EU_Discount_Type__c
        FROM Contract
        Where ZTS_EU_Related_Contract_Template__c = :conttemp1.Id
        AND ZTS_EU_Market__c != 'United States' ];
        // removed-ZTS_EU_Fiscal_Year__c
        system.debug('TestClass--->insertedContract--->'+insertedContract);
        //system.assertEquals(conttemp1.Id, insertedContract[0].ZTS_EU_Related_Contract_Template__c);
    }
    
    
    
}