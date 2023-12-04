/**
 * @description       : Test class for BatchToSendEmailForCallToManager
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-22-2022   Unknown                     Initial Version with single tests
 * 1.1   08-08-2022   Ethan Hirsch @ Zoetis Inc   Set User Ids to query in the Unit Test to avoid batch errors
**/
@isTest
public class BatchToSendEmailForCallToManagerTest {
  private static final string TEST_USERNAME_1 = 'deneme2@deneme1.com';
  private static final string TEST_USERNAME_2 = 'deneme1@deneme1.com';
  private static final string TEST_USERNAME_3 = 'deneme3@deneme1.com';

      @TestSetup
    static void setupData(){
               Account acc = new Account();         
            acc.name = 'Test Account';
            acc.Type = 'Farm';
          acc.ZTS_EU_Account_Official_Name__c = 'test';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';  
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.ZTS_EU_Market__c= 'United States';
           
           insert acc;
           
           Profile profiles=[Select Id From Profile Where Name='System Administrator'];
                                 
            User ususer1 = new user();
        ususer1.FirstName = 'Manager';    
        ususer1.LastName = 'Brown';
        ususer1.ZTS_EU_Market__c = 'United States';
        ususer1.profileid=profiles.Id;
        ususer1.Default_Country__c = 'United States';
        ususer1.Country = 'United States';
        ususer1.Territory__c='US-Terr-6921';
         ususer1.email='denem2e@deneme.com';
        ususer1.username=TEST_USERNAME_1;
        ususer1.alias='dene2';
        ususer1.languagelocalekey='en_US';
        ususer1.localesidkey='en_US';
        ususer1.timezonesidkey='America/Los_Angeles';
        ususer1.localesidkey='en_US';
        ususer1.EmailEncodingKey= 'ISO-8859-1';
        ususer1.Manager_Call_Reminder_Scheduled_Date__c=System.today();
                insert ususer1;
        
            User ususer = new user();
         ususer.FirstName='Rep1';   
        ususer.LastName = 'Mike';
        ususer.ZTS_EU_Market__c = 'United States';
        ususer.profileid=profiles.Id;
        ususer.Default_Country__c = 'United States';
        ususer.Country = 'United States';
        ususer.Territory__c='US-Terr-6921';
         ususer.email='denem1e@deneme.com';
        ususer.username=TEST_USERNAME_2;
        ususer.alias='dene1';
        ususer.languagelocalekey='en_US';
        ususer.localesidkey='en_US';
        ususer.timezonesidkey='America/Los_Angeles';
        ususer.localesidkey='en_US';
        ususer.EmailEncodingKey= 'ISO-8859-1';
        ususer.ManagerId=ususer1.Id;
        ususer.Manager_Call_Reminder_Scheduled_Date__c=System.today();
        insert ususer;
        
        
        user ususer2 = new user();
         ususer2.FirstName='Rep2';   
        ususer2.LastName = 'ket';
        ususer2.ZTS_EU_Market__c = 'United States';
        ususer2.profileid=profiles.Id;
        ususer2.Default_Country__c = 'United States';
        ususer2.Country = 'United States';
        ususer2.Territory__c='US-Terr-6921';
         ususer2.email='denem3e@deneme.com';
        ususer2.username=TEST_USERNAME_3;
        ususer2.alias='dene3';
        ususer2.languagelocalekey='en_US';
        ususer2.localesidkey='en_US';
        ususer2.timezonesidkey='America/Los_Angeles';
        ususer2.localesidkey='en_US';
        ususer2.EmailEncodingKey= 'ISO-8859-1';
        ususer2.ManagerId=ususer1.Id;
        ususer2.Manager_Call_Reminder_Scheduled_Date__c=System.today();
        insert ususer2;
                       
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = acc.Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Submitted_Date__c=datetime.newInstance(2017, 9, 1, 12, 30, 2);
             call.ZTS_EU_Status__c='Submitted';
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Call_Owner__c = ususer.Id;
            
            
            
            
            System.runAs(ususer){
                insert call;
            }
            
              Call__c call2 = new Call__c();         
            call2.ZTS_EU_Account__c = acc.Id;
            call2.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2021, 11, 18, 12, 30, 2);        
            call2.ZTS_EU_End_Date_Time__c = datetime.newInstance(2021, 11, 18, 12, 30, 2).addHours(1);
            call2.ZTS_EU_Submitted_Date__c=datetime.newInstance(2021, 11, 18, 15, 30, 2);
             call2.ZTS_EU_Status__c='Submitted';
            call2.ZTS_EU_Sub_Type__c = 'Account Call';   
            call2.ZTS_EU_Call_Owner__c = ususer1.Id;
            System.runAs(ususer2){
                insert call2;
            }
            
           
            }
          
    static testMethod void testcallreminder(){ 

             List<User> testUsers = [
              SELECT Id
              FROM User
              WHERE Username in: new List<String> {TEST_USERNAME_1, TEST_USERNAME_2, TEST_USERNAME_3}];

             Test.StartTest();
              BatchToSendEmailForCallToManager b = new BatchToSendEmailForCallToManager();
              BatchToSendEmailForCallToManager.testUsers = testUsers;
             database.executeBatch(b);
             Test.StopTest(); 

             for (User updatedUser : [
                SELECT Id, Manager_Call_Reminder_Scheduled_Date__c, Manager_Call_Reminder_Sent_Date__c, UserName
                FROM User
                WHERE Id in: testUsers ]) {
                // No Call is created for this User, so no fields should have chagend
                if (updatedUser.Username == TEST_USERNAME_1) {
                  System.assertEquals(System.today(), updatedUser.Manager_Call_Reminder_Scheduled_Date__c,
                    'Manager Call Reminder Scheduled Date was updated unexpectedly');

                  System.assertEquals(null, updatedUser.Manager_Call_Reminder_Sent_Date__c, 
                    'Mannager Call Reminder Sent Date was set unexpectedly');
                }
                else {
                  // As Submitted date is not more than 5 days, 
                  // Manager_Call_Reminder_Scheduled_Date__c should not be cleared
                  System.assertEquals(System.today(), updatedUser.Manager_Call_Reminder_Scheduled_Date__c,
                    'Manager Call Reminder Scheduled Date was updated unexpectedly.');

                  System.assertEquals(System.today(), updatedUser.Manager_Call_Reminder_Sent_Date__c, 
                    'Mannager Call Reminder Sent Date was not set to today as expected');
                }

            }
         }
            }