/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchCall_Test.cls
   Description: Test Class for Batch Apex ZTS_EU_BatchCall.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   29-03-2016   1.0     Priya               Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class ZTS_EU_BatchCall_Test {
        Public static User u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        public static List<Account> accList =new List<Account>() ;
        public static List<Contact> contLst =new List<Contact>();
        public static AccountAndContactOwnerId__c custId = new AccountAndContactOwnerId__c() ;
    
    static void setUpData(User us){        
        
        AccountAndContactOwnerId__c acc1 = new AccountAndContactOwnerId__c(Name = 'Test User', Market__c = us.ZTS_EU_Market__c, OwnerId__c = us.id);
        insert acc1;
        
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
        
        List<ZTS_EU_Colleague__c> testColleagues = ZTS_EU_DataUtilityTest1.createColleague(1);
        insert testColleagues;
    }
    
    static testMethod void testAccCall(){ 
             u.ZTS_EU_Market__c = system.label.Market_Value;
             insert u;
             System.runAs(u){ 
             setUpData(u);    
             Test.StartTest();
             ZTS_EU_BatchCall b = new ZTS_EU_BatchCall();
             database.executeBatch(b);
             List<Event> testEvents = [Select Id from Event];
             System.assert(testEvents.size()>0 ,'Failed to create Call Event' );
             Test.StopTest(); 
         }
    }
}