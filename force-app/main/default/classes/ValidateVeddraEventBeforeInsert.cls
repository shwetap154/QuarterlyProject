public with sharing class ValidateVeddraEventBeforeInsert
{
  public static void validateVeddraEvent(List<ZTS_US_VedDRA_Event__c> veddraEvents, Map<Id, SObject> oldVedDRAEvent)
  {
        List<Id> eventNarrativeIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
      	Set<Id> veddraCodingIds = new Set<Id>();
      	Decimal highestVersion;
      	Map<Id, ZTS_US_VedDRA_Coding__c> mapVedDRACoding = new Map<Id, ZTS_US_VedDRA_Coding__c>();

        for(ZTS_US_VedDRA_Event__c aVeddraEvent: veddraEvents)
        {
            if(aVeddraEvent.ZTS_US_Event_Narrative__c != null)
            {
                eventNarrativeIds.add(aVeddraEvent.ZTS_US_Event_Narrative__c);
            }
            
            if(oldVedDRAEvent == null && aVeddraEvent.ZTS_US_VedDRA_Coding__c != null){
                veddraCodingIds.add(aVeddraEvent.ZTS_US_VedDRA_Coding__c);
            }
            else if(oldVedDRAEvent != null){
                ZTS_US_VedDRA_Event__c oldRecord = (ZTS_US_VedDRA_Event__c)oldVedDRAEvent.get(aVeddraEvent.Id);
                if(aVeddraEvent.ZTS_US_VedDRA_Coding__c != null && aVeddraEvent.ZTS_US_VedDRA_Coding__c != oldRecord.ZTS_US_VedDRA_Coding__c){
                    veddraCodingIds.add(aVeddraEvent.ZTS_US_VedDRA_Coding__c);
                }
            }
            
        }

        List<ZTS_US_Event_Narrative__c> queriedEventNarratives = [SELECT Id, ZTS_US_Case__c	FROM ZTS_US_Event_Narrative__c WHERE Id IN: eventNarrativeIds];

        System.debug('Event Narratives = '+ queriedEventNarratives);
      	
      if(veddraCodingIds != Null){
         highestVersion = VedDRASelector.getHighestVersion();// Quering Versions from VedDRA coding 
         mapVedDRACoding = VedDRASelector.getVedDRACodingMap(veddraCodingIds); // Query VedDRA coding records
      }	

        for(ZTS_US_Event_Narrative__c eachNarrative: queriedEventNarratives)
        {
            caseIds.add(eachNarrative.ZTS_US_Case__c);
        }

        System.debug('Case Ids = '+ caseIds);


        List<AggregateResult> aggreagateCaseProduct = [SELECT ZTS_US_Case__c, min(ZTS_US_Start_Date__c) startdate, min(ZTS_US_End_Date__c) enddate FROM ZTS_US_Case_Product__c WHERE ZTS_US_Case__c IN:  caseIds group by ZTS_US_Case__c];
		System.debug('Aggregate result = '+ aggreagateCaseProduct);
      
      	Map<Id,Date> mapOfCaseAndMinStartDateAggregate = new Map<Id,Date>();
      	for(AggregateResult eachAggregateResult: aggreagateCaseProduct)
        {
            mapOfCaseAndMinStartDateAggregate.put((Id)eachAggregateResult.get('ZTS_US_Case__c'), 
                                                 (Date)eachAggregateResult.get('startdate'));
          
      	}
      
      	system.debug(' Start Date Map = '+mapOfCaseAndMinStartDateAggregate);

                    
        String timeZone = UserInfo.getTimeZone().getID();       
        system.debug(' User Time Zone ID = '+timeZone);
        
      for(ZTS_US_VedDRA_Event__c veddraEvent: veddraEvents)
        {
            
            if(aggreagateCaseProduct.isEmpty())
            {
                veddraEvent.addError('You cannot add veddra event without single case product');
        	}    
          
           System.debug('Find value'+ mapOfCaseAndMinStartDateAggregate.get(veddraEvent.Case__c) );
            Date startDate;
            Date endDate;
              
            if(veddraEvent.ZTS_US_Start_Date__c != null)
            {
               startDate = Date.newInstance(veddraEvent.ZTS_US_Start_Date__c.year(), 
                                              veddraEvent.ZTS_US_Start_Date__c.month(), 
                                              veddraEvent.ZTS_US_Start_Date__c.day());
                
            } 
            if(veddraEvent.ZTS_US_End_Date__c != null){    
            	endDate   = Date.newInstance(veddraEvent.ZTS_US_End_Date__c.year(), 
                                              veddraEvent.ZTS_US_End_Date__c.month(), 
                                              veddraEvent.ZTS_US_End_Date__c.day());
            }
            
            if((startDate != null && startDate < mapOfCaseAndMinStartDateAggregate.get(veddraEvent.Case__c)) ||
               (endDate != null && endDate < mapOfCaseAndMinStartDateAggregate.get(veddraEvent.Case__c)))
            {
                    
                System.debug('veddra entered start date'+ startDate);
                            
                veddraEvent.addError('Veddra Event Start Date/End date should be greater than or equal to the earliest dose start date');
           }   
            //TPDEV-1932 - Checking VedDRA Coding Versions    
            if (veddraEvent.ZTS_US_VedDRA_Coding__c != null) {
                
                ZTS_US_VedDRA_Event__c oldRecord = oldVedDRAEvent != null ? (ZTS_US_VedDRA_Event__c)oldVedDRAEvent.get(veddraEvent.Id) : null;
                
                if (oldRecord != null && veddraEvent.ZTS_US_VedDRA_Coding__c == oldRecord.ZTS_US_VedDRA_Coding__c) {
                    continue;
                }
                else{
                    if (mapVedDRACoding.get(veddraEvent.ZTS_US_VedDRA_Coding__c).Version__c != highestVersion) {
                        veddraEvent.addError('The selected VedDRA Code is from a previous dictionary version ' +
                                             'and is not valid. Please select another code. ' +
                                             'Selected Version: ' + mapVedDRACoding.get(veddraEvent.ZTS_US_VedDRA_Coding__c).Version__c +
                                             ', Current Version: ' + highestVersion);
                    }
                }
            } 
  }

}
}