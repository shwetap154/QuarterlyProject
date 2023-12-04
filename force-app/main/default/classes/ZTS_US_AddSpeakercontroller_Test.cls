/*******************************************************************************************************************************************
* File Name     :  ZTS_US_AddSpeakercontroller_test
* Description   :  Test class for USZTS_US_AddSpeakercontroller
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.

***************************************************************************************************************/


@isTest(SeeAllData=false) 
public class ZTS_US_AddSpeakercontroller_Test{


public static testMethod void ZTS_US_AddSpeakercontroller_NegativeTest() {
   Primary_Contact_Inactive_Profile_List__c setting = new Primary_Contact_Inactive_Profile_List__c();
   setting.Name = 'Profile Names';
   setting.Profile__c = 'Profile Names';
   Primary_Contact_Inactive_Profile_List__c setting1 = new Primary_Contact_Inactive_Profile_List__c();
   setting1.Name = 'Profile Names 1';
   setting1.Profile__c = 'Profile Names 1';
   Primary_Contact_Inactive_Profile_List__c setting2 = new Primary_Contact_Inactive_Profile_List__c();
   setting2.Name = 'Profile Names 2';
   setting2.Profile__c = 'Profile Names 2';
   insert new List<Primary_Contact_Inactive_Profile_List__c>{ setting, setting1, setting2};

        Test.startTest();
        //Creating the test data
        
     Profile profiles=[Select Id From Profile Where Name='US Small Animal Rep'];
        
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
    newuser.ZTS_EU_isCoacher__c=False;  
    newuser.EmailEncodingKey='ISO-8859-1';
    newuser.ZTS_EU_Market__c = 'United States';
    insert newuser;
        
        
      
       
       System.runas( newuser){
            
       
        List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
       Eve[0].ZTS_US_End_Date__c = system.today().addDays(2);
       insert Eve ;
       List<Contact> Con = ZTS_DataUtilityTest.createContactRecord(1);
        Con[0].ZTS_US_Speaker_Flag__c = true;
        Con[0].ZTS_EU_Market__c = 'United States';
        Insert Con;
        ZTS_EU_KOL__c kolSpeaker = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[0].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
        insert kolSpeaker;
        
       ZTS_US_Speaker__c USSpeaker = new  ZTS_US_Speaker__c();
        USSpeaker.ZTS_US_Speaker_Fee__c = 500;
        USSpeaker.ZTS_US_Contact__c=Con[0].id;
        USSpeaker.ZTS_US_Event__c= Eve[0].id;
        USSpeaker.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker.ZTS_US_Speaking_Date__c = system.today().addDays(1);
        USSpeaker.ZTS_US_Therapeutic_Area_Experience__c = '1';
        Insert USSpeaker;
        
       ZTS_US_Speaker_Fee__c Fee = new  ZTS_US_Speaker_Fee__c(ZTS_US_Contact__c = Con[0].id, ZTS_US_Speaker_Fee_Type__c = 'Dollars',ZTS_US_Amount__c = 500,ZTS_EU_Market__c='United States');
            insert Fee;
       
        
        
       List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
       PageReference pgRef = Page.ZTS_US_AddSpeaker;
       Test.setCurrentPageReference (pgRef);
       ApexPages.currentPage().getParameters().put('eventId',eve[0].id); 
           
    
       ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(USSpeaker);
       USZTS_US_AddSpeakercontroller Target = new USZTS_US_AddSpeakercontroller(controller);
      Target.speaker = USSpeaker;
      Pagereference p = Target.save();
       }
      test.stoptest();
         }




  public static testMethod void ZTS_US_AddSpeakercontroller_Test() {
        Test.startTest();
        //Creating the test data
       List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
       Eve[0].ZTS_US_End_Date__c = system.today().addDays(2);
       insert Eve ;
       List<Contact> Con = ZTS_DataUtilityTest.createContactRecord(1);
        Con[0].ZTS_US_Speaker_Flag__c = true;
        Con[0].ZTS_EU_Market__c = 'United States';
        Insert Con;
        ZTS_EU_KOL__c kolSpeaker = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[0].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
        insert kolSpeaker;
        system.debug(' speaker start date---'+Con[0].ZTS_US_Speaker_Start_Date__c);
        system.debug(' speaker start date---'+Con[0].ZTS_US_Speaker_EndDate_NotSpecified__c);
       ZTS_US_Speaker__c USSpeaker = new  ZTS_US_Speaker__c();
        USSpeaker.ZTS_US_Speaker_Fee__c = 500;
        USSpeaker.ZTS_US_Contact__c=Con[0].id;
        USSpeaker.ZTS_US_Event__c= Eve[0].id;
        USSpeaker.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker.ZTS_US_Speaking_Date__c = system.today().addDays(1);
        USSpeaker.ZTS_US_Therapeutic_Area_Experience__c = '1';
        
        Insert USSpeaker;
        
       List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
       PageReference pgRef = Page.ZTS_US_AddSpeaker;
       Test.setCurrentPageReference (pgRef);
       ApexPages.currentPage().getParameters().put('eventId',eve[0].id); 
           
    
       ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(USSpeaker);
       USZTS_US_AddSpeakercontroller Target = new USZTS_US_AddSpeakercontroller(controller);
      Target.speaker = USSpeaker;
      Pagereference p = Target.save();
       
      test.stoptest();
         }
   }