/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchAccountOwnerUpdate_Test.cls
   Description: Test Class for Batch Apex ZTS_EU_BatchAccountOwnerUpdate.cls and ZTS_EU_BatchContactOwnerUpdate.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   14-10-2014   1.0     Srinivas               Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class ZTS_EU_BatchAccountOwnerUpdate_Test {
        Public static User u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        public static List<Account> accList =new List<Account>() ;
        public static List<Contact> contLst =new List<Contact>();
        public static AccountAndContactOwnerId__c custId = new AccountAndContactOwnerId__c() ;
    
    static void setUpData(User us){  
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        // TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_EU_Account_Trigger', ZTS_EU_Bypass__c = true);
        // insert triActivation;
        // TriggerActivation__c triActivation1 = new TriggerActivation__c(Name = 'ZTS_EU_Contact_Trigger', ZTS_EU_Bypass__c = true);
        // insert triActivation1;
        Primary_Contact_Inactive_Profile_List__c obj = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names',Profile__c = 'System Administrator');
        insert obj;
        
        Primary_Contact_Inactive_Profile_List__c obj1 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 1',Profile__c = 'System Administrator');
        insert obj1;
        
        Primary_Contact_Inactive_Profile_List__c obj2 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 2',Profile__c = 'System Administrator');
        insert obj2;
      
        AccountAndContactOwnerId__c acc1 = new AccountAndContactOwnerId__c(Name = 'Test User', Market__c = us.ZTS_EU_Market__c, OwnerId__c = us.id);
        insert acc1;
        
        MarketGeoMapping__c marktGeo = new MarketGeoMapping__c();
            marktGeo.Geo__c = 'APAC';
            marktGeo.Name = 'Australia';
            insert marktGeo;
            
            State_Country__c sc = new State_Country__c();         
            sc.name = 'AUD';
            sc.ZTS_EU_Country__c = 'Australia';
            sc.ZTS_EU_uniqueCOUNTY__c = 'Australia';
            
           Insert sc;
           Account acc;
           System.runAs(u)
           {
                acc = new Account();         
                acc.name = 'Test Account';
                acc.Type = 'Farm';
                acc.ZTS_EU_Account_Official_Name__c = 'test';
                acc.ZTS_EU_Sub_Type__c = 'Beef';
                acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
                acc.ZTS_EU_City__c = 'Test City';
                acc.ZTS_EU_Zip_Postal_Code__c = 'LD';  
                acc.ZTS_EU_Potential_Region__c = '1';              
                acc.ZTS_EU_Main_Phone__c='9876789876';
                acc.CurrencyIsoCode='AUD';
                acc.ZTS_EU_Market__c='Australia';
                acc.ZTS_EU_Country__c = 'Australia';
                acc.ZTS_EU_State_County__c=sc.Id;
                acc.ZTS_EU_District__c = 'DOGU';
                acc.ZTS_EU_VAT_Code__c = 'please add VAT no.';
                acc.ZTS_EU_Vetsave_ID__c='200';
                acc.ZTS_EU_Vetsave_HO_ID__c='56';
                insert acc;
            
        // accList = ZTS_EU_DataUtilityTest1.createAccountRecord(100);
        // insert accList; 
            
        
            for(Integer i=0;i<10;i++) {
                Contact con = new Contact();         
                con.lastname = 'Test Contact'+i;  
                con.firstname = 'first name';
                con.ZTS_EU_Market__c='Australia';            
                con.AccountId = acc.Id; 
                con.Title = 'Mr.';
                con.Salutation = '';
                contLst.add(con);
            }   
            
            insert contLst;
        }
    }
    
     static testMethod void testAccandContBatch(){
             
             u.ZTS_EU_Market__c = 'Australia';
             insert u;
             Test.StartTest();
             System.runAs(u){ 
             setUpData(u);    
             Test.StopTest();
             ZTS_EU_BatchAccountOwnerUpdate m = new ZTS_EU_BatchAccountOwnerUpdate();
            database.executeBatch(m); 
            
              
         }
         
         System.assertEquals(False, [SELECT IsBatchUpdated__c FROM Account LIMIT 1].IsBatchUpdated__c , 'Batch updated incorrectly');
         
    }
    
    static testmethod void testContactTitleBatch(){
        u.ZTS_EU_Market__c = 'Australia';
        insert u;
        Test.startTest();
        setUpData(u);
        test.stopTest();
        ZTS_EU_BatchContactTitleUpdate contBatch= new ZTS_EU_BatchContactTitleUpdate();
        database.executeBatch(contBatch);
        
    }
    
}