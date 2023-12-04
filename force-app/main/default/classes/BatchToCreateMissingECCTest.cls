@isTest
public class BatchToCreateMissingECCTest {
    

    static final String USER_NEW_ZEALAND = 'Test New Zealand User';

    @TestSetup
    static void setupData(){
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.bypass('callTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');

        User nzUser1 = ZTS_EU_DataUtilityTest.createUserWithProfile('BNLX Business Administrator', false);
        nzUser1.LastName = USER_NEW_ZEALAND + ' 1';
        nzUser1.ZTS_EU_Market__c = 'New Zealand';
        nzUser1.Default_Country__c = 'New Zealand';
        nzUser1.Country = 'New Zealand';
        insert nzUser1;

        User nzUser2 = ZTS_EU_DataUtilityTest.createUserWithProfile('BNLX Business Administrator', false);
        nzUser2.LastName = USER_NEW_ZEALAND + ' 2';
        nzUser2.ZTS_EU_Market__c = 'New Zealand';
        nzUser2.Default_Country__c = 'New Zealand';
        nzUser2.Country = 'New Zealand';
        insert nzUser2;
        
        
        List<Account> accList = new List<Account>();        
        State_Country__c sc = new State_Country__c();         
        sc.name = 'Test State';
        sc.ZTS_EU_Country__c = 'New Zealand';
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
        acc.ZTS_EU_Market__c='New Zealand';
        acc.ZTS_EU_Vetsave_ID__c='200';
        acc.ZTS_EU_Vetsave_HO_ID__c='56';
        acc.ZTS_EU_Country__c = 'New Zealand';
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
        terr1.Name= 'New Zealand Territory1';
        terr1.ZTS_EU_Market__c ='New Zealand';
        terr1.ZTS_EU_Is_Active__c = TRUE;
        lstTerr.add(terr1);
        
        
        ZTS_EU_Territory__c terr2 = new ZTS_EU_Territory__c();
        terr2.Name= 'New Zealand Territory2';
        terr2.ZTS_EU_Market__c ='New Zealand';
        terr2.ZTS_EU_Is_Active__c = TRUE;
        lstTerr.add(terr2); 
        insert lstTerr;
        
        List<ZTS_EU_Position__c> lstPos = new List<ZTS_EU_Position__c>();
        
        ZTS_EU_Position__c pos = new ZTS_EU_Position__c();
        pos.Market__c = 'New Zealand';
        pos.ZTS_EU_Territory__c = lstTerr[0].Id;
        pos.ZTS_EU_Is_Active__c = TRUE;
        pos.ZTS_EU_Employee__c = nzUser1.id;
        lstPos.add(pos);
        
        ZTS_EU_Position__c pos2 = new ZTS_EU_Position__c();
        pos2.Market__c = 'New Zealand';
        pos2.ZTS_EU_Territory__c = lstTerr[1].Id;
        pos2.ZTS_EU_Is_Active__c = TRUE;
        pos2.ZTS_EU_Employee__c = nzUser2.id;
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
        col.ZTS_EU_User__c = nzUser1.id;
        triggerNew.add(col);
        insert triggerNew;
        
        
        Call__c call2 = new Call__c(ZTS_EU_Account__c=accList[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2),
        ZTS_EU_Call_Owner__c = nzUser2.Id, ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today()+2);
        insert call2;
        //Call owner is being added as colleague after insert of call.
        /*List<ZTS_EU_Colleague__c> clglist = new List<ZTS_EU_Colleague__c>();
        ZTS_EU_Colleague__c col1 = new ZTS_EU_Colleague__c();
        col1.ZTS_EU_Call__c = call2.id;
        col1.ZTS_EU_User__c = nzUser2.id;
        clglist.add(col1);
        insert clglist;*/
        DispatchTriggerHandler.clearbypass('UserTriggerHandler');
        DispatchTriggerHandler.clearbypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.clearbypass('callTriggerHandler');
        DispatchTriggerHandler.clearbypass('AccountTriggerHandler');
        

    }

    @isTest static void createInactiveEccTest()
    {
        
        Integer numEmployeeCallCreditsBefore = [SELECT count() FROM ZTS_EU_Employee_Call_Credit__c];

        Test.startTest();
            BatchToCreateMissingECC batch= new BatchToCreateMissingECC();
            database.executeBatch(batch, 200);
        Test.stopTest();

        Integer numEmployeeCallCreditsAfter = [SELECT count() FROM ZTS_EU_Employee_Call_Credit__c];

        System.assertEquals(1, numEmployeeCallCreditsAfter-numEmployeeCallCreditsBefore, 'One employee call credit should have been created');
    }

}