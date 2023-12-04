/*
Class Name	    : setIdevelopConfigBenchmarkDueDateTest
Description	    : Test Class created as part of TPDEV-529 for Code Coverage of class setIdevelopConfigBenchmarkDueDate. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 04-06-2023 
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer				      Date		    Description
-------------------------------------------------------------------------------------------------------------------------
01    Raut, Pranav Krushnarao     04-06-2023    Added methods to cover execute method in setIdevelopConfigBenchmarkDueDate Class
*/
@isTest
public class setIdevelopConfigBenchmarkDueDateTest {    
/*     
* @Description This method will setup the Test data      
* @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 04-06-2023 
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
        
        User coacheeUser = new User(firstname = 'Test', 
                                    lastName = 'Coachee', 
                                    email = uniqueName + '@testcoachee' + orgId + '.org', 
                                    Username = uniqueName + '@testcoachee' + orgId + '.org', 
                                    EmailEncodingKey = 'ISO-8859-1', 
                                    Alias = uniqueName.substring(18, 23), 
                                    TimeZoneSidKey = 'America/Los_Angeles', 
                                    LocaleSidKey = 'en_US', 
                                    LanguageLocaleKey = 'en_US' 
                                   );
        coacheeUser.ProfileId = adminProfileId;
        coacheeUser.ManagerId = coachUser.Id;
        coacheeUser.ZTS_EU_Market__c = 'Vietnam';
        coacheeUser.PIT_Coaching_Group__c = 'ABM'; 
        insert coacheeUser;
        
        //Permission Set Assignment
        insert new PermissionSetAssignment(AssigneeId = coacheeUser.id, PermissionSetId = idPermissionSet);
    }
    
    @isTest
    private static void executeSchedulerTest() {
        
        Map<Integer,String> mapMonthNumberToText = new Map<Integer,String>{01=>'January',02=>'February',03=>'March',04=>'April',05=>'May',06=>'June',07=>'July',08=>'August',09=>'September',10=>'October',11=>'November',12=>'December'};
        iDevelop_Configuration__c objIdev = new iDevelop_Configuration__c();            
        objIdev.Market__c = 'Vietnam';
        objIdev.Role__c = 'ABM';
        objIdev.Days_to_Complete__c = integer.valueOf('30');
        objIdev.Due_Date_Day__c = integer.valueOf(String.valueOf((System.today()+10).day()));
        objIdev.Due_Date_Month__c = mapMonthNumberToText.get(integer.valueOf(System.today().month()));
        insert objIdev;
        
        iDevelop_Configuration__c objIdev2 = new iDevelop_Configuration__c();            
        objIdev2.Market__c = 'United States';
        objIdev2.Role__c = '';
        objIdev2.Days_to_Complete__c = integer.valueOf('30');
        objIdev2.Due_Date_Day__c = integer.valueOf(String.valueOf((System.today()+1).day()));
        objIdev2.Due_Date_Month__c = mapMonthNumberToText.get(integer.valueOf(System.today().month()));       
        insert objIdev2;
        
        Test.startTest();
        new setIdevelopConfigBenchmarkDueDate().execute(null);
        Test.stopTest();
        System.assert(true, 'Scheduler executed successfully');
    }    
}