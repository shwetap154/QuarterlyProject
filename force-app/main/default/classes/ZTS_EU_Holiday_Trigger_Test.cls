/**
 * @description       : Test class for ZTS_EU_Holiday_Trigger
 * @author            : Aritra Chakraborty @ Cognizant
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                           Modification
 * 1.0   04-12-2017   Aritra Chakraborty @ Cognizant   Initial Version
 * 1.0   07-29-2020   Unknown                          Unknown update
 * 1.3   06-07-2022   Ethan Hirsch @ Zoetis Inc        Set State/Country field on Users to avoid errors in lower enviornments
 *                                                     Update Profile names for ZTS_Global HelpDesk and Market-Salesforce Sync
 *                                                     to not include special characters to avoid Copado errors
**/
@isTest
public class ZTS_EU_Holiday_Trigger_Test {
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

        // Setup State/Country values that are visible in Unit Tests
        // The Holiday Trigger will retreive Users with their real values for ZTS_EU_State_County_Id__c.
        // In sandboxes that do not get data refreshes, these values will not be null and result in an error
        // This update makes sure the State/Country values on those Users exist
        List<State_Country__c> stateCountries = new List<State_Country__c>();
        State_Country__c indiaStateCountry = ZTS_EU_DataUtilityTest.createStateCountryRecordPara('Punjab', 'India');
        State_Country__c canadaStateCountry = ZTS_EU_DataUtilityTest.createStateCountryRecordPara('Ottawa', 'Canada');
        insert new List<State_Country__c> {indiaStateCountry, canadaStatecountry};

        List<User> updateUsers = new List<User>();
        for (User user : [
            SELECT ID, ZTS_EU_Market__c
            FROM USER 
            WHERE IsActive = TRUE AND ZTS_EU_State_County_Id__c != NULL 
            AND ZTS_EU_Market__c in ('Canada', 'India')]) {
            // ZTS_EU_State_County_Id__c is a 15 digit text field
            if (user.ZTS_EU_Market__c == 'Canada') {
                user.ZTS_EU_State_County_Id__c = ((String)canadaStateCountry.Id).substring(0, 15);
            }
            else {
                user.ZTS_EU_State_County_Id__c = ((String)indiaStateCountry.Id).substring(0, 15);
            }

            updateUsers.add(user);
        }

        if (updateUsers.size() > 0) {
            update updateUsers;
        }
       
       system.runAs(u1)
       {  
           
          //for after update check
           Map<Id, Holiday__c> triggerOldMap1=new  Map<Id, Holiday__c>();
           List<Holiday__c> triggerOld1=new List<Holiday__c>();
           
           Map<Id, Holiday__c> triggerNewMap1=new  Map<Id, Holiday__c>();
           List<Holiday__c> triggerNew1=new List<Holiday__c>();
           
          //inserting test Holiday
          Holiday__c oldh = new Holiday__c();
          oldh.name='old h';
          oldh.ZTS_EU_Holiday_Date__c = date.ValueOf('2018-12-07');
          oldh.ZTS_EU_Market__c = 'Canada';
          oldh.ZTS_EU_Is_Active__c= true;
          oldh.ZTS_EU_Default_Holiday__c = true;
          insert oldh; 
          triggerOldMap1.put(oldh.id, oldh);
          triggerOld1.add(oldh);
          
           //updating existing old holiday with new name and date
           Holiday__c newYearHolidays = [Select id,name,ZTS_EU_Holiday_Date__c from Holiday__c where id=:oldh.id limit 1];
           System.debug('Test Holiday name is** '+ newYearHolidays);
           	newYearHolidays.ZTS_EU_Holiday_Date__c=System.today();
            newYearHolidays.name = 'New year holiday';
              update newYearHolidays; 
           
              triggerNewMap1.put(newYearHolidays.id, newYearHolidays);
              triggerNew1.add(newYearHolidays);
           
              INTLHolidayTriggerService.afterUpdate(triggerOld1,triggerOldMap1,triggerNew1,triggerNewMap1);
          
           
           
           
          // For Positive testing
          Holiday__c h = new Holiday__c();
          h.name='test1';
          h.ZTS_EU_Holiday_Date__c = System.today();
          h.ZTS_EU_Market__c = 'Canada';
          h.ZTS_EU_Is_Active__c= true;
          h.ZTS_EU_Default_Holiday__c = true;
           insert h; 
            
         // For Negative testing
          Holiday__c hol1 = new Holiday__c();
          hol1.name='test2';
          hol1.ZTS_EU_Holiday_Date__c = date.ValueOf('2017-12-05');
          hol1.ZTS_EU_Market__c = 'Canada';
          hol1.ZTS_EU_Is_Active__c= false;
          hol1.ZTS_EU_Default_Holiday__c = true;
          insert hol1;
        
         //For Testing After Update 
       	 h.name='Holiday update';
         h.ZTS_EU_Holiday_Date__c = date.ValueOf('2017-12-07');
         update h;
    
           
         // For Testing Before Delete
          Holiday__c h3 = new Holiday__c();
          h3.name='Holiday_todel';
          h3.ZTS_EU_Holiday_Date__c = date.ValueOf('2017-12-06');
          h3.ZTS_EU_Market__c = 'India';
          h3.ZTS_EU_Is_Active__c= true;
          h3.ZTS_EU_Default_Holiday__c = true;
          insert h3;
          delete h3;
    
            
          // added by ankur for before delete
         Map<Id, Holiday__c> triggerOldMap=new  Map<Id, Holiday__c>();
         List<Holiday__c> triggerOld=new List<Holiday__c>();
          
          Holiday__c h4 = new Holiday__c();
          h4.name='Holiday_todel';
          h4.ZTS_EU_Holiday_Date__c = date.ValueOf('2018-12-06');
          h4.ZTS_EU_Market__c = 'Canada';
          h4.ZTS_EU_Is_Active__c= true; 
          h4.ZTS_EU_Default_Holiday__c = true;
          insert h4;
          
          List<Time_Out_of_Territory__c> tots=new List<Time_Out_of_Territory__c>();
          Time_Out_of_Territory__c tot=new Time_Out_of_Territory__c();
          tot.ZTS_EU_Holiday_Id__c=h4.id;
           tots.add(tot);
          insert tots;  
          
          triggerOld.add(h4); 
          triggerOldMap.put(h4.id, h4);
          INTLHolidayTriggerService.beforeDelete(triggerOld,triggerOldMap);
         
           
           
             
       }
    }
        
}