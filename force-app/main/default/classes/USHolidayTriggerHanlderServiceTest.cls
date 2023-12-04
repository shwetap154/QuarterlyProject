/****************************************************************************************************************************************** 
* Class Name : USHolidayTriggerHanlderServiceTest
* Description  : This is test class for USHolidayTriggerService class
* Created By   : Sreekanth
* Created Date : 19th Oct, 2022
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sreekanth Battala      19/10/2022          Created 
*****************************************************************************************************************************************/
@isTest
public class USHolidayTriggerHanlderServiceTest {
	public static testmethod void holidaycreate(){
        User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        insert u1;
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

            
       system.runAs(u1)
       {  
          // For Testing Before Delete
          List<Holiday__c> triggerNew = new List<Holiday__c>();
          Map<Id, Holiday__c> triggerNewMap = new Map<Id, Holiday__c>();
          Holiday__c h4 = new Holiday__c();
          h4.name='Holiday_todel_US';
          h4.ZTS_EU_Holiday_Date__c = date.ValueOf('2017-12-07');
          h4.ZTS_EU_Market__c = 'United States';
          h4.ZTS_EU_Is_Active__c= true;
          h4.ZTS_EU_Default_Holiday__c = true;
          triggerNew.add(h4);
          insert triggerNew;
           
          triggerNewMap.put(triggerNew[0].Id,triggerNew[0]);
          System.enqueueJob(new USHolidayTriggerServiceQueueable(triggerNew,triggerNewMap));
           
          // For Testing After Update
          h4.name='Holiday update1';
          h4.ZTS_EU_Holiday_Date__c = date.ValueOf('2017-12-08');
          update h4;
           
          delete h4; 
       }
      
       
    }
}