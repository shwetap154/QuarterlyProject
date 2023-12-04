/******************************************************************************************* 
 * Class Name   : ZTS_EU_UnsyncPositionRltsScheduleTest
 * Description  : This is a test class for AutomateUnSynTerritorySchedule.
 * Created By   : Chanbasha Noorbashasheik
 * Created Date : 19 July 2021.
 ******************************************************************************************/
@isTest
public class ZTS_EU_UnsyncPositionRltsScheduleTest{
    
    @isTest static void executeTest(){
        Test.StartTest();
        SchedulableContext sc = null;
        ZTS_EU_UnsyncPositionResultsSchedule tsc = new ZTS_EU_UnsyncPositionResultsSchedule();
        tsc.execute(sc);
        Test.stopTest();
         
    }      
}