global class UpdateWormingRegister implements Database.Batchable<sobject> {


 global Database.Querylocator start (Database.BatchableContext BC) {
 
     //String query = 'SELECT Id,Name,Due_Date__c FROM VaccinationRegister__c where Due_Date__c =: NULL';
        //return Database.getQueryLocator(query);
      return Database.getQueryLocator('SELECT Id,Name,Due_Date__c FROM Worming__c');
     
   }
   

  global void execute (Database.BatchableContext BC, List<Worming__c> scope) {
  
       for(Worming__c vac: scope)
        {        
            // Update the Account Name 
            //vac.Due_Date__c = Null;
        }
        try {
            // Update the Account Record
            update scope;
         
        } catch(Exception e) {
            System.debug(e);
        }
         
  
  }
  
  
  global void finish(Database.BatchableContext BC) {
  
  
  }


}