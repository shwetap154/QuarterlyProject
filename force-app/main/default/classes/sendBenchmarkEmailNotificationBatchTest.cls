/*
Class Name	    : sendBenchmarkEmailNotificationBatchTest
Description	    : Test Class created as part of TPDEV-529 for Code Coverage of class sendBenchmarkEmailNotificationBatch. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 04-12-2023 
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer				      Date		    Description
-------------------------------------------------------------------------------------------------------------------------
01    Raut, Pranav Krushnarao     04-12-2023    Added methods to cover the batch Class sendBenchmarkEmailNotificationBatch.
02    Padma, Nerella              10-10-2023    TPDEV-2082 - Added userIdsSet to minimize the users to run the test class and to handle null pointer exception.
*/
@isTest
public class sendBenchmarkEmailNotificationBatchTest {
    
/*     
* @Description This method will setup the Test data      
* @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 04-12-2023 
*/
    @testSetup static void setupData() {
        
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id idPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'iDevelop_Coachee'].Id;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User coachUser = new User(firstname = 'Test', 
                                  lastName = 'Coach', 
                                  email = 'praraut@deloitte.com',
                                  //email = uniqueName + '@test' + orgId + '.org', 
                                  Username = uniqueName + '@test' + orgId + '.org', 
                                  EmailEncodingKey = 'ISO-8859-1', 
                                  Alias = uniqueName.substring(18, 23), 
                                  TimeZoneSidKey = 'America/Los_Angeles', 
                                  LocaleSidKey = 'en_US', 
                                  LanguageLocaleKey = 'en_US' 
                                 );
        //coachUser.Email = ;
        coachUser.ProfileId = adminProfileId;
        insert coachUser;
        
        List<User> lstCoacheeUser = new List<User>();
        for(integer i=0; i<4; i++){            
            User coacheeUser = new User(firstname = 'Test', 
                                        lastName = 'Coachee'+i, 
                                        email = uniqueName + '@testcoachee'+i + orgId + '.org', 
                                        Username = uniqueName + '@testcoachee'+i + orgId + '.org', 
                                        EmailEncodingKey = 'ISO-8859-1', 
                                        Alias = uniqueName.substring(18, 23), 
                                        TimeZoneSidKey = 'America/Los_Angeles', 
                                        LocaleSidKey = 'en_US', 
                                        LanguageLocaleKey = 'en_US' 
                                       );
            coacheeUser.ProfileId = adminProfileId;
            coacheeUser.ManagerId = coachUser.Id;
            coacheeUser.Next_Coach_Benchmark_Due_Date__c = null;

            if(i==0){
                coacheeUser.ZTS_EU_Market__c = 'Vietnam';
                coacheeUser.PIT_Coaching_Group__c = 'ABM';                
            }
            if(i==1){
                coacheeUser.ZTS_EU_Market__c = 'Australia';
                coacheeUser.PIT_Coaching_Group__c = 'CVO';                
            }
            if(i==2){
                coacheeUser.ZTS_EU_Market__c = 'Ukraine';
                coacheeUser.PIT_Coaching_Group__c = 'TBM';                
            }
            if(i==3){
                coacheeUser.ZTS_EU_Market__c = 'Egypt';
                coacheeUser.PIT_Coaching_Group__c = 'ABM';                
            }
            lstCoacheeUser.add(coacheeUser); 
        }
        insert lstCoacheeUser;
        
        //Permission Set Assignment
        List<PermissionSetAssignment> lstPermissionSetAssignment = new List<PermissionSetAssignment>();
        for(User objUser : lstCoacheeUser){
            PermissionSetAssignment objPermsnSetAssigmnt = new PermissionSetAssignment();
            objPermsnSetAssigmnt.AssigneeId = objUser.Id;
            objPermsnSetAssigmnt.PermissionSetId = idPermissionSet;
            lstPermissionSetAssignment.add(objPermsnSetAssigmnt);
            //insert new PermissionSetAssignment(AssigneeId = coacheeUser.id, PermissionSetId = idPermissionSet);
        }
        insert lstPermissionSetAssignment;     
    }
    
    @isTest
    private static void BenchmarkEmailNotificationBatchJobTest() {
                
        Map<Integer,String> mapMonthNumberToText = new Map<Integer,String>{01=>'January',02=>'February',03=>'March',04=>'April',05=>'May',06=>'June',07=>'July',08=>'August',09=>'September',10=>'October',11=>'November',12=>'December'};
        Set<String> setMarket = new Set<String>{'Vietnam','United States','Australia','Ukraine','Egypt'};
        Map<String,iDevelop_Configuration__c> mapMarktRoleIdevConfig = new Map<String,iDevelop_Configuration__c>(); 
        Map<String,Date> mapIdevMarketRoleBenchDueDate = new Map<String,Date>();
        Map<String, iDevelop_Configuration__c> mapIdevConfigWithNoRole = new Map<String, iDevelop_Configuration__c>(); 
        Map<String,Date> mapIdevWithNoRoleBenchDueDate = new Map<String,Date>();
        List<User> userlist = [Select Id, Name from user where Firstname = 'test'];
        set<Id> userId =  new Set<Id>();
        for(User user: userlist){
            sendBenchmarkEmailNotificationBatch.testUserIdsSet.add(user.Id);
        }
        iDevelop_Configuration__c objIdev = new iDevelop_Configuration__c();            
        objIdev.Market__c = 'Vietnam';
        objIdev.Role__c = 'ABM';
        objIdev.Days_to_Complete__c = integer.valueOf('30');
        objIdev.Due_Date_Day__c = integer.valueOf(String.valueOf((System.today()-7).day()));
        objIdev.Due_Date_Month__c = mapMonthNumberToText.get(integer.valueOf((System.today()-7).month()));
        insert objIdev;
        Date objIdevBenchDueDate = date.newinstance(integer.valueOf(System.today().year()), integer.valueOf(System.today().month()) , integer.valueOf(String.valueOf((System.today()-7).day())));
        mapMarktRoleIdevConfig.put((objIdev.Market__c+objIdev.Role__c),objIdev);
        mapIdevMarketRoleBenchDueDate.put((objIdev.Market__c+objIdev.Role__c), objIdevBenchDueDate);
        
        iDevelop_Configuration__c objIdev2 = new iDevelop_Configuration__c();            
        objIdev2.Market__c = 'Australia';
        objIdev2.Role__c = 'CVO';
        objIdev2.Days_to_Complete__c = integer.valueOf('30');
        objIdev2.Due_Date_Day__c = integer.valueOf(String.valueOf((System.today()+1).day()));
        objIdev2.Due_Date_Month__c = mapMonthNumberToText.get(integer.valueOf(System.today().month()));
        insert objIdev2;
        Date objIdev2BenchDueDate = date.newinstance(integer.valueOf(System.today().year()), integer.valueOf(System.today().month()) , integer.valueOf(String.valueOf((System.today()+1).day())));
        mapMarktRoleIdevConfig.put((objIdev2.Market__c+objIdev2.Role__c),objIdev2);
        mapIdevMarketRoleBenchDueDate.put((objIdev2.Market__c+objIdev2.Role__c), objIdev2BenchDueDate);
        
        iDevelop_Configuration__c objIdev3 = new iDevelop_Configuration__c();            
        objIdev3.Market__c = 'Ukraine';
        objIdev3.Role__c = 'TBM';
        objIdev3.Days_to_Complete__c = integer.valueOf('30');
        objIdev3.Due_Date_Day__c = integer.valueOf(String.valueOf((System.today()+10).day()));
        objIdev3.Due_Date_Month__c = mapMonthNumberToText.get(integer.valueOf(System.today().month()));
        insert objIdev3;
        Date objIdev3BenchDueDate = date.newinstance(integer.valueOf(System.today().year()), integer.valueOf(System.today().month()) , integer.valueOf(String.valueOf((System.today()+10).day())));
        mapMarktRoleIdevConfig.put((objIdev3.Market__c+objIdev3.Role__c),objIdev3);
        mapIdevMarketRoleBenchDueDate.put((objIdev3.Market__c+objIdev3.Role__c), objIdev3BenchDueDate);
        
        iDevelop_Configuration__c objIdev4 = new iDevelop_Configuration__c();            
        objIdev4.Market__c = 'Egypt';
        objIdev4.Role__c = 'ABM';
        objIdev4.Days_to_Complete__c = integer.valueOf('15');
        objIdev4.Due_Date_Day__c = integer.valueOf(String.valueOf((System.today()+15).day()));
        objIdev4.Due_Date_Month__c = mapMonthNumberToText.get(integer.valueOf((System.today()+15).month()));
        insert objIdev4;
        Date objIdev4BenchDueDate = date.newinstance(integer.valueOf(System.today().year()), integer.valueOf((System.today()+15).month()) , integer.valueOf(String.valueOf((System.today()+15).day())));
        mapMarktRoleIdevConfig.put((objIdev4.Market__c+objIdev4.Role__c),objIdev4);
        mapIdevMarketRoleBenchDueDate.put((objIdev4.Market__c+objIdev4.Role__c), objIdev4BenchDueDate);
        
        iDevelop_Configuration__c objIdev5 = new iDevelop_Configuration__c();                    
        objIdev5.Market__c = 'United States';
        objIdev5.Days_to_Complete__c = integer.valueOf('5');
        objIdev5.Due_Date_Day__c = integer.valueOf(String.valueOf((System.today()+5).day()));
        objIdev5.Due_Date_Month__c = mapMonthNumberToText.get(integer.valueOf(System.today().month()));
        insert objIdev5;
        Date objIdev5BenchDueDate = date.newinstance(integer.valueOf(System.today().year()), integer.valueOf(System.today().month()) , integer.valueOf(String.valueOf((System.today()+5).day())));
        mapIdevConfigWithNoRole.put(objIdev5.Market__c, objIdev5);
        mapIdevWithNoRoleBenchDueDate.put(objIdev5.Market__c,objIdev5BenchDueDate);
        
        
        Test.startTest();
        sendBenchmarkEmailNotificationBatch objBatchClass = new sendBenchmarkEmailNotificationBatch(setMarket,mapMarktRoleIdevConfig, mapIdevMarketRoleBenchDueDate, mapIdevConfigWithNoRole, mapIdevWithNoRoleBenchDueDate);
        Database.executeBatch(objBatchClass); 
        Test.stopTest();
        
        System.assert(true, 'Batch Job executed successfully');
        
        List<User> lstuser = [SELECT Id,ZTS_EU_Market__c,PIT_Coaching_Group__c,firstname,Next_Coach_Benchmark_Due_Date__c FROM User WHERE (ZTS_EU_Market__c = 'Vietnam' AND PIT_Coaching_Group__c = 'ABM' AND firstname = 'Test') Limit 1];      
        System.assertEquals(mapIdevMarketRoleBenchDueDate.get(lstuser[0].ZTS_EU_Market__c+lstuser[0].PIT_Coaching_Group__c), lstuser[0].Next_Coach_Benchmark_Due_Date__c);
        
        List<User> lstuser1 = [SELECT Id,ZTS_EU_Market__c,PIT_Coaching_Group__c,firstname,Next_Coach_Benchmark_Due_Date__c FROM User WHERE (ZTS_EU_Market__c = 'Australia' AND PIT_Coaching_Group__c = 'CVO' AND firstname = 'Test') Limit 1];      
        System.assertEquals(mapIdevMarketRoleBenchDueDate.get(lstuser1[0].ZTS_EU_Market__c+lstuser1[0].PIT_Coaching_Group__c), lstuser1[0].Next_Coach_Benchmark_Due_Date__c);
        
        List<User> lstuser2 = [SELECT Id,ZTS_EU_Market__c,PIT_Coaching_Group__c,firstname,Next_Coach_Benchmark_Due_Date__c FROM User WHERE (ZTS_EU_Market__c = 'Ukraine' AND PIT_Coaching_Group__c = 'TBM' AND firstname = 'Test') Limit 1];      
        System.assertEquals(mapIdevMarketRoleBenchDueDate.get(lstuser2[0].ZTS_EU_Market__c+lstuser2[0].PIT_Coaching_Group__c), lstuser2[0].Next_Coach_Benchmark_Due_Date__c);
        
        List<User> lstuser3 = [SELECT Id,ZTS_EU_Market__c,PIT_Coaching_Group__c,firstname,Next_Coach_Benchmark_Due_Date__c FROM User WHERE (ZTS_EU_Market__c = 'Egypt' AND PIT_Coaching_Group__c = 'ABM' AND firstname = 'Test') Limit 1];      
        System.assertEquals(mapIdevMarketRoleBenchDueDate.get(lstuser3[0].ZTS_EU_Market__c+lstuser3[0].PIT_Coaching_Group__c), lstuser3[0].Next_Coach_Benchmark_Due_Date__c);
     } 
}