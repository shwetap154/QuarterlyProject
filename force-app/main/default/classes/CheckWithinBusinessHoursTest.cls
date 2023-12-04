/**
* @description       : Logic for currently using Einstein BOT users with in US Business Hours or not.
* @author            : Jagadeeswararao
* @group             : 
* @last modified on  : 09-22-2023
* @last modified by  : Jagadeeswararao
* Modifications Log
* Ver   Date         Author                      Modification
**/
@IsTest
private class CheckWithinBusinessHoursTest {
    
    @isTest
    public static void testWithinBusinessHours() {

        // Set the BusinessHours name as the input for your method
        List<String> inputName = new List<String>();
        inputName.add('Default');

        Test.startTest();
        // Call the method being tested
        List<Boolean> result = CheckWithinBusinessHours.makeGetCallout(inputName);
        Test.stopTest();
        // Verify the results
        System.assertEquals(1, result.size(), 'Expected a single boolean result');
    }

    @isTest
    public static void testOutsideBusinessHours() {

        // Set the BusinessHours name as the input for your method
        List<String> inputName = new List<String>();
        inputName.add('Default');

        Test.startTest();
        // Call the method being tested
        List<Boolean> result = CheckWithinBusinessHours.makeGetCallout(inputName);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, result.size(), 'Expected a single boolean result');
    }
}