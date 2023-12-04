public  class ZTS_EU_CallManager {


public  void Ma(Map<Id,Call__c> newCallMap){

    //check for any call conflicts during call creation
    
    Set<Id> userSet=new Set<Id>();
    
    List<Call__c> callList=newCallMap.values();
    for(Call__c call:callList){
        userSet.add(call.CreatedById);
    }
    
    Map<Id,List<Time_Out_of_Territory__c>> timeOfTerritoryUserMap=getTimeOff_Users(userSet);
    
    for(Call__c call:callList){
        if(timeOfTerritoryUserMap.containsKey(call.CreatedById)){
            for(Time_Out_of_Territory__c tot:timeOfTerritoryUserMap.get(call.CreatedById)){
                if(call.ZTS_EU_Start_Date_Time__c.date()==tot.ZTS_EU_Start_Date__c){
                    call.addError('User time of territory conflicts with Call StartTime');
                    
                }
            }
        }
    }
}






private   Map<Id,List<Time_Out_of_Territory__c>> getTimeOff_Users(Set<Id> userSet){
     String cancelled='Cancelled';
     List<Time_Out_of_Territory__c> timeOfTerritory=[SELECT ZTS_EU_Status__c,ZTS_EU_Start_Date__c,CreatedById from Time_Out_of_Territory__c where CreatedById in :userSet AND ZTS_EU_Status__c!=:cancelled AND ZTS_Market__c != 'United States'];
     Map<Id,List<Time_Out_of_Territory__c>> userTimeOffMap=new Map<Id,List<Time_Out_of_Territory__c>>();
  
      for(Time_Out_of_Territory__c tot:timeOfTerritory){
         if(!userTimeOffMap.containsKey(tot.CreatedById)){
            userTimeOffMap.put(tot.CreatedById,new List<Time_Out_of_Territory__c>{tot});
         }
         else
           userTimeOffMap.get(tot.CreatedById).add(tot);
      }
  
   return userTimeOffMap;
}


}