/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_BatchCreateMissingEvent_Test.cls
Description: Test Class for Batch Apex ZTS_EU_BatchCall.cls

Date         Version Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------       
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class ZTS_EU_BatchCreateMissingEvent_Test {
    /*static final Integer NUM_CONTACTS = 1;
    static final Integer NUM_ATTENDEES = 1;
    static final Integer NUM_COLLEAGUES = 1;
    static final Integer NUM_ACCOUNTS = 1;*/
    
    
    Public static User u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
    public static List<Account> accList =new List<Account>() ;
    public static List<Contact> contLst =new List<Contact>();
    public static AccountAndContactOwnerId__c custId = new AccountAndContactOwnerId__c() ;
    
    static void setUpData(User us){        
        
        AccountAndContactOwnerId__c acc2 = new AccountAndContactOwnerId__c(Name = 'Test User', Market__c = us.ZTS_EU_Market__c, OwnerId__c = us.id);
        insert acc2;
        
        State_Country__c sc = new State_Country__c();         
        sc.name = 'Test';
        sc.ZTS_EU_Country__c = system.label.Market_Value;
        sc.ZTS_EU_uniqueCOUNTY__c = system.label.Market_Value;
        Insert sc;
        
        
        Account acc = new Account();         
        acc.name = 'Test Account';
        acc.Type = 'Farm';
        acc.ZTS_EU_Account_Official_Name__c = 'test';
        acc.ZTS_EU_Sub_Type__c = 'Beef';
        acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        acc.ZTS_EU_City__c = 'Test City';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';  
        acc.ZTS_EU_Potential_Region__c = '1';              
        acc.ZTS_EU_Main_Phone__c='9876789876';
        acc.CurrencyIsoCode= system.label.Currency_Code;
        acc.ZTS_EU_Market__c= system.label.Market_Value;
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Country__c = system.label.Market_Value;
        acc.ZTS_EU_State_County__c=sc.Id;
        acc.ZTS_EU_District__c = 'DOGU';
        acc.ZTS_EU_VAT_Code__c = 'please add VAT no.';
        acc.ZTS_EU_Vetsave_ID__c='200';
        acc.ZTS_EU_Vetsave_HO_ID__c='56';
        insert acc;
        
        Call__c newcall = new Call__c();
        datetime dt = system.now();
        newCall.ZTS_EU_Account__c = acc.id;
        newCall.ZTS_EU_Start_Date_Time__c = dt;
        newCall.ZTS_EU_Sub_Type__c = 'Account Call';
        newCall.ZTS_EU_Local_Subtype__c = 'AVS AAP Activity';
        newCall.ZTS_EU_End_Date_Time__c = dt.addMinutes(30);
        newCall.ZTS_EU_Status__c = 'Planned';
        newCall.ZTS_EU_Call_Objectives__c = 'test';
        newCall.ZTS_EU_Duration__c = '0.5 Hour';
        newCall.ZTS_EU_Call_Owner__c = us.id;
        insert newcall;
        list<Event> lstEvent = [Select id,CallRecordId__c from Event];
        System.debug('lstEvent::'+lstEvent);
        for(Event ev : lstEvent){
            ev.CallRecordId__c = '';
        }
        update lstEvent;
        
        User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        insert u1;
        
        ZTS_EU_Colleague__c colleague = new ZTS_EU_Colleague__c();
        colleague.ZTS_EU_User__c = u1.Id;
        colleague.ZTS_EU_call__c = newcall.Id;
        insert colleague;
        
        
        // For US-
        
        
        /*State_Country__c sc2 = new State_Country__c();         
        sc2.name = 'Test2';
        sc2.ZTS_EU_Country__c = 'United States';
        sc2.ZTS_EU_uniqueCOUNTY__c = 'US';
        Insert sc2;
        
        
        Account acc3 = new Account();         
        acc3.name = 'Test2 Account';
        acc3.Type = 'Farm';
        acc3.ZTS_EU_Account_Official_Name__c = 'test2';
        acc3.ZTS_EU_Sub_Type__c = 'Beef';
        acc3.ZTS_EU_Address_Line_1__c = 'Test Address Line1 ';
        acc3.ZTS_EU_City__c = 'Test City2';
        acc3.ZTS_EU_Zip_Postal_Code__c = '12345';  
        acc3.ZTS_EU_Potential_Region__c = '1';              
        acc3.ZTS_EU_Main_Phone__c='9876789876';
        acc3.CurrencyIsoCode= 'USD';
        acc3.ZTS_EU_Market__c= 'United States';
        acc3.Practice_Management_Software__c = 'Other';
        acc3.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc3.ZTS_EU_Country__c = 'United States';
        acc3.ZTS_EU_State_County__c=sc2.Id;
        acc3.ZTS_EU_District__c = 'DOGU';
        acc3.ZTS_EU_VAT_Code__c = 'please add VAT no.';
        acc3.ZTS_EU_Vetsave_ID__c='200';
        acc3.ZTS_EU_Vetsave_HO_ID__c='56';
        insert acc3; */
        
        /*List<Account> testAccounts = new List<Account>();
        testAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(NUM_ACCOUNTS));
        insert testAccounts;

        
        
        List<Contact> testContacts = new List<Contact>();
        testContacts.addAll(ZTS_DataUtilityTest.createContactRecord(NUM_CONTACTS));
        for(Integer i=0; i<NUM_CONTACTS; i++) {
            testContacts[i].AccountId = TestAccounts[i].id;
            testContacts[i].ZTS_EU_Market__c = 'United States';
        }
        insert testContacts;
        
        
        Call__c newcall2 = new Call__c();
        datetime dt2 = system.now();
        newCall2.ZTS_EU_Account__c = testAccounts[0].Id;
        newCall2.ZTS_EU_Start_Date_Time__c = dt;
        newCall2.ZTS_EU_Sub_Type__c = 'Account Call';
        newCall2.ZTS_EU_Local_Subtype__c = 'AVS AAP Activity';
        newCall2.ZTS_EU_End_Date_Time__c = dt.addMinutes(30);
        newCall2.ZTS_EU_Status__c = 'Planned';
        newCall2.ZTS_EU_Call_Objectives__c = 'testing purpose 2';
        newCall2.ZTS_EU_Duration__c = '0.5 Hour';
        newcall2.ZTS_EU_Call_Owner__c = u.id;
        
        insert newcall2;
        
        
        List<ZTS_EU_Colleague__c> testColleagues = new List<ZTS_EU_Colleague__c>();
        for(Integer i=0; i<NUM_COLLEAGUES; i++) {
            ZTS_EU_Colleague__c colleagues = new ZTS_EU_Colleague__c();
            colleagues.ZTS_EU_Call__c = newcall2.Id;
            colleague.ZTS_EU_User__c=newcall2.ZTS_EU_Call_Owner__c;
            colleague.name=us.name;
            testColleagues.add(colleagues);
        }
        insert testColleagues;
        
        
        
        List<Attendee__c> testAttendees = new List<Attendee__c>();
        for(Integer i=0; i<NUM_ATTENDEES; i++) {
            Attendee__c attendee = new Attendee__c();
            attendee.Name = 'Test Attendee' + i; 
            attendee.ZTS_EU_Call__c = newcall2.Id;
            attendee.ZTS_EU_Contact__c = testContacts[i].Id;
            testAttendees.add(attendee);
        }
        insert testAttendees;
        */
        
        State_Country__c sc3 = new State_Country__c();         
        sc3.name = 'Test4';
        sc3.ZTS_EU_Country__c = system.label.Market_Value;
        sc3.ZTS_EU_uniqueCOUNTY__c = 'Global';
        Insert sc3;
        
        
        Account acc4 = new Account();         
        acc4.name = 'Test Account';
        acc4.Type = 'Farm';
        acc4.ZTS_EU_Account_Official_Name__c = 'test';
        acc4.ZTS_EU_Sub_Type__c = 'Beef';
        acc4.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        acc4.ZTS_EU_City__c = 'Test City';
        acc4.ZTS_EU_Zip_Postal_Code__c = '12345';  
        acc4.ZTS_EU_Potential_Region__c = '1';              
        acc4.ZTS_EU_Main_Phone__c='9876789876';
        acc4.CurrencyIsoCode= system.label.Currency_Code;
        acc4.ZTS_EU_Market__c= system.label.Market_Value;
        acc4.Practice_Management_Software__c = 'Other';
        acc4.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc4.ZTS_EU_Country__c = system.label.Market_Value;
        acc4.ZTS_EU_State_County__c=sc.Id;
        acc4.ZTS_EU_District__c = 'DOGU';
        acc4.ZTS_EU_VAT_Code__c = 'please add VAT no.';
        acc4.ZTS_EU_Vetsave_ID__c='200';
        acc4.ZTS_EU_Vetsave_HO_ID__c='56';
        insert acc4;
        
        Call__c newcall3 = new Call__c();
        datetime dt3 = system.now();
        newCall3.ZTS_EU_Account__c = acc4.id;
        newCall3.ZTS_EU_Start_Date_Time__c = null;
        newCall3.ZTS_EU_Sub_Type__c = 'Account Call';
        newCall3.ZTS_EU_Local_Subtype__c = 'AVS AAP Activity';
        newCall3.ZTS_EU_End_Date_Time__c = null;
        newCall3.ZTS_EU_Call_Objectives__c = 'test';
        newCall3.ZTS_EU_Duration__c = '0.5 Hour';
        
        insert newcall3;
        
        ZTS_EU_Colleague__c colleague3 = new ZTS_EU_Colleague__c();
        colleague3.ZTS_EU_User__c = u1.Id;
        colleague3.ZTS_EU_call__c = newcall3.Id;
        insert colleague3;
        
        
    }
    
    static testMethod void testAccCall(){ 
        //u.ZTS_EU_Market__c = system.label.Market_Value;
        insert u;

        System.runAs(u){ 
            setUpData(u);    
            Test.StartTest();
            ZTS_EU_BatchCreateMissingEventForCall b = new ZTS_EU_BatchCreateMissingEventForCall();
            database.executeBatch(b,40);
            
            SchedulableContext sc = null;
            ZTS_EU_SchedulerCreateMissingEvent objSch = new ZTS_EU_SchedulerCreateMissingEvent();
            objSch.execute(sc);
            
            List<Event> testEvents = [Select Id from Event];
            System.assert(testEvents.size()>0 ,'Failed to create Call Event' );
            Test.StopTest(); 
        }
    }
}