global class AlphascheduledBatchable_Weekly implements Schedulable {
   global void execute(SchedulableContext sc) {
      alpha_NewForecastEmailAlert_Batch b = new alpha_NewForecastEmailAlert_Batch(); 
      database.executebatch(b);
    
        alpha_UpdateForecastEmailAlert_Batch b3 = new alpha_UpdateForecastEmailAlert_Batch(); 
      database.executebatch(b3);
       
       alpha_UpdateStockEmailAlert_Batch b4 = new alpha_UpdateStockEmailAlert_Batch(); 
      database.executebatch(b4);
       
       
   }
}