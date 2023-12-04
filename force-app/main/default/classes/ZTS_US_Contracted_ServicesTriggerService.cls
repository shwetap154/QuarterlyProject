public with sharing class ZTS_US_Contracted_ServicesTriggerService {
    
    public static void afterInsert(List<ZTS_US_Contracted_Services__c> triggerNew){
        
        List<Id> listOfIds = new List<Id>();
        for (ZTS_US_Contracted_Services__c cs : triggerNew) { 
            listOfIds.add(cs.Id);  
        }
        if(listOfIds.isEmpty()){
            return;
        }
        
        List<ZTS_US_Contracted_Services__c> css =  [ SELECT Id, ZTS_US_Opportunity__c,ZTS_US_Opportunity__r.Type  
                                                        FROM ZTS_US_Contracted_Services__c 
                                                        WHERE Id IN :listOfIds ];
        Map< Id , Id > csToOppty = new Map< Id , Id >();  
        for(ZTS_US_Contracted_Services__c cs : css)  { 
            if(cs.ZTS_US_Opportunity__c != null && cs.ZTS_US_Opportunity__r.Type != null && ((cs.ZTS_US_Opportunity__r.Type == 'PeopleFirst') || cs.ZTS_US_Opportunity__r.Type == 'ProfitSolver')){
                csToOppty.put(cs.ZTS_US_Opportunity__r.Id, cs.Id);
            }
        } 

        List<Opportunity> updateOpptys = new List<Opportunity>();
        if(csToOppty != null && csToOppty.size() > 0){
            updateOpptys = [ SELECT Id, Contracted_Services__c 
                                FROM Opportunity 
                                WHERE Id IN :csToOppty.keySet() ];    
            for(Opportunity opp : updateOpptys)  {
                opp.Contracted_Services__c = csToOppty.get(opp.Id);
            }   
        } 

        if(updateOpptys != null && updateOpptys.size() > 0){ 
            update updateOpptys;       
        }
    }
}