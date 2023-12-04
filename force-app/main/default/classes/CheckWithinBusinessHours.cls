/**
* @description       : Logic for currently using Einstein BOT users with in US Business Hours or not.
* @author            : Jagadeeswararo G
* @group             : 
* @last modified on  : 09-22-2023
* @last modified by  : Jagadeeswararo G
* Modifications Log
* Ver   Date         Author                      Modification
**/
public class CheckWithinBusinessHours {
    @InvocableMethod(label = 'Within Business Hours Check')
    public static List<Boolean> makeGetCallout(List<String> Name) {
        String BHName= String.valueOf(+Name[0]);
        BusinessHours bh;
        Boolean isWithin;
        // Get Business hours based on name, input from bot
        if (Test.isRunningTest()) {
            /*Sends always true as we can't do DML in BusinessHours. If we are running this test class Outside Business
Hours it will always fail.*/
            bh = [SELECT Id FROM BusinessHours WHERE name= :BHName];
            //isWithin = true;
        } else {
            bh = [SELECT Id FROM BusinessHours WHERE name= :BHName];//BHName
        }
        // Create Datetime with current date/time in local time zone
        Datetime targetTime = Datetime.now();
        // Find whether the time is within business hours
        isWithin= BusinessHours.isWithin(bh.id, targetTime);
        
        return new List<Boolean>{isWithin};
            }
}