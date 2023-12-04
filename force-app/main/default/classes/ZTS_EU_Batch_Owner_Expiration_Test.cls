/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_Batch_Owner_Expiration_Test.cls
Description: Test Class for Batch Apex ZTS_EU_Batch_Owner_Expiration_Notice_Sch.cls

Date         Version Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
8-4-2015   1.0     Srinivas               Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData=false)
public class ZTS_EU_Batch_Owner_Expiration_Test {
    public static List<Account> accList =new List<Account>();
    public static List<Contract> contList =new List<Contract>();
    public static List<Contract> updatContList =new List<Contract>();
    public static List<Contract> insertContList =new List<Contract>();
    static void setUpData(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            accList = ZTS_EU_DataUtilityTest1.createAccountRecord(50);
            insert accList;
            for(Integer i=0;i<50;i++) {
                date dt=system.today().adddays(15);
                Contract contract1 =new Contract();
                contract1.Status ='Draft';
                contract1.ZTS_EU_Committed_Amount__c = 10000;
                contract1.ZTS_EU_Discount__c = 20.00;
                contract1.AccountId= accList[2].Id;
                //contract1.OwnerExpirationNotice_Checkbox__c=false;
                contract1.ZTS_EU_End_Date__c=dt;
                contract1.OwnerExpirationNotice='15';
                insertContList.add(contract1);       
            }
            database.insert(insertContList,false);
        }        
    }
    
    static testmethod void ContractOwnerBatch(){
        setUpData();  
        list<contract> contlst=[Select Id,ContractNumber,OwnerExpirationNotice,OwnerId, Owner.Name, Owner.email,ZTS_EU_End_Date__c From contract WHERE ZTS_EU_Market__c != 'United States'];
        
        Test.StartTest();
        //ZTS_EU_Batch_Owner_Expiration_Notice contractBatch= new ZTS_EU_Batch_Owner_Expiration_Notice();
        //Id batchId = Database.executeBatch(contractBatch); 
        
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ZTS_EU_Batch_Owner_Expiration_Notice_Sch() );
        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.StopTest();
    } 
}