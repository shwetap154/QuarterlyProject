@isTest
public class ZTS_EU_Task_Controller_Test{

static testmethod void ZTS_EU_Task_Controller()
{

    Account A1= new Account();
        A1.Name= 'Test Account';
        A1.Type= 'Vet Practice';
        A1.ZTS_EU_Address_Line_1__c = 'Test123';
        A1.ZTS_EU_City__c= 'Test City';
        A1.ZTS_EU_Zip_Postal_Code__c= '123456';
        A1.ZTS_EU_Market__c='United Kingdom';
        A1.Practice_Management_Software__c = 'Other';
        A1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        A1.BillingPostalCode = '12345';
        A1.BillingCity = 'Boca Raton';
        A1.BillingState = 'Florida';
        A1.BillingStreet = 'Elm Lane';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert A1;
        }

        

    Call__c newCall= new Call__c();
        newCall.ZTS_EU_Sub_Type__c = 'Account Call';
        newCall.ZTS_EU_Start_Date_Time__c= DateTime.newInstance(2014,6,16,7,00,00);
        newCall.ZTS_EU_Duration__c= '0.5 Hour';
        newCall.ZTS_EU_Account__c= A1.id;

insert newCall;

    Call__c newCall1= new Call__c();
        newCall1.ZTS_EU_Sub_Type__c = 'Account Call';
        newCall1.ZTS_EU_Start_Date_Time__c= DateTime.newInstance(2014,6,17,7,00,00);
        newCall1.ZTS_EU_Duration__c= '1 Hour';
        newCall1.ZTS_EU_Account__c= A1.id;

insert newCall1;

    
 Profile profiles=[Select Id From Profile Where Name='System Administrator'];
   
    User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='deneme@deneme.com';
    newuser.username='deneme1@deneme1.com';
    newuser.lastname='deneme';
    newuser.alias='deneme1';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';
    newuser.ZTS_EU_isCoacher__c=TRUE;    
    newuser.ZTS_EU_Market__c='United Kingdom';
    newuser.EmailEncodingKey='ISO-8859-1';
    
        
        
insert newuser;



        Task t1= new Task();
         t1.whatId = newCall.Id;
        t1.ownerId =newuser.id;
         
insert t1;

         
                 Task task= new Task();
        PageReference pageRef = Page.ZTS_EU_Task_Page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('callId',t1.whatId);  
       ApexPages.currentPage().getParameters().put('userId',t1.ownerId);  
         ApexPages.StandardController stdTask = new ApexPages.StandardController(task);                        
        ZTS_EU_Task_Controller testTask = new ZTS_EU_Task_Controller (stdTask );
        testTask.Save();
        testTask.Cancel();      
       
    }
}