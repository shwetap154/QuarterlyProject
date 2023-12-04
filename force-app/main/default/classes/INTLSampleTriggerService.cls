public inherited sharing class INTLSampleTriggerService {

    public static void afterUpdate(List<ZTS_EU_Sample__c> triggerOld, Map<Id, ZTS_EU_Sample__c> triggerOldMap, List<ZTS_EU_Sample__c> triggerNew, Map<Id, ZTS_EU_Sample__c> triggerNewMap) {
        List<ZTS_EU_Sample__c> sList_YearChanged = new List<ZTS_EU_Sample__c>();
        for (Id i : triggerNewMap.keySet()){ 
            if(triggerNewMap.get(i).ZTS_EU_Year__c != triggerOldMap.get(i).ZTS_EU_Year__c){
                sList_YearChanged.add( triggerNewMap.get(i) );
            }
        }
        
        List<Sample_Drop__c> sdList = new List<Sample_Drop__c>();
        
        if(sList_YearChanged.size() > 0){
            sdList = ZTS_EU_SampleAndSampleDropUtility.getSampleDrops(sList_YearChanged);
            if(sdList.size() > 0){
                ZTS_EU_SampleAndSampleDropUtility.populateCurrentYearCheckbox(sdList);
            }
        }
    
        update sdList;
    }

}