public with sharing class ZTS_EU_CoachingTriggerService {
    
    public static void beforeInsert(List<ZTS_EU_Coaching__c> triggerNew){
        
        List<Id> listofRepIds = new  List<Id>();   
        for(ZTS_EU_Coaching__c coaching:triggerNew){
        
            if(coaching.ZTS_EU_Start_Date__c != Null && coaching.ZTS_EU_End_Date__c != Null && coaching.ZTS_EU_Sales_Rep__c != Null ){
                listofRepIds.add(coaching.ZTS_EU_Sales_Rep__c);
            }  
        }
        List<Time_Out_of_Territory__c> listTOT = [SELECT Id,CreatedbyId , ZTS_EU_Start_Date__c, ZTS_EU_End_Date__c,ZTS_EU_Status__c 
                                                    FROM Time_Out_of_Territory__c 
                                                    WHERE ZTS_EU_Status__c = 'Submitted' AND createdbyId IN :listofRepIds ];
        
        Map<Id, Time_Out_of_Territory__c> MapTOT = new Map<id, Time_Out_of_Territory__c> ();
        
        for(Time_Out_of_Territory__c tot : listTOT ){
            MapTOT.put(tot.createdbyId,tot);
        }
        
        for(ZTS_EU_Coaching__c coaching:triggerNew){ 
            if(MapTOT.containsKey(coaching.ZTS_EU_Sales_Rep__c)){
            
                if((coaching.ZTS_EU_start_Date__c <= MapTOT.get(coaching.ZTS_EU_Sales_Rep__c).ZTS_EU_End_Date__c) && (coaching.ZTS_EU_start_Date__c >= MapTOT.get(coaching.ZTS_EU_Sales_Rep__c).ZTS_EU_Start_Date__c)){
                    
                    coaching.adderror('The assigned sales rep is on Time OFF. Please contact the sales rep for the coaching or choose different coaching dates');
                }
                else if((coaching.ZTS_EU_End_Date__c <= MapTOT.get(coaching.ZTS_EU_Sales_Rep__c).ZTS_EU_End_Date__c) && (coaching.ZTS_EU_End_Date__c >= MapTOT.get(coaching.ZTS_EU_Sales_Rep__c).ZTS_EU_Start_Date__c)){
                    
                    coaching.adderror('The assigned sales rep is on Time OFF. Please contact the sales rep for the coaching or choose different coaching dates');
            
                }
            }
        }
    }
}