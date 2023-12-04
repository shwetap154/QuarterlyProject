/**
 * @description       : Test class for INTL Account Trigger
 * @author            : Chandana Ka @ Cloud Sense
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-23-2016   Chandana Ka @ Cloud Sense   Initial Version
 * 1.1   07-08-2021   Unknown                     Unknown Updates
 * 1.2   06-07-2022   Ethan Hirsch @ Zoetis Inc   Update references to JPN & North Asia Business Administrator Profile to not
 *                                                include & to avoid Copado deployment issues with Profiles.
**/
@isTest
public class ZTS_EU_Account_Trigger_Test {
    Public static User u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
    //Public static User u = ZTS_EU_DataUtilityTest.createUserWithProfile('ZTS JPN Field Based Function', false);
    Public static User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('JPN and North Asia Business Administrator', false);
    Public static User u2 = ZTS_EU_DataUtilityTest.createUserWithProfile('JPN and North Asia Business Administrator', false);
    Public static User u3 = ZTS_EU_DataUtilityTest.createUserWithProfile('ZTS CLAR BR Business Administrator', false);
    public static List<Account> accList =new List<Account>() ;
    public static List<Contact> contLst =new List<Contact>();
    public static AccountAndContactOwnerId__c custId = new AccountAndContactOwnerId__c() ;
    
    static void setUpData(User us){        
        // TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_EU_Account_Trigger', ZTS_EU_Bypass__c = true);
        // insert triActivation;
            
        AccountAndContactOwnerId__c acc1 = new AccountAndContactOwnerId__c(Name = 'Test User', Market__c = us.ZTS_EU_Market__c, OwnerId__c = us.id);
        insert acc1;
        
        State_Country__c sc = new State_Country__c();
        sc.Name = 'Sachsen';
        sc.ZTS_EU_Country__c = 'Germany';
        insert sc;
        
        List<Account> accList = new List<Account>();
        //for(Integer i = 0; i < 200; i++){
            Account acc = new Account();         
            //acc.name = 'Test Account'+i;
            acc.name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_Account_Official_Name__c = 'test';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';  
            acc.ZTS_EU_Potential_Region__c = '1';              
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.CurrencyIsoCode= system.label.Currency_Code;
            acc.ZTS_EU_Market__c='United Kingdom';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc.ZTS_EU_Country__c = 'Germany';
            acc.ZTS_EU_State_County__c = sc.Id;
            acc.ZTS_EU_District__c = 'DOGU';
            acc.ZTS_EU_VAT_Code__c = '231423434534543';
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            acc.ZTS_EU_Account_Status__c = 'Pending';
            accList.add(acc);
        //}
        insert accList;
        
        for(Account accUp : accList){
            accUp.ZTS_EU_Account_Status__c = 'Active';
        }
        
        update accList;
        
        /*Call__c newcall = new Call__c();
        datetime dt = system.now();
        newCall.ZTS_EU_Account__c = acc.id;
        newCall.ZTS_EU_Start_Date_Time__c = dt;
        newCall.ZTS_EU_Sub_Type__c = 'Account Call';
        newCall.ZTS_EU_Local_Subtype__c = 'AVS AAP Activity';
        newCall.ZTS_EU_End_Date_Time__c = dt.addMinutes(30);
        newCall.ZTS_EU_Status__c = 'Planned';
        newCall.ZTS_EU_Call_Objectives__c = 'test';
        newCall.ZTS_EU_Duration__c = '0.5 Hour';
        newCall.ZTS_EU_Call_Owner__c = us.id;
        insert newCall;*/
        
        /*ZTS_EU_Colleague__c coll = new ZTS_EU_Colleague__c();
        coll.Name = 'test';
        coll.ZTS_EU_Call__c = newCall.id;
        coll.ZTS_EU_User__c = us.id;
        insert coll;*/
        
                
    }
    
    static testMethod void testPotentialRegionUpdate(){        
        // TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_EU_Account_Trigger', ZTS_EU_Bypass__c = true);
        // insert triActivation;
            
        State_Country__c sc = new State_Country__c();
        sc.Name = 'SALVADOR';
        sc.ZTS_EU_Country__c = 'Brazil';
        insert sc;
        
                
        Account accPR = new Account();         
        accPR.name = 'Test Account';
        accPR.Type = 'Distributor';
        accPR.ZTS_EU_Account_Official_Name__c = 'test';
        accPR.ZTS_EU_Sub_Type__c = 'Beef';
        accPR.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        accPR.ZTS_EU_City__c = 'Test City';
        accPR.ZTS_EU_Zip_Postal_Code__c = '143532345';  
        accPR.ZTS_EU_Potential_Region__c = '1';              
        accPR.ZTS_EU_Main_Phone__c='9876789876';
        accPR.CurrencyIsoCode= system.label.Currency_Code;
        accPR.ZTS_EU_Market__c= 'Brazil';
        accPR.Practice_Management_Software__c = 'Other';
        accPR.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        accPR.ZTS_EU_Country__c = 'Brazil';
        accPR.ZTS_EU_State_County__c = sc.Id;
        accPR.ZTS_EU_District__c = 'DOGU';
        accPR.ZTS_EU_VAT_Code__c = '12323214234332';
        accPR.ZTS_EU_Vetsave_ID__c='200';
        accPR.ZTS_EU_Vetsave_HO_ID__c='56';
        accPR.ZTS_EU_Account_Status__c = 'Active';
        User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert accPR;
            }
        
        accPR.ZTS_EU_Sub_Type__c = 'Petshop';
        update accPR;
                
        accPR.ZTS_EU_Sub_Type__c = 'Clinic+Petshop';
        update accPR;
        
        accPR.ZTS_EU_Sub_Type__c = 'Hospital';
        update accPR;
        
        accPR.ZTS_EU_Sub_Type__c = 'Use or may use FTAI';
        update accPR;
        
        accPR.ZTS_EU_Sub_Type__c = 'Retailer';
        update accPR;
        
        accPR.Type = null;        
        accPR.ZTS_EU_Sub_Type__c = null;
        update accPR;  
    }
    
    static testMethod void testAccCall(){ 
         u.ZTS_EU_Market__c = 'Germany';
         u.ZTS_EU_Primary_Business_Unit__c = 'PY';
         insert u;
         System.runAs(u){ 
             setUpData(u);    
             Test.StartTest();
             ZTS_EU_BatchCall b = new ZTS_EU_BatchCall();
             database.executeBatch(b); 
             Test.StopTest(); 
         }
                     
    }
    
   static testMethod void testAcc1(){
                    
        List<string> Lst = new List<string>();
        Set<id> Accountid = new Set<id>();
        Map<String,Boolean> Mapacc = new Map<String,Boolean>();
                  
        State_Country__c sc = new State_Country__c();         
        sc.name = 'Germany';
        sc.ZTS_EU_Country__c = 'Germany';
        Insert sc;
        
        Account acc1 = new Account();         
        acc1.name = 'Test Account';
        acc1.Type = 'Farm';
        acc1.ZTS_EU_Account_Official_Name__c = 'test';
        acc1.ZTS_EU_Sub_Type__c = 'Beef';
        acc1.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        acc1.ZTS_EU_City__c = 'Test City';
        acc1.ZTS_EU_Zip_Postal_Code__c = '12334345';  
        acc1.ZTS_EU_Potential_Region__c = '1';              
        acc1.ZTS_EU_Main_Phone__c='9876789876';
        acc1.CurrencyIsoCode= system.label.Currency_Code;
        acc1.ZTS_EU_Market__c= 'Brazil';
        acc1.Practice_Management_Software__c = 'Other';
        acc1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc1.ZTS_EU_Country__c = 'Germany';
        
        
        acc1.ZTS_EU_State_County__c=sc.Id;
        acc1.ZTS_EU_District__c = 'DOGU';
        acc1.ZTS_EU_VAT_Code__c = '1232343534564654';
        acc1.ZTS_EU_Vetsave_ID__c='200';
        acc1.ZTS_EU_Vetsave_HO_ID__c='56';
        acc1.ZTS_EU_Account_Status__c = 'Pending';
        acc1.Email__c = 'abc@gmail.com';
        User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert acc1;
            }
        
        Lst.add(acc1.Email__c);
        Accountid.add(acc1.Id);
        Mapacc.put(acc1.Email__c, acc1.ZTS_EU_Opt_Out_Email__c); 
         
         
    }
    
     static testMethod void testAcc2(){
                
        List<string> Lst2 = new List<string>();
        Set<id> Accountid2 = new Set<id>();
        Map<String,Boolean> Mapacc2 = new Map<String,Boolean>();
         
        State_Country__c sc = new State_Country__c();         
        sc.name = 'Germany';
        sc.ZTS_EU_Country__c = 'Germany';
        Insert sc;    
        
        Account acc2 = new Account();         
        acc2.name = 'Test Account';
        acc2.Type = 'Farm';
        acc2.ZTS_EU_Account_Official_Name__c = 'test';
        acc2.ZTS_EU_Sub_Type__c = 'Beef';
        acc2.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        acc2.ZTS_EU_City__c = 'Test City';
        acc2.ZTS_EU_Zip_Postal_Code__c = '1232324345';  
        acc2.ZTS_EU_Potential_Region__c = '1';              
        acc2.ZTS_EU_Main_Phone__c='9876789876';
        acc2.CurrencyIsoCode= system.label.Currency_Code;
        acc2.ZTS_EU_Market__c= 'Brazil';
        acc2.Practice_Management_Software__c = 'Other';
        acc2.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc2.ZTS_EU_Country__c = 'Germany';
        acc2.ZTS_EU_State_County__c= sc.Id;
        acc2.ZTS_EU_District__c = 'DOGU';
        acc2.ZTS_EU_VAT_Code__c = '213545654655555';
        acc2.ZTS_EU_Vetsave_ID__c='200';
        acc2.ZTS_EU_Vetsave_HO_ID__c='56';
        acc2.ZTS_EU_Account_Status__c = 'Pending';
        acc2.Email__c = 'abc@gmail.com';
        User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert acc2;
            }
        
        Lst2.add(acc2.Email__c);
        Accountid2.add(acc2.Id);
        Mapacc2.put(acc2.Email__c, acc2.ZTS_EU_Opt_Out_Email__c); 
         
   }

    static testMethod void m(){
        
        
            Account acc = new Account();         
            acc.name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_Account_Official_Name__c = 'test';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = '12324323345';  
            acc.ZTS_EU_Potential_Region__c = '1';              
            acc.ZTS_EU_Main_Phone__c='987673389876';
            acc.CurrencyIsoCode= system.label.Currency_Code;
            acc.ZTS_EU_Market__c= 'Brazil';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc.ZTS_EU_Country__c = system.label.Market_Value;
            // acc.ZTS_EU_State_County__c=sc.Id;
            acc.ZTS_EU_District__c = 'DOGU';
            acc.ZTS_EU_VAT_Code__c = '23435456575675666';
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            acc.ZTS_EU_Account_Status__c = 'Pending';
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert acc;
            }
    }
    
    static testMethod void Pbu(){
        u1.ZTS_EU_Market__c = 'Japan';
        u1.ZTS_EU_Primary_Business_Unit__c = 'EQ';
        insert u1;
        System.runAs(u1){
            Account acc = new Account();         
            acc.name = 'Test Account2';
            acc.Type = 'Farm';
            acc.ZTS_EU_Account_Official_Name__c = 'test';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';  
            acc.ZTS_EU_Potential_Region__c = '1';              
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.CurrencyIsoCode= system.label.Currency_Code;
            acc.ZTS_EU_Market__c= 'Brazil';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc.ZTS_EU_Country__c = system.label.Market_Value;
            // acc.ZTS_EU_State_County__c=sc.Id;
            acc.ZTS_EU_District__c = 'DOGU';
            acc.ZTS_EU_VAT_Code__c = '23432435433376';
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            acc.ZTS_EU_Account_Status__c = 'Pending';
            acc.ZTS_EU_RAT_EQ__c = 'EQ-New';
            insert acc;
        }
    }       
    static testMethod void Pbu1(){
        u2.ZTS_EU_Primary_Business_Unit__c = 'RU';
        insert u2;
        System.runAs(u2){
            Account acc1 = new Account();         
            acc1.name = 'Test Account3';
            acc1.Type = 'Farm';
            acc1.ZTS_EU_Account_Official_Name__c = 'test';
            acc1.ZTS_EU_Sub_Type__c = 'Beef';
            acc1.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc1.ZTS_EU_City__c = 'Test City';
            acc1.ZTS_EU_Zip_Postal_Code__c = '12345';  
            acc1.ZTS_EU_Potential_Region__c = '1';              
            acc1.ZTS_EU_Main_Phone__c='9876789876';
            acc1.CurrencyIsoCode= system.label.Currency_Code;
            acc1.ZTS_EU_Market__c= 'Brazil';
            acc1.Practice_Management_Software__c = 'Other';
            acc1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc1.ZTS_EU_Country__c = system.label.Market_Value;
            // acc.ZTS_EU_State_County__c=sc.Id;
            acc1.ZTS_EU_District__c = 'DOGU';
            acc1.ZTS_EU_VAT_Code__c = '23424325436456566';
            acc1.ZTS_EU_Vetsave_ID__c='200';
            acc1.ZTS_EU_Vetsave_HO_ID__c='56';
            acc1.ZTS_EU_Account_Status__c = 'Pending';
            acc1.ZTS_EU_RAT_EQ__c = 'RU-New';
           insert acc1;   
        }
    }
    static testMethod void Pbu2(){
        u1.ZTS_EU_Primary_Business_Unit__c = 'SW';
        insert u1;
        System.runAs(u1){
        Account acc2 = new Account();         
            acc2.name = 'Test Account3';
            acc2.Type = 'Farm';
            acc2.ZTS_EU_Account_Official_Name__c = 'test';
            acc2.ZTS_EU_Sub_Type__c = 'Beef';
            acc2.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc2.ZTS_EU_City__c = 'Test City';
            acc2.ZTS_EU_Zip_Postal_Code__c = '12345';  
            acc2.ZTS_EU_Potential_Region__c = '1';              
            acc2.ZTS_EU_Main_Phone__c='987675589876';
            acc2.CurrencyIsoCode= system.label.Currency_Code;
            acc2.ZTS_EU_Market__c= 'Brazil';
            acc2.Practice_Management_Software__c = 'Other';
            acc2.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc2.ZTS_EU_Country__c = system.label.Market_Value;
            // acc.ZTS_EU_State_County__c=sc.Id;
            acc2.ZTS_EU_District__c = 'DOGU';
            acc2.ZTS_EU_VAT_Code__c = '32243545655788765';
            acc2.ZTS_EU_Vetsave_ID__c='200';
            acc2.ZTS_EU_Vetsave_HO_ID__c='56';
            acc2.ZTS_EU_Account_Status__c = 'Pending';
            acc2.ZTS_EU_RAT_EQ__c = 'SW-New';
            insert acc2;   
        }
    }  
    static testMethod void Pbu3(){
        u2.ZTS_EU_Primary_Business_Unit__c = 'PY';
        insert u2;
        System.runAs(u2){
        Account acc3 = new Account();         
            acc3.name = 'Test Account4';
            acc3.Type = 'Farm';
            acc3.ZTS_EU_Account_Official_Name__c = 'test';
            acc3.ZTS_EU_Sub_Type__c = 'Beef';
            acc3.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc3.ZTS_EU_City__c = 'Test City';
            acc3.ZTS_EU_Zip_Postal_Code__c = '12345';  
            acc3.ZTS_EU_Potential_Region__c = '1';              
            acc3.ZTS_EU_Main_Phone__c='985576789876';
            acc3.CurrencyIsoCode= system.label.Currency_Code;
            acc3.ZTS_EU_Market__c= 'Brazil';
            acc3.Practice_Management_Software__c = 'Other';
            acc3.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc3.ZTS_EU_Country__c = system.label.Market_Value;
            // acc.ZTS_EU_State_County__c=sc.Id;
            acc3.ZTS_EU_District__c = 'DOGU';
            acc3.ZTS_EU_VAT_Code__c = '3234556654443445676';
            acc3.ZTS_EU_Vetsave_ID__c='200';
            acc3.ZTS_EU_Vetsave_HO_ID__c='56';
            acc3.ZTS_EU_Account_Status__c = 'Pending';
            acc3.ZTS_EU_RAT_EQ__c = 'PY-New';
           insert acc3;   
            }
    }
    static testMethod void test_vat_brazil(){
             
        // TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_EU_Account_Trigger', ZTS_EU_Bypass__c = true);
        // insert triActivation;
            Account acc10 = new Account();         
            acc10.name = 'Test Account1';
            acc10.Type = 'Farm';
            acc10.ZTS_EU_Sub_Type__c = 'Beef';
            acc10.ZTS_EU_Address_Line_1__c = 'Test Address Line 1';
            acc10.ZTS_EU_City__c = 'Test City';
            acc10.ZTS_EU_Zip_Postal_Code__c = '3243245345';                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc10.ZTS_EU_Main_Phone__c='9876789876';
           // acc10.CurrencyIsoCode='EUR';
            acc10.ZTS_EU_Market__c='Brazil';
            acc10.Practice_Management_Software__c = 'Other';
            acc10.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc10.ZTS_EU_Country__c = 'Brazil';
            acc10.ZTS_EU_VAT_Code__c = '12543543455534';
                        
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert acc10;
            }
        
        Account acc11 = new Account();         
            acc11.name = 'Test2 Account2';
            acc11.Type = 'Farm';
            acc11.ZTS_EU_Sub_Type__c = 'Beef';
            acc11.ZTS_EU_Address_Line_1__c = 'Test Address Line 2';
            acc11.ZTS_EU_City__c = 'Test City1';
            acc11.ZTS_EU_Zip_Postal_Code__c = '425365456457';                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc11.ZTS_EU_Main_Phone__c='9876789877';
           // acc10.CurrencyIsoCode='EUR';
            acc11.ZTS_EU_Market__c='Brazil';
            acc11.Practice_Management_Software__c = 'Other';
            acc11.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc11.ZTS_EU_Country__c = 'Brazil';
            acc11.ZTS_EU_VAT_Code__c = '1234453454353455';
                       
        system.debug('acc11 --->>'+acc11);   
          insert acc11;      
        
    }
//13th-Sep-2017   Aritra (Cognizant)      Added test method to cover the logic to move only non-duplicate ASC to survivor Account after merge 
//                                          on Delete context (SC-003118)    
static testMethod void testAcctMerge(){
    //Test.startTest();
    //  TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_EU_Account_Trigger', ZTS_EU_Bypass__c = true);
    //     insert triActivation;
    
     //insert 1st account
     Account acc = new Account();         
            acc.name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';  
            acc.ZTS_EU_Potential_Region__c = '1';              
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.ZTS_EU_Market__c='United Kingdom';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc.ZTS_EU_Country__c = 'United Kingdom';
            // acc.ZTS_EU_State_County__c=sc.Id;
            acc.ZTS_EU_District__c = 'DOGU';
            acc.ZTS_EU_Account_Status__c = 'Active';
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;

            System.runAs(usr){
                insert acc;
            }
        
       //insert 2nd account
       Account acc2 = new Account();         
            acc2.name = 'Test Account2';
            acc2.Type = 'Farm';
            acc2.ZTS_EU_Address_Line_1__c = 'Test Address Line 2';
            acc2.ZTS_EU_City__c = 'Test City 2';
            acc2.ZTS_EU_Zip_Postal_Code__c = '78964';  
            acc2.ZTS_EU_Potential_Region__c = '1';              
            acc2.ZTS_EU_Main_Phone__c='42678289129';
            acc2.ZTS_EU_Market__c='United Kingdom';
            acc2.Practice_Management_Software__c = 'Other';
            acc2.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc2.ZTS_EU_Country__c = 'United Kingdom';
            // acc.ZTS_EU_State_County__c=sc.Id;
            acc2.ZTS_EU_District__c = 'Test';
            acc2.ZTS_EU_Account_Status__c = 'Active';
            insert acc2;
        
        set<string> objNames = new set<String>();
            objNames.add('Account');
            objNames.add('ZTS_EU_Species_Product__c');
            list<recordtype> recordtypesLst = new list<recordtype>();
            recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
            
            map<string, string> recordtypeMap = new map<string, string>();
            
            for(Recordtype r : recordtypesLst){
                string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
                recordtypeMap.put(objName_DeveloperName, r.id);
                system.debug('objName_DeveloperName>>:'+objName_DeveloperName);
            }
    
        /*Creating Product Hierarchy records */
            /*Creating Swine BU PRODUCTS and Species */
            ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
            buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
            buRecord.ZTS_EU_Business_Unit_Abbr__c = 'SW';
            insert buRecord;
            
            ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
            tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
            insert tgRecord;
           
            ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
            brandRecord = AccountProductPotentialHelper_Test.createProdHierarchyRecord('Ph 2','Brand','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
            insert brandRecord;
           
            ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
            mpgRecord = AccountProductPotentialHelper_Test.createProdHierarchyRecord('Ph 2','MPG','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
            insert mpgRecord;
           
            ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
            skuRecord = AccountProductPotentialHelper_Test.createProdHierarchyRecord('Ph 2','SKU','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id);
            insert skuRecord;
            
            /* Creating ZTS_EU_Species__c records */
            list<ZTS_EU_Species__c> swinespeciesRecords = new list<ZTS_EU_Species__c>();
            for(integer i=0; i<5; i++){
                swinespeciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','United Kingdom'));
            }
            insert swinespeciesRecords;
            
            /* Creating ZTS_EU_Potential_Brands__c records */
            list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
            for(ZTS_EU_Species__c z:swinespeciesRecords ){
                pb.add(TestUtilities.createNoInsertPotBrands(z.id,brandRecord.id,1,1,1,1));
            }
            
            insert pb;
        
        /*Creating Ruminant BU PRODUCTS and Species */
            ZTS_EU_Species_Product__c buRecord2 = new ZTS_EU_Species_Product__c();
            buRecord2 = TestUtilities.createNoInsertBrand('Ph 3','Business Unit','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
            buRecord2.ZTS_EU_Business_Unit_Abbr__c = 'RU';
            insert buRecord2;
            
            ZTS_EU_Species_Product__c tgRecord2 = new ZTS_EU_Species_Product__c();
            tgRecord2 = TestUtilities.createNoInsertBrand('Ph 3','Therapeutic Group','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
            insert tgRecord2;
           
            ZTS_EU_Species_Product__c brandRecord2 = new ZTS_EU_Species_Product__c();
            brandRecord2 = AccountProductPotentialHelper_Test.createProdHierarchyRecord('Ph 4','Brand','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord2.id);
            insert brandRecord2;
           
            ZTS_EU_Species_Product__c mpgRecord2 = new ZTS_EU_Species_Product__c();
            mpgRecord2 = AccountProductPotentialHelper_Test.createProdHierarchyRecord('Ph 4','MPG','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord2.id);
            insert mpgRecord2;
           
            ZTS_EU_Species_Product__c skuRecord2 = new ZTS_EU_Species_Product__c();
            skuRecord = AccountProductPotentialHelper_Test.createProdHierarchyRecord('Ph 4','SKU','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord2.id);
            insert skuRecord2;
            
            /* Creating ZTS_EU_Species__c records */
            list<ZTS_EU_Species__c> ruminantspeciesRecords = new list<ZTS_EU_Species__c>();
            for(integer i=0; i<5; i++){
                ruminantspeciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord2.id,'Specie name','United Kingdom'));
            }
            insert ruminantspeciesRecords;
            
            /* Creating ZTS_EU_Potential_Brands__c records */
            list<ZTS_EU_Potential_Brands__c> pb2 = new list<ZTS_EU_Potential_Brands__c>();
            for(ZTS_EU_Species__c z:ruminantspeciesRecords ){
                pb2.add(TestUtilities.createNoInsertPotBrands(z.id,brandRecord2.id,1,1,1,1));
            }
            Test.startTest();
            insert pb2;
            //Test.stopTest();
                        
            /* Creating ZTS_EU_Account_Species_Potential__c records for 1st account*/
            list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,swinespeciesRecords[0].id,20,20));
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,ruminantspeciesRecords[0].id,10,10));
                        
            insert accSpecieConsulatation;
    
           /* Creating ZTS_EU_Account_Species_Potential__c records for 2nd account*/
            list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation2 = new list<ZTS_EU_Account_Species_Potential__c>();
            accSpecieConsulatation2.add(TestUtilities.createNoInsertAcctSpcPot(acc2.id,swinespeciesRecords[0].id,30,30));
            accSpecieConsulatation2.add(TestUtilities.createNoInsertAcctSpcPot(acc2.id,swinespeciesRecords[1].id,5,5));
                        
            insert accSpecieConsulatation2; 

    
     //Test.startTest();
     merge acc acc2;
     Test.stopTest();
     
 }
    
    
         
    
    /*static testMethod void test_vat_brazil_negative(){
        // TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_EU_Account_Trigger', ZTS_EU_Bypass__c = true);
        // insert triActivation;
        
            Account acc12 = new Account();         
            acc12.name = 'Account1';
            acc12.Type = 'Farm';
            acc12.ZTS_EU_Sub_Type__c = 'Beef';
            acc12.ZTS_EU_Address_Line_1__c = 'Test Address Line 1';
            acc12.ZTS_EU_City__c = 'Test City';
            acc12.ZTS_EU_Zip_Postal_Code__c = 'LD';                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc12.ZTS_EU_Main_Phone__c='9876789876';
           // acc10.CurrencyIsoCode='EUR';
            acc12.ZTS_EU_Market__c='Brazil';
            acc12.ZTS_EU_Country__c = 'Brazil';
            acc12.ZTS_EU_VAT_Code__c = '1234';
                        
        insert acc12;
        
        Account acc13 = new Account();         
            acc13.name = 'Account2';
            acc13.Type = 'Farm';
            acc13.ZTS_EU_Sub_Type__c = 'Beef';
            acc13.ZTS_EU_Address_Line_1__c = 'Test Address Line 2';
            acc13.ZTS_EU_City__c = 'Test City1';
            acc13.ZTS_EU_Zip_Postal_Code__c = 'LD1';                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc13.ZTS_EU_Main_Phone__c='9458488855';
           // acc10.CurrencyIsoCode='EUR';
            acc13.ZTS_EU_Market__c='Brazil';
            acc13.ZTS_EU_Country__c = 'Brazil';
            acc13.ZTS_EU_VAT_Code__c = '1234';
                       
        system.debug('acc11 --->>'+acc13);   
          insert acc13; 
        
    }
    
    static testMethod void test_vat_brazil_update_neg(){
        //  TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_EU_Account_Trigger', ZTS_EU_Bypass__c = true);
        // insert triActivation;
        
            Account acc12 = new Account();         
            acc12.name = 'Account1';
            acc12.Type = 'Farm';
            acc12.ZTS_EU_Sub_Type__c = 'Beef';
            acc12.ZTS_EU_Address_Line_1__c = 'Test Address Line 1';
            acc12.ZTS_EU_City__c = 'Test City';
            acc12.ZTS_EU_Zip_Postal_Code__c = 'LD';                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc12.ZTS_EU_Main_Phone__c='9876789876';
           // acc10.CurrencyIsoCode='EUR';
            acc12.ZTS_EU_Market__c='Brazil';
            acc12.ZTS_EU_Country__c = 'Brazil';
            acc12.ZTS_EU_VAT_Code__c = '1234';
                        
        insert acc12;
        
        Account acc13 = new Account();         
            acc13.name = 'Account2';
            acc13.Type = 'Farm';
            acc13.ZTS_EU_Sub_Type__c = 'Beef';
            acc13.ZTS_EU_Address_Line_1__c = 'Test Address Line 2';
            acc13.ZTS_EU_City__c = 'Test City1';
            acc13.ZTS_EU_Zip_Postal_Code__c = 'LD1';                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc13.ZTS_EU_Main_Phone__c='9458488855';
           // acc10.CurrencyIsoCode='EUR';
            acc13.ZTS_EU_Market__c='Brazil';
            acc13.ZTS_EU_Country__c = 'Brazil';
            acc13.ZTS_EU_VAT_Code__c = '12345';
                       
        system.debug('acc11 --->>'+acc13);   
          insert acc13; 
        acc13.ZTS_EU_VAT_Code__c = '1234';
        update acc13;
        
    }*/
        
        
    }