/**
 * @description       : 
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-21-2014   Unknown                     Initial Version
 * 1.0   01-22-2021   Unknown                     Initial Version
 * 1.0   06-07-2022   Ethan Hirsch @ Zoetis Inc   Update references to ZTS_Global HelpDesk and Marketo-Salesforce Sync
 *                                                to not include special characters as part of changes to Profile 
 *                                                names to avoid Copado deployment issues.
**/
@isTest
public with sharing class ZTS_EU_AllTOTTrigger_Test {
    
    @isTest static void ZTS_EU_AllTOTTrigger() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            
           List<State_Country__c> stateCountryList = ZTS_EU_DataUtilityTest.createStateCountryRecord();
            
            for(State_Country__c sc : stateCountryList){
                sc.name = 'County Down1';
                sc.ZTS_EU_Country__c = 'India';
                sc.ZTS_EU_uniqueCOUNTY__c = 'County Down1';
            }
            
            User createUser = ZTS_EU_DataUtilityTest.createUser(true);
            
            insert stateCountryList;
            
            List < Time_Out_of_Territory__c > totAMOffRecord = ZTS_EU_DataUtilityTest.createToTOffAM(1); // 8/1/2014
            for(Time_Out_of_Territory__c totAm : totAMOffRecord){
                totAm.ZTS_Market__c = 'India';  
                totAm.ZTS_EU_State_County__c = stateCountryList[0].Id;
 
            }
            List < Time_Out_of_Territory__c > totPMONRecord = ZTS_EU_DataUtilityTest.createToTOffPM(1); //7/1/2014
            
            List < Time_Out_of_Territory__c > totAMOffRecord1 = ZTS_EU_DataUtilityTest.createToTOffAM(1); // 8/1/2014
            List < Time_Out_of_Territory__c > totPMONRecord1 = ZTS_EU_DataUtilityTest.createToTOffPM(1); //7/1/2014
            List < Time_Out_of_Territory__c > totrecONFull = ZTS_EU_DataUtilityTest.createToTONFull(1);
            List < Time_Out_of_Territory__c > totONOFFAMRecord = ZTS_EU_DataUtilityTest.createToTONOFFAM(1); //8/1/2014 ON AM
            for(Time_Out_of_Territory__c tot : totONOFFAMRecord){
                tot.ZTS_EU_Sales_Representative__c = UserInfo.getUserId();
            }
            List < Time_Out_of_Territory__c > totOFFONPMRecord = ZTS_EU_DataUtilityTest.createToTOFFONFull(1); //7/1/2014 OFF PM
            List < Time_Out_of_Territory__c > totFULLOffRecord = ZTS_EU_DataUtilityTest.createToTOffFull(1);
            List < Time_Out_of_Territory__c > totlst = new List < Time_Out_of_Territory__c > ();
            
            List < Time_Out_of_Territory__c > totAMONRecord = ZTS_EU_DataUtilityTest.createToTOffAM(1);
            List < Time_Out_of_Territory__c > totFULLONRecord = ZTS_EU_DataUtilityTest.createToTOffFull(1);
            
            List<Account> acc = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert acc;
            Datetime datm = Datetime.newInstance(2017, 4, 5, 14,00,00);
            Call__c Callrec = new Call__c(ZTS_EU_Account__c = acc[0].id, ZTS_EU_Duration__c = '2 hours', ZTS_EU_Sub_Type__c = 'Account Call', ZTS_EU_Start_Date_Time__c = datm  );
            insert Callrec;
            
            ZTS_EU_Accounting_Period__c ap = new ZTS_EU_Accounting_Period__c();
            ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2017, 4, 1);
            ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2017, 4, 28);
            ap.ZTS_EU_Fiscal_Year__c = '2017';
            ap.ZTS_EU_Market__c = 'United Kingdom';
            ap.ZTS_EU_Account_Period__c = '04';
            ap.ZTS_EU_No_of_Working_Days__c = 24;
            insert ap;
            //Added by Aritra: As part of SC-002868 
            List <Excluded_Profiles_for_Auto_TOT__c> lst_ExclProf = new List<Excluded_Profiles_for_Auto_TOT__c>();
            Excluded_Profiles_for_Auto_TOT__c prof1;
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'ZTS_Helpdesk', Profile_Id__c = '00eF0000000hypOIAQ');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Pitcher Zero System Admin', Profile_Id__c = '00eF0000000hyduIAA');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'ZTS Global HelpDesk', Profile_Id__c = '00eF0000000i0sRIAQ');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Trial Customer Portal User', Profile_Id__c = '00eF0000000U6IuIAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'System Administrator', Profile_Id__c = '00eF0000000U6IvIAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Marketing User', Profile_Id__c = '00eF0000000U6IzIAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Premier Support User', Profile_Id__c = '00eF0000001V5EvIAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'sfdc', Profile_Id__c = '00eF0000000i5DuIAI');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Data Vendor', Profile_Id__c = '00eF0000000i1G1IAI');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Contract Manager', Profile_Id__c = '00eF0000000U6J0IAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Guest License User', Profile_Id__c = '00eF0000000hWDGIA2');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter External User', Profile_Id__c = '00eF0000000U6J2IAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Standard User', Profile_Id__c = '00eF0000000U6IwIAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Integration Profile', Profile_Id__c = '00eF0000000hyLzIAI');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter Moderator User', Profile_Id__c = '00eF0000000U6J1IAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Solution Manager', Profile_Id__c = '00eF0000000U6IyIAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter Free User', Profile_Id__c = '00eF0000000U6IsIAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'High Volume Customer Portal User', Profile_Id__c = '00eF0000000U6J3IAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Passport Chatter External Profile', Profile_Id__c = '00eF0000001V4eYIAS');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Passport Chatter Profile', Profile_Id__c = '00eF0000001V4eTIAS');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Read Only', Profile_Id__c = '00eF0000000U6IxIAK');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Marketo Salesforce Sync', Profile_Id__c = '00eF0000001CAhKIAW');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Passport Integration Profile', Profile_Id__c = '00eF0000001V4edIAC');
            lst_ExclProf.add(prof1);
            prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter Free Zoetis', Profile_Id__c = '00e2A000000i7NRQAY');
            lst_ExclProf.add(prof1);  
            insert lst_ExclProf;
            User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            u1.ZTS_EU_Market__c='United Kingdom';
            u1.TimeZoneSidKey = 'Europe/London';
            system.debug('u1>>'+u1);
            insert u1;
            
            system.runAs(u1)
            {  
                Holiday__c h = new Holiday__c();
                h.ZTS_EU_Is_Active__c = true;
                h.ZTS_EU_Market__c = 'India';
                h.ZTS_EU_Holiday_Date__c = System.today();
                h.ZTS_EU_Default_Holiday__c = false;
                h.ZTS_EU_Country__c = 'India';
                h.ZTS_EU_State_County__c = stateCountryList[0].Id;
                system.debug('h>>'+h);
                insert h;
                
                Holiday__c h2 = new Holiday__c();
                h2.ZTS_EU_Is_Active__c = true;
                h2.ZTS_EU_Market__c = 'Switzerland';
                h2.ZTS_EU_Holiday_Date__c = System.today();
                h2.ZTS_EU_Default_Holiday__c = true;
                system.debug('h2>>>'+h2);
                insert h2;              
            }
            
            List<User> usersList = ZTS_EU_DataUtilityTest.createcoacherUser();
            insert userslist;
            Test.startTest();
          
            List<Time_Out_of_Territory__c> totupd = new List<Time_Out_of_Territory__c>();

            Database.insert(totAMOffRecord);
            
            ZTS_EU_TOT_Utils.validateTOTDateOninsertAndUpdate(totAMOffRecord);
            System.assert(totAMOffRecord[0].id != null);
            Database.insert(totPMONRecord);
            System.assert(totPMONRecord[0].id != null);        
            List<Time_Out_of_Territory__c> totoncall = ZTS_EU_DataUtilityTest.createToTCallOnOff(1);
            for(Time_Out_of_Territory__c tot: totoncall){
                tot.ownerid = userinfo.getuserid();
                tot.ZTS_EU_Start_Date__c = system.today();
                tot.ZTS_EU_End_Date__c = system.today();
                tot.ZTS_EU_Type__c = 'Time on';
                //tot.Record_Owner__c = usersList[0].id;
                totupd.add(tot);
            }
            insert totupd;
            
            ZTS_EU_TOT_Utils.validateTOTOffconflicts(totupd);
            ZTS_EU_TOT_Utils.validateTOTOnconflicts(totAMOffRecord);
            
            System.assert(totupd[0].id != null);

            insert totrecONFull;
            insert totAMOffRecord1;
            insert totPMONRecord1;
            insert totFULLOffRecord;
            insert totONOFFAMRecord;
            insert totOFFONPMRecord;
            List < Time_Out_of_Territory__c > updlst = new List < Time_Out_of_Territory__c > ();
            for (Time_Out_of_Territory__c tot: totAMOffRecord) {
                tot.ZTS_EU_Description__c = 'ToT From test class';
                tot.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 10);
                tot.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 10);
                //tot.ZTS_EU_Sales_Representative__c = userinfo.getUserId();
                updlst.add(tot);
            }
            upsert updlst;
            Test.stopTest();
            
        }
        
    }
    
     //added by Ankur as part of TPDEV-862
     
    @isTest 
    static void validateTOT_test() {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'Brazil';
        insert usr;
        
        System.runAs(usr){
            
            State_Country__c stateCountryList = ZTS_EU_DataUtilityTest.createStateCountryRecordPara('MP','Brazil');
            
            
            User createUser = ZTS_EU_DataUtilityTest.createUser(true);
            insert stateCountryList;
            List<Time_Out_of_Territory__c> lisOfTot = new  List<Time_Out_of_Territory__c>();
           
            
            
             List < Time_Out_of_Territory__c > totAMOffRecord =  ZTS_EU_DataUtilityTest.createToTOffThisYear(2, ZTS_EU_GlobalConstants.ToT_TIMEOFF, ZTS_EU_GlobalConstants.ToT_AM); // 8/1/2014
 			totAMOffRecord[1].ZTS_EU_Type__c=ZTS_EU_GlobalConstants.ToT_TIMEON;           
            for(Time_Out_of_Territory__c totAm : totAMOffRecord){
                totAm.ZTS_Market__c = 'Brazil';  
                totAm.ZTS_EU_State_County__c = stateCountryList.Id;
                totAm.ZTS_EU_Sales_Representative__c = createUser.Id;
                totAm.ownerId = createUser.id;
                 lisOfTot.add(totAm);
            }
            
            List < Time_Out_of_Territory__c > totAMONRecords = ZTS_EU_DataUtilityTest.createToTOffThisYear(2, ZTS_EU_GlobalConstants.ToT_TIMEON, ZTS_EU_GlobalConstants.ToT_AM); // 8/1/2014
           
            for(Time_Out_of_Territory__c totAmON : totAMONRecords){
                totAmON.ZTS_Market__c = 'Brazil';  
                totAmON.ZTS_EU_State_County__c = stateCountryList.Id; 
                totAmON.ZTS_EU_Sales_Representative__c = createUser.Id;
                totAmON.ownerId = createUser.id;
                lisOfTot.add(totAmON);
            }
          
          List < ZTS_EU_Accounting_Period__c > ap = ZTS_EU_DataUtilityTest.createAccountingperiod(2);
            
          Holiday__c h = new Holiday__c();
          h.name='test1';
          h.ZTS_EU_Holiday_Date__c = System.now().date();
          h.ZTS_EU_Market__c = 'Brazil';
          h.ZTS_EU_Is_Active__c= true;
          h.ZTS_EU_Default_Holiday__c = false;
          h.ZTS_EU_Country__c='Brazil';
          h.ZTS_EU_State_County__c=stateCountryList.Id; 
            
        
             
          Test.startTest();
            upsert ap;
            insert h;
            upsert lisOfTot;
         
            ZTS_EU_TOT_Utils.calculateDayCount(totAMOffRecord);
            ZTS_EU_TOT_Utils.validateTOT(totAMOffRecord);
            ZTS_EU_TOT_Utils.validateTOT(totAMONRecords);
            ZTS_EU_TOT_Utils.populateStateOnToT(totAMOffRecord);
            ZTS_EU_TOT_Utils.populateAccountingPeriodOnTOT(totAMOffRecord);
            
            
            Test.stopTest();
            
        }
        
        
  
    }  
    
     //added by Ankur as part of TPDEV-862
    @isTest 
    static void validateTOTDateOnInsertAndUpdate_test() {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'Brazil';
        insert usr;
        
        System.runAs(usr){
            DispatchTriggerHandler.bypass('callTriggerHandler');
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            DispatchTriggerHandler.bypass('ZTS_EU_ColleagueTriggerHandler');
            
              User createUser = ZTS_EU_DataUtilityTest.createUser(true); 
            
            State_Country__c stateCountryList = ZTS_EU_DataUtilityTest.createStateCountryRecordPara('MP','Brazil');
            insert stateCountryList;
            
            List < Time_Out_of_Territory__c > totAMOffRecord_test =  ZTS_EU_DataUtilityTest.createToTOffThisYear(2, ZTS_EU_GlobalConstants.ToT_TIMEON, ZTS_EU_GlobalConstants.ToT_AM); 

                List<Time_Out_of_Territory__c> lisOfTot = new  List<Time_Out_of_Territory__c>();
             for(Time_Out_of_Territory__c totAm : totAMOffRecord_test){
                totAm.ZTS_Market__c = 'Brazil';  
                totAm.ZTS_EU_State_County__c = stateCountryList.Id;
                totAm.ZTS_EU_Sales_Representative__c = createUser.Id;
                totAm.ZTS_EU_Start_Date__c=Date.newInstance(2023, 05,29);
                totAm.ZTS_EU_End_Date__c=Date.newInstance(2023, 05,29);  
                totAm.ownerId = createUser.id;
                 totAM.recalculateFormulas();
                   
               lisOfTot.add(totAm);
            }  
            
            //Create test Account  
        Account statesAcct = CPQ_TestDataFactory.createAccount(false);
        statesAcct.Name = 'Brazil Acc';
        statesAcct.BillingStreet = 'Hornsey Rd';
        statesAcct.BillingCity = 'Brazil';
        statesAcct.BillingPostalCode = 'N7 7AJ';
        statesAcct.BillingCountry = 'Brazil';
        statesAcct.ZTS_EU_Market__c = 'Brazil';
        statesAcct.ZTS_EU_Zip_Postal_Code__c = '00001';
        insert statesAcct;
             
        
            //create test call
         Call__c call = new Call__c();        
            call.Name = 'Account Call';
            call.ZTS_EU_Account__c = statesAcct.Id;
            call.ZTS_EU_Start_Date_Time__c = Datetime.newInstance(2023, 05, 29, 9, 0, 0);
            call.ZTS_EU_Additional_Notes__c = 'Testing';
            call.Discussion_Item__c = 'Diagnostics Equipment Lead';
            call.ZTS_EU_Duration__c = '0.5 Hour';
            call.ZTS_EU_End_Date_Time__c =Datetime.newInstance(2023, 05, 29, 17, 0, 0);
            call.ZTS_EU_Status__c = 'Planned';
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.ZTS_EU_Call_Owner__c = createUser.Id;
            call.ZTS_EU_Call_Objectives__c = 'This is a test';
            call.recalculateFormulas();
            insert call;
            
            
            
             
             insert lisOfTot;
            
            //create colleagues
             List<ZTS_EU_Colleague__c> colleagues = new List<ZTS_EU_Colleague__c>();
         
            colleagues.add( TestDataFactory.createColleague(call.Id, createUser.Id ));
            //insert colleagues;
            Test.startTest();
            ZTS_EU_TOT_Utils.validateTOTDateOnInsertAndUpdate(lisOfTot);
            Test.stopTest();
            DispatchTriggerHandler.clearbypass('callTriggerHandler');
            DispatchTriggerHandler.clearbypass('AccountTriggerHandler');
            DispatchTriggerHandler.clearbypass('ZTS_EU_ColleagueTriggerHandler');
            
            
        }
        
    }
    

}