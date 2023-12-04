public class WormingAction {
  @InvocableMethod(label='Update WormingAction' description='Update  Due Date specified and returns the IDs of the Worming Action.')
 

//public static list<Id> insertworm(List<Id> Worming){
    public static void  insertworm(List<Id> Worming){
    List<Worming__c> myworming = [select id,Animal__c,Vaccination_Type__c   ,Date_of_Worming__c,animal__r.recordtype.name,Due_Date__c from Worming__c where id In :Worming];   
    
    List<Vaccination_Threshold__mdt> myVThreold_list1 = new list<Vaccination_Threshold__mdt>([select id,DeveloperName,Animal_Type__c,Due_Date__c,Treatment__c,Vaccination_Type__c from Vaccination_Threshold__mdt ]);
    system.debug(myVThreold_list1);  
  
  
  for (Worming__c w :myWorming){
    for (Vaccination_Threshold__mdt mymdt1 :myVThreold_list1){
    //If (mymdt1.Treatment__c==null  && w.animal__r.recordtype.name ==mymdt1.animal_type__c && mymdt1.Vaccination_Type__c !='Other' && w.Vaccination_Type__c ==mymdt1.Vaccination_Type__c && mymdt1.DeveloperName.contains(w.Vaccination_Type__c)) {
       If (mymdt1.Treatment__c==null  && w.animal__r.recordtype.name ==mymdt1.animal_type__c && mymdt1.Vaccination_Type__c !='Other' && w.Vaccination_Type__c ==mymdt1.Vaccination_Type__c ) { 
       System.debug('####################');
        w.Due_Date__c = w.Date_of_Worming__c.addDays((Integer)(mymdt1.Due_Date__c));
         System.debug('@@@@@@@@@@@@@@@@2'+w.Due_Date__c);
        If (mymdt1.due_date__c <30 && mymdt1.due_date__c >0) w.exception__c = true;
       
    }
    }
    }
 If ( myworming.size() >0 ) Database.SaveResult[] results1 = Database.Update(myworming);
//  return null;
  
  }
  
  
  
}