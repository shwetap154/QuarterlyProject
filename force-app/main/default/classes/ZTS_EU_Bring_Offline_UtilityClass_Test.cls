@isTest
public class ZTS_EU_Bring_Offline_UtilityClass_Test {
    public static Account acc; 
    public static User createAccountandStateCountryRecord(){
        
    List<State_Country__c> scList = new List<State_Country__c>();    
            State_Country__c sc = new State_Country__c();         
            sc.name = 'County';
            sc.ZTS_EU_Country__c = 'United Kingdom';
            sc.ZTS_EU_uniqueCOUNTY__c = 'County Down';
            scList.add(sc);
       insert scList;

            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;
            
            acc=new Account();
            acc.name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = 'DL12 8ED';  
            acc.ZTS_EU_Potential_Region__c = '1';              
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.CurrencyIsoCode='EUR';
            acc.ZTS_EU_Market__c='United Kingdom';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        	acc.ZTS_EU_Country__c = 'United Kingdom';
            acc.ZTS_EU_State_County__c=scList[0].Id;
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
        acc.ZTS_EU_Rep_Account_Status__c='Active';
         
        System.runAs(usr)
        {
            Insert acc;
        }

        
        User u = new User();
        u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', true);
                      
        List<ZTS_EU_Account_Position__c> apList = new List<ZTS_EU_Account_Position__c>();
        System.runAs(usr)
        {
            ZTS_EU_Account_Position__c ap1 = ZTS_EU_DataUtilityTest.createAccountPosition(u.Id, acc.Id);
        }
        return usr;
    }
    
    public static testMethod void testCreationOfAccountAndstate(){
        User usr = createAccountandStateCountryRecord(); 
        test.startTest();
        acc.ZTS_EU_Account_Status__c='Inactive';
        acc.ZTS_EU_Rep_Account_Status__c='Inactive';
        acc.ZTS_EU_Reason__c='Moved';
        System.runAs(usr)
        {
            Update acc;
        }
        test.stopTest();
    }
    
}