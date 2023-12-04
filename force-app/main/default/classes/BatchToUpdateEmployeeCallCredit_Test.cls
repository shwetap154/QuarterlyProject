/* -----------------------------------------------------------------------------------------------------------------------
   Name:        BatchToUpdateEmployeeCallCredit_Test.cls
   Description: Test class for BatchToUpdateEmployeeCallCredit .                    
   Date         Version    Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   02-1-2016  1.0        Srinivas               Initial Version    
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class BatchToUpdateEmployeeCallCredit_Test {
    static testMethod void Method1(){
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.zts_eu_market__c = 'United States';
         insert usr;

        System.runAs(usr)
        {
            List<Account> accList = new List<Account>();        
            State_Country__c sc = new State_Country__c();         
                sc.name = 'Test State';
                sc.ZTS_EU_Country__c = 'United States';
                sc.ZTS_EU_uniqueCOUNTY__c = 'Test State';
            insert sc;
            Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];     
                acc.ZTS_EU_Country__c = 'United States';
                acc.ZTS_EU_State_County__c = sc.Id;
                acc.ZTS_EU_Market__c = 'United States';
                acc.BillingPostalCode = '45220';
                acc.BillingCity = 'Cincinnati';
                acc.BillingState = 'OH';
                acc.BillingStreet = '727 Martin Luther King';
                accList.add(acc);
            
            insert accList;
            

            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            
            Call__c call;
            ZTS_EU_Account_Position__c ap1;
            List<ZTS_EU_Account_Position__c> apList;

            call = new Call__c(ZTS_EU_Account__c=accList[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2),
                                        ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today());
            insert call;
            System.debug('$$$ num calls before');
            apList = new List<ZTS_EU_Account_Position__c>();
            ap1 = ZTS_EU_DataUtilityTest.createAccountPosition(usr.Id, accList[0].Id);
            

            ZTS_EU_Territory__c	testTerritory = new ZTS_EU_Territory__c	(Name = 'TestSlalomTerr',
            ZTS_EU_Market__c = 'United States');
            insert testTerritory;

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

            List<ZTS_EU_Colleague__c> triggerNew = new List<ZTS_EU_Colleague__c>();

            triggerNew = [SELECT Id FROM ZTS_EU_Colleague__c WHERE ZTS_EU_Call__c = :call.id AND ZTS_EU_User__c = :usr.id];
            
            ZTS_EU_EmployeeCallCreditCreate.createEmployeeCallCredit(triggerNew);
            call.ZTS_EU_Status__c = 'Completed';
            update call; 
            

            // List<ZTS_EU_Employee_Call_Credit__c> callCreditList = [SELECT Id, ZTS_EU_Market__c ,Is_Call_status_Completed__c,ZTS_EU_Call__r.ZTS_EU_Status__c FROM ZTS_EU_Employee_Call_Credit__c WHERE ZTS_EU_Call__c = :call.Id];
            // callCreditList[0].ZTS_EU_Call__r.ZTS_EU_Status__c = 'Completed';
            // callCreditList[0].Is_Call_status_Completed__c = false;
            // update callCreditList;

            Test.startTest();
            BatchToUpdateEmployeeCallCredit ECCBatch= new BatchToUpdateEmployeeCallCredit();
            database.executeBatch(ECCBatch, 200);
            Test.stopTest();

            // List<ZTS_EU_Employee_Call_Credit__c> callCreditListAfterBatch = [SELECT Id, ZTS_EU_Market__c ,Is_Call_status_Completed__c,ZTS_EU_Call__r.ZTS_EU_Status__c FROM ZTS_EU_Employee_Call_Credit__c WHERE ZTS_EU_Call__c = :call.Id];
            // System.assertEquals(true,callCreditListAfterBatch[0].Is_Call_status_Completed__c , 'The expected value of Is_Call_status_Completed__c must change from False to True');
        }
    }
}