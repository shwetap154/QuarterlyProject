/****************************************************************************************************************************************** 
 * Trigger Name : CSE_MilestoneTimeCalculatorTest
 * Description  : All  Unit test Logic for CSE_MilestoneTimeCalculator.
 * Created By   : Slalom(Madhu Goriparthi) 
 * Created Date : 8th August, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Madhu Goriparthi			   08/08/2021			  Created
 * Venkat Joginapally          08/27/2021             Updated   
 * Chelsea Paice	           05/24/2022             Updated 
 * Ethan Hirsch	               11/07/2022             Updated tests to calculate using Business Hours
 * Ethan Hirsch	               11/08/2022             Retrieve Business Hours using Custom Metadata. 
 *                                                    Add a test to verify Default Business Hours are used as a fallback 
 *                                                    when no mapping exists.
*****************************************************************************************************************************************/

@isTest
private class CSE_MilestoneTimeCalculatorTest {
    //pull information from the Org that will be used by all of the test classes
    static final String REC_TYPE_DEVELOPER_NAME_CASE = 'Animal_Support';
    static final String ANIMAL_COMPLAINT_CASE_TYPE = 'Animal Complaint'; 

    @testSetup static void caseCreate() {      
        Account testAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
        insert testAccount;

        SlaProcess slaProcess = [
            Select Id 
            FROM SlaProcess 
            Where Name='CSE- Turn Around Time' 
            AND IsActive = true 
            AND IsVersionDefault = true
            LIMIT 1];
            
        Entitlement testEntitlement = (Entitlement)SL_TestDataFactory.createSObject(
            new Entitlement(
                Name='Test Entilement',
                AccountId=testAccount.Id,
                SlaProcessId = slaProcess.Id), true);

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(REC_TYPE_DEVELOPER_NAME_CASE).getRecordTypeId();
         // Create case data.
         // Typically, the milestone type is related to the case, 
         // but for simplicity, the case is created separately for this test.
         //List storing the cases to be inserted
         List<Case> testCaseList = new List<Case>();
        //NOTE: 3 day and 7 day & 10 day case can all use the same case to test as the criteria are done in the entitlement process and not the apex class
            Case productTestCase = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
            Subject = 'Test Case for Milestone Calculator Product Related Milestones',
            Type = ANIMAL_COMPLAINT_CASE_TYPE,
            Origin = 'Phone',
            Priority = 'Medium',
            Status = 'Open',
            ZTS_US_First_Received_Date__c=Date.today(),
            EntitlementId = testEntitlement.Id),false);
            testCaseList.add(productTestCase);
        //10 day case for ZTS_US_Date_First_Valid__c in the past
        Case productTestCasePastValidDate = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
            Subject = 'Test Case for Milestone Calculator Product Related Milestones Past Date First Valid',
            Type = ANIMAL_COMPLAINT_CASE_TYPE,
            Origin = 'Phone',
            Priority = 'Medium',
            Status = 'Open',
            Case_Updated_Date__c = system.now(),
			ZTS_US_Latest_Follow_Up_Date__c = Date.today(), //cass-944
            ZTS_US_First_Received_Date__c = (Date.today() - 3),                                                                                    
            ZTS_US_Date_First_Valid__c=(Date.today() - 3),
            EntitlementId = testEntitlement.Id),false);
         testCaseList.add(productTestCasePastValidDate);
         //3 day alert case
         // Will create Milestone
         Case alertTestCase = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
            Subject = 'Test Case for Milestone Calculator Alert Related Milestones',
            Type = ANIMAL_COMPLAINT_CASE_TYPE,
            Origin = 'Phone',
            Priority = 'Medium',
            Status = 'Open',
            ZTS_US_Reportability__c = '3-day alert',
            EntitlementId = testEntitlement.Id
        ),false);
         testCaseList.add(alertTestCase);
         //10 day reportability case
         // Will Create Milestone
         Case reportTestCase = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
            Subject = 'Test Case for Milestone Calculator Report Related Milestones',
            Type = ANIMAL_COMPLAINT_CASE_TYPE,
            Origin = 'Phone',
            Priority = 'Medium',
            Status = 'Open',
            ZTS_US_Reportability__c = '15-day report',
            ZTS_US_Date_First_Valid__c = Date.today(),
            EntitlementId = testEntitlement.Id
        ),false);
         testCaseList.add(reportTestCase);
         //negative case
         // Will create CSE - 10 Day Alert (Reportability) Milestone
         Case negativeTestCase = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
            Subject = 'Test Case for Milestone Calculator Negative Test Case',
            Type = ANIMAL_COMPLAINT_CASE_TYPE,
            Origin = 'Phone',
            Priority = 'Medium',
            Status = 'Open',
            ZTS_US_Reportability__c = '15-day report',
            ZTS_US_First_Received_Date__c = Date.today().addDays(-21),
            ZTS_US_Date_First_Valid__c = Date.today().addDays(-20),
            EntitlementId = testEntitlement.Id
            ),false);
            testCaseList.add(negativeTestCase);
        // Will create CSE - 10 Day Alert (Reportability) Milestone
        Case splitTestCase = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
            Subject = 'Test Case for Milestone Calculator Split Test Case',
            Type = ANIMAL_COMPLAINT_CASE_TYPE,
            Origin = 'Phone',
            Priority = 'Medium',
            Status = 'Open',
            ZTS_US_Reportability__c = '15-day report',
            ZTS_US_First_Received_Date__c = Date.today().addDays(-5),
            ZTS_US_Date_First_Valid__c = Date.today().addDays(-5),
            EntitlementId = testEntitlement.Id
            ),false);
            testCaseList.add(splitTestCase);
        Case splitTestCaseOverWeekend = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
            Subject = 'Test Case for Milestone Calculator Split Test Case Over Weekend',
            Type = ANIMAL_COMPLAINT_CASE_TYPE,
            Origin = 'Phone',
            Priority = 'Medium',
            Status = 'Open',
            ZTS_US_First_Received_Date__c = Date.newInstance(2022, 11, 4),
            EntitlementId = testEntitlement.Id
            ),false);
            testCaseList.add(splitTestCaseOverWeekend);
         insert testCaseList;
        }

    @isTest
    private static void threeDayProductCalculatorTest(){
        system.debug('starting threeDayProductCalculatorTest');
         //get the specific Milestone for the case
         MilestoneType testMilestone = [SELECT Id, Name FROM MilestoneType WHERE Name='CSE - 3 Day Case Product' LIMIT 1];
         //pull the relevant case for use inside this method
         Case testCase = [SELECT Id, ZTS_US_First_Received_Date__c FROM Case Where Subject = 'Test Case for Milestone Calculator Product Related Milestones' LIMIT 1];

         //Calculate the number of minutes using the MilestoneCalculator
         system.debug('actualTriggerTime run');
         Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime(testCase.Id, testMilestone.Id);

         //complete the same calculations inside of this test method
         system.debug('expectedTriggerTime run');
         Datetime dFVdt = convertDateFirstValid(testCase.ZTS_US_First_Received_Date__c);
         //3 business days, number is 2 since first day is included
         Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,2,null,
            retrieveBusinessHoursNameForMilestoneType(testMilestone.Name));

         //assert the equality between the what the calculator returns and what is returned by the calculations within the test class
         System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 3 business days from DateFirstReceived, with DateFirstReceived counting as day 1');
     }
    @isTest
    private static void sevenDayProductCalculatorTest(){
        system.debug('CP starting 7 day test');
        MilestoneType testMilestone = [SELECT Id, Name FROM MilestoneType WHERE Name='CSE - 7 Day Case Product' LIMIT 1];

        Case testCase = [SELECT Id, ZTS_US_First_Received_Date__c FROM Case Where Subject = 'Test Case for Milestone Calculator Product Related Milestones' LIMIT 1];
        
        system.debug('test case dfv: ' + testCase.ZTS_US_First_Received_Date__c);
     
         //Calculate the number of minutes using the MilestoneCalculator
         system.debug('7 day actual');
         Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime(testCase.Id, testMilestone.Id);

         //complete the calculations inside the test class
         system.debug('7 day expected');
         Datetime dFVdt = convertDateFirstValid(testCase.ZTS_US_First_Received_Date__c);
         system.debug('dFVdt: ' + String.valueOf(dFVdt));
         //7 calendar days, number is 6 since first day is included
         Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,6,null,
            retrieveBusinessHoursNameForMilestoneType(testMilestone.Name));

         //assert the equality between the what the calculator returns and what is returned by the calculations within the test class
         System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 7 calendar days from DateFirstReceived, with DateFirstReceived counting as day 1');
     }
    @isTest
    private static void tenDayProductCalculatorTest(){
        MilestoneType testMilestone = [SELECT Id, Name FROM MilestoneType WHERE Name='CSE - 10 Days Case Product' LIMIT 1];

        Case testCase = [SELECT Id, ZTS_US_First_Received_Date__c FROM Case Where Subject = 'Test Case for Milestone Calculator Product Related Milestones' LIMIT 1];
         
        //Calculate the number of minutes using the MilestoneCalculator
         Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime(testCase.Id, testMilestone.Id);

         //complete the calculations inside the test class
         Datetime dFVdt = convertDateFirstValid(testCase.ZTS_US_First_Received_Date__c);
         //10 calendar days, number is 9 since first day is included
         Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,9,null,
            retrieveBusinessHoursNameForMilestoneType(testMilestone.Name));


         //assert the equality between the what the calculator returns and what is returned by the calculations within the test class
         System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 10 calendar days from DateFirstReceived, with DateFirstReceived counting as day 1');
     }
    
    @isTest
    private static void tenDayPastDateFirstValidProductCalculatorTest(){
        MilestoneType testMilestone = [SELECT Id, Name FROM MilestoneType WHERE Name='CSE - 10 Days Case Product' LIMIT 1];

        //Case testCase = [SELECT Id, Case_Updated_Date__c FROM Case Where Subject = 'Test Case for Milestone Calculator Product Related Milestones Past Date First Valid' LIMIT 1];
        Case testCase = [SELECT Id, ZTS_US_Latest_Follow_Up_Date__c FROM Case Where Subject = 'Test Case for Milestone Calculator Product Related Milestones Past Date First Valid' LIMIT 1]; //cass-944
         
        //Calculate the number of minutes using the MilestoneCalculator
         Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime(testCase.Id, testMilestone.Id);
        
         //complete the calculations inside the test class
        // Datetime dFVdt = convertDateFirstValid(date.newInstance(testCase.Case_Updated_Date__c.year(), testCase.Case_Updated_Date__c.month(), testCase.Case_Updated_Date__c.day()));
       	 Datetime dFVdt = convertDateFirstValid(date.newInstance(testCase.ZTS_US_Latest_Follow_Up_Date__c.year(), testCase.ZTS_US_Latest_Follow_Up_Date__c.month(), testCase.ZTS_US_Latest_Follow_Up_Date__c.day()));//Cass-944
         //10 calendar days, number is 9 since first day is included
         Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,9,null,
            retrieveBusinessHoursNameForMilestoneType(testMilestone.Name));

         //assert the equality between the what the calculator returns and what is returned by the calculations within the test class
         System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 10 calendar days from CaseUpdatedDate, with CaseUpdatedDate counting as day 1');
     }
     @isTest
     private static void alertCalculatorTest(){
        MilestoneType testMilestone = [SELECT Id, Name FROM MilestoneType WHERE Name='CSE - 3 Day Alert' LIMIT 1];

          Case testCase = [SELECT Id, CreatedDate FROM Case Where Subject = 'Test Case for Milestone Calculator Alert Related Milestones' LIMIT 1];
          

          //Calculate the number of minutes using the MilestoneCalculator
          Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime(testCase.Id, testMilestone.Id);
 
          Datetime dFVdt = convertDateFirstValid(Date.newInstance(testCase.CreatedDate.year(),testCase.CreatedDate.month(),testCase.CreatedDate.day()));
          //1 business day, number is 0 since first day is included
          Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,0,null,
            retrieveBusinessHoursNameForMilestoneType(testMilestone.Name));

          //if test is run later in the day, it's possible that the expectedTriggerTime will be 1 minute, since the end of work hours milestone may be in the past
          //adding logic to handle that
          if (expectedTriggerTime < 0) {
            expectedTriggerTime = 1;
          }
 
          //assert the equality between the what the calculator returns and what is returned by the calculations within the test class
          System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 1 business day from CreatedDate, with CreatedDate counting as day 1');
      }
    @isTest
    private static void tenDayReportabilityCalculatorTest(){
        MilestoneType testMilestone = [ SELECT Id, Name FROM MilestoneType WHERE Name = 'CSE- 10 Day Alert (Reportability)' LIMIT 1 ];

        Case testCase = [ SELECT Id, ZTS_US_Date_First_Valid__c FROM Case Where Subject = 'Test Case for Milestone Calculator Report Related Milestones' LIMIT 1 ];
        
        //complete the calculations inside the test class
        Datetime now = Datetime.now();

        //Calculate the number of minutes using the MilestoneCalculator
        Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime( testCase.Id, testMilestone.Id );
        Datetime dFVdt = convertDateFirstValid(testCase.ZTS_US_Date_First_Valid__c);
        //10 calendar days, number is 9 since first day is included
        Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,9,null,
            retrieveBusinessHoursNameForMilestoneType(testMilestone.Name));

        //assert the equality between the what the calculator returns and what is returned by the calculations within the test class
        System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 10 business days from the time reportability field is set');
    }

    @isTest
    private static void negativeCalculatorTest(){
         MilestoneType testMilestone = [SELECT Id, Name FROM MilestoneType WHERE Name='CSE - 10 Days Case Product' LIMIT 1];

         Case testCase = [SELECT Id FROM Case Where Subject = 'Test Case for Milestone Calculator Negative Test Case' LIMIT 1];

         Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime(testCase.Id, testMilestone.Id);

         //test to see if it returns the correct value for negative cases
         System.assertEquals(1, actualTriggerTime, 'Expected Result is 1 minute when none of the criteria is passed');
     }

     //testing when the milestone starts in the past, but the due date is in the future
     // This test will use the Existing Milestone for Business Hours
     @isTest
    private static void splitCalculatorTest(){
         
        MilestoneType testMilestone = [ SELECT Id, Name FROM MilestoneType WHERE Name = 'CSE- 10 Day Alert (Reportability)' LIMIT 1 ];

         Case testCase = [SELECT Id,ZTS_US_Date_First_Valid__c FROM Case Where Subject = 'Test Case for Milestone Calculator Split Test Case' LIMIT 1];

         //Calculate the number of minutes using the MilestoneCalculator
        Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime( testCase.Id, testMilestone.Id );
        Datetime dFVdt = convertDateFirstValid(testCase.ZTS_US_Date_First_Valid__c);

        // Use the existing Milestone to calculate the expected Trigger Time.
        // This avoids any issues caused by differences between Milestone Start Date and Now
        CaseMilestone existingMilestone = [
            SELECT Id, StartDate 
            FROM CaseMilestone 
            WHERE CaseId = :testCase.Id 
            AND IsCompleted = false 
            ORDER BY StartDate DESC LIMIT 1];
        //10 calendar days, number is 9 since first day is included
        Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,9,existingMilestone,
            retrieveBusinessHoursNameForMilestoneType(testMilestone.Name));

         //test to see if it returns the correct value for negative cases
         System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 10 business days from the time reportability field is set');
     }

    //testing when the milestone starts in the past, but the due date is in the future
    // and it cross over the weekend (Off Days)
    @isTest
    private static void splitCalculatorTest_OverWeekend(){
         
        MilestoneType testMilestone = [ SELECT Id, Name FROM MilestoneType WHERE Name = 'CSE - 3 Day Case Product' LIMIT 1 ];

        Case testCase = [SELECT Id,ZTS_US_First_Received_Date__c, Entitlement.BusinessHoursId FROM Case Where Subject = 'Test Case for Milestone Calculator Split Test Case Over Weekend' LIMIT 1];

        // Override Now value so that there are no diffences with Milestone time calculation
        CSE_MilestoneTimeCalculator.overrideNow = Date.newInstance(2022, 11, 7);

        //Calculate the number of minutes using the MilestoneCalculator
        Integer actualTriggerTime = CSE_MilestoneTimeCalculator.calculateMilestoneTriggerTime( testCase.Id, testMilestone.Id );
        Datetime dFVdt = convertDateFirstValid(testCase.ZTS_US_First_Received_Date__c);

        //3 calendar days, number is 2 since first day is included
        Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,2,null,
            retrieveBusinessHoursNameForMilestoneType(testMilestone.Name));

        //test to see if it returns the correct value for negative cases
        System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 3 business days from the time reportability field is set');
        
        System.assertNotEquals(1, actualTriggerTime, 'Actual Trigger time should not be 1 minute. This would mean that weekends were included in the elapsed count.');
    }

    // Special test to verify that the Calculator uses Default Business Hours when no mapping is found
    @isTest
    private static void calculatorTestDefaultHours() {
        DateTime dFVdt = convertDateFirstValid(Date.newInstance(2022, 11, 4));

         // Override Now value so that there are no diffences with Milestone time calculation
         CSE_MilestoneTimeCalculator.overrideNow = Date.newInstance(2022, 11, 7);

        Integer actualTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,2,null,
            'INVALID BUSINESS HOURS THAT ARE TOO LONG TO ACTUALLY EVER BE A REAL BUSINESS HOURS NAME');

        
        Integer expectedTriggerTime = CSE_MilestoneTimeCalculator.getMilestoneTargetMinutes(dFVdt,2,null,
            [SELECT ID, Name FROM BusinessHours WHERE IsDefault = true LIMIT 1].Name);

        System.assertEquals(expectedTriggerTime, actualTriggerTime, 'Expected Result is minutes to complete Milestone should be 3 business days from the time reportability field is set using Default Business Hours.');
    }

     private static Datetime convertDateFirstValid(Date dateFirstValid) {
        //Set a beginning time of the Date First Valid date, at 9am eastern time
        Time targetTime = Time.newInstance(9, 0, 0, 0);
        TimeZone targetTimezone = TimeZone.getTimeZone('America/New_York');
        // The targetDate is used here to decide whether 
        // Daylight Savings should apply.
        Integer offsetSeconds = targetTimezone.getOffset(dateFirstValid) / 1000;
        Datetime dateFirstValidDT = Datetime.newInstanceGmt(dateFirstValid, targetTime)
                                        .addSeconds(-offsetSeconds);
        return dateFirstValidDT;
     }

    private static String retrieveBusinessHoursNameForMilestoneType(String milestoneType) {
        return [
            SELECT Business_Hours_Name__c
            FROM Milestone_Type_Business_Hours_Mapping__mdt
            WHERE Entitlement_Process_Name__c = 'CSE- Turn Around Time'
            AND  Milestone_Type_Name__c =: milestoneType
            LIMIT 1
        ].Business_Hours_Name__c;
    }
    
}