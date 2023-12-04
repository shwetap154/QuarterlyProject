@isTest
private with sharing class cse_caseSendtoPVWorksControllerTest {
    
       @testVisible static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
        static final String SYNC_UNAPPROVED = 'Unapproved';

    @isTest
    private static void testMethod1(){
                String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        
        Test.startTest();
                 Case testCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'VMIPS Test Case',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        
        insert testCase;
        
         //Insert Contact
		List<contact> contactList = new  List<contact>();
        contactList.add(new Contact(LastName = 'Last1', 
                                    FirstName = 'First1',
                                    ZTS_US_Job_Function__c = 'CFO', 
                                    Interface_Email__c = 'testcolleague@test.com', 
                                    ZTS_US_Profession__c= 'Consultant'));   
        contactList.add(new Contact(LastName = 'Last2', 
                                    FirstName = 'First2',
                                    ZTS_US_Job_Function__c = 'CFO', 
                                    ZTS_US_Profession__c= 'Consultant'));
        insert contactList;
      
        //Insert Case Contact		
        Case_Contact__c caseContact1 = new Case_Contact__c(Contact__c = contactList[0].Id, 
                                                           ZTS_US_Contact_Role__c = 'Attending Vet', 
                                                           ZTS_US_Primary_Reporter__c = true,
                                                           Case__c=testCase.Id);
        Case_Contact__c caseContact2 = new Case_Contact__c(Contact__c = contactList[1].Id, 
                                                           ZTS_US_Contact_Role__c = 'Pharmacist',
                                                           Case__c=testCase.Id);
        Case_Contact__c[] caseContactList = new Case_Contact__c[]{caseContact1,caseContact2};
        insert caseContactList;
      Test.stopTest();
      String primaryReportEmail  =  cse_caseSendtoPVWorksController.getPrimaryReporterEmail(testCase.id);
      Case_Contact__c caseContact = [ SELECT Id, ZTS_US_Primary_Reporter__c, Email__c FROM Case_Contact__c WHERE Case__c = :testCase.id and ZTS_US_Primary_Reporter__c = true limit 1 ]; 
        
      System.assertEquals(caseContact.email__c,primaryReportEmail );
            

    }
    
     @isTest
    private static void testMethod2(){
                String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        
        Test.startTest();
                 Case testCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'VMIPS Test Case',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        
        insert testCase;
        
         //Insert Contact
		List<contact> contactList = new  List<contact>();
        contactList.add(new Contact(LastName = 'Last1', 
                                    FirstName = 'First1',
                                    ZTS_US_Job_Function__c = 'CFO', 
                                  //  Interface_Email__c = 'testcolleague@test.com', 
                                    ZTS_US_Profession__c= 'Consultant'));   
        contactList.add(new Contact(LastName = 'Last2', 
                                    FirstName = 'First2',
                                    ZTS_US_Job_Function__c = 'CFO', 
                                    ZTS_US_Profession__c= 'Consultant'));
        insert contactList;
      
        //Insert Case Contact		
        Case_Contact__c caseContact1 = new Case_Contact__c(Contact__c = contactList[0].Id, 
                                                           ZTS_US_Contact_Role__c = 'Attending Vet', 
                                                           ZTS_US_Primary_Reporter__c = true,
                                                           Case__c=testCase.Id);
        Case_Contact__c caseContact2 = new Case_Contact__c(Contact__c = contactList[1].Id, 
                                                           ZTS_US_Contact_Role__c = 'Pharmacist',
                                                           Case__c=testCase.Id);
        Case_Contact__c[] caseContactList = new Case_Contact__c[]{caseContact1,caseContact2};
        insert caseContactList;
      Test.stopTest();
      String primaryReportEmail  =  cse_caseSendtoPVWorksController.getPrimaryReporterEmail(testCase.id);
      Case_Contact__c caseContact = [ SELECT Id, ZTS_US_Primary_Reporter__c, Email__c FROM Case_Contact__c WHERE Case__c = :testCase.id and ZTS_US_Primary_Reporter__c = true limit 1 ]; 
        
      System.assertEquals(caseContact.email__c,primaryReportEmail );
        
        //Creating sales rep user for covering Catch block
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('US Small Animal Rep', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr){
            try{
                  String primaryReportEmail2  =  cse_caseSendtoPVWorksController.getPrimaryReporterEmail(testCase.id);
            }catch(Exception e){
                ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'cse_caseSendtoPVWorksControllerTest-testMethod2');
            }
           

        }

    } 
    
  


}