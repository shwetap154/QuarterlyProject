/****************************************************************************************************************************************** 
 * Trigger Name : CSE_MilestoneTimeCalculator
 * Description  : All  Logic for MilestoneTriggerTimeCalculator.
 * Created By   : Slalom(Madhu Goriparthi) 
 * Created Date : 8th August, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Madhu Goriparthi			   08/08/2021			  Created
 * Venkat Joginapally          08/27/2021             Updated   
 * Chelsea Paice               05/24/2022            Updated to address bug CSEPVW-214
 * Ethan Hirsch                11/07/2022            Updated logic subtracting time elapsed to take into 
 *                                                   account off days using Business Hours (CASS-893)
 * Ethan Hirsch                11/08/2022            Pull Business Hours from Custom Metadata to avoid 
 *                                                   hacky solutions for pulling this back (CASS-893)
*****************************************************************************************************************************************/



global class CSE_MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {  
    //setting default timer return to 1 minute, to handle non-valid time scenarios, as method 
    //cannot return null or negative value
    static Integer resultingInMinute = 1;
    //NOTE: timezone is supposed to be treated as EST
    global static Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){   
            //Get Specific milestone to set time trigger
        
        MilestoneType cseMilestone = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        
        //Get the Case record
        Case objCase = [SELECT Id, 
                        ZTS_US_Date_First_Valid__c,
                        ZTS_US_First_Received_Date__c,
                        ZTS_US_Latest_Follow_Up_Date__c, //Cass-944 retrieving Latest follow up date
                        Case_Updated_Date__c,
                        CreatedDate, Entitlement.SlaProcess.Name
                        FROM Case WHERE Id=:caseId];
        CaseMilestone[] existingMilestones = [SELECT Id,StartDate,TargetDate FROM CaseMilestone WHERE CaseId = :caseId AND IsCompleted = false ORDER BY StartDate DESC LIMIT 1];
        CaseMilestone existingMilestone = (existingMilestones!=null && !existingMilestones.isEmpty() ? existingMilestones[0] : null);
        system.debug('existingMilestone: ' +existingMilestone);
        Date dFV;

        // Retrieve the Name of the Business Hours using the Case's SLA Process and Milestone
        // The Id will be retrieved later
        String businessHoursName = retrieveBusinessHoursName(objCase.Entitlement?.SlaProcess?.Name, cseMilestone.Name);
        system.debug('businessHoursName: ' +businessHoursName);
        //most of the entitlements require Date First Valid, but not all. If Date First Valid is null, use either first recieved date or case created date.
        //if there is a follow up (represented by 'Case Update Date'), prioritize that field.       
		//if(objCase.Case_Updated_Date__c !=null){
            //dFV = date.newInstance(objCase.Case_Updated_Date__c.year(), objCase.Case_Updated_Date__c.month(), objCase.Case_Updated_Date__c.day());
            //Cass-944 - Latest follow Up Date is updated. 
         if(objCase.ZTS_US_Latest_Follow_Up_Date__c !=null){
            dFV = date.newInstance(objCase.ZTS_US_Latest_Follow_Up_Date__c.year(), objCase.ZTS_US_Latest_Follow_Up_Date__c.month(), objCase.ZTS_US_Latest_Follow_Up_Date__c.day());
        }else if (objCase.ZTS_US_Date_First_Valid__c != null) {
            dFV = objCase.ZTS_US_Date_First_Valid__c;
        } else if (objCase.ZTS_US_First_Received_Date__c != null) {
            dFV = objCase.ZTS_US_First_Received_Date__c;
        } else {
            dFV = Date.newInstance(objCase.CreatedDate.year(),objCase.CreatedDate.month(),objCase.CreatedDate.day());
        }

        //Set a beginning time of the Date First Valid date, at 9am eastern time
        Time targetTime = Time.newInstance(9, 0, 0, 0);
        TimeZone targetTimezone = TimeZone.getTimeZone('America/New_York');
        // The targetDate is used here to decide whether 
        // Daylight Savings should apply.
        Integer offsetSeconds = targetTimezone.getOffset(dFV) / 1000;
        Datetime dateFirstValidDT = Datetime.newInstanceGmt(dFV, targetTime)
                                        .addSeconds(-offsetSeconds);
        system.debug('dateFirstValidDT: ' + String.valueOf(dateFirstValidDT));
        
        Service_Cloud_Settings__mdt cusMdt = Service_Cloud_Settings__mdt.getAll().values()[0];

        //setting default number of days and biz hours, then will specify for each type
        Integer numberOfDays = 0;

        if (cseMilestone.Name.equals(cusMdt.X3_Day_Alert__c)) {
            //1 business day, number is 0 (set above) since first day is included
			numberOfDays = 0;
        } else if (cseMilestone.Name.equals(cusMdt.X3_Day_Product__c)) {
            //3 business days, number is 2 since first day is included
            numberOfDays = 2;
        } else if (cseMilestone.Name.equals(cusMdt.X7_Day_Product__c)) {
            //7 calendar days, number is 6 since first day is included
            numberOfDays = 6;
        } else if (cseMilestone.Name.equals(cusMdt.X10_Day_Reportability__c) || cseMilestone.Name.equals(cusMdt.X10_Day_Product__c)) {
            //10 calendar days, number is 9 since first day is included
            numberOfDays = 9;
        }
        
        system.debug('numberOfDays: ' + numberOfDays);
        system.debug('milestone: ' + cseMilestone.Name);

        resultingInMinute = getMilestoneTargetMinutes(dateFirstValidDT, numberOfDays,existingMilestone, businessHoursName);
        
        //all functions must return a positive integer value that represents the number of minutes in the milestone
        if(resultingInMinute < 0){
            resultingInMinute = 1;  
        }
        system.debug('about to return minutes: ' + resultingInMinute);
        	return resultingInMinute;      
    }

    @TestVisible private static DateTime overrideNow;
    
    @TestVisible private static integer getMilestoneTargetMinutes(Datetime dateFirstValidDT, Integer numberOfDays, CaseMilestone existingMilestone, String businessHoursName) {
        //get target milestone end date/time in calendar days, then calculate minute difference between start time and that time
        //the milestone rules themselves handle any business days calculation needed
        DateTime targetDate = getTargetMilestoneDateTime(dateFirstValidDT, numberOfDays);
        // calculate diff between the start date and the target date/time
        Long targetTime = targetDate.getTime();
        Long startTime = dateFirstValidDT.getTime();
        Long totalMilliseconds = targetTime - startTime;
        Date dateValid = date.newInstance(dateFirstValidDT.year(), dateFirstValidDT.month(), dateFirstValidDT.day());
        Long targetMilliseconds;
        system.debug('totalMilliseconds' +totalMilliseconds);
        system.debug('dateValid' +dateValid);
        if(dateValid<date.today()){
            system.debug('In If');
            // Only retrieve Business Hours if they will be used
            Id businessHoursId = retrieveBusinessHoursId(businessHoursName);

            Long timeElapsed;
            //use the start time of the existing milestone if the case has already entered it.  This prevents the case from subtracting the current time from the
            //milestone time if the case is continually updated after the case is in the milestone.
            //The BusinessHours class allows off days to not count towards the time elapsed.
            if(existingMilestone!=null){
                timeElapsed = BusinessHours.diff(businessHoursId, dateFirstValidDT, existingMilestone.StartDate);
            }
            //if the case has not entered the milestone yet, get the current time against when it was first valid to know how much time is already spent.
            else{
                DateTime now = system.now();
                if (Test.isRunningTest() && overrideNow != null) {
                    now = overrideNow;
                }

                timeElapsed = BusinessHours.diff(businessHoursId, dateFirstValidDT, now);
            }

            targetMilliseconds = totalMilliseconds - timeElapsed;
        }
        else{
            system.debug('In Else');
            targetMilliseconds = totalMilliseconds;
        }
        system.debug('targetMilliseconds' +targetMilliseconds);
        Long seconds = targetMilliseconds / 1000;
        Long minutes = seconds / 60;
        Integer minuteDiff = (Integer)minutes;
        system.debug('minuteDiff' +minuteDiff);
        return minuteDiff;

    }
    /*@TestVisible private static integer getMilestoneTargetMinutes(Datetime dateFirstValidDT, Integer numberOfDays) {
        //get target milestone end date/time in calendar days, then calculate minute difference between now and that time
        //the milestone rules themselves handle any business days calculation needed
        DateTime targetDate = getTargetMilestoneDateTime(dateFirstValidDT, numberOfDays);
        system.debug('target date: ' + String.valueOf(targetDate));
        //then calculate diff between NOW (when milestone is getting created) and the target date/time
        Long targetTime = targetDate.getTime();
        Long nowTime = Datetime.now().getTime();
        Long milliseconds = targetTime - nowTime;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Integer minuteDiff = (Integer)minutes;
        system.debug('minuteDiff: ' + minuteDiff);
        return minuteDiff;
    }*/

    private static DateTime getTargetMilestoneDateTime(Datetime dateFirstValidDT, Integer numberOfDays) {
        Datetime calDaysResultNineAm = dateFirstValidDT.addDays(numberOfDays);
        Datetime calDaysResultFivePm = calDaysResultNineAm.addHours(8);
        return calDaysResultFivePm;
    }
    
    private static String retrieveBusinessHoursName(String entitlementProcessName, String milestoneTypeName) {
        List<Milestone_Type_Business_Hours_Mapping__mdt> businessHoursMappings = [
            SELECT Business_Hours_Name__c
            FROM Milestone_Type_Business_Hours_Mapping__mdt
            WHERE Entitlement_Process_Name__c =: entitlementProcessName
            AND  Milestone_Type_Name__c =: milestoneTypeName
            LIMIT 1
        ];
        
        // Null is returned if no records exist.
        String businessHoursName = null;
        if (!businessHoursMappings.isEmpty()) {
            businessHoursName = businessHoursMappings[0].Business_Hours_Name__c;
        }

        return businessHoursName;
    }

    private static Id retrieveBusinessHoursId(String businessHoursName) {
        Id businessHoursId = null;
        // If no name is specified, default Business Hours will be used.
        if (String.isNotEmpty(businessHoursName)) {
            List<BusinessHours> businessHours = [
                SELECT Id
                FROM BusinessHours
                WHERE Name =: businessHoursName
                LIMIT 1];

            if (!businessHours.isEmpty()) {
                businessHoursId = businessHours[0].Id;
            }
        }

        // If Business Hours cannot be found, default business hours will be used
        if (businessHoursId == null) {
            businessHoursId = [SELECT ID FROM BusinessHours WHERE IsDefault = true LIMIT 1].Id;
        }

        return businessHoursId;
    }
}