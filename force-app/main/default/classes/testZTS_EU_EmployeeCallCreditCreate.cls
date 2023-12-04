/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class testZTS_EU_EmployeeCallCreditCreate {
    
    
    /*-------insert Call__c object records------*/
    public static List<Call__c> createCalls(List<Account> listAcct){
        List<Call__c> listCall = new List<Call__c>();
        for(Account acc: listAcct){
            Call__c call = new Call__c(ZTS_EU_Account__c=acc.Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2),
                                       ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today());
            listCall.add(call);
        }
        return listCall;
    }
    
    static testMethod void ZTS_EU_EmployeeCallCreditCreate(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            List<Account> listAccount = new List<Account>();
            List<Call__c> listCalls;
            
            // listAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            //insert listAccount;
            
            Account acc1 = new Account();         
            acc1.name = 'Test Account';
            acc1.Type = 'Farm';
            acc1.ZTS_EU_Sub_Type__c = 'Beef';
            acc1.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc1.ZTS_EU_City__c = 'Test City';
            acc1.ZTS_EU_Zip_Postal_Code__c = 'LD';                
            acc1.ZTS_EU_Main_Phone__c='9876789876';
            acc1.CurrencyIsoCode='EUR';
            acc1.ZTS_EU_Market__c='United Kingdom';
            acc1.Practice_Management_Software__c = 'Other';
            acc1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc1.ZTS_EU_Account_Official_Name__c = 'test';
            acc1.ZTS_EU_Vetsave_ID__c='200';
            acc1.ZTS_EU_Vetsave_HO_ID__c='56';
            listAccount.add(acc1);
            insert listAccount;
            
            listCalls = createCalls(listAccount);
            insert listCalls;
            
            list<user> u = ZTS_EU_DataUtilityTest.createcoacherUser();
            list<user> utoInsert = new list<user>();
            for(User us : u){
                us.FirstName = 'testUserFname';
                us.IsActive = true;
                utoInsert.add(us);
            }
            insert utoInsert;
            
            ZTS_EU_Territory__c terr2 = new ZTS_EU_Territory__c();
            terr2.Name= 'Turkey Territory2';
            terr2.ZTS_EU_Market__c ='Turkey';
            terr2.ZTS_EU_Is_Active__c = TRUE;
            insert terr2;
            
            ZTS_EU_Position__c pos = new ZTS_EU_Position__c();
            pos.ZTS_EU_Is_Active__c = true;
            pos.ZTS_EU_Employee__c = utoInsert[0].id;
            pos.ZTS_EU_Territory__c = terr2.id;
            insert pos;
            
            ZTS_EU_Position__c posrec = [select Name,ZTS_EU_Employee__c from ZTS_EU_Position__c where id =: pos.id];
            
            ZTS_EU_Account_Position__c ap = new ZTS_EU_Account_Position__c();
            //ap.ZTS_EU_Is_Active__c = TRUE;
            ap.ZTS_EU_Position__c = posrec.id;
            //ap.ZTS_EU_Position__r.ZTS_EU_Employee__c = posrec.ZTS_EU_Employee__c;
            ap.ZTS_EU_Account__c = listAccount[0].id;
            ap.ZTS_EU_Active__c = true;
            ap.ZTS_EU_Call_Target__c = 1;
            insert ap;
            
            List<ZTS_EU_Colleague__c> triggerNew = new List<ZTS_EU_Colleague__c>();
            ZTS_EU_Colleague__c col = new ZTS_EU_Colleague__c();
            col.ZTS_EU_Call__c = listCalls[0].id;
            triggerNew.add(col);
            insert triggerNew;
            
            ZTS_EU_EmployeeCallCreditCreate.createEmployeeCallCredit(triggerNew);
            ZTS_EU_BatchECC ecc = new ZTS_EU_BatchECC();
            database.executebatch(ecc);
            test.stopTest();
        }
    }
    
}