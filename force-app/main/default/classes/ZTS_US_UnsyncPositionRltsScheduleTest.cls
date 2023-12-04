/******************************************************************************************* 
 * Class Name   : ZTS_US_UnsyncPositionResultsScheduleTest
 * Description  : This is a test class for AutomateUnSynTerritorySchedule.
 * Created By   : Chanbasha Noorbashasheik
 * Created Date : 16 August 2021.
 ******************************************************************************************/
@isTest
public class ZTS_US_UnsyncPositionRltsScheduleTest{
    
    @isTest static void executeTest(){
        Test.StartTest();
        SchedulableContext sc = null;
        ZTS_US_UnsyncPositionResultsSchedule tsc = new ZTS_US_UnsyncPositionResultsSchedule();
        tsc.execute(sc);
        Test.stopTest();
         
    }      
}