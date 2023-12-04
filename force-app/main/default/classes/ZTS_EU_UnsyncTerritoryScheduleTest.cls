/******************************************************************************************* 
 * Class Name   : ZTS_EU_UnsyncTerritoryScheduleTest
 * Description  : This is a test class for ZTS_EU_UnsyncTerritoryConsoleSchedule.
 * Created By   : Chanbasha Noorbashasheik
 * Created Date : 16 August 2021.
 ******************************************************************************************/
@isTest
public class ZTS_EU_UnsyncTerritoryScheduleTest{
    
    @isTest static void executeTest(){
        Test.StartTest();
        SchedulableContext sc = null;
        ZTS_EU_UnsyncTerritoryConsoleSchedule  tsc = new ZTS_EU_UnsyncTerritoryConsoleSchedule ();
        tsc.execute(sc);
        Test.stopTest();
         
    }      
}