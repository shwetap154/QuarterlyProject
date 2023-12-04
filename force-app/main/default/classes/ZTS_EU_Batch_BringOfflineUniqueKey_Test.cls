/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_Batch_BringOfflineUniqueKey_Test.cls
   Description: Test Class for Batch Apex ZTS_EU_Batch_BringOfflineUniqueKey.cls and ZTS_EU_Schedulable_BringOfflineUniqueKey.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   17-12-2014   1.0     Shefali               Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class ZTS_EU_Batch_BringOfflineUniqueKey_Test{
    public static List<ZTS_EU_Bring_Offline__c > boList =new List<ZTS_EU_Bring_Offline__c>() ;
    public static List<Account> accList =new List<Account>() ;
    public static List<Contact> contLst =new List<Contact>();
    
    static void setUpData(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            User user = ZTS_EU_DataUtilityTest.createUtilityUser(true,' ',' ','Brazil');
            accList = ZTS_EU_DataUtilityTest1.createAccountRecord(10);
            insert accList;
            
            for(Integer i=0;i<5;i++){
                Contact con = new Contact();         
                con.lastname = 'Test Contact'+i;  
                con.firstname = 'first name';
                con.ZTS_EU_Market__c='United Kingdom';            
                con.AccountId = accList[0].Id;       
                contLst.add(con);
            }   
            insert contLst;
        
            ZTS_EU_Bring_Offline__c bOffTest1 = new ZTS_EU_Bring_Offline__c();
            bOffTest1.ZTS_EU_Account__c = accList[0].Id;
            boList.add(bOffTest1);
            
            ZTS_EU_Bring_Offline__c bOffTest2 = new ZTS_EU_Bring_Offline__c();
            bOffTest2.ZTS_EU_Contact__c = contLst[1].Id;
            boList.add(bOffTest2);
            
            insert boList;
        }
    }
    
    
    public static testMethod void testBringOffLineBatch(){
        setUpData();                                                                                                                                                                                                                   
        Test.StartTest();
            ZTS_EU_Schedulable_BringOfflineUniqueKey m = new ZTS_EU_Schedulable_BringOfflineUniqueKey();
            String sch = '0 0 * * * ?';
            String jobID = system.schedule('Test Job', sch, m); 
            
        Test.StopTest(); 
         
            
    }
}