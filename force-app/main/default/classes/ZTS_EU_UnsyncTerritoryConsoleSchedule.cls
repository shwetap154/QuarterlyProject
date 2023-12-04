/******************************************************************************************* 
 * Class Name   : ZTS_EU_UnsyncTerritoryConsoleSchedule 
 * Description  : This class schedules ZTS_EU_UnsyncTerritoryConsoleSchedule to automate territory sync process.
 * Created By   : Chanbasha Noorbashasheik
 * Created Date : 16-08-2021.
 ******************************************************************************************/
global class ZTS_EU_UnsyncTerritoryConsoleSchedule implements Schedulable{

   global void execute(SchedulableContext SC) {
   
       //Territory Records Sync
       ZTS_EU_UnsyncTerritoryConsoleResults stdterr = new ZTS_EU_UnsyncTerritoryConsoleResults();
       stdterr.createStdTerrFromCustomTerritory();       
   }
}