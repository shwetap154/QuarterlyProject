/* -----------------------------------------------------------------------------------------------------------------------
       Name:        ZTS_EU_Batch_HolidayToT_Test.cls
       Description: Test Class for Class ZTS_EU_Batch_HolidayToT.cls
                        
       Date         Version Author              Summary of Changes 
       -----------  ------- -----------------   ------------------------------------------------------------------------------
       05-12-2014   1.0     CloudSense(Shefali)   Initial Version      
       06-07-2022   1.1     Zoetis (Ethan)        Update Profile names for ZTS_Global HelpDesk and Market-Salesforce Sync
                                                  to not include special characters as part of changes to Profile names
                                                  to avoid Copado Profile deployment issues. 
    ------------------------------------------------------------------------------------------------------------------------ */
    
    
    @isTest
    public class ZTS_EU_Batch_HolidayToT_Test{ 
        public static testMethod void testToT(){
                Holiday__c testHoliday = new Holiday__c();
                testHoliday.Name ='Test Holiday1';
                testHoliday.ZTS_EU_Holiday_Date__c=System.today()+15;
                testHoliday.CurrencyIsoCode ='EUR';
                testHoliday.ZTS_EU_Market__c='United Kingdom';
                testHoliday.ZTS_EU_Is_Updated__c =false;
                testHoliday.ZTS_EU_Is_Active__c=true;
                testHoliday.ZTS_EU_Default_Holiday__c = true;
                
                
                Time_Out_of_Territory__c  testTOT1 = new Time_Out_of_Territory__c(
                															ZTS_EU_End_Date__c=System.today()+7,
                															ZTS_EU_Start_Date__c=System.today()+3,
                															ZTS_Market__c='United Kingdom',
                															ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM');
                testTOT1.ZTS_EU_Number_of_non_working_days_within__c= 1;
                insert testTOT1;
                
                Database.QueryLocator queryLoc;
                Database.BatchableContext BatchCont;
                
                List<Holiday__c> holidayList = new List<Holiday__c>();
                holidayList.add(testHoliday);
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
               insert u1;
               
               system.runAs(u1)
               {  
                insert holidayList;
               }
                
                Test.startTest();
                
                String CRON_EXP = '0 0 0 1 1 ? 2025';  
                String jobId = System.schedule('testScheduledApex', CRON_EXP, new ZTS_EU_Schedulable_HolidayToT() );
                CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
                System.assertEquals(CRON_EXP, ct.CronExpression); 
                System.assertEquals(0, ct.TimesTriggered);
                System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
                
                Test.stopTest();
                      
                
                
                    
        }
        public static testMethod void testToTNoDefaultHoliday(){
        
        
                Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
                User u = new User(Alias = 'shefS', Email='shefalitestuser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='ShefaliV', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='shefalitestuser@testorg.com');
                u.ZTS_EU_Market__c ='United Kingdom';               
                u.ZTS_EU_State_County_Id__c = 'London';
                u.ZTS_EU_isCoacher__c  = True;
                insert u;
                
                State_Country__c state =new State_Country__c(Name='London',ZTS_EU_Country__c='United Kingdom');
                insert state;
                
                Holiday__c testHoliday = new Holiday__c();
                testHoliday.Name ='Test Holiday1';
                testHoliday.ZTS_EU_Holiday_Date__c=System.today()+15;
                testHoliday.CurrencyIsoCode ='EUR';
                testHoliday.ZTS_EU_Market__c='United Kingdom';
                testHoliday.ZTS_EU_Is_Updated__c =false;
                testHoliday.ZTS_EU_Is_Active__c=true;
                testHoliday.ZTS_EU_Default_Holiday__c = false;
                testHoliday.ZTS_EU_Country__c = 'United Kingdom';
                testHoliday.ZTS_EU_State_County__c= state.Id;
                
                
                
                Time_Out_of_Territory__c  testTOT1 = new Time_Out_of_Territory__c(
                														ZTS_EU_End_Date__c=System.today()+7,
                														ZTS_EU_Start_Date__c=System.today()+3,
                														ZTS_Market__c='United Kingdom',
                														ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM');
                testTOT1.ZTS_EU_Number_of_non_working_days_within__c= 1;
                testTOT1.ZTS_EU_State_County__c =state.Id;
                insert testTOT1;
                
                Database.QueryLocator queryLoc;
                Database.BatchableContext BatchCont;
                
                List<Holiday__c> holidayList = new List<Holiday__c>();
                holidayList.add(testHoliday);
                //Added by Aritra: As part of SC-002868
                User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
               insert u1;
               
               system.runAs(u1)
               {  string id1 = [select id from profile where name='Chatter Free User'].id;     
                  Excluded_Profiles_for_Auto_TOT__c prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter Free User', Profile_Id__c = id1);
                  insert prof1;
                insert holidayList;
               }
                
                Test.startTest();
                
                String CRON_EXP = '0 0 0 1 1 ? 2025';  
                String jobId = System.schedule('testScheduledApex', CRON_EXP, new ZTS_EU_Schedulable_HolidayToT() );
                CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
                System.assertEquals(CRON_EXP, ct.CronExpression); 
                System.assertEquals(0, ct.TimesTriggered);
                System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
                
                Test.stopTest();
                
                
        }
    }