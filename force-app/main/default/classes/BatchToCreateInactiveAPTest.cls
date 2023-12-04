/**
 * @description       : Test class for BatchToCreateInactiveAP
 * @author            : Arita Chakraborty @ Cognizant
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   08-28-2019   Arita Chakraborty @ Cognizant  Initial Version
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc      Fix an error with Profiles not existing. Change the test to use 
 *                                                   Australia instead of New Zealand as Australia is in the 
 *                                                   ECC Correction Market Label and will be used in the Batch Job.
**/
@isTest
public class BatchToCreateInactiveAPTest {

    static final String USER_AUSTRALIA = 'Test Australia User';

    @TestSetup
    static void setupData(){
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.bypass('callTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');

        User ausUser1 = ZTS_EU_DataUtilityTest.createUserWithProfile('ZTS AUS Business Administrator', false);
        ausUser1.LastName = USER_AUSTRALIA + ' 1';
        ausUser1.ZTS_EU_Market__c = 'Australia';
        ausUser1.Default_Country__c = 'Australia';
        ausUser1.Country = 'Australia';
        insert ausUser1;

        User ausUser2 = ZTS_EU_DataUtilityTest.createUserWithProfile('ZTS AUS Business Administrator', false);
        ausUser2.LastName = USER_AUSTRALIA + ' 2';
        ausUser2.ZTS_EU_Market__c = 'Australia';
        ausUser2.Default_Country__c = 'Australia';
        ausUser2.Country = 'Australia';
        insert ausUser2;
        
        
        List<Account> accList = new List<Account>();        
        State_Country__c sc = new State_Country__c();         
        sc.name = 'Test State';
        sc.ZTS_EU_Country__c = 'Australia';
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
        acc.ZTS_EU_Market__c='Australia';
        acc.ZTS_EU_Vetsave_ID__c='200';
        acc.ZTS_EU_Vetsave_HO_ID__c='56';
        acc.ZTS_EU_Country__c = 'Australia';
        acc.ZTS_EU_VAT_Code__c = '132434223';
        acc.ZTS_EU_State_County__c = sc.Id;
        accList.add(acc);
        
        User intlUser = new User();
        intlUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUser.FirstName = 'intlUser';
        intlUser.zts_eu_market__c = 'United Kingdom';
        insert intlUser;
        
        System.runAs(intlUser){
            insert accList; 
        }
        
        
        Call__c call = new Call__c(ZTS_EU_Account__c=accList[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2),
        ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today()+2);
        insert call;
        List<ZTS_EU_Territory__c> lstTerr = new List<ZTS_EU_Territory__c>();
        ZTS_EU_Territory__c terr1 = new ZTS_EU_Territory__c();
        terr1.Name= 'Australia Territory1';
        terr1.ZTS_EU_Market__c ='Australia';
        terr1.ZTS_EU_Is_Active__c = TRUE;
        lstTerr.add(terr1);
        
        
        ZTS_EU_Territory__c terr2 = new ZTS_EU_Territory__c();
        terr2.Name= 'Australia Territory2';
        terr2.ZTS_EU_Market__c ='Australia';
        terr2.ZTS_EU_Is_Active__c = TRUE;
        lstTerr.add(terr2); 
        insert lstTerr;
        
        List<ZTS_EU_Position__c> lstPos = new List<ZTS_EU_Position__c>();
        
        ZTS_EU_Position__c pos = new ZTS_EU_Position__c();
        pos.Market__c = 'Australia';
        pos.ZTS_EU_Territory__c = lstTerr[0].Id;
        pos.ZTS_EU_Is_Active__c = TRUE;
        pos.ZTS_EU_Employee__c = ausUser1.id;
        lstPos.add(pos);
        
        ZTS_EU_Position__c pos2 = new ZTS_EU_Position__c();
        pos2.Market__c = 'Australia';
        pos2.ZTS_EU_Territory__c = lstTerr[1].Id;
        pos2.ZTS_EU_Is_Active__c = TRUE;
        pos2.ZTS_EU_Employee__c = ausUser2.id;
        lstPos.add(pos2);
        
        insert lstPos;
        
        ZTS_EU_Account_Position__c ap = new ZTS_EU_Account_Position__c();
        ap.ZTS_EU_Position__c = pos.id;  
        ap.ZTS_EU_Account__c = accList[0].id;
        ap.ZTS_EU_Call_Target__c = 1;
        insert ap;
        
        List<ZTS_EU_Colleague__c> triggerNew = new List<ZTS_EU_Colleague__c>();
        ZTS_EU_Colleague__c col = new ZTS_EU_Colleague__c();
        col.ZTS_EU_Call__c = call.id;
        col.ZTS_EU_User__c = ausUser1.id;
        triggerNew.add(col);
        insert triggerNew;
        
        
        Call__c call2 = new Call__c(ZTS_EU_Account__c=accList[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2),
        ZTS_EU_Call_Owner__c = ausUser2.Id, ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today()+2);
        insert call2;
        
        List<ZTS_EU_Colleague__c> clglist = new List<ZTS_EU_Colleague__c>();
        ZTS_EU_Colleague__c col1 = new ZTS_EU_Colleague__c();
        col1.ZTS_EU_Call__c = call2.id;
        col1.ZTS_EU_User__c = ausUser1.id;
        clglist.add(col1);
        insert clglist;
        DispatchTriggerHandler.clearbypass('UserTriggerHandler');
        DispatchTriggerHandler.clearbypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.clearbypass('callTriggerHandler');
        DispatchTriggerHandler.clearbypass('AccountTriggerHandler');
        

    }
    
    @isTest static void createInactiveAPTest()
    {
        Integer numAccountPositionBefore = [SELECT count() FROM ZTS_EU_Account_Position__c];
        
        Test.startTest();
        BatchToCreateInactiveAP batch= new BatchToCreateInactiveAP();
        database.executeBatch(batch, 200);
        Test.stopTest();
        
        Integer numAccountPositionAfter = [SELECT count() FROM ZTS_EU_Account_Position__c];

        System.assertEquals(1, numAccountPositionAfter-numAccountPositionBefore, 'One account position should have been created');

    }
    
    
}