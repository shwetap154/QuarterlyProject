global class AlphascheduledBatchable_Monthly implements Schedulable {
   global void execute(SchedulableContext sc) {
      
        alpha_OrderSubmissionReminder_Batch b1 = new alpha_OrderSubmissionReminder_Batch(); 
      database.executebatch(b1);
       
              alpha_StockAndForecastReminder_Batch b2 = new alpha_StockAndForecastReminder_Batch(); 
      database.executebatch(b2);
       
   }
}