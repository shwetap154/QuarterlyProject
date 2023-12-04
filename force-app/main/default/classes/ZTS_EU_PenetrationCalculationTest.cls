/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_PenetrationCalculationTest
* Description   :  Test class for ZTS_EU_Account_Penetration_Calculation
                :  Test class for ZTS_EU_BatchUpdateOfPotentialToSales       
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public without sharing class ZTS_EU_PenetrationCalculationTest {
    
    /*Method to validate methods in ZTS_EU_Account_Penetration_Calculation class*/
    
    public static testMethod void validate_ZTS_EU_Account_Penetration_Calculation(){
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    string userName = generateRandomUserName(); 
    User u = new User(Alias = 'standt', Email=userName, 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName=userName,ZTS_EU_Market__c = 'United Kingdom');

      System.runAs(u) {
   List<Account> accList = ZTS_EU_DataUtilityTest1.createAccountRecord(1);
        insert accList ;
        List<ZTS_EU_Account_Species_Potential__c> aspList = ZTS_EU_DataUtilityTest1.createAcctSpeciesPotRecords(4,accList[0].id);
        //insert aspList;
        Account acc= new Account(id = accList[0].id);
        PageReference pageRef = Page.ZTS_EU_AccountPenetrationCalculation;
        Test.startTest();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId',accList[0].Id);  
        ApexPages.currentPage().getParameters().put('accountName',accList[0].Name);  
        ApexPages.currentPage().getParameters().put('potentialRegion',accList[0].ZTS_EU_Potential_Region__c);    
        ApexPages.currentPage().getParameters().put('businessUnit','businessUnit');   
        ApexPages.StandardController stdAcc = new ApexPages.StandardController(acc);                        
        ZTS_EU_Account_Penetration_Calculation acPenetration = new ZTS_EU_Account_Penetration_Calculation (stdAcc );
        acPenetration.filterDataAll();
        acPenetration.filterDataForTGSection();
        ApexPages.currentPage().getParameters().put('businessUnit','species');   
        acPenetration.filterDataAll();
        acPenetration.filterDataForTGSection();
        system.assertNotEquals(accList.size(),0);
        Test.stopTest();
      }
    } 
    
    /*Method to validate methods in ZTS_EU_Account_Penetration_Calculation class*/
    
    public static testMethod void validate_ZTS_EU_Account_Penetration_Calculation2(){
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    string userName = generateRandomUserName(); 
    User u = new User(Alias = 'standt', Email=userName, 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName=userName,ZTS_EU_Market__c = 'United Kingdom');

      System.runAs(u) {
   List<Account> accList = ZTS_EU_DataUtilityTest1.createAccountRecord(1);          
        insert accList ;
        List<ZTS_EU_Account_Species_Potential__c> aspList = ZTS_EU_DataUtilityTest1.createAcctSpeciesPotRecords(4,accList[0].id);
        accList[0].ZTS_EU_Potential_Region__c = '2';
        //insert aspList;
        Account acc= new Account(id = accList[0].id);
        PageReference pageRef = Page.ZTS_EU_AccountPenetrationCalculation;
        Test.startTest();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId',accList[0].Id);  
        ApexPages.currentPage().getParameters().put('accountName',accList[0].Name);  
        ApexPages.currentPage().getParameters().put('potentialRegion',accList[0].ZTS_EU_Potential_Region__c);    
        ApexPages.currentPage().getParameters().put('businessUnit','businessUnit');   
        ApexPages.StandardController stdAcc = new ApexPages.StandardController(acc);                        
        ZTS_EU_Account_Penetration_Calculation acPenetration = new ZTS_EU_Account_Penetration_Calculation (stdAcc );
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId',accList[0].Id);  
        ApexPages.currentPage().getParameters().put('accountName',accList[0].Name);  
        ApexPages.currentPage().getParameters().put('potentialRegion','3');    
        ApexPages.currentPage().getParameters().put('businessUnit','businessUnit');   
        stdAcc = new ApexPages.StandardController(acc);                        
        acPenetration = new ZTS_EU_Account_Penetration_Calculation (stdAcc );
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId',accList[0].Id);  
        ApexPages.currentPage().getParameters().put('accountName',accList[0].Name);  
        ApexPages.currentPage().getParameters().put('potentialRegion','4');    
        ApexPages.currentPage().getParameters().put('businessUnit','businessUnit');   
         stdAcc = new ApexPages.StandardController(acc);                        
        acPenetration = new ZTS_EU_Account_Penetration_Calculation (stdAcc );
        
        acPenetration.filterDataAll();
        acPenetration.filterDataForTGSection();
        ApexPages.currentPage().getParameters().put('businessUnit','species');   
        acPenetration.filterDataAll();
        acPenetration.filterDataForTGSection();
        system.assertNotEquals(accList.size(),0);
        Test.stopTest();
      }
    } 
    
    /*Method to validate methods in ZTS_EU_BatchUpdateOfPotentialToSales batch class*/
    
    public static testMethod void validate_ZTS_EU_BatchUpdateOfPotentialToSales(){
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    string userName = generateRandomUserName();     
    User u = new User(Alias = 'standt', Email=userName, 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName=userName,ZTS_EU_Market__c = 'United Kingdom');

      System.runAs(u) {
        List<Account> accList = ZTS_EU_DataUtilityTest1.createAccountRecord(1);
        insert accList ;
        List<ZTS_EU_Account_Species_Potential__c> aspList = ZTS_EU_DataUtilityTest1.createAcctSpeciesPotRecords(4,accList[0].id);
        //insert aspList;
        Test.startTest();
        ZTS_EU_BatchUpdateOfPotentialToSales c = new ZTS_EU_BatchUpdateOfPotentialToSales();
        Database.executeBatch(c);
        Test.stopTest();
    }
    }
    
     public static string generateRandomUserName() {
        double a=(Math.random() + 1)*100000;
        integer b = a.intValue();
        string c = String.valueOf(b);
        string userName = 'standarduser' + c + '@testorg.com';
        return userName;     
    } 
}