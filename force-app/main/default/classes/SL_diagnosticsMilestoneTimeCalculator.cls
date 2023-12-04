global class SL_diagnosticsMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {

    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        Integer timeRemaining = getRemainingTime(caseId, milestoneTypeId);
        SL_MilestoneHandler.calculateDiagnosticsSLA(caseId, milestoneTypeId, timeRemaining); 
        return timeRemaining;

    }
    private Integer getRemainingTime(String caseId, String milestoneTypeId) {
        Integer timeRemaining; 
        Integer totalElapsedTime = 0;
        Case c = [SELECT Id FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Id FROM MilestoneType WHERE Id=:milestoneTypeId];

        Service_Cloud_Settings__mdt cusMdtRecord = [SELECT Id, Diagnostics_L1_Milestone_Type_Id__c, Diagnostics_L1_SLA__c, 
                                                            Diagnostics_L2_Milestone_Type_Id__c, Diagnostics_L2_SLA__c,
                                                            Diagnostics_L3_Milestone_Type_Id__c, Diagnostics_L3_SLA__c,
                                                            Diagnostics_Case_Milestone_Type_Id__c, Diagnostics_Case_SLA__c
                                                            FROM Service_Cloud_Settings__mdt
                                                            WHERE MasterLabel = 'DEFAULT'];

        system.debug('DEFAULT Custom Metadata Record from SOQL: ' + cusMdtRecord);
        system.debug('milestoneTypeId Param: ' + milestoneTypeId);
        system.debug('SOQL for 18 digit MilestoneTypeId: ' + mt.Id);
        system.debug('caseId Param: ' + caseId); 

        if(((String)mt.Id).contains( cusMdtRecord.Diagnostics_L1_Milestone_Type_Id__c ))
            {timeRemaining = integer.valueOf(cusMdtRecord.Diagnostics_L1_SLA__c);} 
        else if(((String)mt.Id).contains(cusMdtRecord.Diagnostics_L2_Milestone_Type_Id__c))
            {timeRemaining = integer.valueOf(cusMdtRecord.Diagnostics_L2_SLA__c);}
        else if(((String)mt.Id).contains(cusMdtRecord.Diagnostics_L3_Milestone_Type_Id__c)) 
            {timeRemaining = integer.valueOf(cusMdtRecord.Diagnostics_L3_SLA__c);}
        else {timeRemaining = integer.valueOf(cusMdtRecord.Diagnostics_Case_SLA__c);}
       
        CaseMilestone[] cmList =  [Select Id, ElapsedTimeInMins
                                   FROM CaseMilestone
                                   WHERE CaseId = :caseId AND MilestoneTypeID = :mt.Id AND CompletionDate != null];
        
        system.debug('cmList:' + cmList);  
        
        for(CaseMilestone i : cmList){
           totalElapsedTime = totalElapsedTime + i.ElapsedTimeInMins;
        }
                                 
        if((cmList.size() > 0) && (timeRemaining > totalElapsedTime)){
            timeRemaining = timeRemaining - totalElapsedTime;
            return timeRemaining;} 
        else if((cmList.size() > 0) && (totalElapsedTime >= timeRemaining)){
            timeRemaining = 0;
            return timeRemaining;} 
        else {
            return timeRemaining;
        }
    }
}