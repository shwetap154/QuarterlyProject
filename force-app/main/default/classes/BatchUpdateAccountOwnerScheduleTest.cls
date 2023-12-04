/*
 * Name          :   BatchUpdateAccountOwnerScheduleTest
* Description   :    This is used to test BatchUpdateAccountOwnerSchedule
* Author        :    Amitabh
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
01/02/2018       Amitabh                      Created
 */
@isTest
public class BatchUpdateAccountOwnerScheduleTest {
    public static String exp='0 0 23 * * ?';
    @isTest static void scheduleTest()
    {
        Test.startTest();
        
        BatchUpdateAccountOwnerSchedule acccountTest=new BatchUpdateAccountOwnerSchedule();
        system.schedule('Test account owner update',exp,acccountTest);
        test.stopTest();
        
    } 
}