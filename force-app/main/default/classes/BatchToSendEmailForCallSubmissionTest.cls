/**
 * @description       : Test class for BatchToSendEmailForCallSubmission
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 07-27-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-22-2021   Unknown                      Initial Version
 * 1.1   07-27-2022   Ethan Hirsch @ Zoetis Inc    Update testCallReminder to handle testUserId being a static variable 
**/
@isTest(SeeAllData=false)
public class BatchToSendEmailForCallSubmissionTest {
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
           
            User ususer = new user();
            Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        ususer.LastName = 'Mike';
        ususer.ZTS_EU_Market__c = 'United States';
        ususer.profileid=profiles.Id;
        ususer.Default_Country__c = 'United States';
        ususer.Country = 'United States';
        ususer.Territory__c='US-Terr-6921';
         ususer.email='denem1e@deneme.com';
        ususer.username='deneme1@deneme1.com';
        ususer.alias='dene1';
        ususer.languagelocalekey='en_US';
        ususer.localesidkey='en_US';
        ususer.timezonesidkey='America/Los_Angeles';
        ususer.localesidkey='en_US';
        ususer.EmailEncodingKey= 'ISO-8859-1';
        ususer.Call_Reminder_Sent_Date__c=Date.newInstance(2021,11,22);
        insert ususer;
        
            List<Call__c> calllist = new List<Call__c>();
            
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = acc.Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Call_Owner__c = ususer.Id;
            calllist.add(call);
            
            Call__c call1 = new Call__c();
             call1.ZTS_EU_Account__c = acc.Id;
            call1.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2016, 9, 1, 12, 30, 2);        
            call1.ZTS_EU_End_Date_Time__c = datetime.newInstance(2016, 9, 1, 12, 30, 2).addHours(1);
            call1.ZTS_EU_Sub_Type__c = 'Account Call';   
            call1.ZTS_EU_Call_Owner__c = ususer.Id;
             calllist.add(call1);
            
            System.runAs(ususer){
                insert calllist;
            }
            
            for(Call__c c: calllist){
            
        call.ZTS_EU_Submitted_Date__c=datetime.newInstance(2017, 9, 1, 12, 30, 2);
        call.ZTS_EU_Status__c='Submitted';
                       }
                    
                    update calllist;
                    
                }    
    static testMethod void testcallreminder(){ 
             User TestUser = [SELECT Id FROM User WHERE Username = 'deneme1@deneme1.com' LIMIT 1];
             Test.StartTest();
             BatchToSendEmailForCallSubmission b = new BatchToSendEmailForCallSubmission();
             BatchToSendEmailForCallSubmission.testUserId = testUser.Id;
             database.executeBatch(b,20);
             Test.StopTest(); 
         }
            }