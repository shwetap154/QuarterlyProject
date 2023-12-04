/******************************************************************************************* 
 * Class Name   : ZTS_US_UnsyncTerritoryConsoleSchedule 
 * Description  : This class schedules ZTS_US_UnsyncTerritoryConsoleSchedule to automate territory sync process.
 * Created By   : Chanbasha Noorbashasheik
 * Created Date : 16-08-2021.
 ******************************************************************************************/
global class ZTS_US_UnsyncTerritoryConsoleSchedule implements Schedulable{

   global void execute(SchedulableContext SC) {
   
       //Territory Records Sync
       ZTS_US_UnsyncTerritoryConsoleResults stdterr = new ZTS_US_UnsyncTerritoryConsoleResults();
       stdterr.createStdTerrFromCustomTerritory();            
   }
}