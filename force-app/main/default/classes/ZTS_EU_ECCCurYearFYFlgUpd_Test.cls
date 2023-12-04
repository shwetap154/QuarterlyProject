/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_ECCCurYearFYFlgUpd_Test
* Description   :  Test class for ZTS_EU_ECCcurrentYearFYFlag_Update          
* @author       :  Aritra (Cognizant)
* Modification Log
===================================================================================================
* Ver.       Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     8-Dec-2020       Aritra             Created the Class.
*****************************************************************************************************************************************/
@isTest
public class ZTS_EU_ECCCurYearFYFlgUpd_Test {
   static testmethod void testmethod1()
    {
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', true);
         usr.ZTS_EU_Market__c='Turkey';
         usr.Default_Country__c='Turkey';
         usr.Country='Turkey';
         update usr;
         List<Account> accList = new List<Account>();        
         State_Country__c sc = new State_Country__c();         
            sc.name = 'Test State';
            sc.ZTS_EU_Country__c = 'Turkey';
            sc.ZTS_EU_uniqueCOUNTY__c = 'Test State';
        insert sc;
        Account acc = new Account();         
            acc.name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = 'LD';                
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.ZTS_EU_District__c ='Test';
            acc.CurrencyIsoCode='EUR';
            acc.ZTS_EU_Market__c='Turkey';
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            acc.ZTS_EU_Country__c = 'Turkey';
            acc.ZTS_EU_VAT_Code__c = '132434223';
            acc.ZTS_EU_State_County__c = sc.Id;
            accList.add(acc);
            User usr2 = new User();
            usr2 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr2.FirstName = 'davidsUser';
            usr2.zts_eu_market__c = 'United Kingdom';
            insert usr2;
            
            System.runAs(usr2){
                insert accList; 
            }
        
        
          
      
        List<ZTS_EU_Account_Position__c> apList = new List<ZTS_EU_Account_Position__c>();
        
        
        ZTS_EU_Territory__c testTerritory = new ZTS_EU_Territory__c (Name = 'TestSlalomTerr',
        ZTS_EU_Market__c = 'United Kingdom');
        insert testTerritory;
        test.startTest();

        ZTS_EU_Position__c pos = new ZTS_EU_Position__c();
        pos.ZTS_EU_Is_Active__c = true;
        pos.ZTS_EU_Employee__c = usr.id;
        pos.ZTS_EU_Territory__c = testTerritory.Id;
        insert pos;
     
         ZTS_EU_Position__c posrec = [select Name,ZTS_EU_Employee__c from ZTS_EU_Position__c where id =: pos.id];
         ZTS_EU_Account_Position__c ap = new ZTS_EU_Account_Position__c();
         ap.ZTS_EU_Position__c = posrec.id;  
         ap.ZTS_EU_Account__c = accList[0].id;
         ap.ZTS_EU_Call_Target__c = 1;
         insert ap;
        
        Call__c call = new Call__c(ZTS_EU_Account__c=accList[0].Id, ZTS_EU_Start_Date_Time__c=system.today().addDays(-365),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(-3),
                                        ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today()+2);
        insert call;
        call.ZTS_EU_Submitted_Date__c = system.today().addDays(-364);
        call.ZTS_EU_Status__c = 'Completed';
        update call;
        
        
        
         List<ZTS_EU_Colleague__c> triggerNew = new List<ZTS_EU_Colleague__c>();
         ZTS_EU_Colleague__c col = new ZTS_EU_Colleague__c();
         col.ZTS_EU_Call__c = call.id;
         col.ZTS_EU_User__c = usr.id;
         triggerNew.add(col);
         insert triggerNew;
        
        ZTS_EU_Employee_Call_Credit__c ecc= new ZTS_EU_Employee_Call_Credit__c();
        ecc.ZTS_EU_Call__c = call.Id;
        ecc.Is_Call_Completed_In_Current_FY__c = true;
        ecc.ZTS_EU_FY_EndDate__c = Date.newInstance(2020, 11, 30);
        ecc.ZTS_EU_Account_Position__c = ap.id;
        ecc.ZTS_EU_Employee_Colleague__c = col.id;
        insert ecc;
          
      
        
        	ZTS_EU_ECCcurrentYearFYFlag_Update batch= new ZTS_EU_ECCcurrentYearFYFlag_Update();
        database.executeBatch(batch, 200);
        test.stopTest();
        
        List<ZTS_EU_Employee_Call_Credit__c> lst = [Select Id from ZTS_EU_Employee_Call_Credit__c where Is_Call_Completed_In_Current_FY__c = true];
        //system.debug('lst->'+lst);
        System.assertEquals(0,lst.size());
   
    }
}